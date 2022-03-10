// explore_test.v
module hamnn

fn test_explore_cross() ? {
	mut result := ExploreResult{}
	mut metrics := Metrics{}
	mut opts := Options{
		verbose_flag: false
		number_of_attributes: [1, 4]
		bins: [2, 7]
		show_flag: false
		concurrency_flag: true
		uniform_bins: true
		datafile_path: 'datasets/iris.tab'
	}
	mut ds := load_file(opts.datafile_path)
	result = explore(ds, opts) ?
	assert result.array_of_results[0].correct_count == 99
	assert result.array_of_results[0].incorrects_count == 51
	assert result.array_of_results[0].wrong_count == 51
	assert result.array_of_results[0].total_count == 150
	metrics = get_metrics(result.array_of_results[0]) ?
	assert metrics.balanced_accuracy >= 0.66

	opts.uniform_bins = false
	opts.bins = [10, 12]
	result = explore(ds, opts) ?
	assert result.array_of_results.last().correct_count == 141
	assert result.array_of_results.last().incorrects_count == 9
	assert result.array_of_results.last().wrong_count == 9
	assert result.array_of_results.last().total_count == 150
	metrics = get_metrics(result.array_of_results.last()) ?
	assert metrics.balanced_accuracy >= 0.94
	println('Done with iris.tab')

	opts.folds = 10
	opts.number_of_attributes = [27, 29]
	opts.bins = [20, 22]
	opts.weighting_flag = true
	opts.datafile_path = 'datasets/anneal.tab'
	opts.uniform_bins = true
	ds = load_file(opts.datafile_path)
	result = explore(ds, opts) ?
	metrics = get_metrics(result.array_of_results[1]) ?
	assert metrics.balanced_accuracy >= 0.96

	opts.uniform_bins = false
	result = explore(ds, opts) ?
	metrics = get_metrics(result.array_of_results[1]) ?
	assert metrics.balanced_accuracy >= 0.955

	opts.folds = 5
	opts.repetitions = 50
	result = explore(ds, opts) ?
	metrics = get_metrics(result.array_of_results[1]) ?
	assert metrics.balanced_accuracy >= 0.945
	println('Done with anneal.tab')
}

fn test_explore_verify() ? {
	mut opts := Options{
		// verbose_flag: true
		command: 'explore'
		concurrency_flag: true
		weighting_flag: true
		testfile_path: 'datasets/bcw174test'
		datafile_path: 'datasets/bcw350train'
	}
	mut ds := load_file(opts.datafile_path)
	mut result := explore(ds, opts) ?
	assert result.array_of_results[7].correct_count == 170
	assert result.array_of_results[7].wrong_count == 4
}
