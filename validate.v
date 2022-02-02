// validate.v
/*
Given a classifier and a validation dataset, classifies each instance
  of the validation_set on the trained classifier; returns the predicted classes for each instance of the validation_set.*/
module hamnn

// import tools
// import classify
import json
import os

// validate classifies each instance of a validation datafile against
// a trained Classifier; returns the predicted classes for each instance
// of the validation_set.
// Optionally, saves the instances and their predicted classes in a file.
// This file can be used to append these instances to the classifier.
pub fn validate(cl Classifier, opts Options) ?ValidateResult {
	// load the testfile as a Dataset struct
	mut test_ds := load_file(opts.testfile_path)
	// instantiate a struct for the result
	mut validate_result := ValidateResult{
		inferred_classes: []string{}
	}
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
	test_instances := transpose(test_attr_binned_values)
	// for each instance in the test data, perform a classification and compile the results
	validate_result = classify_to_validate(cl, test_instances, mut validate_result, opts)
	if opts.show_flag && opts.command == 'validate' {
		println('validate_result: $validate_result')
	}
	if opts.outputfile_path != '' {
		validate_result.instances = test_instances
		s := json.encode(validate_result)
		// println('After json encoding, before writing:\n $s')
		mut f := os.open_file(opts.outputfile_path, 'w') or { panic(err.msg) }
		f.write_string(s) or { panic(err.msg) }
		f.close()
	}
	return validate_result
}

// classify_to_validate
fn classify_to_validate(cl Classifier, test_instances [][]byte, mut result ValidateResult, opts Options) ValidateResult {
	result.Class = cl.Class
	mut classify_result := ClassifyResult{}
	// for each instance in the test data, perform a classification
	for test_instance in test_instances {
		classify_result = classify_instance(cl, test_instance, opts)
		result.inferred_classes << classify_result.inferred_class
		result.counts << classify_result.nearest_neighbors_by_class
	}
	return result
}
