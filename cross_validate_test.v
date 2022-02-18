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
	ds = load_file(opts.datafile_path)
	result = cross_validate(ds, opts)
	assert result.correct_count == 881
	assert result.incorrects_count == 17
	assert result.wrong_count == 17
	assert result.total_count == 898

	opts.weighting_flag = true
	result = cross_validate(ds, opts)
	assert result.correct_count == 876
	assert result.incorrects_count == 22
	assert result.wrong_count == 22
	assert result.total_count == 898

	opts.datafile_path = 'datasets/developer.tab'
	opts.number_of_attributes = [2]
	opts.bins = [3, 3]
	opts.folds = 0
	opts.weighting_flag = false
	ds = load_file(opts.datafile_path)
	result = cross_validate(ds, opts)
	assert result.correct_count == 9
	assert result.incorrects_count == 4
	assert result.wrong_count == 4
	assert result.total_count == 13
	assert result.confusion_matrix == [
		['Predicted Classes (columns)', 'm', 'f', 'X'],
		['Actual Classes (rows)'],
		['m', '8', '0', '0'],
		['f', '2', '1', '0'],
		['X', '1', '1', '0'],
	]

	opts.concurrency_flag = false

	opts.datafile_path = 'datasets/developer.tab'
	opts.number_of_attributes = [2]
	opts.bins = [3, 3]
	opts.folds = 2
	opts.weighting_flag = true
	ds = load_file(opts.datafile_path)
	result = cross_validate(ds, opts)
	assert result.correct_count == 8
	assert result.incorrects_count == 5
	assert result.wrong_count == 5
	assert result.total_count == 13
	assert result.confusion_matrix == [
		['Predicted Classes (columns)', 'm', 'f', 'X'],
		['Actual Classes (rows)'],
		['m', '7', '1', '0'],
		['f', '2', '1', '0'],
		['X', '1', '1', '0'],
	]

	opts.datafile_path = 'datasets/developer.tab'
	opts.number_of_attributes = [2]
	opts.bins = [3, 3]
	opts.folds = 3
	ds = load_file(opts.datafile_path)
	result = cross_validate(ds, opts)
	assert result.correct_count == 12
	assert result.incorrects_count == 1
	assert result.wrong_count == 1
	assert result.total_count == 13

	opts.concurrency_flag = true

	opts.datafile_path = 'datasets/developer.tab'
	opts.number_of_attributes = [2]
	opts.bins = [3, 3]
	opts.folds = 4
	ds = load_file(opts.datafile_path)
	result = cross_validate(ds, opts)
	assert result.correct_count == 9
	assert result.incorrects_count == 4
	assert result.wrong_count == 4
	assert result.total_count == 13

	opts.datafile_path = 'datasets/iris.tab'
	opts.number_of_attributes = [2]
	opts.bins = [3, 3]
	opts.folds = 0
	ds = load_file(opts.datafile_path)
	result = cross_validate(ds, opts)
	assert result.correct_count == 147
	assert result.incorrects_count == 3
	assert result.wrong_count == 3
	assert result.total_count == 150

	opts.datafile_path = 'datasets/breast-cancer-wisconsin-disc.tab'
	opts.number_of_attributes = [9]
	ds = load_file(opts.datafile_path)
	result = cross_validate(ds, opts)
	assert result.correct_count == 672
	assert result.incorrects_count == 27
	assert result.wrong_count == 27
	assert result.total_count == 699

	if get_environment().arch_details[0] != '4 cpus' {
		opts.concurrency_flag = true
		opts.datafile_path = 'datasets/mnist_test.tab'
		opts.number_of_attributes = [310]
		opts.bins = [2, 2]
		opts.folds = 200
		opts.weighting_flag = false
		ds = load_file(opts.datafile_path)
		result = cross_validate(ds, opts)
		assert result.correct_count == 9420
		assert result.incorrects_count == 580
		assert result.wrong_count == 580
		assert result.total_count == 10000
	}
}
