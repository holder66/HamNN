// cross_validate_test.v
module hamnn

// test_cross_validate
fn test_cross_validate() ? {
	mut ds := Dataset{}
	mut opts := Options{
		command: 'cross'
		exclude_flag: false
		verbose_flag: false
		show_flag: false
		expanded_flag: false
		concurrency_flag: true
	}
	mut result := CrossVerifyResult{}

	opts.datafile_path = 'datasets/anneal.tab'
	opts.number_of_attributes = [28]
	opts.bins = [21, 21]
	opts.folds = 10
	opts.repetitions = 10
	opts.random_pick = true
	ds = load_file(opts.datafile_path)
	result = cross_validate(ds, opts) ?
	assert result.correct_count >= 878 && result.correct_count <= 883

	opts.weighting_flag = true
	result = cross_validate(ds, opts) ?
	assert result.correct_count >= 870 && result.correct_count <= 883

	opts.datafile_path = 'datasets/developer.tab'
	opts.number_of_attributes = [2]
	opts.bins = [3, 3]
	opts.folds = 4
	opts.weighting_flag = false
	opts.repetitions = 2
	opts.random_pick = false
	ds = load_file(opts.datafile_path)
	result = cross_validate(ds, opts) ?
	assert result.total_count == 13

	opts.concurrency_flag = false

	opts.datafile_path = 'datasets/developer.tab'
	opts.number_of_attributes = [2]
	opts.bins = [3, 3]
	opts.folds = 2
	opts.weighting_flag = true
	ds = load_file(opts.datafile_path)
	result = cross_validate(ds, opts) ?
	assert result.total_count == 13
	// assert result.confusion_matrix_map == {'m': {'m': 8, 'f': 0, 'X': 0}, 'f': {'m': 2, 'f': 1, 'X': 0}, 'X': {'m': 0, 'f': 1, 'X': 1}}

	opts.datafile_path = 'datasets/developer.tab'
	opts.number_of_attributes = [2]
	opts.bins = [3, 3]
	opts.folds = 3
	ds = load_file(opts.datafile_path)
	result = cross_validate(ds, opts) ?
	assert result.total_count == 13

	opts.concurrency_flag = true

	opts.datafile_path = 'datasets/developer.tab'
	opts.number_of_attributes = [2]
	opts.bins = [3, 3]
	opts.folds = 4
	ds = load_file(opts.datafile_path)
	result = cross_validate(ds, opts) ?
	assert result.correct_count == 9
	assert result.incorrects_count == 4
	assert result.wrong_count == 4
	assert result.total_count == 13

	opts.datafile_path = 'datasets/iris.tab'
	opts.number_of_attributes = [2]
	opts.bins = [3, 3]
	opts.folds = 0
	ds = load_file(opts.datafile_path)
	result = cross_validate(ds, opts) ?
	assert result.correct_count == 147
	assert result.incorrects_count == 3
	assert result.wrong_count == 3
	assert result.total_count == 150

	opts.datafile_path = 'datasets/breast-cancer-wisconsin-disc.tab'
	opts.number_of_attributes = [9]
	ds = load_file(opts.datafile_path)
	result = cross_validate(ds, opts) ?
	assert result.correct_count == 672
	assert result.incorrects_count == 27
	assert result.wrong_count == 27
	assert result.total_count == 699

	// if get_environment().arch_details[0] != '4 cpus' {
	// 	opts.concurrency_flag = true
	// 	opts.datafile_path = 'datasets/mnist_test.tab'
	// 	opts.number_of_attributes = [310]
	// 	opts.bins = [2, 2]
	// 	opts.folds = 20
	// 	opts.repetitions = 5
	// 	opts.random_pick = true
	// 	opts.weighting_flag = false
	// 	ds = load_file(opts.datafile_path)
	// 	result = cross_validate(ds, opts) ?
	// 	assert result.correct_count > 9400
	// }
}
