// analyze.v
module hamnn

import math

// analyze_dataset returns a struct with information about a datafile.
// ```sh
// Optional:
// if show_flag is true, displays on the console (using show_analyze):
// 1. a list of attributes, their types, the unique values, and a count of
// missing values;
// 2. a table with counts for each type of attribute;
// 3. a list of discrete attributes useful for training a classifier;
// 4. a list of continuous attributes useful for training a classifier;
// 5. a breakdown of the class attribute, showing counts for each class.
//
// outputfile_path: if specified, saves the analysis results.
// ```
pub fn analyze_dataset(ds Dataset, opts Options) AnalyzeResult {
	mut result := AnalyzeResult{
		environment: get_environment()
		datafile_path: ds.path
		datafile_type: file_type(ds.path)
		class_name: ds.class_name
		class_counts: ds.class_counts
	}
	mut missing_vals := ds.data.map(missing_values(it))
	// println('missing_values in analyze_dataset: $missing_vals')
	mut indices_of_useful_attributes := ds.useful_continuous_attributes.keys()
	indices_of_useful_attributes << ds.useful_discrete_attributes.keys()
	mut atts := []Attribute{}
	for i, name in ds.attribute_names {
		mut att_info := Attribute{
			id: i
			name: name
			count: ds.data[i].len
			uniques: uniques(ds.data[i])
			missing: missing_vals[i]
			att_type: ds.inferred_attribute_types[i]
			for_training: i in indices_of_useful_attributes
		}
		if i in indices_of_useful_attributes && ds.inferred_attribute_types[i] == 'C' {
			att_info.max = array_max(ds.useful_continuous_attributes[i])
			att_info.min = f32(array_min(ds.useful_continuous_attributes[i].filter(it != -math.max_f32)))
		}
		atts << att_info
	}
	result.attributes = atts
	if opts.show_flag {
		show_analyze(result)
	}
	if opts.outputfile_path != '' {
		save_json_file(result, opts.outputfile_path)
	}
	return result
}

// uniques
fn uniques(attribute_values []string) int {
	return string_element_counts(attribute_values).len
}

// missing_values
fn missing_values(attribute_values []string) int {
	return attribute_values.filter(it in missings).len
}
