// plot_test.v

module hamnn

// test_area_under_curve
fn test_area_under_curve() {
	mut x := []f64{}
	mut y := []f64{}
	x = [0.0, 1]
	y = [0.0, 1]
	assert area_under_curve(x, y) == 0.5
	x = [0.2, 0.4]
	y = [0.3, 0.4]
	assert area_under_curve(x, y) == 0.07
	x = [0.2, 0.3, 0.4]
	y = [0.5, 0.3, 0.1]
	assert area_under_curve(x, y) == 0.06
}

// test_explore_cross
fn test_explore_cross() {
	mut results := ExploreResult{}
	mut opts := Options{
		number_of_attributes: [2, 7]
		bins: [2, 8]
		show_flag: true
		expanded_flag: true
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
	// results = explore(load_file(opts.datafile_path), opts)

	opts.datafile_path = 'datasets/bcw350train'
	opts.testfile_path = 'datasets/bcw174test'
	opts.number_of_attributes = [0]

	results = explore(load_file(opts.datafile_path), opts)
}
