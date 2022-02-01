// classify.v
module classify

import tools
// import arrays

// classify_instance takes a trained classifier and an instance to be
// classified and returns the inferred class for the instance.
// The classification algorithm gets Hamming distances between the instance
// to be classified and all the instances in the trained classifier, and
// infers class based on minimum Hamming distance.
pub fn classify_instance(cl tools.Classifier, instance_to_be_classified []byte, opts tools.Options) tools.ClassifyResult {
	// to classify, get Hamming distances between the entered instance and
	// all the instances in the classifier; return the class for the instance
	// giving the lowest Hamming distance.
	// mut lcm_class_counts := i64(0)
	// if opts.weighting_flag {
	// 	lcm_class_counts = i64(tools.lcm(tools.get_map_values(cl.class_counts)))
	// }
	mut results := [][]int{len: 10000, init: []int{len: cl.class_counts.len}}
	// mut results := [][]int{}

	mut hamming_dist_array := []int{}
	mut hamming_dist := 0
	mut classify_result := tools.ClassifyResult{}
	for instance in cl.instances {
		hamming_dist = 0
		for i, byte_value in instance_to_be_classified {
			// println('i: $i')
			hamming_dist += get_hamming_distance(byte_value, instance[i])
		}
		hamming_dist_array << hamming_dist
	}
	// get counts of unique hamming distance values and sort
	counts := tools.integer_element_counts(hamming_dist_array)

	// println('counts: $counts')

	mut distances := tools.get_integer_keys(counts)
	distances.sort()

	// println('distances: $distances')

	// println(cl.class_values)
	// for each distance in distances, get the classes for instances this
	// distance away
	// first, get an array of unique class values
	classes := tools.get_string_keys(tools.string_element_counts(cl.class_values))
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
			classify_result = tools.ClassifyResult{
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
	mut dist := 0
	if left == right {
		dist = 0
	} else if left == byte(0) || right == byte(0) {
		dist = 1
	} else {
		dist = 2
	}
	return dist
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
