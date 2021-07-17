// cross_validate.v
module cross

import tools
import partition
import make
import verify
import strconv

// cross_validate takes a dataset and performs n-fold cross classification.
// Type: `v run hamnn.v cross --help`
pub fn cross_validate(ds tools.Dataset, opts tools.Options) tools.VerifyResult {
	cross_opts := opts
	mut folds := opts.folds
	mut fold_result := tools.VerifyResult{}
	mut cross_result := tools.VerifyResult{
		labeled_classes: ds.Class.class_values
	}
	// mut size := 1
	// test if leave-one-out crossvalidation is requested
	if opts.folds == 0 {
		folds = ds.class_values.len
	}
	// println('folds: $folds')
	// instantiate an entry for each class in the cross_result class_table
	for key, value in ds.Class.class_counts {
		cross_result.class_table[key] = tools.ResultForClass {
			labeled_instances: value
		}
	}
	// if the concurrency flag is set
	if opts.concurrency_flag {
		mut work_channel := chan int{cap: folds}
		mut result_channel := chan tools.VerifyResult{cap: folds}
		for i in 0 .. folds {
			// println('i in cross_validate: $i')
			work_channel <- i
			// dump(work_channel)
			go option_worker(work_channel, result_channel, folds, ds, opts)
		}
		for _ in 0 .. folds {
			fold_result = <- result_channel
			// println('fold_result in cross_validate: $fold_result')
			cross_result = update_cross_result(fold_result, mut cross_result)
		}
	} else {
	// for each fold
	for current_fold in 0 .. folds {
		fold_result = do_one_fold(current_fold, folds, ds, cross_opts)
		cross_result = update_cross_result(fold_result, mut cross_result)	
	}
}

	if opts.show_flag && opts.command == 'cross' {
		show_crossvalidation_result(cross_result, opts)	
	}
	return cross_result
}


// do_one_fold 
fn do_one_fold(current_fold int, folds int, ds tools.Dataset, cross_opts tools.Options) tools.VerifyResult {
	mut byte_values_array := [][]byte{cap: cross_opts.number_of_attributes[0], init: []byte{}}
		// partition the dataset into a partial dataset and a fold
		part_ds, fold := partition.partition(current_fold, folds, ds, cross_opts)
		mut fold_result := tools.VerifyResult{
			labeled_classes: fold.class_values
		}
		part_cl := make.make_classifier(part_ds, cross_opts)
		// for each attribute in the trained partition classifier
		for attr in part_cl.attribute_ordering {
			// get the index of the corresponding attribute in the fold
			j := fold.attribute_names.index(attr)
			// create byte_values for the fold data
			byte_values_array << process_fold_data(part_cl.trained_attributes[attr], fold.data[j])
		}
		fold_instances := tools.transpose(byte_values_array)
		// for each class, instantiate an entry in the class table for the result
		for key, value in part_cl.Class.class_counts {
			fold_result.class_table[key] = tools.ResultForClass {
				labeled_instances: value
			}
		}
		fold_result = verify.classify_to_verify(part_cl, fold_instances, mut fold_result,
			cross_opts)
		return fold_result
}

// process_fold_data 
fn process_fold_data(part_attr tools.TrainedAttribute, fold_data []string) []byte {
	mut byte_vals := []byte{cap: fold_data.len}
	// for a continuous attribute
	if part_attr.attribute_type == 'C' {
		values := fold_data.map(f32(strconv.atof_quick(it)))
		byte_vals << tools.bin_values_array(values, part_attr.minimum,
			part_attr.maximum, part_attr.bins)
	} else {
		byte_vals << fold_data.map(byte(part_attr.translation_table[it]))
	}
	return byte_vals
}

// update_cross_result 
fn update_cross_result(fold_result tools.VerifyResult, mut cross_result tools.VerifyResult) tools.VerifyResult {
	mut correct_count := 0
	// for each class, add the fold counts to the cross_result counts
		for key, mut value in cross_result.class_table {
			value.correct_inferences += fold_result.class_table[key].correct_inferences
			value.wrong_inferences += fold_result.class_table[key].wrong_inferences
			value.missed_inferences = value.labeled_instances - value.correct_inferences
			correct_count += value.correct_inferences
		}
		cross_result.correct_count = correct_count
	return cross_result
}

// option_worker
	fn option_worker(work_channel chan int, result_channel chan tools.VerifyResult, folds int, ds tools.Dataset, opts tools.Options) {
	// mut processed := 0
	// mut result := tools.VerifyResult{}
	mut current_fold := <-work_channel
	// println('current_fold in option_worker: $current_fold')
	result_channel <- do_one_fold(current_fold, folds, ds, opts)
	// dump(result_channel)
	return
}

// show_crossvalidation_result 
fn show_crossvalidation_result(cross_result tools.VerifyResult, opts tools.Options) {
	percent := (f32(cross_result.correct_count) * 100 / cross_result.labeled_classes.len)
		folding_string := if opts.folds == 0 { 'leave-one-out' } else { '$opts.folds-fold' }
		exclude_string := if opts.exclude_flag {
			'excluding missing values'
		} else {
			'including missing values'
		}
		attr_string := if opts.number_of_attributes[0] == 0 {
			'all'
		} else {
			opts.number_of_attributes[0].str()
		}
		weight_string := if opts.weighting_flag { '' } else { 'not' }

		println('Cross-validation of "$opts.datafile_path" using $folding_string partitioning,\n$attr_string attributes, $exclude_string,\nbin range for continuous attributes from ${opts.bins[0]} to ${opts.bins[1]},\nand $weight_string weighting the number of nearest neighbor counts by class prevalences.\ncorrect inferences: ${cross_result.correct_count} out of $cross_result.labeled_classes.len  ${percent:5.2f}%')
}

