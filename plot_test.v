// plot_test.v
// for some reason, we are unable to actually generate plots from this code.
// It seems using the vhamm CLI is the only way to have plots actually show up.

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

// test_rank_attributes_plot
fn test_rank_attributes_plot() {
	mut result := RankingResult{}
	mut opts := Options{
		datafile_path: 'datasets/developer.tab'
		graph_flag: true
		command: 'rank'
	}
	result = rank_attributes(load_file(opts.datafile_path), opts)
	opts.exclude_flag = true
	result = rank_attributes(load_file(opts.datafile_path), opts)
	opts.exclude_flag = false
	opts.datafile_path = 'datasets/anneal.tab'
	result = rank_attributes(load_file(opts.datafile_path), opts)
	opts.exclude_flag = true
	result = rank_attributes(load_file(opts.datafile_path), opts)
}

// test_explore_plot
fn test_explore_plot() ? {
	mut results := ExploreResult{}
	mut opts := Options{
		command: 'explore'
		// number_of_attributes: [2, 7]
		bins: [3, 7]
		show_flag: true
		// expanded_flag: true
		graph_flag: true
		weighting_flag: true
		exclude_flag: true
		concurrency_flag: true
		// uniform_bins: true
		purge_flag: true
		// folds: 10
		// repetitions: 50
		// random_pick: true
		// datafile_path: 'datasets/2_class_developer.tab'
	}
	// cross with 2 classes (generates ROC plots)
	// results = explore(load_file(opts.datafile_path), opts)?

	// test for cross with more than 2 classes
	opts.datafile_path = 'datasets/iris.tab'
	results = explore(load_file(opts.datafile_path), opts)?

	// // verify with 2 classes (generates ROC plots)
	// opts.datafile_path = 'datasets/bcw350train'
	// opts.testfile_path = 'datasets/bcw174test'
	// opts.number_of_attributes = [0]

	// results = explore(load_file(opts.datafile_path), opts)?

	// // verify with more than 2 classes
	// opts.datafile_path = 'datasets/soybean-large-train.tab'
	// opts.testfile_path = 'datasets/soybean-large-test.tab'
	// opts.number_of_attributes = [0]

	// results = explore(load_file(opts.datafile_path), opts)?
}
