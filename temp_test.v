// temp_test.v
module hamnn

// test_explore_cross
fn test_explore_cross() {
	mut results := ExploreResult{}
	mut opts := Options{
		verbose_flag: false
		number_of_attributes: [2, 7]
		bins: [2, 8]
		show_flag: false
		expanded_flag: false
		graph_flag: true
		weighting_flag: true
		exclude_flag: true
		concurrency_flag: true
		uniform_bins: true
		folds: 10
		repetitions: 50
		random_pick: true
		datafile_path: 'datasets/developer.tab'
	}
	results = explore(load_file(opts.datafile_path), opts)

	// opts.bins = [3, 4]
	// opts.number_of_attributes = [2, 3]
	results = explore(load_file(opts.datafile_path), opts)

	// opts.datafile_path = 'datasets/bcw350train'
	// opts.testfile_path = 'datasets/bcw174test'
	// opts.number_of_attributes = [0]


	results = explore(load_file(opts.datafile_path), opts)
}
