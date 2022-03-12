// append_test.v
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

// test_append
fn test_append() ? {
	mut opts := Options{
		verbose_flag: false
		command: 'append'
		show_flag: false
		concurrency_flag: false
		weighting_flag: true
	}

	mut cl := Classifier{}
	mut tcl := Classifier{}
	mut val_results := ValidateResult{}
	// create the classifier file and save it
	opts.outputfile_path = 'tempfolder/classifierfile'
	cl = make_classifier(load_file('datasets/test.tab'), opts)
	// do a validation and save the result
	opts.outputfile_path = 'tempfolder/instancesfile'
	opts.testfile_path = 'datasets/test_validate.tab'
	val_results = validate(cl, opts) ?
	// now do the append, first from val_results, and
	// saving the extended classifier
	opts.outputfile_path = 'tempfolder/extclassifierfile'
	tcl = append_instances(cl, val_results, opts)
	assert tcl.class_counts == {
		'f': 9
		'm': 7
	}
	// repeat the append, this time with the saved files
	stcl := append_instances(load_classifier_file('tempfolder/extclassifierfile') ?, load_instances_file('tempfolder/instancesfile') ?,
		opts)
	assert stcl.instances.len == 26
	assert stcl.history.len == 3

	// test if the appended classifier works as a classifier
	opts.testfile_path = 'datasets/test_verify.tab'
	opts.classifierfile_path = 'tempfolder/extclassifierfile'
	mut result := verify(load_classifier_file(opts.classifierfile_path) ?, opts) ?
	assert result.correct_count == 10
	assert result.wrong_count == 0

	// test with the soybean files
	// create the classifier file and save it
	opts.outputfile_path = 'tempfolder/classifierfile'
	cl = make_classifier(load_file('datasets/soybean-large-train.tab'), opts)
	// do a validation and save the result
	opts.outputfile_path = 'tempfolder/instancesfile'
	opts.testfile_path = 'datasets/soybean-large-validate.tab'
	val_results = validate(cl, opts) ?
	// now do the append

	opts.outputfile_path = 'tempfolder/extended_classifierfile'
	tcl = append_instances(cl, val_results, opts)
	assert tcl.class_counts == {
		'diaporthe-stem-canker':       20
		'charcoal-rot':                20
		'rhizoctonia-root-rot':        20
		'phytophthora-rot':            88
		'brown-stem-rot':              44
		'powdery-mildew':              20
		'downy-mildew':                19
		'brown-spot':                  85
		'bacterial-blight':            19
		'bacterial-pustule':           19
		'purple-seed-stain':           21
		'anthracnose':                 44
		'phyllosticta-leaf-spot':      23
		'alternarialeaf-spot':         93
		'frog-eye-leaf-spot':          95
		'diaporthe-pod-&-stem-blight': 15
		'cyst-nematode':               14
		'2-4-d-injury':                16
		'herbicide-injury':            8
	}

	// test if the appended classifier works as a classifier
	opts.testfile_path = 'datasets/soybean-large-test.tab'
	opts.classifierfile_path = 'tempfolder/extended_classifierfile'
	result = verify(load_classifier_file(opts.classifierfile_path) ?, opts) ?
	assert result.correct_count == 333
	assert result.wrong_count == 43
}
