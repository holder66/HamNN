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
pub fn verify(cl Classifier, opts Options) ?CrossVerifyResult {
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
		classifier_path: cl.datafile_path
		testfile_path: opts.testfile_path
		labeled_classes: test_ds.class_values
		class_counts: test_ds.class_counts
		pos_neg_classes: get_pos_neg_classes(test_ds.class_counts)
		confusion_matrix_map: confusion_matrix_map
		binning: cl.binning
		Parameters: cl.Parameters
		DisplaySettings: opts.DisplaySettings
	}
	verify_result.command = 'verify' // override the 'make' command from cl.Parameters
	// massage each instance in the test dataset according to the
	// attribute parameters in the classifier
	test_instances := generate_test_instances_array(cl, test_ds)
	// for the instances in the test data, perform classifications
	verify_result = classify_to_verify(cl, test_instances, mut verify_result, opts)
	if opts.command == 'verify' && (opts.show_flag || opts.expanded_flag) {
		show_verify(verify_result, opts.DisplaySettings) ?
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
fn generate_test_instances_array(cl Classifier, test_ds Dataset) [][]byte {
	// for each usable attribute in cl, massage the equivalent test_ds attribute
	mut test_binned_values := []int{}
	mut test_attr_binned_values := [][]byte{}
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
		test_attr_binned_values << test_binned_values.map(byte(it))
	}
	return transpose(test_attr_binned_values)
}

// option_worker_verify
fn option_worker_verify(work_channel chan int, result_channel chan ClassifyResult, cl Classifier, test_instances [][]byte, labeled_classes []string, opts Options) {
	mut index := <-work_channel
	mut classify_result := classify_instance(index, cl, test_instances[index], opts)
	classify_result.labeled_class = labeled_classes[index]
	result_channel <- classify_result
	// dump(result_channel)
	return
}

// classify_to_verify classifies each instance in an array, and
// returns the results of the classification.
fn classify_to_verify(cl Classifier, test_instances [][]byte, mut result CrossVerifyResult, opts Options) CrossVerifyResult {
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
		}
	} else {
		for i, test_instance in test_instances {
			result.inferred_classes << classify_instance(i, cl, test_instance, opts).inferred_class
			result.actual_classes << result.labeled_classes[i]
		}
	}
	if opts.verbose_flag && opts.command == 'verify' {
		println('result in classify_to_verify(): $result')
	}
	result = summarize_results(1, mut result)
	if opts.verbose_flag && opts.command == 'verify' {
		println('summarize_result: $result')
	}
	return result
}
