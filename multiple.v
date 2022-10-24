// multiple.v

module hamnn

import arrays
import os
import json

pub struct MultipleOptions {
	classifier_options []Parameters
}

// read_multiple_opts
fn read_multiple_opts(path string) ?MultipleOptions {
	s := os.read_file(path.trim_space()) or { panic('failed to open $path') }
	return json.decode(MultipleOptions, s)
}

// get_mult_classifier
// fn get_mult_classifier(ds Dataset, cl_opts ClassifierOptions, mut opts Options) Classifier {
// 	opts.bins = cl_opts.bins
// 	opts.number_of_attributes = cl_opts.number_of_attributes
// 	opts.uniform_bins = cl_opts.uniform_bins
// 	opts.exclude_flag = cl_opts.exclude_flag
// 	opts.multiple_flag = cl_opts.multiple_flag
// 	opts.purge_flag = cl_opts.purge_flag
// 	opts.weighting_flag = cl_opts.weighting_flag
// 	return make_classifier(ds, opts)
// }

// when multiple classifiers have been generated with different settings,
// a given instance to be classified will take multiple values, one for
// each classifier, and corresponding to the settings for that classifier.
// Note that opts is not used at present
// multiple_classifier_classify
fn multiple_classifier_classify(index int, classifiers []Classifier, instances_to_be_classified [][]u8, opts Options) ClassifyResult {
	// cl0 := classifiers[0]
	mut m_cr := []ClassifyResult{}
	mut final_cr := ClassifyResult{
		index: index
		// classes: cl0.class_values
	}
	// println('mcr.classes: $mcr.classes')
	// to classify, get Hamming distances between the entered instance and
	// all the instances in all the classifiers; return the class for the
	// instance giving the lowest Hamming distance.
	// println('instances_to_be_classified in multiple_classifier_classify: $instances_to_be_classified')
	mut hamming_distances := []int{}
	mut hamming_dist_arrays := [][]int{}
	mut hamming_dist := 0
	mut number_of_attributes := []int{}
	mut nearest_neighbors_array := [][]int{}
	mut inferred_class_array := []string{}
	for cl in classifiers {
		number_of_attributes << cl.attribute_ordering.len
	}
	// println('number_of_attributes: $number_of_attributes')
	maximum_number_of_attributes := array_max(number_of_attributes)
	// println('maximum_number_of_attributes: $maximum_number_of_attributes')
	// get the hamming distance for each of the corresponding byte_values
	// in each classifier instance and the instance to be classified
	for i, cl in classifiers {
		// find the max number of attributes used
		// println('i: $i number of attributes: $cl.attribute_ordering.len')
		hamming_distances = []
		for instance in cl.instances {
			hamming_dist = 0
			for j, byte_value in instances_to_be_classified[i] {
				// println('$j $byte_value ${instance[j]}')
				hamming_dist += get_hamming_distance(byte_value, instance[j])
			}
			hamming_distances << hamming_dist
		}
		// println('hamming_distances: $hamming_distances')
		// multiply each value by the maximum number of attributes, and
		// divide by this classifier's number of attributes
		// println(hamming_distances.map(it * maximum_number_of_attributes / cl.attribute_ordering.len))
		hamming_dist_arrays << hamming_distances.map(it * maximum_number_of_attributes / cl.attribute_ordering.len)
	}
	// println('hamming_dist_arrays: $hamming_dist_arrays')

	// instead of doing this on the summed distances, which produces
	// terrible results, let's try it on each row individually
	mut radii := []int{}
	mut combined_radii := []int{}
	// mut radius_row := []int{len: cl.class_counts.len}
	// mut radius_row := []int{}
	// mut nearest_neighbors_array := [][]int{}
	// mut inferred_class_array := []string{}
	for row in hamming_dist_arrays {
		radii = uniques(row)
		// radii.sort()
		// println('radii: $radii')
		combined_radii = arrays.merge(combined_radii, radii)
	}
	combined_radii = uniques(combined_radii)
	combined_radii.sort()
	// println('combined_radii: $combined_radii')
	for i, row in hamming_dist_arrays {
		mut radius_row := []int{len: classifiers[i].class_counts.len}
		mut cr := ClassifyResult{}
		for sphere_index, radius in combined_radii {
			if radius == classifiers[i].class_counts.len * 2 {
				break
			}
			radius_row = radius_row.map(it - it)
			// println('radius_row: $radius_row')
			for class_index, class in classifiers[i].classes {
				// println('class_index: $class_index class: $class')
				for instance, distance in row {
					// println('classifiers[i].class_values[instance]: ${classifiers[i].class_values[instance]}')
					if distance <= radius && class == classifiers[i].class_values[instance] {
						radius_row[class_index] += if !classifiers[i].weighting_flag {
							1
						} else {
							// println(int(i64(lcm(get_map_values(classifiers[i].class_counts))) / classifiers[i].class_counts[classifiers[i].classes[class_index]]))
							int(i64(lcm(get_map_values(classifiers[i].class_counts))) / classifiers[i].class_counts[classifiers[i].classes[class_index]])
						}
					}
				}
			}
			// println('radius_row: $radius_row')
			if !single_array_maximum(radius_row) {
				continue
			}
			// println('sphere_index: $sphere_index')
			cr.inferred_class = classifiers[i].classes[idx_max(radius_row)]
			cr.nearest_neighbors_by_class = radius_row
			cr.classes = classifiers[i].classes
			cr.weighting_flag = classifiers[i].weighting_flag
			cr.hamming_distance = combined_radii[sphere_index]
			cr.sphere_index = sphere_index
			break
		}
		m_cr << cr
		nearest_neighbors_array << cr.nearest_neighbors_by_class
		inferred_class_array << cr.inferred_class
		// println('$i $cr.nearest_neighbors_by_class $cr.inferred_class')
	}
	// println('nearest_neighbors_array: $nearest_neighbors_array')
	// println('inferred_class_array: $inferred_class_array')
	// identify when there is disagreement between classifiers for
	// the inferred class
	// mut i_nn := 0
	// mut max_nn := 0
	// mut sum_nn := 0
	// mut avg_nn := 0.0
	// mut ratios_array := []f64{}
	// zero_nn := nearest_neighbors_array.filter(0 in it).len
	// println(uniques(inferred_class_array))
	// println(uniques(inferred_class_array).filter(it != ''))
	if inferred_class_array.len > 1 && uniques(inferred_class_array).len > 1 {
		final_cr.inferred_class = resolve_conflict(inferred_class_array, nearest_neighbors_array)

		// // println('zero_nn: $zero_nn')
		// match true {
		// 	// if the number of inferred classes is an odd number, pick
		// 	// the winner
		// 	inferred_class_array.len % 2 != 0 {
		// 		final_cr.inferred_class = get_map_key_for_max_value(string_element_counts(inferred_class_array))
		// 	}
		// 	// if only one of the nearest neighbors lists has entries,
		// 	// use that inferred class
		// 	uniques(inferred_class_array).filter(it != '').len == 1 {
		// 		final_cr.inferred_class = uniques(inferred_class_array).filter(it != '')[0]
		// 	}
		// 	// if only one of the nearest neighbors lists has a zero, use that
		// 	// inferred class
		// 	zero_nn == 1 {
		// 		// println(inferred_class_array[idx_true(nearest_neighbors_array.map(0 in it))])
		// 		final_cr.inferred_class = inferred_class_array[idx_true(nearest_neighbors_array.map(0 in it))]
		// 	}
		// 	zero_nn > 1 {
		// 	// 	when there are 2 or more results with zeros, pick the
		// 	// 	result having the largest maximum, and use that maximum
		// 	// 	to get the inferred class
		// 		println(nearest_neighbors_array.map(array_max(it)))
		// 		println(idx_max(nearest_neighbors_array.map(array_max(it))))
		// 		// println(classifiers[i].classes[idx_max(nearest_neighbors_array[idx_max(nearest_neighbors_array.map(array_max(it)))])])
		// 		// final_cr.inferred_class = classifiers[i].classes[idx_max(nearest_neighbors_array[idx_max(nearest_neighbors_array.map(array_max(it)))])]
		// 	}
		// 	else {
		// 		// when none of the results have zeros in them, pick the
		// 		// result having the largest ratio of its maximum to the
		// 		// average of the other nearest neighbor counts
		// 		for nearest_neighbors in nearest_neighbors_array {
		// 			// i_nn := idx_max(nearest_neighbors)
		// 			if nearest_neighbors.len >0 {
		// 				max_nn = array_max(nearest_neighbors)
		// 				sum_nn = array_sum(nearest_neighbors)
		// 				// average of non-maximum values
		// 				avg_nn = (sum_nn - max_nn) / (nearest_neighbors.len - 1)
		// 				// println('i_nn: $i_nn max_nn: $max_nn sum_nn: $sum_nn avg_nn: $avg_nn')
		// 				// get ratio
		// 				// println(max_nn / avg_nn)
		// 				ratios_array << (max_nn / avg_nn)
		// 			} else {
		// 				ratios_array << 0
		// 			}
		// 			// println('ratios_array: $ratios_array')
		// 			final_cr.inferred_class = inferred_class_array[idx_max(ratios_array)]

		// 		}
		// 		// println(cl0.classes[idx_max(nearest_neighbors_array[idx_max(ratios_array)])])
		// 		// final_cr.inferred_class = cl.classes[idx_max(mcr.nearest_neighbors_array[idx_max(ratios_array)])]
		// 	}
		println('$index $nearest_neighbors_array $inferred_class_array inferred_class: $final_cr.inferred_class')
	} else {
		final_cr.inferred_class = uniques(inferred_class_array)[0]
	}
	return final_cr
}

