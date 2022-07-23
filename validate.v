// validate.v
/*
Given a classifier and a validation dataset, classifies each instance
  of the validation_set on the trained classifier; returns the predicted classes for each instance of the validation_set.*/
module hamnn

// validate classifies each instance of a validation datafile against
// a trained Classifier; returns the predicted classes for each instance
// of the validation_set.
// The file to be validated is specified by `opts.testfile_path`.
// Optionally, saves the instances and their predicted classes in a file.
// This file can be used to append these instances to the classifier.
pub fn validate(cl Classifier, opts Options) ?ValidateResult {
	// load the testfile as a Dataset struct
	mut test_ds := load_file(opts.testfile_path)
	// instantiate a struct for the result
	mut validate_result := ValidateResult{
		struct_type: '.ValidateResult'
		inferred_classes: []string{}
		validate_file_path: opts.testfile_path
		classifier_path: opts.datafile_path
		exclude_flag: opts.exclude_flag
		weighting_flag: opts.weighting_flag
		number_of_attributes: opts.number_of_attributes
		binning: cl.binning
		classifier_instances_counts << cl.history[0].instances_count
		prepurge_instances_counts_array << cl.history[0].prepurge_instances_count
	}
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
	test_instances := transpose(test_attr_binned_values)
	// for each instance in the test data, perform a classification and compile the results
	validate_result = classify_to_validate(cl, test_instances, mut validate_result, opts)
	if opts.command == 'validate' && (opts.show_flag || opts.expanded_flag) {
		show_validate(validate_result)
	}
	if opts.outputfile_path != '' {
		validate_result.instances = test_instances
		save_json_file(validate_result, opts.outputfile_path)
	}
	return validate_result
}

// classify_to_validate
fn classify_to_validate(cl Classifier, test_instances [][]u8, mut result ValidateResult, opts Options) ValidateResult {
	result.Class = cl.Class
	mut classify_result := ClassifyResult{}
	// for each instance in the test data, perform a classification
	for test_instance in test_instances {
		classify_result = classify_instance(0, cl, test_instance, opts)
		result.inferred_classes << classify_result.inferred_class
		result.counts << classify_result.nearest_neighbors_by_class
	}
	return result
}
