// analyze
module analyze

import tools
import math
import arrays

// analyze_dataset outputs to the console information about a datafile.
// Type: `v run hamnn.v analyze --help`
/*
1. a list of attributes, their types, the unique values, and a count of
missing values;
2. a table with counts for each type of attribute;
3. a list of discrete attributes useful for training a classifier;
4. a list of continuous attributes useful for training a classifier;
5. a breakdown of the class attribute, showing counts for each class.
*/
pub fn analyze_dataset(ds tools.Dataset) []string {
	// mut spaces := 18
	mut show_dataset := ['']
	mut show_attributes := ['',
		'Analysis of Dataset "$ds.path" (File Type ${tools.file_type(ds.path)})', 'All Attributes',
		'Index  Name                          Count  Uniques  Missing    Type',
		'_____  __________________________  _______  _______  _______    ____',
	]
	for i, name in ds.attribute_names {
		show_attributes << '${i:5}  ${name:-27}   ${ds.data[i].len:5}    ${uniques(ds.data[i]):5}     ${missing_values(ds.data[i]):4}    ${ds.inferred_attribute_types[i]}'
	}
	mut show_types := ['', 'Counts of Attributes by Type', 'Type        Count', '____        _____']
	for key, value in tools.string_element_counts(ds.inferred_attribute_types) {
		show_types << '$key          ${value:6}'
	}
	show_types << 'Total:     ${ds.inferred_attribute_types.len:6}'

	mut show_discrete_attributes := ['', 'Discrete Attributes for Training',
		' Index  Name                           Uniques',
		' _____  __________________________     _______',
	]
	for key, value in ds.useful_discrete_attributes {
		show_discrete_attributes << '${key:6}  ${ds.attribute_names[key]:-27}      ${uniques(value):5}'
	}

	mut show_continuous_attributes := ['', 'Continuous Attributes for Training',
		' Index  Name                   Min         Max',
		' _____  __________________  ______      ______',
	]
	mut min := 0.0
	for key, value in ds.useful_continuous_attributes {
		// to calculate the minimum, strip out missing values (placeholder is -math.max_f32)
		min = f32_abs(arrays.min(value.filter(it != -math.max_f32)))

		show_continuous_attributes << '${key:6}  ${ds.attribute_names[key]:-27} ${min:6.3g}      ${arrays.max(value):6}'
	}

	mut show_class := ['', 'The Class Attribute: "$ds.Class.class_name"',
		'Class Value           Cases', '____________________  _____']
	for key, value in ds.Class.class_counts {
		show_class << '${key:-20}  ${value:5}'
	}

	show_dataset << show_attributes
	show_dataset << show_types
	show_dataset << show_discrete_attributes
	show_dataset << show_continuous_attributes
	show_dataset << show_class

	return show_dataset
}

// uniques
fn uniques(attribute_values []string) int {
	return tools.string_element_counts(attribute_values).len
}

// missing_values
fn missing_values(attribute_values []string) int {
	return attribute_values.filter(it in tools.missings).len
}
