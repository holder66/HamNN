// append_test.v
module append

import tools
import make
import validate
import verify
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

// test_append_file_to_file 
fn test_append_file_to_file() ? {
	mut opts := tools.Options{
		verbose_flag: false
		command: 'append'
		show_flag: true
		concurrency_flag: false 
		weighting_flag: true
		testfile_path: 'datasets/test_validate.tab'
		classifierfile_path: 'tempfolder/classifierfile'
		instancesfile_path: 'tempfolder/instancesfile'
		outputfile_path: 'tempfolder/extended_classifierfile'
	}

	mut cl := tools.Classifier{}
	mut tcl := tools.Classifier{}
	mut val_results := tools.ValidateResult{}
	// create the classifier file and save it
	cl = make.make_classifier(tools.load_file('datasets/test.tab'), opts)
	// do a validation and save the result
	val_results = validate.validate(cl, opts) ?
	tcl = append_file_to_file(opts) ?
	assert tcl.class_counts == {'f': 9, 'm': 7}

	// test if the appended classifier works as a classifier
	opts.testfile_path = 'datasets/test_verify.tab'
	opts.classifierfile_path = 'tempfolder/extended_classifierfile'
	result := verify.verify(tools.load_classifier_file(opts.classifierfile_path) ?, opts) ?

	assert result.correct_count == 10
	assert result.wrong_count == 0
}
