// cross_validate_test.v
module cross

import tools

// test_cross_validate
fn test_cross_validate() {
	mut opts := tools.Options{
		command: 'cross'
		exclude_flag: false
		verbose_flag: false
		show_flag: false
		concurrency_flag: true
	}

	opts.datafile_path = 'datasets/developer.tab'
	opts.number_of_attributes = [2]
	opts.bins = [3, 3]
	opts.folds = 0
	mut ds := tools.load_file(opts.datafile_path)
	mut result := cross_validate(ds, opts)
	assert result.correct_count == 11
	assert result.misses_count == 2
	assert result.wrong_count == 3
	assert result.total_count == 13

	opts.datafile_path = 'datasets/iris.tab'
	opts.number_of_attributes = [2]
	opts.bins = [3, 3]
	opts.folds = 0
	ds = tools.load_file(opts.datafile_path)
	result = cross_validate(ds, opts)
	assert result.correct_count == 148
	assert result.misses_count == 2
	assert result.wrong_count == 3
	assert result.total_count == 150

	opts.datafile_path = 'datasets/breast-cancer-wisconsin-disc.tab'
	opts.number_of_attributes = [9]
	ds = tools.load_file(opts.datafile_path)
	result = cross_validate(ds, opts)
	assert result.correct_count == 671
	assert result.misses_count == 28
	assert result.wrong_count == 29
	assert result.total_count == 699

	opts.datafile_path = 'datasets/anneal.tab'
	opts.number_of_attributes = [7]
	opts.bins = [14, 14]
	opts.weighting_flag = false
	ds = tools.load_file(opts.datafile_path)
	result = cross_validate(ds, opts)
	assert result.correct_count == 886
	assert result.misses_count == 12
	assert result.wrong_count == 13
	assert result.total_count == 898

	opts.weighting_flag = true
	result = cross_validate(ds, opts)
	assert result.correct_count == 884
	assert result.misses_count == 14
	assert result.wrong_count == 15
	assert result.total_count == 898

	opts.datafile_path = 'datasets/mnist_test.tab'
	opts.number_of_attributes = [310]
	opts.bins = [2, 2]
	opts.folds = 200
	opts.weighting_flag = false
	ds = tools.load_file(opts.datafile_path)
	result = cross_validate(ds, opts)
	assert result.correct_count == 9420
	assert result.wrong_count == 580
}

// test_append_map_values
fn test_append_map_values() {
	mut a := {
		'm': 3
		'f': 0
		'X': 1
	}
	b := {
		'm': 4
		'f': 5
		'X': 0
	}
	assert append_map_values(mut a, b) == {
		'm': 7
		'f': 5
		'X': 1
	}
}
