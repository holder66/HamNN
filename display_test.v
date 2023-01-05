// display_test.v

module hamnn

import os

fn testsuite_begin() ! {
	if os.is_dir('tempfolder') {
		os.rmdir_all('tempfolder')!
	}
	os.mkdir_all('tempfolder')!
}

fn testsuite_end() ! {
	os.rmdir_all('tempfolder')!
}

fn test_display_classifier() ? {
	// make a classifier and save it, then display the saved classifier file
	mut opts := Options{
		show_flag: false
		command: 'make'
		bins: [3, 10]
		number_of_attributes: [8]
		graph_flag: true
	}
	opts.outputfile_path = 'tempfolder/classifierfile'
	mut ds := load_file('datasets/developer.tab')
	mut cl := make_classifier(mut ds, opts)
	path := 'tempfolder/classifierfile'
	opts.show_flag = true
	display_file(path, opts)
}

fn test_display_analyze_result() ? {
	// analyze a dataset file, save the result, then display
	mut opts := Options{
		command: 'analyze'
		outputfile_path: 'tempfolder/analyze_result'
	}
	mut settings := DisplaySettings{
		show_flag: false
	}
	analyze_dataset(load_file('datasets/UCI/anneal.arff'), opts)
	display_file(opts.outputfile_path, opts)
}

fn test_display_ranking_result() ? {
	// rank a dataset file, save the result, then display
	mut opts := Options{
		command: 'rank'
		outputfile_path: 'tempfolder/rank_result'
	}
	_ = rank_attributes(load_file('datasets/UCI/anneal.arff'), opts)
	// mut settings := DisplaySettings{
	// 	show_flag: false
	// }
	display_file(opts.outputfile_path, opts)
	// repeat for displaying a plot
	// settings.graph_flag = true
	// display_file(opts.outputfile_path, settings) ?
}

fn test_display_validate_result() ? {
	// validate a dataset file, save the result, then display
	mut opts := Options{
		command: 'make'
	}
	// mut settings := DisplaySettings{
	// 	show_flag: true
	// }
	opts.datafile_path = 'datasets/bcw350train'
	mut ds := load_file(opts.datafile_path)
	cl := make_classifier(mut ds, opts)
	opts.outputfile_path = 'tempfolder/validate_result'
	opts.testfile_path = 'datasets/bcw174validate'
	_ = validate(cl, opts)?
	display_file(opts.outputfile_path, opts)
}

fn test_display_verify_result() ? {
	// verify a dataset file, save the result, then display
	mut opts := Options{
		datafile_path: 'datasets/bcw350train'
		testfile_path: 'datasets/bcw174test'
		outputfile_path: 'tempfolder/verify_result'
		command: 'verify'
		number_of_attributes: [5]
		concurrency_flag: true
		show_flag: true
	}
	_ = verify(opts)
	opts.expanded_flag = false
	display_file(opts.outputfile_path, opts)
	opts.expanded_flag = true
	display_file(opts.outputfile_path, opts)
}

fn test_display_cross_result() ? {
	// cross-validate a dataset file, save the result, then display
	mut opts := Options{
		command: 'cross'
		number_of_attributes: [4]
		bins: [12]
		folds: 5
		repetitions: 0
		random_pick: false
		concurrency_flag: true
	}
	// mut settings := DisplaySettings{
	// 	show_flag: true
	// }
	ds := load_file('datasets/UCI/segment.arff')
	opts.outputfile_path = 'tempfolder/cross_result'
	_ = cross_validate(ds, opts)
	display_file(opts.outputfile_path, opts)
	opts.expanded_flag = true
	opts.folds = 10
	opts.repetitions = 10
	opts.random_pick = true
	_ = cross_validate(ds, opts)
	display_file(opts.outputfile_path, opts)
}

fn test_display_explore_result_cross() ? {
	mut opts := Options{
		command: 'explore'
		datafile_path: 'datasets/UCI/iris.arff'
		bins: [2, 3]
		number_of_attributes: [2, 3]
		concurrency_flag: true
		outputfile_path: 'tempfolder/explore_result'
		graph_flag: true
		// show_flag: true
	}
	_ = explore(load_file(opts.datafile_path), opts)
	// mut settings := DisplaySettings{
	// 	show_flag: true
	// 	graph_flag: true
	// }
	opts.show_flag = true
	opts.graph_flag = true
	display_file(opts.outputfile_path, opts)
	opts.expanded_flag = true
	display_file(opts.outputfile_path, opts)

	// repeat with purge flag set
	opts.purge_flag = true
	_ = explore(load_file(opts.datafile_path), opts)
	opts.expanded_flag = false
	display_file(opts.outputfile_path, opts)
	opts.expanded_flag = true
	display_file(opts.outputfile_path, opts)

	// repeat for a binary class dataset
	opts.number_of_attributes = [0]
	opts.datafile_path = 'datasets/bcw174test'
	opts.purge_flag = false
	_ = explore(load_file(opts.datafile_path), opts)
	opts.expanded_flag = false
	display_file(opts.outputfile_path, opts)
	opts.expanded_flag = true
	display_file(opts.outputfile_path, opts)

	// repeat with purge flag set
	opts.purge_flag = true
	_ = explore(load_file(opts.datafile_path), opts)
	opts.expanded_flag = false
	display_file(opts.outputfile_path, opts)
	opts.expanded_flag = true
	display_file(opts.outputfile_path, opts)
}

fn test_display_explore_result_verify() ? {
	mut opts := Options{
		command: 'explore'
		datafile_path: 'datasets/soybean-large-train.tab'
		testfile_path: 'datasets/soybean-large-test.tab'
		bins: [2, 6]
		number_of_attributes: [12, 15]
		concurrency_flag: true
		outputfile_path: 'tempfolder/explore_result'
		graph_flag: true
	}
	_ = explore(load_file(opts.datafile_path), opts)
	// mut settings := DisplaySettings{
	// 	show_flag: true
	// }
	display_file(opts.outputfile_path, opts)
	opts.expanded_flag = true
	display_file(opts.outputfile_path, opts)

	// repeat with purge flag set
	opts.purge_flag = true
	_ = explore(load_file(opts.datafile_path), opts)
	opts.expanded_flag = false
	display_file(opts.outputfile_path, opts)
	opts.expanded_flag = true
	display_file(opts.outputfile_path, opts)

	// repeat for a binary class dataset
	opts.datafile_path = 'datasets/bcw350train'
	opts.testfile_path = 'datasets/bcw174test'
	opts.purge_flag = false
	opts.number_of_attributes = [0]
	_ = explore(load_file(opts.datafile_path), opts)
	opts.expanded_flag = false
	display_file(opts.outputfile_path, opts)
	opts.expanded_flag = true
	display_file(opts.outputfile_path, opts)

	// repeat with purge flag set
	opts.purge_flag = true
	_ = explore(load_file(opts.datafile_path), opts)
	opts.expanded_flag = false
	display_file(opts.outputfile_path, opts)
	opts.expanded_flag = true
	display_file(opts.outputfile_path, opts)
}
