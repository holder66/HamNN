// analyze
module hamnn

import math

// analyze_dataset returns an array of strings with information about a
// datafile; print to the console with print_array().
// ```sh
// 1. a list of attributes, their types, the unique values, and a count of
// missing values;
// 2. a table with counts for each type of attribute;
// 3. a list of discrete attributes useful for training a classifier;
// 4. a list of continuous attributes useful for training a classifier;
// 5. a breakdown of the class attribute, showing counts for each class.
// ```
pub fn analyze_dataset(ds Dataset, opts Options) AnalyzeResult {
	mut result := AnalyzeResult{
		environment: get_environment()
		datafile_path: ds.path 
		datafile_type:	file_type(ds.path)
	}
	mut missing_vals := ds.data.map(missing_values(it))
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
	if opts.show_flag { show_analyze(result)}
	return result
}

pub // show_analyze 
fn show_analyze(result AnalyzeResult) {
	// println(result)
	mut show := []string{}
	show << [
	'',
	'Analysis of Dataset "$result.datafile_path" (File Type $result.datafile_type)',
	'All Attributes', 'Index  Name                          Count  Uniques  Missing      %  Type',
	'_____  __________________________  _______  _______  _______  _____  ____'
	]
	for attr in result.attributes {
		show << '${attr.id:5}  ${attr.name:-27}  ${attr.count:6}  ${attr.uniques:7}  ${attr.missing:7}  ${attr.missing * 100 / f32(attr.count):5.1f}  ${attr.att_type:4}'
		}
	mut total_count := 0
	mut total_missings := 0
	for attr in result.attributes { 
		total_count += attr.count
		total_missings += attr.missing
	}
	show << [
	'______                             _______           _______  _____',
	'Totals (less Class attribute)   ${total_count:10}        ${total_missings:10}  ${total_missings * 100 / f32(total_count):5.2f}%'
	]
	print_array(show)
}

pub fn analyze_dataset_old(ds Dataset) []string {
	cases_count := ds.data[0].len
	mut show_dataset := ['']
	mut missing_vals := ds.data.map(missing_values(it))
	missing_vals << 0
	mut show_attributes := ['', 'Analysis of Dataset "$ds.path" (File Type ${file_type(ds.path)})',
		'All Attributes', 'Index  Name                          Count  Uniques  Missing     %   Type',
		'_____  __________________________  _______  _______  _______  ____   ____']
	for i, name in ds.attribute_names {
		show_attributes << '${i:5}  ${name:-27}   ${ds.data[i].len:5}    ${uniques(ds.data[i]):5}     ${missing_vals[i]:4} ${f32(missing_vals[i]) / f32(cases_count) * 100.0:5.1f}   ${ds.inferred_attribute_types[i]}'
	}
	show_attributes << '______                             _______           _______ _____'
	show_attributes << 'Totals (less Class attribute)   ${cases_count * (ds.data.len - 1):10}        ${array_sum<int>(missing_vals):10}  ${f32(array_sum<int>(missing_vals)) / (cases_count * (ds.data.len - 1)) * 100.0:5.2f}%'
	mut show_types := ['', 'Counts of Attributes by Type', 'Type        Count', '____        _____']
	for key, value in string_element_counts(ds.inferred_attribute_types) {
		show_types << '$key          ${value:6}'
	}
	show_types << 'Total:     ${ds.inferred_attribute_types.len:6}'

	mut show_discrete_attributes := ['', 'Discrete Attributes for Training',
		' Index  Name                           Uniques',
		' _____  __________________________     _______']
	for key, value in ds.useful_discrete_attributes {
		show_discrete_attributes << '${key:6}  ${ds.attribute_names[key]:-27}      ${uniques(value):5}'
	}

	mut show_continuous_attributes := ['', 'Continuous Attributes for Training',
		' Index  Name                           Min         Max',
		' _____  __________________________  ______      ______']
	mut min := 0.0
	for key, value in ds.useful_continuous_attributes {
		// to calculate the minimum, strip out missing values (placeholder is -math.max_f32)
		min = f32_abs(array_min(value.filter(it != -math.max_f32)))

		show_continuous_attributes << '${key:6}  ${ds.attribute_names[key]:-27} ${min:6.3g}      ${array_max(value):6}'
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
	return string_element_counts(attribute_values).len
}

// missing_values
fn missing_values(attribute_values []string) int {
	return attribute_values.filter(it in missings).len
}

// sum_elements
fn sum_elements() ? {
}
