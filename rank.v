// rank
module hamnn

import math

// rank_attributes takes a Dataset and returns a list of all the
// dataset's usable attributes, ranked in order of each attribute's
// ability to separate the classes.
// ```
// Algorithm:
// for each attribute:
// 	create a matrix with attribute values for row headers, and 
// 	class values for column headers;
// 	for each unique value `val` for that attribute:
// 		for each unique value `class` of the class attribute:
// 			for each instance:
// 				accumulate a count for those instances whose class value 
// 				equals `class`;
// 				populate the matrix with these accumulated counts;
// 	for each `val`:
// 		get the absolute values of the differences between accumulated 
// 		counts for each pair of `class` values`;
// 		add those absolute differences;
// 	total those added absolute differences to get the raw rank value 
// for that attribute.
// To obtain rank values weighted by class prevalences, use the same algorithm 
// except before taking the difference of each pair of accumulated counts,
// multiply each count of the pair by the class prevalence of the other class.
// (Note: rank_attributes always uses class prevalences as weights)
// 
// Obtain a maximum rank value by calculating a rank value for the class  
// attribute itself.
// 
// To obtain normalized rank values:
// for each attribute:
// 	divide its raw rank value by the maximum rank value and multiply by 100. 
// 
// Sort the attributes by descending rank values.
// ```
// 
// ```sh
// Options:
// `bins` specifies the range for binning (slicing) continous attributes;
// `exclude_flag` to exclude missing values when calculating rank values;
// Output options:
// `show_flag` to print the ranked list to the console;
// `graph_flag` to generate plots of rank values for each attribute on the
//     y axis, with number of bins on the x axis.
// `outputfile_path`, saves the result as json.
// ```
pub fn rank_attributes(ds Dataset, opts Options) RankingResult {
	// to get the denominator for calculating percentages of rank values,
	// we get the rank value for the class attribute, which should be 100%
	mut ranking_result := RankingResult{
		path: ds.path
		exclude_flag: opts.exclude_flag
	}
	perfect_rank_value := f32(get_rank_value_for_strings(ds.Class.class_values, ds.Class.class_values,
		ds.Class.class_counts, opts.exclude_flag))
	if opts.verbose_flag && opts.command == 'rank' {
		println('perfect_rank_value: $perfect_rank_value')
	}
	mut ranked_atts := []RankedAttribute{}
	mut binning := Binning{}
	if ds.useful_continuous_attributes.len != 0 {
		binning = get_binning(opts.bins)
	}

	// for each usable attribute, calculate a rank value taking into
	// account the class prevalences
	// create an array of the unique class values
	mut count := 0
	// mut diff := 0
	mut rank_value := i64(0)
	mut rank_value_array := []f32{}
	mut maximum_rank_value := i64(0)
	mut attr_index_for_maximum_rank_value := 0
	mut bin_number_for_maximum_rank_value := 0
	mut min := f32(0.0)
	mut max := f32(0.0)
	mut binned_values := []int{}
	// loop through usable continuous attributes
	for attr_index, attr_values in ds.useful_continuous_attributes {
		rank_value_array = []
		maximum_rank_value = 0
		attr_index_for_maximum_rank_value = 0
		bin_number_for_maximum_rank_value = 0
		min = array_min(attr_values.filter(it != -math.max_f32))
		max = array_max(attr_values)
		// discretize each attribute by binning, over the bins given by lower
		// and upper and using an interval given by interval; go from high to
		// low, so that the maximum rank value used
		// is associated with the smallest bin number giving that rank value.

		// create an array whose values are the bin numbers we want to use
		mut bin_numbers := []int{}
		mut b := binning.lower
		// println('$lower $upper $interval')
		for {
			bin_numbers << b
			b += binning.interval
			if b > binning.upper {
				break
			}
		}
		bin_numbers.reverse_in_place()
		for bin_number in bin_numbers {
			rank_value = i64(0)

			binned_values = discretize_attribute(attr_values, min, max, bin_number)
			// loop through each possible value for bin in the bins bin_number + 1
			for bin_value in 0 .. bin_number + 1 {
				// a bin_value of 0 represents a missing value, so skip
				// if opts.exclude_flag is true
				if bin_value == 0 && opts.exclude_flag {
					continue
				}
				mut row := []int{}
				// loop through classes
				for class, _ in ds.class_counts {
					// at this point, we have the columns and rows we need
					// now to populate it
					// we can't use the same strategy as for discrete attributes
					// of creating an 2d array, since binned_values are integers
					// and class_values are strings
					count = 0
					for i, value in binned_values {
						if value == bin_value && ds.class_values[i] == class {
							count += 1
						}
					}
					row << count
				}
				rank_value += sum_along_row(row, get_map_values(ds.class_counts))
			}

			// for each attribute, find the maximum for the rank_values and
			// the corresponding number of bins
			if rank_value >= maximum_rank_value {
				maximum_rank_value = rank_value
				attr_index_for_maximum_rank_value = attr_index
				bin_number_for_maximum_rank_value = bin_number
			}
			rank_value_array << f32(rank_value)
			// bin_number -= interval
		}
		rank_value_array = rank_value_array.map(100.0 * f32(it) / perfect_rank_value)
		ranked_atts << RankedAttribute{
			attribute_index: attr_index_for_maximum_rank_value
			attribute_name: ds.attribute_names[attr_index_for_maximum_rank_value]
			inferred_attribute_type: ds.inferred_attribute_types[attr_index_for_maximum_rank_value]
			rank_value: 100.0 * f32(maximum_rank_value) / perfect_rank_value
			rank_value_array: rank_value_array
			bins: bin_number_for_maximum_rank_value
		}
	}
	// loop through discrete attributes
	for attr_index, attr_values in ds.useful_discrete_attributes {
		rank_value = get_rank_value_for_strings(attr_values, ds.class_values, ds.class_counts,
			opts.exclude_flag)
		ranked_atts << RankedAttribute{
			attribute_index: attr_index
			attribute_name: ds.attribute_names[attr_index]
			inferred_attribute_type: ds.inferred_attribute_types[attr_index]
			rank_value: 100.0 * f32(rank_value) / perfect_rank_value
		}
	}
	custom_sort_fn := fn (a &RankedAttribute, b &RankedAttribute) int {
		if a.rank_value > b.rank_value {
			return -1
		}
		if a.rank_value < b.rank_value {
			return 1
		}
		if a.rank_value == b.rank_value {
			if a.bins > b.bins {
				return 1
			}
			if a.bins < b.bins {
				return -1
			}
			if a.bins == b.bins {
				if a.attribute_index < b.attribute_index {
					return -1
				}
				return 1
			}
			return 0
		}

		return 0
	}
	ranking_result.array_of_ranked_attributes = ranked_atts
	// custom sort on descending rank value, then ascending bins, then index
	ranked_atts.sort_with_compare(custom_sort_fn)
	ranking_result.binning = binning

	if (opts.show_flag || opts.expanded_flag) && opts.command == 'rank' {
		show_rank_attributes(ranking_result)
	}
	if opts.graph_flag && opts.command == 'rank' {
		plot_rank(ranking_result)
	}
	if opts.outputfile_path != '' {
		save_json_file(ranking_result, opts.outputfile_path)
	}
	return ranking_result
}

