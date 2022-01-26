// make_classifier_test
module make

import tools

// test_make_classifier
fn test_make_classifier() {
	mut opts := tools.Options{
		bins: [2, 12]
		exclude_flag: false
		verbose_flag: false
		command: 'make'
		number_of_attributes: [6]
		show_flag: false
		weighting_flag: true
	}
	mut ds := tools.load_file('datasets/developer.tab')
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
	mut opts := tools.Options{
		bins: [2, 12]
		exclude_flag: false
		verbose_flag: false
		command: 'make'
		number_of_attributes: [6]
		show_flag: false
		weighting_flag: true
		outputfile_path: '../temp_files/classifierfile'
	}
	mut ds := tools.load_file('datasets/developer.tab')
	mut cl := make_classifier(ds, opts)
	opts.classifierfile_path = opts.outputfile_path
	mut tcl := tools.load_classifier_file(opts.classifierfile_path) ?
	assert tcl.trained_attributes == cl.trained_attributes
	assert tcl.instances == cl.instances

	ds = tools.load_file('datasets/anneal.tab')
	cl = make_classifier(ds, opts)
	opts.classifierfile_path = opts.outputfile_path
	tcl = tools.load_classifier_file(opts.classifierfile_path) ?
	assert tcl.trained_attributes == cl.trained_attributes
	assert tcl.instances == cl.instances
}
