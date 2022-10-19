// verify.v
/*
Given a classifier and a verification dataset, classifies each instance
  of the verification_set on the trained classifier; returns metrics
  comparing the predicted classes to the assigned classes.*/
module hamnn

import runtime

// verify classifies all the instances in a verification datafile (specified
// by `opts.testfile_path`) using a trained Classifier; returns metrics
// comparing the inferred classes to the labeled (assigned) classes
// of the verification datafile.
// ```sh
// Optional (also see `make_classifier()` for options in training a classifier)
// weighting_flag: nearest neighbor counts are weighted by
// 	class prevalences.
// Output options:
// show_flag: display results on the console;
// expanded_flag: display additional information on the console, including
// 		a confusion matrix.
// outputfile_path: saves the result as a json file
// ```
pub fn verify(opts Options) ?CrossVerifyResult {
	// load the testfile as a Dataset struct
	mut test_ds := load_file(opts.testfile_path)
	mut confusion_matrix_map := map[string]map[string]f64{}
	// for each class, instantiate an entry in the confusion matrix map
	for key1, _ in test_ds.class_counts {
		for key2, _ in test_ds.class_counts {
			confusion_matrix_map[key2][key1] = 0
		}
	}
	// instantiate a struct for the result
	mut verify_result := CrossVerifyResult{
		classifier_path: opts.datafile_path
		testfile_path: opts.testfile_path
		labeled_classes: test_ds.class_values
		class_counts: test_ds.class_counts
		classes: test_ds.classes
		pos_neg_classes: get_pos_neg_classes(test_ds.class_counts)
		confusion_matrix_map: confusion_matrix_map
		binning: opts.binning
		command: 'verify'
		Parameters: opts.Parameters
		DisplaySettings: opts.DisplaySettings
	}
	if opts.multiple_classify_options_file_path == '' {
		mut cl := Classifier{}
		if opts.classifierfile_path == '' {
			cl = make_classifier(load_file(opts.datafile_path), opts)
		} else {
			cl = load_classifier_file(opts.classifierfile_path)?
		}
		// verify_result.command = 'verify' // override the 'make' command from cl.Parameters
		// massage each instance in the test dataset according to the
		// attribute parameters in the classifier
		test_instances := generate_test_instances_array(cl, test_ds)
		// for the instances in the test data, perform classifications
		verify_result = classify_to_verify(cl, test_instances, mut verify_result, opts)
	} else {
		mut classifier_array := []Classifier{}
		mut instances_to_be_classified := [][][]u8{}
		// mut mult_opts := []Parameters{}
		mut mult_opts := opts
		ds := load_file(opts.datafile_path)
		mut saved_params := read_multiple_opts(opts.multiple_classify_options_file_path)?
		// println('mult_opts: $mult_opts')
		for params in saved_params.classifier_options {
			// println('params: $params')
			// println('number of attributes: $params.number_of_attributes')
			mult_opts.Parameters = params
			// println('mult_opts: $mult_opts')
			classifier_array << make_classifier(ds, mult_opts)
			instances_to_be_classified << generate_test_instances_array(classifier_array.last(), test_ds)
		}
		// println('classifier_array: $classifier_array')
		// println('instances_to_be_classified: $instances_to_be_classified')
		instances_to_be_classified = transpose(instances_to_be_classified)
		// println('instances_to_be_classified: $instances_to_be_classified')
		verify_result = multiple_classify_to_verify(classifier_array, instances_to_be_classified, mut verify_result, opts)
	}
	verify_result.Metrics = get_metrics(verify_result)?
	// println('cross_result.pos_neg_classes: $cross_result.pos_neg_classes')
	if verify_result.pos_neg_classes.len == 2 {
		verify_result.BinaryMetrics = get_binary_stats(verify_result)
	}
	// verify_result.command = 'verify'
	// println('verify_result: $verify_result')
	if verify_result.command == 'verify' && (verify_result.show_flag || verify_result.expanded_flag) {
		show_verify(verify_result)?
	}
	if opts.verbose_flag && opts.command == 'verify' {
		println('verify_result in verify(): $verify_result')
	}
	if opts.outputfile_path != '' {
		save_json_file(verify_result, opts.outputfile_path)
	}
	return verify_result
}

