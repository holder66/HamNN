// multiple.v

module hamnn
import arrays
import os
import json

pub struct ClassifierOptions {
	Binning
pub mut:
	number_of_attributes []int 
	uniform_bins         bool
	exclude_flag         bool
	multiple_flag 	bool
	purge_flag           bool
	weighting_flag       bool
}

pub struct MultipleOptions {
	classifier_options []ClassifierOptions
}

// read_multiple_opts 
fn read_multiple_opts(path string) ?MultipleOptions {
	s := os.read_file(path.trim_space()) or { panic('failed to open $path') }
	print(s)
	mut multiple_options := json.decode(MultipleOptions, s) or { panic('Failed to parse json') }
	return multiple_options
}
// when multiple classifiers have been generated with different settings, 
// a given instance to be classified will take multiple values, one for 
// each classifier, and corresponding to the settings for that classifier.
// multiple_classifier_classify
fn multiple_classifier_classify(index int, classifiers []Classifier, instances_to_be_classified [][]u8, opts Options) ClassifyResult {
	cl0 := classifiers[0]
	mut mcr := ClassifyResult{
		index: index 
		classes: cl0.class_values
	}
	// println(cl0.class_values)
	// to classify, get Hamming distances between the entered instance and
	// all the instances in all the classifiers; return the class for the 
	// instance giving the lowest Hamming distance.
	// println('instances_to_be_classified: $instances_to_be_classified')
	mut hamming_distances := []int{}
	mut hamming_dist_arrays := [][]int{}
	mut hamming_dist := 0
	mut number_of_attributes := []int{}
	for _ in classifiers {
		number_of_attributes << cl0.attribute_ordering.len
	}
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
		// multiply each value by the maximum number of attributes, and 
		// divide by this classifier's number of attributes
		hamming_dist_arrays << hamming_distances.map(it * maximum_number_of_attributes / cl.attribute_ordering.len)
	}
	// println('hamming_dist_arrays: $hamming_dist_arrays')
	

	// instead of doing this on the summed distances, which produces
	// terrible results, let's try it on each row individually
	mut radii := []int{}
	mut combined_radii := []int{}
	mut radius_row := []int{len: cl0.class_counts.len}
	// mut nearest_neighbors_array := [][]int{}
	// mut inferred_class_array := []string{}
	for row in hamming_dist_arrays {
		radii = uniques(row)
		// radii.sort()
		// println('sorted radii: $radii')
		combined_radii = arrays.merge(combined_radii, radii)

	}
	combined_radii = uniques(combined_radii)
	combined_radii.sort()
	// println('combined_radii: $combined_radii')
	for i, row in hamming_dist_arrays {
		for sphere_index, radius in combined_radii {
			if radius == cl0.class_counts.len * 2 {break}
			radius_row = radius_row.map(it - it)
			for class_index, class in cl0.classes {
				for instance, distance in row {
					if distance <= radius && class == cl0.class_values[instance] { radius_row[class_index] += 
						if !classifiers[i].weighting_flag {
							1
						} else {
							int(i64(lcm(get_map_values(cl0.class_counts))) / cl0.class_counts[cl0.classes[class_index]])
						}
					}
				}
			}
			// println('radius_row: $radius_row')
			if !single_array_maximum(radius_row) {continue}
			// println('sphere_index: $sphere_index')
			mcr.inferred_class = cl0.classes[idx_max(radius_row)]
			mcr.nearest_neighbors_by_class = radius_row
			mcr.weighting_flag = classifiers[i].weighting_flag
			mcr.hamming_distance = combined_radii[sphere_index]
			mcr.sphere_index = sphere_index
			break
		}
		mcr.nearest_neighbors_array << mcr.nearest_neighbors_by_class
		mcr.inferred_class_array << mcr.inferred_class
		// println('$i $mcr.nearest_neighbors_by_class $mcr.inferred_class')
	}
	// identify when there is disagreement between classifiers for 
	// the inferred class
	// mut i_nn := 0
	mut max_nn := 0
	mut sum_nn := 0
	mut avg_nn := 0.0
	mut ratios_array := []f64{}
	zero_nn := mcr.nearest_neighbors_array.filter(0 in it).len
	if mcr.inferred_class_array.len > 1 && uniques(mcr.inferred_class_array).len > 1 {
		println('$index $mcr.nearest_neighbors_array $mcr.inferred_class_array')
		// if only one of the nearest neighbors lists has a zero, use that
		// inferred class

		// println(zero_nn)
		match true {
			zero_nn == 1 {
				// println(inferred_class_array[idx_true(nearest_neighbors_array.map(0 in it))])
				mcr.inferred_class = mcr.inferred_class_array[idx_true(mcr.nearest_neighbors_array.map(0 in it))]
			}
			zero_nn > 1 {
				// when there are 2 or more results with zeros, pick the 
				// result having the largest maximum, and use that maximum
				// to get the inferred class
				// println(nearest_neighbors_array.map(array_max(it)))
				// println(idx_max(nearest_neighbors_array.map(array_max(it))))
				// println(cl0.classes[idx_max(nearest_neighbors_array[idx_max(nearest_neighbors_array.map(array_max(it)))])])
				mcr.inferred_class = cl0.classes[idx_max(mcr.nearest_neighbors_array[idx_max(mcr.nearest_neighbors_array.map(array_max(it)))])]
			}
			else {
				// when none of the results have zeros in them, pick the 
				// result having the largest ratio of its maximum to the 
				// average of the other nearest neighbor counts
				for nearest_neighbors in mcr.nearest_neighbors_array {
					// i_nn = idx_max(nearest_neighbors)
					max_nn = array_max(nearest_neighbors)
					sum_nn = array_sum(nearest_neighbors)
					// average of non-maximum values
					avg_nn = (sum_nn - max_nn) / (nearest_neighbors.len - 1)
					// println('i_nn: $i_nn max_nn: $max_nn sum_nn: $sum_nn avg_nn: $avg_nn')
					// get ratio 
					// println(max_nn / avg_nn)
					ratios_array << (max_nn / avg_nn)
				}
				// println(cl0.classes[idx_max(nearest_neighbors_array[idx_max(ratios_array)])])
				mcr.inferred_class = cl0.classes[idx_max(mcr.nearest_neighbors_array[idx_max(ratios_array)])]
			}
		}
	
	}
	return mcr
}
