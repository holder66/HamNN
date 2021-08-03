// verify.v
/*
Given a classifier and a verification dataset, classifies each instance
  of the verification_set on the trained classifier; returns metrics
  comparing the predicted classes to the assigned classes.*/
module verify

import tools
import classify

// verify classifies each instance of a verification datafile against
// a trained Classifier; returns metrics comparing the inferred classes
// to the labeled (assigned) classes of the verification datafile.
// Type: `v run hamnn.v verify --help`
pub fn verify(cl tools.Classifier, opts tools.Options) tools.VerifyResult {
	// load the testfile as a Dataset struct
	mut test_ds := tools.load_file(opts.testfile_path)
	// instantiate a struct for the result
	mut verify_result := tools.VerifyResult{
		labeled_classes: test_ds.Class.class_values
		pos_neg_classes: tools.get_pos_neg_classes(test_ds.class_counts)
	}
	// for each class, instantiate an entry in the class table
	for key, value in test_ds.Class.class_counts {
		verify_result.class_table[key] = tools.ResultForClass{
			labeled_instances: value
		}
	}
	// massage each instance in the test dataset according to the
	// attribute parameters in the classifier
	test_instances := generate_test_instances_array(cl, test_ds)
	// for each instance in the test data, perform a classification
	verify_result = classify_to_verify(cl, test_instances, mut verify_result, opts)
	tools.show_results(verify_result, opts)
	// if opts.show_flag && opts.command == 'verify' {

	// 	percent := (f32(verify_result.correct_count) * 100 / verify_result.labeled_classes.len)
	// 	println('correct inferences: $verify_result.correct_count out of $verify_result.labeled_classes.len (${percent:5.2f}%)')
	// }
	// if opts.expanded_flag && opts.command == 'verify' {
	// 	tools.show_expanded_result(verify_result, opts)
	// }
	if opts.verbose_flag && opts.command == 'verify' {
		println('verify_result.class_table in verify: $verify_result.class_table')
	}
	return verify_result
}

// verify_classify_results
fn verify_classify_results(classify_result_array []tools.ClassifyResult, mut result tools.VerifyResult) tools.VerifyResult {
	for classify_result in classify_result_array {
		if classify_result.inferred_class == classify_result.labeled_class {
			result.class_table[classify_result.inferred_class].correct_inferences += 1
		} else {
			result.class_table[classify_result.inferred_class].wrong_inferences += 1
		}
	}
	return summarize_results(mut result)
}

// do_classification
fn do_classification(cl tools.Classifier, test_instances [][]byte, opts tools.Options) []tools.ClassifyResult {
	mut classify_result_array := []tools.ClassifyResult{}
	for test_instance in test_instances {
		classify_result_array << classify.classify_instance(cl, test_instance, opts)
	}
	return classify_result_array
}

// generate_test_instances_array
fn generate_test_instances_array(cl tools.Classifier, test_ds tools.Dataset) [][]byte {
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
			test_binned_values = tools.discretize_attribute<f32>(test_ds.useful_continuous_attributes[test_index],
				cl.trained_attributes[attr].minimum, cl.trained_attributes[attr].maximum,
				cl.trained_attributes[attr].bins)
		} else { // ie for discrete attributes
			test_binned_values = test_ds.useful_discrete_attributes[test_index].map(cl.trained_attributes[attr].translation_table[it])
		}
		test_attr_binned_values << test_binned_values.map(byte(it))
	}
	return tools.transpose(test_attr_binned_values)
}

// option_worker
fn option_worker(work_channel chan int, result_channel chan tools.ClassifyResult, cl tools.Classifier, test_instances [][]byte, labeled_classes []string, opts tools.Options) {
	mut index := <-work_channel
	mut classify_result := classify.classify_instance(cl, test_instances[index], opts)
	classify_result.labeled_class = labeled_classes[index]
	result_channel <- classify_result
	// dump(result_channel)
	return
}

// classify_to_verify is used by cross_validate
pub fn classify_to_verify(cl tools.Classifier, test_instances [][]byte, mut result tools.VerifyResult, opts tools.Options) tools.VerifyResult {
	// for each instance in the test data, perform a classification
	mut inferred_class := ''
	mut classify_result := tools.ClassifyResult{}

	if opts.concurrency_flag {
		mut work_channel := chan int{cap: test_instances.len}
		mut result_channel := chan tools.ClassifyResult{cap: test_instances.len}
		for i, _ in test_instances {
			work_channel <- i
			go option_worker(work_channel, result_channel, cl, test_instances, result.labeled_classes,
				opts)
		}
		for _ in test_instances {
			classify_result = <-result_channel
			if classify_result.inferred_class == classify_result.labeled_class {
				result.class_table[classify_result.inferred_class].correct_inferences += 1
			} else {
				result.class_table[classify_result.inferred_class].wrong_inferences += 1
			}
		}
	} else {
		for i, test_instance in test_instances {
			inferred_class = classify.classify_instance(cl, test_instance, opts).inferred_class
			if inferred_class == result.labeled_classes[i] {
				result.class_table[result.labeled_classes[i]].correct_inferences += 1
			} else {
				result.class_table[inferred_class].wrong_inferences += 1
			}
		}
	}
	if opts.verbose_flag && opts.command == 'verify' {
		println('result.class_table in verify: $result.class_table')
	}

	return summarize_results(mut result)
}

// summarize_results 
fn summarize_results(mut result tools.VerifyResult) tools.VerifyResult {
	for _, mut value in result.class_table {
		value.missed_inferences = value.labeled_instances - value.correct_inferences
		result.correct_count += value.correct_inferences
		result.total_count += value.labeled_instances
		result.misses_count += value.missed_inferences
		result.wrong_count += value.wrong_inferences
	}
	return result
}