// resolve_conflict
fn resolve_conflict(inferred_class_array []string, nearest_neighbors_array [][]int) string {
	zero_nn := nearest_neighbors_array.filter(0 in it).len
	match true {
		// if the number of inferred classes is an odd number, pick
		// the winner
		inferred_class_array.len % 2 != 0 {
			return get_map_key_for_max_value(string_element_counts(inferred_class_array))
		}
		// if only one of the nearest neighbors lists has entries,
		// use that inferred class
		uniques(inferred_class_array).filter(it != '').len == 1 {
			return uniques(inferred_class_array).filter(it != '')[0]
		}
		// if only one of the nearest neighbors lists has a zero, use that
		// inferred class
		zero_nn == 1 {
			// println(inferred_class_array[idx_true(nearest_neighbors_array.map(0 in it))])
			return inferred_class_array[idx_true(nearest_neighbors_array.map(0 in it))]
		}
		zero_nn > 1 {
			// 	when there are 2 or more results with zeros, pick the
			// 	result having the largest maximum, and use that maximum
			// 	to get the inferred class
			println(nearest_neighbors_array.map(array_max(it)))
			println(idx_max(nearest_neighbors_array.map(array_max(it))))
			// println(classifiers[i].classes[idx_max(nearest_neighbors_array[idx_max(nearest_neighbors_array.map(array_max(it)))])])
			// classifiers[i].classes[idx_max(nearest_neighbors_array[idx_max(nearest_neighbors_array.map(array_max(it)))])]
			return inferred_class_array[idx_true(nearest_neighbors_array.map(0 in it))]
		}
		else {
			// when none of the results have zeros in them, pick the
			// result having the largest ratio of its maximum to the
			// average of the other nearest neighbor counts
			mut max_nn := 0
			mut sum_nn := 0
			mut avg_nn := 0.0
			mut ratios_array := []f64{}

			for nearest_neighbors in nearest_neighbors_array {
				// i_nn := idx_max(nearest_neighbors)
				if nearest_neighbors.len > 0 {
					max_nn = array_max(nearest_neighbors)
					sum_nn = array_sum(nearest_neighbors)
					// average of non-maximum values
					avg_nn = (sum_nn - max_nn) / (nearest_neighbors.len - 1)
					// println('i_nn: $i_nn max_nn: $max_nn sum_nn: $sum_nn avg_nn: $avg_nn')
					// get ratio
					// println(max_nn / avg_nn)
					ratios_array << (max_nn / avg_nn)
				} else {
					ratios_array << 0
				}
				// println('ratios_array: $ratios_array')
			}
			return inferred_class_array[idx_max(ratios_array)]
			// println(cl0.classes[idx_max(nearest_neighbors_array[idx_max(ratios_array)])])
			// final_cr.inferred_class = cl.classes[idx_max(mcr.nearest_neighbors_array[idx_max(ratios_array)])]
		}
	}
}

fn get_map_key_for_max_value(m map[string]int) string {
	max := array_max(m.values())
	for key, val in m {
		if val == max {
			return key
		}
	}
	return ''
}