// get_binning
fn get_binning(bins []int) Binning {
	if bins == [0] {
		return Binning{
			lower: 0
			upper: 0
			interval: 1
		}
	}
	if bins.len == 1 {
		return Binning{
			lower: 2
			upper: bins[0]
			interval: 1
		}
	}
	if bins.len == 2 {
		return Binning{
			lower: bins[0]
			upper: bins[1]
			interval: 1
		}
	}
	return Binning{
		lower: bins[0]
		upper: bins[1]
		interval: bins[2]
	}
}

// get_rank_value_for_strings
fn get_rank_value_for_strings(values []string, class_values []string, class_counts map[string]int, exclude bool) i64 {
	// println('values: $values  class_values: $class_values  class_counts: $class_counts  $exclude')
	mut rank_val := i64(0)
	mut count := 0
	mut row := []int{}
	for unique_val, _ in string_element_counts(values) {
		if unique_val in missings && exclude {
			continue
		}
		row = []int{}
		// loop through classes
		for class, _ in class_counts {
			// at this point, we have the columns and rows we need
			// now to populate it
			count = 0
			for i, val in values {
				if val == unique_val && class_values[i] == class {
					count += 1
				}
			}
			row << count
		}
		rank_val += sum_along_row(row, get_map_values(class_counts))
	}
	return rank_val
}

// sum_along_row returns the sum of the absolute values of the differences
// between counts multiplied by the class count for every combination pair
// of classes
fn sum_along_row(row []int, class_counts_array []int) i64 {
	mut row_sum := 0
	mut diff := 0
	for i, count1 in row {
		for j, count2 in row[i + 1..] {
			diff = count1 * class_counts_array[j + 1] - count2 * class_counts_array[i]
			if diff < 0 {
				diff *= -1
			}
			row_sum += diff
		}
	}
	// println('row_sum: $row_sum')
	return row_sum
}
