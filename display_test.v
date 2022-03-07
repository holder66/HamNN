// display_test.v

module hamnn

import os
// import json

// 	if os.is_dir('tempfolder') {
// 		os.rmdir_all('tempfolder') ?
// 	}
fn testsuite_begin() ? {
	os.mkdir_all('tempfolder') ?
}

// fn testsuite_end() ? {
// 	os.rmdir_all('tempfolder') ?
// }

// fn test_display_classifier() ? {
// 	// make a classifier and save it, then display the saved classifier file
// 	mut opts := Options{
// 		show_flag: false
// 		command: 'make'
// 		bins: [3, 10]
// 		number_of_attributes: [8]
// 	}
// 	opts.outputfile_path = 'tempfolder/classifierfile'
// 	mut ds := load_file('datasets/developer.tab')
// 	mut cl := make_classifier(ds, opts)
// 	path := 'tempfolder/classifierfile'
// 	mut settings := DisplaySettings{
// 		show_flag: true
// 	}
// 	display_file(path, settings) ?
// }

// fn test_display_analyze_result() ? {
// 	// analyze a dataset file, save the result, then display
// 	mut opts := Options{
// 		command: 'analyze'
// 		outputfile_path: 'tempfolder/analyze_result'
// 	}
// 	mut settings := DisplaySettings{
// 		show_flag: true
// 	}
// 	analyze_dataset(load_file('datasets/UCI/anneal.arff'), opts)
// 	display_file(opts.outputfile_path, settings) ?
// }

// fn test_display_ranking_result() ? {
// 	// rank a dataset file, save the result, then display
// 	mut opts := Options{
// 		command: 'rank'
// 		outputfile_path: 'tempfolder/rank_result'
// 	}
// 	_ = rank_attributes(load_file('datasets/UCI/anneal.arff'), opts)
// 	mut settings := DisplaySettings{
// 		show_flag: true
// 	}
// 	display_file(opts.outputfile_path, settings) ?
// 	// repeat for displaying a plot
// 	settings.graph_flag = true
// 	display_file(opts.outputfile_path, settings) ?
// }

// fn test_display_validate_result() ? {
// 	// validate a dataset file, save the result, then display
// 	mut opts := Options{
// 		command: 'make'
// 	}
// 	mut settings := DisplaySettings{
// 		show_flag: true
// 	}
// 	cl := make_classifier(load_file('datasets/bcw350train'), opts)
// 	opts.outputfile_path = 'tempfolder/validate_result'
// 	opts.testfile_path = 'datasets/bcw174validate'
// 	_ = validate(cl, opts) ?
// 	display_file(opts.outputfile_path, settings) ?
// }

// fn test_display_verify_result() ? {
// 	// verify a dataset file, save the result, then display
// 	mut opts := Options{
// 		command: 'make'
// 		number_of_attributes: [5]
// 	}
// 	mut settings := DisplaySettings{
// 		show_flag: true
// 	}
// 	cl := make_classifier(load_file('datasets/bcw350train'), opts)
// 	opts.outputfile_path = 'tempfolder/verify_result'
// 	opts.testfile_path = 'datasets/bcw174test'
// 	_ = verify(cl, opts) ?
// 	display_file(opts.outputfile_path, settings) ?
// 	settings.expanded_flag = true
// 	display_file(opts.outputfile_path, settings) ?
// }

fn test_display_cross_result() ? {
	// cross-validate a dataset file, save the result, then display
	mut opts := Options{
		command: 'cross'
		number_of_attributes: [4]
		bins: [12]
		folds: 0
		repetitions: 0
		random_pick: false
		concurrency_flag: true
	}
	mut settings := DisplaySettings{
		show_flag: true
	}
	ds := load_file('datasets/UCI/segment.arff')
	opts.outputfile_path = 'tempfolder/cross_result'
	_ = cross_validate(ds, opts) ?
	display_file(opts.outputfile_path, settings) ?
	settings.expanded_flag = true
	opts.folds = 20
	opts.repetitions = 50
	opts.random_pick = true
	_ = cross_validate(ds, opts) ?
	display_file(opts.outputfile_path, settings) ?
}

// fn test_display_explore_result_cross()? {
// 	mut opts := Options{
// 		command: 'explore'
// 		datafile_path: 'datasets/UCI/iris.arff'
// 		bins: [2,6]
// 		concurrency_flag: true
// 		outputfile_path: 'tempfolder/explore_result'
// 		// show_flag: true
// 	}
// 	_ = explore(load_file(opts.datafile_path), opts) ?
// 	mut settings := DisplaySettings{
// 		show_flag: true
// 	}
// 	display_file(opts.outputfile_path, settings)?
// 	settings.expanded_flag = true
// 	display_file(opts.outputfile_path, settings)?

// 	// repeat for a binary class dataset
// 	opts.datafile_path = 'datasets/bcw174test'
// 	_ = explore(load_file(opts.datafile_path), opts) ?
// 	settings.expanded_flag = false
// 	display_file(opts.outputfile_path, settings)?
// 	settings.expanded_flag = true
// 	display_file(opts.outputfile_path, settings)?
// }

// fn test_display_explore_result_verify()? {
// 	mut opts := Options{
// 		command: 'explore'
// 		datafile_path: 'datasets/soybean-large-train.tab'
// 		testfile_path: 'datasets/soybean-large-test.tab'
// 		bins: [2,6]
// 		concurrency_flag: true
// 		outputfile_path: 'tempfolder/explore_result'
// 	}
// 	_ = explore(load_file(opts.datafile_path), opts) ?
// 	mut settings := DisplaySettings{
// 		show_flag: true
// 	}
// 	display_file(opts.outputfile_path, settings)?
// 	settings.expanded_flag = true
// 	display_file(opts.outputfile_path, settings)?

// 	// repeat for a binary class dataset
// 	opts.datafile_path = 'datasets/bcw350train'
// 	opts.testfile_path = 'datasets/bcw174test'
// 	_ = explore(load_file(opts.datafile_path), opts) ?
// 	settings.expanded_flag = false
// 	display_file(opts.outputfile_path, settings)?
// 	settings.expanded_flag = true
// 	display_file(opts.outputfile_path, settings)?
// }
