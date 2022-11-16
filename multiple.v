// multiple.v

module hamnn

import arrays
import os
import json
// import math

pub struct MultipleOptions {
	classifier_options []Parameters
}

// read_multiple_opts
fn read_multiple_opts(path string) !MultipleOptions {
	s := os.read_file(path.trim_space()) or { panic('failed to open ${path}') }
	return json.decode(MultipleOptions, s)
}

struct RadiusResults {
	sphere_index int 
	hamming_distances_by_class []int 
	inferred_class_found []bool	
	inferred_class []string
}

struct MultipleClassifierResults {
	number_of_attributes []int 
	maximum_number_of_attributes int 
	lcm_attributes int 
	combined_radii []int 
	results_by_classifier []RadiusResults
}

// 2022-10-25: consider a different approach: what if we accumulated nearest
// neighbor counts for all possible values within each classifier, up until
// all classifiers have gotten to a decision. Since we will be a the same radius
// in each classifier, the numbers of nearest neighbor counts should be
// comparable (except cannot use purging, since that reduces total counts)

// when multiple classifiers have been generated with different settings,
// a given instance to be classified will take multiple values, one for
// each classifier, and corresponding to the settings for that classifier.
// Note that opts is not used at present
// multiple_classifier_classify
fn multiple_classifier_classify(index int, classifiers []Classifier, instances_to_be_classified [][]u8, opts Options) ClassifyResult {
	mut final_cr := ClassifyResult{
		index: index
		multiple_flag: true
		Class: classifiers[0].Class
	}
	// to classify, get Hamming distances between the entered instance and
	// all the instances in all the classifiers; return the class for the
	// instance giving the lowest Hamming distance.

	mut hamming_dist_arrays := [][]int{}
	mut number_of_attributes := []int{}

	// find the max number of attributes used
	for cl in classifiers {
		number_of_attributes << cl.attribute_ordering.len
	}
	maximum_number_of_attributes := array_max(number_of_attributes)
	lcm_attributes := lcm(number_of_attributes)

	// get the hamming distance for each of the corresponding byte_values
	// in each classifier instance and the instance to be classified
	// note that to compare hamming distances between classifiers using
	// different numbers of attributes, the distances need to be weighted.
	// mut lcm_attributes := lcm([25,29,8])
	println('lcm_attributes: ${lcm_attributes}')
	for i, cl in classifiers {
		final_cr.weighting_flag_array << cl.weighting_flag
		mut hamming_distances := []int{}
		for instance in cl.instances {
			mut hamming_dist := 0
			for j, byte_value in instances_to_be_classified[i] {
				hamming_dist += int(get_hamming_distance(byte_value, instance[j]) * lcm_attributes / number_of_attributes[i])
			}
			hamming_distances << hamming_dist
		}
		// println('hamming_distances: $hamming_distances')
		// multiply each value by the maximum number of attributes, and
		// divide by this classifier's number of attributes
		// println(hamming_distances.map(it * maximum_number_of_attributes / cl.attribute_ordering.len))
		// hamming_dist_arrays << hamming_distances.map(it * maximum_number_of_attributes / cl.attribute_ordering.len)
		hamming_dist_arrays << hamming_distances
	}
	// println('hamming_dist_arrays: $hamming_dist_arrays')
	mut combined_radii := []int{}

	// first, get a sorted list of all possible hamming distances
	for row in hamming_dist_arrays {
		combined_radii = arrays.merge(combined_radii, uniques(row))
	}
	combined_radii = uniques(combined_radii)
	combined_radii.sort()
	println('combined_radii: ${combined_radii}')

	// set up an array for noting when each classifier has gotten a result
	mut inferred_class_found := []bool{len: hamming_dist_arrays.len, init: false}

	mut nearest_neighbors_array := [][]int{cap: hamming_dist_arrays.len}
	mut inferred_class_array := []string{len: hamming_dist_arrays.len, init: ''}
	// for each possible hamming distance...
	radius_loop: for sphere_index, radius in combined_radii {
		nearest_neighbors_array = [][]int{cap: hamming_dist_arrays.len}
		inferred_class_array = []string{len: hamming_dist_arrays.len, init: ''}
		mut radius_row := []int{len: classifiers[i].class_counts.len}
		// cycle through each classifier...
		for i, row in hamming_dist_arrays {
			// cycle through each class...
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
							// 1
						}
					}
					// println('radius_row: $radius_row')
				}
			}
			nearest_neighbors_array << radius_row

			println('nearest_neighbors_array: ${nearest_neighbors_array}')
			if single_array_maximum(radius_row) {
				inferred_class_array[i] = classifiers[i].classes[idx_max(radius_row)]

				inferred_class_found[i] = true
			}
			println('inferred_class_array: ${inferred_class_array}')
			println('inferred_class_found: ${inferred_class_found}')
		}
		if inferred_class_found.all(it) {
			break radius_loop
		}
		// end of loop through classifiers
		final_cr.sphere_index = sphere_index
	} // end of loop through radii
	if inferred_class_array.all(it == '') {
		panic('failed to infer a class')
	}
	if inferred_class_array.len > 1 && uniques(inferred_class_array.filter(it != '')).len > 1 {
		final_cr.inferred_class = resolve_conflict(inferred_class_array, nearest_neighbors_array)

		println('instance: ${index} ${nearest_neighbors_array} ${inferred_class_array} inferred_class: ${final_cr.inferred_class}')
	} else {
		println('instance: ${index} ${nearest_neighbors_array} inferred_class_array: ${inferred_class_array}')
		final_cr.inferred_class = uniques(inferred_class_array.filter(it != ''))[0]
	}
	final_cr.inferred_class_array = inferred_class_array
	final_cr.nearest_neighbors_array = nearest_neighbors_array
	return final_cr
}

