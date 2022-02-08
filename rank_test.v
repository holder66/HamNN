// rank_test.v
module hamnn

// test_rank_attributes
// fn test_rank_attributes() {
// 	mut opts := Options{
// 		bins: [3, 3]
// 		exclude_flag: true
// 	}
// 	mut ds := load_file('datasets/developer.tab')
// 	mut rank_value := rank_attributes(ds, opts).array_of_ranked_attributes[1].rank_value
// 	assert rank_value >= 65.26315
// 	assert rank_value <= 65.26317
// 	opts.exclude_flag = false
// 	assert rank_attributes(ds, opts).array_of_ranked_attributes[2].attribute_name == 'number'
// 	opts.bins = [2, 16]
// 	assert rank_attributes(ds, opts).array_of_ranked_attributes[7].attribute_index == 7
// 	opts.exclude_flag = true
// 	rank_value = rank_attributes(ds, opts).array_of_ranked_attributes[0].rank_value
// 	assert rank_value >= 94.73683
// 	assert rank_value <= 94.73684
// 	ds = load_file('datasets/anneal.tab')
// 	assert rank_attributes(ds, opts).array_of_ranked_attributes[3].attribute_name == 'hardness'
// 	opts.bins = [2, 2]
// 	ds = load_file('datasets/mnist_test.tab')
// 	rank_value = rank_attributes(ds, opts).array_of_ranked_attributes[0].rank_value
// 	assert rank_value >= 38.13513
// 	assert rank_value <= 38.13514
	// ds = load_file('datasets/mnist_train.tab')
	// assert rank_attributes(ds, opts)[1].rank_value == 35.861344890805036
// }

// test_get_rank_value_for_strings
// fn test_get_rank_value_for_strings() {
// 	mut ds := load_file('datasets/developer.tab')
// 	assert get_rank_value_for_strings(ds.data[1], ds.class_values, ds.class_counts, true) == 61
// 	assert get_rank_value_for_strings(ds.class_values, ds.class_values, ds.class_counts,
// 		true) == 95
// 	assert get_rank_value_for_strings(ds.class_values, ds.class_values, ds.class_counts,
// 		false) == 95
// 	ds = load_file('datasets/anneal.tab')
// 	assert get_rank_value_for_strings(ds.class_values, ds.class_values, ds.class_counts,
// 		true) == 315337
// }

// test_rank_attribute_sorting 
fn test_rank_attribute_sorting() {
	mut opts := Options{}
	mut ds := load_file('datasets/developer.tab')
	mut result := rank_attributes(ds, opts)
	for att in result.array_of_ranked_attributes {
		println(att.attribute_name)
	}
opts.bins = [3,3]
result = rank_attributes(ds, opts)
	for att in result.array_of_ranked_attributes {
		println(att.attribute_name)
}
}
