// classify_test.v
module classify

import tools
import make

// test_classify_instance
fn test_classify_instance() {
	mut opts := tools.Options{
		bins: [2, 12]
		exclude_flag: false
		verbose_flag: false
		command: 'classify'
		number_of_attributes: [6]
		show_flag: false
	}
	mut ds := tools.load_file('datasets/developer.tab')
	mut cl := make.make_classifier(ds, opts)
	assert classify_instance(cl, cl.instances[0], opts).inferred_class == 'm'
	assert classify_instance(cl, cl.instances[0], opts).nearest_neighbors_by_class == [
		1,
		0,
		0,
	]
	opts.weighting_flag = true
	cl = make.make_classifier(ds, opts)
	assert classify_instance(cl, cl.instances[3], opts).inferred_class == 'f'
	assert classify_instance(cl, cl.instances[3], opts).nearest_neighbors_by_class == [
		0,
		8,
		0,
	]
}

// test_idx_count_max
fn test_idx_count_max() {
	mut a, mut b := idx_count_max([12, 8, 12])
	assert a == 0 && b == 2
	a, b = idx_count_max([0, 1, 2, 3, 4, 5])
	assert a == 5 && b == 1
	a, b = idx_count_max([5])
	assert a == 0 && b == 1
	a, b = idx_count_max([0, 0, 0, 0])
	assert a == 0 && b == 4
}

// test_get_hamming_distance
fn test_get_hamming_distance() {
	assert get_hamming_distance(0, 0) == 0
	assert get_hamming_distance(0, 1) == 1
	assert get_hamming_distance(2, 0) == 1
	assert get_hamming_distance(1, 2) == 2
}
