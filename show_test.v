// show_test.v
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

// test_show_analyze has no asserts; the console output needs
// to be verified visually.
fn test_show_analyze() {
	println('test_show_analyze should print out dataset analyses for developer.tab and for iris.tab')
	mut opts := Options{
		show_flag: false
	}
	mut ar := AnalyzeResult{}

	ar = analyze_dataset(load_file('datasets/developer.tab'), opts)
	show_analyze(ar)

	ar = analyze_dataset(load_file('datasets/iris.tab'), opts)
	show_analyze(ar)
}

// test_show_append
fn test_show_append() ? {
	println('test_show_append should print out a test.tab classifier, with 6 instances, followed by a test.tab classifier with 16 instances, and then a test.tab classifier with 26 instances and 3 history events. Then 3 classifiers based on soybean-large-train.tab.')
	mut opts := Options{
		verbose_flag: false
		show_flag: true
		concurrency_flag: false
		weighting_flag: true
	}

	mut cl := Classifier{}
	mut tcl := Classifier{}
	mut val_results := ValidateResult{}
	// create the classifier file and save it
	opts.command = 'make'
	opts.outputfile_path = 'tempfolder/classifierfile'
	cl = make_classifier(load_file('datasets/test.tab'), opts)
	// do a validation and save the result
	opts.outputfile_path = 'tempfolder/instancesfile'
	opts.testfile_path = 'datasets/test_validate.tab'
	val_results = validate(cl, opts) ?
	// now do the append, first from val_results, and
	// saving the extended classifier
	opts.outputfile_path = 'tempfolder/classifierfile'
	opts.command = 'append'
	tcl = append_instances(cl, val_results, opts)

	// now do it again but from the saved validate result,
	// appending to the previously extended classifier
	tcl = append_instances(load_classifier_file('tempfolder/classifierfile') ?, load_instances_file('tempfolder/instancesfile') ?,
		opts)

	// repeat with soybean
	opts.command = 'make'
	opts.outputfile_path = 'tempfolder/classifierfile'
	cl = make_classifier(load_file('datasets/soybean-large-train.tab'), opts)
	// do a validation and save the result
	opts.outputfile_path = 'tempfolder/instancesfile'
	opts.testfile_path = 'datasets/soybean-large-validate.tab'
	val_results = validate(cl, opts) ?
	// now do the append, first from val_results, and
	// saving the extended classifier
	opts.outputfile_path = 'tempfolder/classifierfile'
	opts.command = 'append'
	tcl = append_instances(cl, val_results, opts)

	// now do it again but from the saved validate result,
	// appending to the previously extended classifier
	tcl = append_instances(load_classifier_file('tempfolder/classifierfile') ?, load_instances_file('tempfolder/instancesfile') ?,
		opts)
}

// fn test_show_classifier
fn test_show_classifier() {
	println('test_show_classifier prints out classifiers for iris.tab and for anneal.tab')
	mut opts := Options{
		show_flag: true
		command: 'make'
		bins: [3, 10]
	}
	mut cl := make_classifier(load_file('datasets/iris.tab'), opts)
	opts.number_of_attributes = [8]
	cl = make_classifier(load_file('datasets/anneal.tab'), opts)
}

// test_show_crossvalidation_result
fn test_show_crossvalidation_result() ? {
	mut cvr := CrossVerifyResult{}
	mut opts := Options{
		show_flag: true
		concurrency_flag: true
		command: 'cross'
	}
	println('developer.tab')
	cvr = cross_validate(load_file('datasets/developer.tab'), opts)
	println('\n\ndeveloper.tab with expanded results')
	opts.expanded_flag = true
	cvr = cross_validate(load_file('datasets/developer.tab'), opts)

	println('\n\nbreast-cancer-wisconsin-disc.tab')
	opts.expanded_flag = false
	opts.number_of_attributes = [4]
	cvr = cross_validate(load_file('datasets/breast-cancer-wisconsin-disc.tab'), opts)
	println('\n\nbreast-cancer-wisconsin-disc.tab with expanded results')
	opts.expanded_flag = true
	cvr = cross_validate(load_file('datasets/breast-cancer-wisconsin-disc.tab'), opts)

	println('\n\niris.tab')
	opts.expanded_flag = false
	opts.bins = [3, 6]
	opts.number_of_attributes = [2]
	cvr = cross_validate(load_file('datasets/iris.tab'), opts)
	println('\n\niris.tab with expanded results')
	opts.expanded_flag = true
	cvr = cross_validate(load_file('datasets/iris.tab'), opts)
}

// test_explore_cross
fn test_explore_cross() {
	mut results := ExploreResult{}
	mut opts := Options{
		verbose_flag: false
		number_of_attributes: [2, 4]
		bins: [2, 5]
		show_flag: true
		expanded_flag: false
		weighting_flag: true
		exclude_flag: true
		concurrency_flag: true
		uniform_bins: true
		folds: 10
		repetitions: 50
		random_pick: true
		datafile_path: 'datasets/developer.tab'
	}
	results = explore(load_file(opts.datafile_path), opts)

	opts.expanded_flag = true
	opts.bins = [3, 4]
	opts.number_of_attributes = [2, 3]
	results = explore(load_file(opts.datafile_path), opts)

	opts.datafile_path = 'datasets/bcw350train'
	opts.testfile_path = 'datasets/bcw174test'
	opts.number_of_attributes = [0]

	results = explore(load_file(opts.datafile_path), opts)

	opts.expanded_flag = false
	results = explore(load_file(opts.datafile_path), opts)
}

// test_show_rank_attributes
fn test_show_rank_attributes() {
	mut opts := Options{
		exclude_flag: true
		show_flag: true
		command: 'rank'
	}
	mut ds := Dataset{}
	mut rr := RankingResult{}
	ds = load_file('datasets/developer.tab')
	rr = rank_attributes(ds, opts)

	opts.bins = [3, 3]
	ds = load_file('datasets/iris.tab')
	rr = rank_attributes(ds, opts)

	ds = load_file('datasets/anneal.tab')
	rr = rank_attributes(ds, opts)

	opts.exclude_flag = false
	rr = rank_attributes(ds, opts)
}
