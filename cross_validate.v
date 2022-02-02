// cross_validate.v
module hamnn

// import tools
// import partition
// import make
// import verify
import strconv
import runtime

// cross_validate takes a dataset and performs n-fold cross classification.
// Type: `v run hamnn.v cross --help`
pub fn cross_validate(ds Dataset, opts Options) VerifyResult {
	cross_opts := opts
	mut folds := opts.folds
	mut fold_result := VerifyResult{}
	mut cross_result := VerifyResult{
		labeled_classes: ds.Class.class_values
		pos_neg_classes: get_pos_neg_classes(ds.class_counts)
	}
	// instantiate a confusion_matrix_row
	mut confusion_matrix_row := map[string]int{}
	for key, _ in ds.class_counts {
		confusion_matrix_row[key] = 0
	}
	// test if leave-one-out crossvalidation is requested
	if opts.folds == 0 {
		folds = ds.class_values.len
	}

	// instantiate an entry for each class in the cross_result class_table
	for key, value in ds.Class.class_counts {
		cross_result.class_table[key] = ResultForClass{
			labeled_instances: value
			confusion_matrix_row: confusion_matrix_row.clone()
		}
	}
	// if the concurrency flag is set
	if opts.concurrency_flag {
		mut result_channel := chan VerifyResult{cap: folds}
		// queue all work + the sentinel values:
		jobs := runtime.nr_jobs()
		mut work_channel := chan int{cap: folds + jobs}
		for i in 0 .. folds {
			work_channel <- i
		}
		for _ in 0 .. jobs {
			work_channel <- -1
		}
		// start a thread pool to do the work:
		mut tpool := []thread{}
		for _ in 0 .. jobs {
			tpool << go option_worker(work_channel, result_channel, folds, ds, opts)
		}
		tpool.wait()
		//
		for _ in 0 .. folds {
			fold_result = <-result_channel
			cross_result = update_cross_result(fold_result, mut cross_result)
		}
	} else {
		// for each fold
		for current_fold in 0 .. folds {
			fold_result = do_one_fold(current_fold, folds, ds, cross_opts)
			cross_result = update_cross_result(fold_result, mut cross_result)
		}
	}
	cross_result = finalize_cross_result(mut cross_result)
	show_results(cross_result, cross_opts)
	return cross_result
}

// do_one_fold
fn do_one_fold(current_fold int, folds int, ds Dataset, cross_opts Options) VerifyResult {
	mut byte_values_array := [][]byte{}
	// partition the dataset into a partial dataset and a fold
	part_ds, fold := partition(current_fold, folds, ds, cross_opts)
	// println('fold: $fold')
	mut fold_result := VerifyResult{
		labeled_classes: fold.class_values
	}
	part_cl := make_classifier(part_ds, cross_opts)
	// for each attribute in the trained partition classifier
	for attr in part_cl.attribute_ordering {
		// get the index of the corresponding attribute in the fold
		j := fold.attribute_names.index(attr)
		// create byte_values for the fold data
		byte_values_array << process_fold_data(part_cl.trained_attributes[attr], fold.data[j])
	}
	fold_instances := transpose(byte_values_array)
	// for each class, instantiate an entry in the class table for the result
	// note that this needs to use the classes in the partition portion, not
	// the fold, so that wrong inferences get recorded properly.
	mut confusion_matrix_row := map[string]int{}
	// for each class, instantiate an entry in the confusion matrix row
	for key, _ in ds.Class.class_counts {
		confusion_matrix_row[key] = 0
	}
	for key, value in part_cl.Class.class_counts {
		fold_result.class_table[key] = ResultForClass{
			labeled_instances: value
			confusion_matrix_row: confusion_matrix_row.clone()
		}
	}
	fold_result = classify_to_verify(part_cl, fold_instances, mut fold_result, cross_opts)
	return fold_result
}

// process_fold_data
fn process_fold_data(part_attr TrainedAttribute, fold_data []string) []byte {
	mut byte_vals := []byte{cap: fold_data.len}
	// for a continuous attribute
	if part_attr.attribute_type == 'C' {
		values := fold_data.map(f32(strconv.atof_quick(it)))
		byte_vals << bin_values_array(values, part_attr.minimum, part_attr.maximum, part_attr.bins)
	} else {
		byte_vals << fold_data.map(byte(part_attr.translation_table[it]))
	}
	return byte_vals
}

// update_cross_result
fn update_cross_result(fold_result VerifyResult, mut cross_result VerifyResult) VerifyResult {
	// for each class, add the fold counts to the cross_result counts
	for key, mut value in cross_result.class_table {
		value.correct_inferences += fold_result.class_table[key].correct_inferences
		value.wrong_inferences += fold_result.class_table[key].wrong_inferences
		value.confusion_matrix_row = append_map_values(mut value.confusion_matrix_row,
			fold_result.class_table[key].confusion_matrix_row)
	}
	return cross_result
}

// append_map_values appends values from b to a
fn append_map_values(mut a map[string]int, b map[string]int) map[string]int {
	for key, mut value in a {
		value += b[key]
	}
	return a
}

// finalize_cross_result
fn finalize_cross_result(mut cross_result VerifyResult) VerifyResult {
	for _, mut value in cross_result.class_table {
		value.missed_inferences = value.labeled_instances - value.correct_inferences
		cross_result.correct_count += value.correct_inferences
		cross_result.misses_count += value.missed_inferences
		cross_result.wrong_count += value.wrong_inferences
		cross_result.total_count += value.labeled_instances
	}
	// collect confusion matrix rows into a matrix
	mut header_row := ['Predicted Classes (columns)']
	mut data_row := []string{}
	for key, value in cross_result.class_table {
		header_row << key
		data_row = [key]
		for _, value2 in value.confusion_matrix_row {
			data_row << '$value2'
		}
		cross_result.confusion_matrix << data_row
	}
	cross_result.confusion_matrix.prepend(['Actual Classes (rows)'])
	cross_result.confusion_matrix.prepend(header_row)
	return cross_result
}

// option_worker
fn option_worker(work_channel chan int, result_channel chan VerifyResult, folds int, ds Dataset, opts Options) {
	for {
		mut current_fold := <-work_channel
		if current_fold < 0 {
			break
		}
		result_channel <- do_one_fold(current_fold, folds, ds, opts)
		// if x := do_one_fold(current_fold, folds, ds, opts) {
		// 	result_channel <- x
		// }
	}
}
