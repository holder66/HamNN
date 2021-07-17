// validate.v
/*
Given a classifier and a validation dataset, classifies each instance
  of the validation_set on the trained classifier; returns the predicted classes for each instance of the validation_set.*/
module validate

import tools
import classify

// validate classifies each instance of a validation datafile against
// a trained Classifier; returns the predicted classes for each instance 
// of the validation_set.
// Type: `v run hamnn.v validate --help`
pub fn validate(cl tools.Classifier, opts tools.Options) tools.ValidateResult {
	// load the testfile as a Dataset struct
	mut test_ds := tools.load_file(opts.testfile_path)
	// instantiate a struct for the result
	mut validate_result := tools.ValidateResult{
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
			test_binned_values = tools.discretize_attribute<f32>(test_ds.useful_continuous_attributes[test_index],
				cl.trained_attributes[attr].minimum, cl.trained_attributes[attr].maximum,
				cl.trained_attributes[attr].bins)
		} else { // ie for discrete attributes
			test_binned_values = test_ds.useful_discrete_attributes[test_index].map(cl.trained_attributes[attr].translation_table[it])
		}
		test_attr_binned_values << test_binned_values.map(byte(it))
	}
	test_instances := tools.transpose(test_attr_binned_values)
	// for each instance in the test data, perform a classification and compile the results
	validate_result = classify_to_validate(cl, test_instances, mut validate_result, opts)
	if opts.show_flag {
		println('validate_result: $validate_result')
	}
	return validate_result
}

// classify_to_validate
pub fn classify_to_validate(cl tools.Classifier, test_instances [][]byte, mut result tools.ValidateResult, opts tools.Options) tools.ValidateResult {
	// for each instance in the test data, perform a classification
	for test_instance in test_instances {
		result.inferred_classes << classify.classify_instance(cl, test_instance, opts).class
	}
	return result
}