// generate_test_instances_array
fn generate_test_instances_array(cl Classifier, test_ds Dataset) [][]u8 {
	// for each usable attribute in cl, massage the equivalent test_ds attribute
	mut test_binned_values := []int{}
	mut test_attr_binned_values := [][]u8{}
	mut test_index := 0
	for attr in cl.attribute_ordering {
		// get an index into this attribute in test_ds
		for j, value in test_ds.attribute_names {
			if value == attr {
				test_index = j
			}
		}
		if cl.trained_attributes[attr].attribute_type == 'C' {
			test_binned_values = discretize_attribute<f32>(test_ds.useful_continuous_attributes[test_index],
				cl.trained_attributes[attr].minimum, cl.trained_attributes[attr].maximum,
				cl.trained_attributes[attr].bins)
		} else { // ie for discrete attributes
			test_binned_values = test_ds.useful_discrete_attributes[test_index].map(cl.trained_attributes[attr].translation_table[it])
		}
		test_attr_binned_values << test_binned_values.map(u8(it))
	}
	return transpose(test_attr_binned_values)
}

// option_worker_verify
fn option_worker_verify(work_channel chan int, result_channel chan ClassifyResult, cl Classifier, test_instances [][]u8, labeled_classes []string, opts Options) {
	mut index := <-work_channel
	mut classify_result := classify_instance(index, cl, test_instances[index], opts)
	classify_result.labeled_class = labeled_classes[index]
	result_channel <- classify_result
	// dump(result_channel)
	return
}

// multiple_classify_to_verify 
fn multiple_classify_to_verify(m_cl []Classifier, m_instances [][][]u8, mut result CrossVerifyResult, opts Options) CrossVerifyResult {
	mut m_classify_result := ClassifyResult{}
	
	if !opts.concurrency_flag {

	} else {
		for i, test_instance in m_instances {
			m_classify_result = multiple_classifier_classify(i, m_cl, test_instance, opts)
			// println('m_classify_result: $m_classify_result.inferred_class')
			result.inferred_classes << m_classify_result.inferred_class
			result.actual_classes << result.labeled_classes[i]
			result.nearest_neighbors_by_class << m_classify_result.nearest_neighbors_by_class
		}
	}
	result.classifier_instances_counts << m_cl[0].history[0].instances_count
	result.prepurge_instances_counts_array << m_cl[0].history[0].prepurge_instances_count
	if opts.verbose_flag && opts.command == 'verify' {
		println('result in classify_to_verify(): $result')
	}
	result = summarize_results(1, mut result)
	if opts.verbose_flag && opts.command == 'verify' {
		println('summarize_result: $result')
	}
	// println('result: $result')
	return result
}

// classify_to_verify classifies each instance in an array, and
// returns the results of the classification.
fn classify_to_verify(cl Classifier, test_instances [][]u8, mut result CrossVerifyResult, opts Options) CrossVerifyResult {
	// for each instance in the test data, perform a classification
	mut classify_result := ClassifyResult{}
	if opts.concurrency_flag {
		mut work_channel := chan int{cap: runtime.nr_jobs()}
		mut result_channel := chan ClassifyResult{cap: test_instances.len}
		for i, _ in test_instances {
			work_channel <- i
			go option_worker_verify(work_channel, result_channel, cl, test_instances,
				result.labeled_classes, opts)
		}
		for _ in test_instances {
			classify_result = <-result_channel
			// println(classify_result)
			result.inferred_classes << classify_result.inferred_class
			result.actual_classes << classify_result.labeled_class
			result.nearest_neighbors_by_class << classify_result.nearest_neighbors_by_class
		}
	} else {
		for i, test_instance in test_instances {
			classify_result = classify_instance(i, cl, test_instance, opts)
			// result.inferred_classes << classify_instance(i, cl, test_instance, opts).inferred_class
			result.inferred_classes << classify_result.inferred_class
			result.nearest_neighbors_by_class << classify_result.nearest_neighbors_by_class
			result.actual_classes << result.labeled_classes[i]
		}
	}
	result.classifier_instances_counts << cl.history[0].instances_count
	result.prepurge_instances_counts_array << cl.history[0].prepurge_instances_count
	if opts.verbose_flag && opts.command == 'verify' {
		println('result in classify_to_verify(): $result')
	}
	result = summarize_results(1, mut result)
	if opts.verbose_flag && opts.command == 'verify' {
		println('summarize_result: $result')
	}
	return result
}
