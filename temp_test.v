// temp_test.v
module hamnn

// test_explore_cross 
fn test_explore_cross() {
	mut results := ExploreResult{}
	mut opts := Options{
		verbose_flag: false
		number_of_attributes: [1, 4]
		bins: [2, 7]
		show_flag: true
		expanded_flag: true
		weighting_flag: true
		exclude_flag: true
		concurrency_flag: true
		uniform_bins: true
		// folds: 10
		// repetitions: 50
		random_pick: true
		datafile_path: 'datasets/iris.tab'
		
	}
	mut ds := load_file(opts.datafile_path)
	results = explore(ds, opts)

	opts.datafile_path = 'datasets/bcw350train'
	opts.testfile_path = 'datasets/bcw174test'

	ds = load_file(opts.datafile_path)
	results = explore(ds, opts)

	// println(results)
}