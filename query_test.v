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
	mut cl := make_classifier(mut load_file('datasets/developer.tab'), opts)
	// println(query(cl, opts))
}
