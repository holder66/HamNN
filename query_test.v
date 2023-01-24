// query_test.v
module hamnn

// test_query
fn test_query() ? {
	mut opts := Options{
		number_of_attributes: [2]
		bins: [2, 2]
		exclude_flag: false
		verbose_flag: false
	}
	mut ds := load_file('datasets/developer.tab')
	mut cl := make_classifier(mut ds, opts)
	// println(query(cl, opts))
}
