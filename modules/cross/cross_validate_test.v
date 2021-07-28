// cross_validate_test.v
module cross

import tools

// test_cross_validate
fn test_cross_validate() {
	mut opts := tools.Options{
		bins: [21, 21]
		exclude_flag: false
		verbose_flag: false
		number_of_attributes: [28]
		show_flag: true
		datafile_path: 'datasets/anneal.tab'
		concurrency_flag: false
	}
	mut ds := tools.load_file(opts.datafile_path)
	// assert cross_validate(ds, opts).correct_count == 881

	opts.weighting_flag = true
	// assert cross_validate(ds, opts).correct_count == 876

	opts.datafile_path = 'datasets/developer.tab'
	opts.number_of_attributes = [2]
	opts.bins = [3,3]
	opts.folds = 0
	ds = tools.load_file(opts.datafile_path)
	assert cross_validate(ds, opts).correct_count == 11

	opts.datafile_path = 'datasets/iris.tab'
	opts.number_of_attributes = [2]
	opts.bins = [3, 3]
	opts.folds = 0
	ds = tools.load_file(opts.datafile_path)
	// assert cross_validate(ds, opts).correct_count == 147

	opts.datafile_path = 'datasets/breast-cancer-wisconsin-disc.tab'
	opts.number_of_attributes = [9]
	ds = tools.load_file(opts.datafile_path)
	// assert cross_validate(ds, opts).correct_count == 672

	opts.datafile_path = 'datasets/mnist_test.tab'
	opts.number_of_attributes = [310]
	opts.bins = [2, 2]
	opts.folds = 200
	opts.weighting_flag = false
	ds = tools.load_file(opts.datafile_path)
	// assert cross_validate(ds, opts).correct_count == 9420
}
