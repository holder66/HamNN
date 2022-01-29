// append_test.v
module append

import tools
import make
import validate
import os

fn testsuite_begin() ? {
	if os.is_dir('tempfolder') {
	os.rmdir_all('tempfolder') ?
	}
	os.mkdir_all('tempfolder') ?
}

// fn testsuite_end() ? {
// 	os.rmdir_all('tempfolder') ?
// }

// test_append_file_to_file 
fn test_append_file_to_file() ? {
	mut opts := tools.Options{
		verbose_flag: true
		command: 'append'
		show_flag: true
		concurrency_flag: false 
		testfile_path: 'datasets/test_validate.tab'
		classifierfile_path: 'tempfolder/classifierfile'
		instancesfile_path: 'tempfolder/instancesfile'
		outputfile_path: 'tempfolder/extended_classifierfile'
	}

	mut cl := tools.Classifier{}
	mut tcl := tools.Classifier{}
	mut val_results := tools.ValidateResult{}
	// create the classifier file and save it
	cl = make.make_classifier(tools.load_file('datasets/test.tab'), opts) ?
	// do a validation and save the result
	val_results = validate.validate(cl, opts) ?
	tcl = append_file_to_file(opts) ?
}
