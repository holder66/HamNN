// rank
module hamnn

import math
import json
import os
// import arrays

// rank_attributes takes a Dataset and returns a list of all the
// dataset's usable attributes, ranked in order of each attribute's
// ability to separate the classes.
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
		bins: opts.bins
	}
	perfect_rank_value := f32(get_rank_value_for_strings(ds.Class.class_values, ds.Class.class_values,
		ds.Class.class_counts, opts.exclude_flag))
	if opts.verbose_flag && opts.command == 'rank' {
		println('perfect_rank_value: $perfect_rank_value')
	}
	mut ranked_atts := []RankedAttribute{}
	mut lower := opts.bins[0]
	mut upper := opts.bins[0] + 1
	mut interval := 1
	if opts.bins.len == 2 {
		upper = opts.bins[1] + 1
	} else if opts.bins.len == 3 {
		upper = opts.bins[1] + 1
		interval = opts.bins[2]
	} else if opts.bins.len != 1 {
		panic('invalid bins $opts.bins')
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
		// since a normal for loop is exclusive, we start from upper - 1
		mut bin_number := upper - 1
		for bin_number >= lower {
			rank_value = i64(0)

			binned_values = discretize_attribute(attr_values, min, max, bin_number)
			// loop through each possible value for bin in the bins bin_number + 1
			for bin_value in 0 .. bin_number + 1 {
				// a bin_value of 0 represents a missing value, so skip
				// if the opts.exclude_flag flag is set
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
			bin_number -= interval
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

	if (opts.show_flag || opts.expanded_flag) && opts.command == 'rank' {
		show_rank_attributes(ranking_result)
	}
	if opts.graph_flag  && opts.command == 'rank' {
		plot_rank(ranking_result)
	}
	if opts.outputfile_path != '' {
		mut f := os.open_file(opts.outputfile_path, 'w') or { panic(err.msg) }
		f.write_string(json.encode(ranking_result)) or { panic(err.msg) }
		f.close()
	}
	return ranking_result
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
