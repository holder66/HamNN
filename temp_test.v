// temp_test.v
module hamnn

import os

fn testsuite_begin() ? {
	if os.is_dir('tempfolder') {
		os.rmdir_all('tempfolder') ?
	}
	os.mkdir_all('tempfolder') ?
}

fn testsuite_end() ? {
	os.rmdir_all('tempfolder') ?
}

// fn test_show_classifier
fn test_show_classifier() {
	println('test_show_classifier prints out classifiers for iris.tab and for anneal.tab')
	mut opts := Options{
		show_flag: true
		command: 'make'
		bins: [3, 10]
	}
	mut ds := load_file('datasets/developer.tab')
	mut cl := make_classifier(ds, opts)
	// opts.number_of_attributes = [8]
	// cl = make_classifier(load_file('datasets/anneal.tab'), opts)
}

// fn test_show_cross_validate() ? {
// 	mut ds := Dataset{}
// 	mut opts := Options{
// 		command: 'cross'
// 		exclude_flag: false
// 		verbose_flag: false
// 		show_flag: true
// 		expanded_flag: false
// 		concurrency_flag: true
// 	}
// 	mut result := CrossVerifyResult{}

// 	// start with binary classes, cross, -s

// 	opts.datafile_path = 'datasets/UCI/credit-g.arff'
// 	ds = load_file(opts.datafile_path)
// 	result = cross_validate(ds, opts) ?

// 	// repeat with -e

// 	opts.expanded_flag = true
// 	result = cross_validate(ds, opts) ?

// 	// multiclass, cross, -s

// 	opts.expanded_flag = false

// 	opts.datafile_path = 'datasets/UCI/anneal.arff'
// 	opts.number_of_attributes = [28]
// 	opts.bins = [21, 21]
// 	opts.folds = 10
// 	opts.repetitions = 10
// 	opts.random_pick = true
// 	ds = load_file(opts.datafile_path)
// 	result = cross_validate(ds, opts) ?

// 	// repeat with -e

// 	opts.expanded_flag = true
// 	result = cross_validate(ds, opts) ?
// }

// fn test_show_verify() ? {
// 	// now for verify, binary classes, -s
// 	mut opts := Options{
// 		command: 'verify'
// 		show_flag: true
// 		concurrency_flag: true
// 	}

// 	opts.datafile_path = 'datasets/bcw350train'
// 	opts.testfile_path = 'datasets/bcw174test'
// 	mut ds := Dataset{}
// 	mut cl := Classifier{}
// 	mut result := CrossVerifyResult{}

// 	ds = load_file(opts.datafile_path)
// 	cl = make_classifier(ds, opts)
// 	result = verify(cl, opts) ?

// 	// repeat with -e

// 	opts.expanded_flag = true
// 	result = verify(cl, opts) ?

// 	// for multiclass, -s
// 	opts.expanded_flag = false
// 	opts.datafile_path = 'datasets/soybean-large-train.tab'
// 	opts.testfile_path = 'datasets/soybean-large-test.tab'

// 	ds = load_file(opts.datafile_path)
// 	cl = make_classifier(ds, opts)
// 	result = verify(cl, opts) ?

// 	// repeat with -e

// 	opts.expanded_flag = true
// 	result = verify(cl, opts) ?
// }

// fn test_show_explore_cross_validate() ? {
// 	mut ds := Dataset{}
// 	mut opts := Options{
// 		command: 'explore'
// 		exclude_flag: false
// 		verbose_flag: false
// 		show_flag: true
// 		expanded_flag: false
// 		concurrency_flag: true
// 	}
// 	mut result := ExploreResult{}

// 	// start with binary classes, cross, -s

// 	opts.datafile_path = 'datasets/UCI/credit-g.arff'
// 	opts.bins = [2, 9, 3]
// 	opts.number_of_attributes = [13, 16]
// 	opts.folds = 5
// 	opts.repetitions = 3
// 	ds = load_file(opts.datafile_path)
// 	// result = explore(ds, opts) ?

// 	// repeat with -e

// 	opts.expanded_flag = true
// 	result = explore(ds, opts) ?
// result = cross_validate(ds, opts) ?

// // multiclass, cross, -s

// opts.expanded_flag = false

// opts.datafile_path = 'datasets/UCI/anneal.arff'
// opts.number_of_attributes = [28]
// opts.bins = [21, 21]
// opts.folds = 10
// opts.repetitions = 10
// opts.random_pick = true
// ds = load_file(opts.datafile_path)
// result = cross_validate(ds, opts) ?

// // repeat with -e

// opts.expanded_flag = true
// result = cross_validate(ds, opts) ?
// }
