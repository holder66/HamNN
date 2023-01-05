// rank_test.v
module hamnn

// test_sum_along_row_unweighted
fn test_sum_along_row_unweighted() {
	assert sum_along_row_unweighted([]int{}) == 0
	assert sum_along_row_unweighted([0]) == 0
	assert sum_along_row_unweighted([2, 3, 4]) == 4
	assert sum_along_row_unweighted([-2, 3, -4]) == 14
	assert sum_along_row_unweighted([0, 0, 8]) == 16
}

// test_sum_along_row_uweighted
fn test_sum_along_row_weighted() {
	cca := [4, 8, 3]
	assert sum_along_row_weighted([0], cca) == 0
	assert sum_along_row_weighted([2, 3, 4], cca) == 37
	assert sum_along_row_weighted([-2, 3, -4], cca) == 79
	assert sum_along_row_weighted([0, 0, 8], cca) == 96
}

// test_rank_attributes
fn test_rank_attributes() {
	mut opts := Options{
		bins: [3, 3]
		exclude_flag: true
		weight_ranking_flag: true
	}
	mut ds := load_file('datasets/developer.tab')
	mut rank_value := rank_attributes(ds, opts).array_of_ranked_attributes[1].rank_value
	assert rank_value >= 66.30434
	assert rank_value <= 66.30435
	opts.exclude_flag = false
	assert rank_attributes(ds, opts).array_of_ranked_attributes[2].attribute_name == 'lastname'
	opts.bins = [2, 16]
	assert rank_attributes(ds, opts).array_of_ranked_attributes[7].attribute_index == 7
	opts.exclude_flag = true
	rank_value = rank_attributes(ds, opts).array_of_ranked_attributes[0].rank_value
	assert rank_value >= 95.65217
	assert rank_value <= 95.65219
	ds = load_file('datasets/anneal.tab')
	assert rank_attributes(ds, opts).array_of_ranked_attributes[3].attribute_name == 'formability'
	opts.bins = [2, 2]
	ds = load_file('datasets/mnist_test.tab')
	rank_value = rank_attributes(ds, opts).array_of_ranked_attributes[0].rank_value
	assert rank_value >= 38.08885
	assert rank_value <= 38.08886

	opts.weight_ranking_flag = false
	ds = load_file('datasets/developer.tab')
	rank_value = rank_attributes(ds, opts).array_of_ranked_attributes[1].rank_value
	assert rank_value >= 69.23077
	assert rank_value <= 69.23078
	opts.exclude_flag = false
	assert rank_attributes(ds, opts).array_of_ranked_attributes[2].attribute_name == 'city'
	opts.bins = [2, 16]
	assert rank_attributes(ds, opts).array_of_ranked_attributes[7].attribute_index == 6
	opts.exclude_flag = true
	rank_value = rank_attributes(ds, opts).array_of_ranked_attributes[0].rank_value
	assert rank_value >= 92.30769
	assert rank_value <= 92.30770
	ds = load_file('datasets/anneal.tab')
	assert rank_attributes(ds, opts).array_of_ranked_attributes[3].attribute_name == 'strength'
	opts.bins = [2, 2]
	ds = load_file('datasets/mnist_test.tab')
	rank_value = rank_attributes(ds, opts).array_of_ranked_attributes[0].rank_value
	assert rank_value >= 38.48
	assert rank_value <= 38.49
}

// test_get_rank_value_for_strings
fn test_get_rank_value_for_strings() {
	mut params := Parameters{
		exclude_flag: true
		weight_ranking_flag: true
	}
	mut ds := load_file('datasets/developer.tab')
	assert get_rank_value_for_strings(ds.data[1], ds.class_values, ds.class_counts, params) == 60
	assert get_rank_value_for_strings(ds.class_values, ds.class_values, ds.class_counts,
		params) == 92
	params.exclude_flag = false
	assert get_rank_value_for_strings(ds.class_values, ds.class_values, ds.class_counts,
		params) == 92
	params.weight_ranking_flag = false
	assert get_rank_value_for_strings(ds.data[1], ds.class_values, ds.class_counts, params) == 18
	assert get_rank_value_for_strings(ds.class_values, ds.class_values, ds.class_counts,
		params) == 26
	params.exclude_flag = false
	assert get_rank_value_for_strings(ds.class_values, ds.class_values, ds.class_counts,
		params) == 26
	ds = load_file('datasets/anneal.tab')
	params.exclude_flag = true
	params.weight_ranking_flag = true
	assert get_rank_value_for_strings(ds.class_values, ds.class_values, ds.class_counts,
		params) == 322594
	params.weight_ranking_flag = false
	assert get_rank_value_for_strings(ds.class_values, ds.class_values, ds.class_counts,
		params) == 3592
}

// test_rank_attribute_sorting
fn test_rank_attribute_sorting() {
	mut opts := Options{
		weight_ranking_flag: true
	}
	mut ds := load_file('datasets/developer.tab')
	mut result := rank_attributes(ds, opts)
	mut atts := []string{}
	for att in result.array_of_ranked_attributes {
		atts << att.attribute_name
	}
	assert atts == ['height', 'negative', 'weight', 'number', 'age', 'lastname', 'SEC', 'city']
	atts = []
	opts.bins = [3, 3]
	result = rank_attributes(ds, opts)
	for att in result.array_of_ranked_attributes {
		atts << att.attribute_name
	}
	assert atts == ['height', 'negative', 'lastname', 'number', 'SEC', 'city', 'age', 'weight']
	atts = []
	opts.bins = [4, 9]
	result = rank_attributes(ds, opts)
	for att in result.array_of_ranked_attributes {
		atts << att.attribute_name
	}
	assert atts == ['height', 'number', 'weight', 'negative', 'age', 'lastname', 'SEC', 'city']
	opts.weight_ranking_flag = false
	result = rank_attributes(ds, opts)
	atts = []
	for att in result.array_of_ranked_attributes {
		atts << att.attribute_name
	}
	assert atts == ['height', 'weight', 'number', 'negative', 'age', 'lastname', 'city', 'SEC']
	atts = []
	opts.bins = [3, 3]
	result = rank_attributes(ds, opts)
	for att in result.array_of_ranked_attributes {
		atts << att.attribute_name
	}
	assert atts == ['height', 'lastname', 'city', 'SEC', 'age', 'number', 'negative', 'weight']
	atts = []
	opts.bins = [4, 9]
	result = rank_attributes(ds, opts)
	for att in result.array_of_ranked_attributes {
		atts << att.attribute_name
	}
	assert atts == ['height', 'weight', 'number', 'negative', 'age', 'lastname', 'city', 'SEC']
}
