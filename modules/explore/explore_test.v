// explore_test.v
module explore

import tools

// test_explore
fn test_explore_cross() {
	mut opts := tools.Options{
		verbose_flag: false
		number_of_attributes: [1, 4]
		bins: [2, 12]
		show_flag: false
		concurrency_flag: true
		datafile_path: 'datasets/iris.tab'
	}
	mut ds := tools.load_file(opts.datafile_path)
	explore(ds, opts)

	opts.folds = 10
	opts.datafile_path = 'datasets/anneal.tab'
	ds = tools.load_file(opts.datafile_path)
	// explore(ds, opts)
}

// test_explore_verify 
fn test_explore_verify() {
	println('we are at test_explore_verify')
	mut opts := tools.Options{
		concurrency_flag: true 
		testfile_path: 'datasets/bcw174test'
		datafile_path: 'datasets/bcw350train'
	}
	mut ds := tools.load_file(opts.datafile_path)
	mut results := explore(ds, opts)
	assert results[7].correct_count == 169
}
