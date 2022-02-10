// classify.v
module hamnn

import arrays

// classify_instance takes a trained classifier and an instance to be
// classified and returns the inferred class for the instance.
// The classification algorithm gets Hamming distances between the instance
// to be classified and all the instances in the trained classifier, and
// infers class based on minimum Hamming distance.
// ```sh
// Optional (specified in opts):
// weighting_flag: when true, the nearest neighbor algorithm takes into
// 		account class prevalences.
// ```
pub fn classify_instance(cl Classifier, instance_to_be_classified []byte, opts Options) ClassifyResult {
	// to classify, get Hamming distances between the entered instance and
	// all the instances in the classifier; return the class for the instance
	// giving the lowest Hamming distance.
	mut hamming_dist_array := []int{}
	mut hamming_dist := 0
	mut classify_result := ClassifyResult{}
	// get the hamming distance for each of the corresponding byte_values
	// in each classifier instance and the instance to be classified
	for instance in cl.instances {
		hamming_dist = 0
		for i, byte_value in instance_to_be_classified {
			hamming_dist += get_hamming_distance(byte_value, instance[i])
		}
		hamming_dist_array << hamming_dist
	}
	// hamming_dist_array gives the hamming distance for each instance
	// in the classifier, to the instance to be classified
	// get counts of unique hamming distance values and sort
	counts := integer_element_counts(hamming_dist_array)

	// println('counts: $counts')

	mut distances := get_integer_keys(counts)
	distances.sort()
	// we now have in distances, the unique hamming distance values between
	// the classifier instances and the instance to be classified, sorted
	// by ascending hamming distance (ie, minimum hamming distance is first).
	// for each distance in distances, get the classes for instances this
	// distance away; note that we want to continue in this loop only while
	// we cannot get a unique class
	// first, get an array of unique class values
	classes := get_string_keys(string_element_counts(cl.class_values))
	max_distance := arrays.max(distances) or { 255 }
	mut results := [][]int{len: (max_distance + 1), init: []int{len: cl.class_counts.len}}
	// cycle through the unique hamming distances, starting with the minimm
	for i, dist in distances {
		for j, instance_dist in hamming_dist_array {
			for k, class in classes {
				// println('j, k: $j $k')
				if dist == instance_dist && class == cl.class_values[j] {
					// println('j, k: $j $k')
					results[i][k] += 1
				}
			}
		}
		// if the weighting_flag is set, multiply each value in the results
		// row by the least common multiple (lcm) of the prevalences of the
		// classes, and then
		// divide by the prevalence of the associated class, in order to
		// weight the numbers by class prevalences
		if opts.weighting_flag {
			if opts.verbose_flag && opts.command == 'classify' {
				println('nearest neighbors by class unweighted in classify.v: ${results[i]}')
				println('lcm_class_counts: $cl.lcm_class_counts')
			}
			for n, mut val in results[i] {
				val *= int(cl.lcm_class_counts / cl.class_counts[classes[n]])
			}
		}
		// look for a single maximum; if found, return its class
		index, max_count := idx_count_max(results[i])
		if max_count == 1 {
			classify_result = ClassifyResult{
				inferred_class: classes[index]
				nearest_neighbors_by_class: results[i]
				classes: cl.class_counts.keys()
				weighting_flag: opts.weighting_flag
			}
			break
		}
	}
	if opts.verbose_flag && opts.command == 'classify' {
		println('ClassifyResult in classify.v: $classify_result')
	}
	return classify_result
}

// get_hamming_distance returns hamming distance between left and right,
// when both left and right are values which can be represented by a single
// bit if a bitstring were created
fn get_hamming_distance<T>(left T, right T) int {
	if left == right {
		return 0
	}
	if left == byte(0) || right == byte(0) {
		return 1
	}
	return 2
}

// idx_count_max returns the index of the first maximum and the count
// of that maximum
fn idx_count_max<T>(a []T) (int, int) {
	if a.len == 0 {
		panic('.idx_count_max called on an empty array')
	}
	mut idx := 0
	mut val := a[0] // so that val has the right type
	val = 0
	mut count := 0
	for i, e in a {
		if e > val {
			val = e
			idx = i
		}
	}
	for e in a {
		if e == val {
			count += 1
		}
	}
	return idx, count
}
