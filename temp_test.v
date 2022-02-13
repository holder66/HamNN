// temp_test.v
module hamnn

// test_explore_cross 
fn test_explore_cross() {
	mut results := ExploreResult{}
	mut opts := Options{
		verbose_flag: false
		number_of_attributes: [2, 4]
		bins: [2,5]
		show_flag: true
		expanded_flag: false
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

	opts.expanded_flag = true
	opts.bins = [3,4]
	opts.number_of_attributes = [2,3]
	results = explore(load_file(opts.datafile_path), opts)

	opts.datafile_path = 'datasets/bcw350train'
	opts.testfile_path = 'datasets/bcw174test'
	opts.number_of_attributes = [0]

	results = explore(load_file(opts.datafile_path), opts)

	opts.expanded_flag = false
	results = explore(load_file(opts.datafile_path), opts)

}