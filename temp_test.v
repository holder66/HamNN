// temp_test.v
module hamnn

import os

// fn test_show_classifier
fn test_show_classifier() {
	mut opts := Options{
		show_flag: true
		command: 'make'
		bins: [3,10]

	}
	mut cl := make_classifier(load_file('datasets/iris.tab'), opts)
	opts.number_of_attributes = [8]
	cl = make_classifier(load_file('datasets/anneal.tab'), opts)
}



fn testsuite_begin() ? {
	if os.is_dir('tempfolder') {
		os.rmdir_all('tempfolder') ?
	}
	os.mkdir_all('tempfolder') ?
}

fn testsuite_end() ? {
	os.rmdir_all('tempfolder') ?
}

// test_append
fn test_append() ? {
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
	tcl = append_instances(load_classifier_file('tempfolder/classifierfile') ?, load_instances_file('tempfolder/instancesfile') ?, opts)

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
	tcl = append_instances(load_classifier_file('tempfolder/classifierfile') ?, load_instances_file('tempfolder/instancesfile') ?, opts)
	}