// resolve_conflict
fn resolve_conflict(inferred_class_array []string, nearest_neighbors_array [][]int) string {
	// return get_map_key_for_max_value(string_element_counts(inferred_class_array_filtered))
	// filter out the null classifier results
	inferred_class_array_filtered := inferred_class_array.filter(it != '')
	return get_map_key_for_max_value(string_element_counts(inferred_class_array_filtered))
	// nearest_neighbors_array_filtered := nearest_neighbors_array.filter(it.len == 0)
	// zero_nn := nearest_neighbors_array.filter(0 in it).len
	// println(uniques(inferred_class_array).filter(it != ''))
	// println(uniques(inferred_class_array).filter(it != '')[0])
	// match true {
	// if only one of the nearest neighbors lists has entries,
	// use that inferred class
	// inferred_class_array.filter(it != '').len == 1 {
	// 	println('only one entry in inferred class array')
	// 	return inferred_class_array.filter(it != '')[0]
	// }
	// if the number of inferred classes is an odd number, pick
	// the winner
	// inferred_class_array_filtered.len % 2 != 0 {
	// 	return get_map_key_for_max_value(string_element_counts(inferred_class_array_filtered))
	// }

	// if only one of the nearest neighbors lists has a zero, use that
	// inferred class
	// zero_nn == 1 {
	// 	println('only one entry has a zero')
	// return inferred_class_array[idx_max(nearest_neighbors_array.map(math.abs(it[0]-it[1])))]
	// 	// println(inferred_class_array[idx_true(nearest_neighbors_array.map(0 in it))])
	// 	// return inferred_class_array[idx_true(nearest_neighbors_array.map(0 in it))]
	// }

	// zero_nn > 1 {
	// 	// 	when there are 2 or more results with zeros, pick the
	// 	// 	result having the largest maximum, and use that maximum
	// 	// 	to get the inferred class
	// 	println(nearest_neighbors_array.map(array_max(it)))
	// 	println(idx_max(nearest_neighbors_array.map(array_max(it))))
	// 	// println(classifiers[i].classes[idx_max(nearest_neighbors_array[idx_max(nearest_neighbors_array.map(array_max(it)))])])
	// 	// classifiers[i].classes[idx_max(nearest_neighbors_array[idx_max(nearest_neighbors_array.map(array_max(it)))])]
	// 	return inferred_class_array[idx_true(nearest_neighbors_array.map(0 in it))]
	// }
	// else {
	// 	// when none of the results have zeros in them, pick the
	// 	// result having the largest ratio of its maximum to the
	// 	// average of the other nearest neighbor counts
	// 	mut max_nn := 0
	// 	mut sum_nn := 0
	// 	mut avg_nn := 0.0
	// 	mut ratios_array := []f64{}

	// 	for nearest_neighbors in nearest_neighbors_array {
	// 		// i_nn := idx_max(nearest_neighbors)
	// 		if nearest_neighbors.len > 0 {
	// 			max_nn = array_max(nearest_neighbors)
	// 			sum_nn = array_sum(nearest_neighbors)
	// 			// average of non-maximum values
	// 			avg_nn = (sum_nn - max_nn) / (nearest_neighbors.len - 1)
	// 			// println('i_nn: $i_nn max_nn: $max_nn sum_nn: $sum_nn avg_nn: $avg_nn')
	// 			// get ratio
	// 			// println(max_nn / avg_nn)
	// 			ratios_array << (max_nn / avg_nn)
	// 		} else {
	// 			ratios_array << 0
	// 		}
	// 		// println('ratios_array: $ratios_array')
	// 	}
	// 	return inferred_class_array[idx_max(nearest_neighbors_array.map(math.abs(it[0]-it[1])))]
	// 	// return inferred_class_array[idx_max(ratios_array)]
	// 	// println(cl0.classes[idx_max(nearest_neighbors_array[idx_max(ratios_array)])])
	// 	// final_cr.inferred_class = cl.classes[idx_max(mcr.nearest_neighbors_array[idx_max(ratios_array)])]
	// }
	// }
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
