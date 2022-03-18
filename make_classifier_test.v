// make_classifier_test
module hamnn

import os

fn testsuite_begin() ? {
	if os.is_dir('tempfolder2') {
		os.rmdir_all('tempfolder2') ?
	}
	os.mkdir_all('tempfolder2') ?
}

fn testsuite_end() ? {
	os.rmdir_all('tempfolder2') ?
}

// test_make_classifier
fn test_make_classifier() ? {
	mut opts := Options{
		bins: [2, 12]
		exclude_flag: false
		verbose_flag: false
		command: 'make'
		number_of_attributes: [6]
		show_flag: false
		weighting_flag: true
	}
	mut ds := load_file('datasets/developer.tab')
	mut cl := make_classifier(ds, opts)
	assert cl.class_counts == {
		'm': 8
		'f': 3
		'X': 2
	}
	assert cl.lcm_class_counts == 24
	assert cl.attribute_ordering == ['height', 'negative', 'number', 'weight', 'age', 'lastname']
}

// test_make_translation_table
fn test_make_translation_table() {
	mut array := ['Montreal', 'Ottawa', 'Markham', 'Oakville', 'Oakville', 'Laval', 'Laval', 'Laval',
		'Laval', 'Laval', 'Laval', 'Laval', 'Laval']
	assert make_translation_table(array) == {
		'Montreal': 1
		'Ottawa':   2
		'Markham':  3
		'Oakville': 4
		'Laval':    5
	}
	array = ['4', '5', '3', '?', '2', '4', '2', '4', '2', '4', '4', '3', '3']
	assert make_translation_table(array) == {
		'4': 1
		'5': 2
		'3': 3
		'?': 0
		'2': 4
	}
}

// test_save_classifier
fn test_save_classifier() ? {
	mut ds := Dataset{}
	mut cl := Classifier{}
	mut tcl := Classifier{}
	mut opts := Options{
		bins: [2, 12]
		exclude_flag: false
		verbose_flag: false
		command: 'make'
		number_of_attributes: [6]
		show_flag: false
		weighting_flag: true
		outputfile_path: 'tempfolder2/classifierfile'
	}
	opts.classifierfile_path = opts.outputfile_path

	ds = load_file('datasets/developer.tab')
	cl = make_classifier(ds, opts)

	tcl = load_classifier_file(opts.classifierfile_path) ?
	assert tcl.trained_attributes == cl.trained_attributes
	assert tcl.instances == cl.instances

	ds = load_file('datasets/anneal.tab')
	cl = make_classifier(ds, opts)

	tcl = load_classifier_file(opts.classifierfile_path) ?
	assert tcl.trained_attributes == cl.trained_attributes
	assert tcl.instances == cl.instances

	ds = load_file('datasets/soybean-large-train.tab')
	cl = make_classifier(ds, opts)

	tcl = load_classifier_file(opts.classifierfile_path) ?
	assert tcl.trained_attributes == cl.trained_attributes
	assert tcl.instances == cl.instances

	if get_environment().arch_details[0] != '4 cpus' {
		path := 'datasets/mnist_test.tab'
		ds = load_file(path)
		cl = make_classifier(ds, opts)

		tcl = load_classifier_file(opts.classifierfile_path) ?
		assert tcl.trained_attributes == cl.trained_attributes
		assert tcl.instances == cl.instances
	}
}
