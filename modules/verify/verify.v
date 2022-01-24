// verify.v
/*
Given a classifier and a verification dataset, classifies each instance
  of the verification_set on the trained classifier; returns metrics
  comparing the predicted classes to the assigned classes.*/
module verify

import tools
import classify
import runtime

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
	mut confusion_matrix_row := map[string]int{}
	// for each class, instantiate an entry in the confusion matrix row
	for key, _ in test_ds.Class.class_counts {
		confusion_matrix_row[key] = 0
	}
	// for each class, instantiate an entry in the class table
	for key, value in test_ds.Class.class_counts {
		verify_result.class_table[key] = tools.ResultForClass{
			labeled_instances: value
			confusion_matrix_row: confusion_matrix_row.clone()
		}
	}
	// massage each instance in the test dataset according to the
	// attribute parameters in the classifier
	test_instances := generate_test_instances_array(cl, test_ds)
	// for the instances in the test data, perform classifications
	verify_result = classify_to_verify(cl, test_instances, mut verify_result, opts)
	tools.show_results(verify_result, opts)
	if opts.verbose_flag && opts.command == 'verify' {
		// println('verify_result.class_table in verify: $verify_result.class_table')
	}
	return verify_result
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
	// println('result in classify_to_verify: $result')
	if opts.concurrency_flag {
		mut work_channel := chan int{cap: runtime.nr_jobs()}
		mut result_channel := chan tools.ClassifyResult{cap: test_instances.len}
		for i, _ in test_instances {
			work_channel <- i
			go option_worker(work_channel, result_channel, cl, test_instances, result.labeled_classes,
				opts)
		}
		for _ in test_instances {
			classify_result = <-result_channel
			// println(classify_result)
			if classify_result.inferred_class == classify_result.labeled_class {
				result.class_table[classify_result.inferred_class].correct_inferences += 1
			} else {
				result.class_table[classify_result.inferred_class].wrong_inferences += 1
			}
			// update confusion matrix row
			// println(result.class_table[classify_result.labeled_class])
			result.class_table[classify_result.labeled_class].confusion_matrix_row[classify_result.inferred_class] += 1
			// println(result.class_table)
		}
	} else {
		for i, test_instance in test_instances {
			inferred_class = classify.classify_instance(cl, test_instance, opts).inferred_class
			if inferred_class == result.labeled_classes[i] {
				result.class_table[result.labeled_classes[i]].correct_inferences += 1
			} else {
				result.class_table[inferred_class].wrong_inferences += 1
			}
			// update confusion matrix row
			result.class_table[result.labeled_classes[i]].confusion_matrix_row[inferred_class] += 1
		}
	}
	if opts.verbose_flag && opts.command == 'verify' {
		// println('result.class_table in verify: $result.class_table')
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
