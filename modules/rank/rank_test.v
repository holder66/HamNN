// rank__test.v
module rank

import tools

// test_rank_attributes
fn test_rank_attributes() {
	mut opts := tools.Options{
		bins: [3, 3]
		exclude_flag: true
	}
	mut ds := tools.load_file('datasets/developer.tab')
	mut rank_value := rank_attributes(ds, opts)[1].rank_value
	assert rank_value >= 65.26315
	assert rank_value <= 65.26317
	opts.exclude_flag = false
	assert rank_attributes(ds, opts)[2].attribute_name == 'number'
	opts.bins = [2, 16]
	assert rank_attributes(ds, opts)[7].attribute_index == 7
	opts.exclude_flag = true
	rank_value = rank_attributes(ds, opts)[0].rank_value
	assert rank_value >= 94.73683
	assert rank_value <= 94.73684
	ds = tools.load_file('datasets/anneal.tab')
	assert rank_attributes(ds, opts)[3].attribute_name == 'hardness'
	opts.bins = [2, 2]
	ds = tools.load_file('datasets/mnist_test.tab')
	rank_value = rank_attributes(ds, opts)[0].rank_value
	assert rank_value >= 38.13513
	assert rank_value <= 38.13514
	// ds = tools.load_file('datasets/mnist_train.tab')
	// assert rank_attributes(ds, opts)[1].rank_value == 35.861344890805036
}

// test_get_rank_value_for_strings
fn test_get_rank_value_for_strings() {
	mut ds := tools.load_file('datasets/developer.tab')
	assert get_rank_value_for_strings(ds.data[1], ds.class_values, ds.class_counts, true) == 61
	assert get_rank_value_for_strings(ds.class_values, ds.class_values, ds.class_counts,
		true) == 95
	assert get_rank_value_for_strings(ds.class_values, ds.class_values, ds.class_counts,
		false) == 95
	ds = tools.load_file('datasets/anneal.tab')
	assert get_rank_value_for_strings(ds.class_values, ds.class_values, ds.class_counts,
		true) == 315337
}
