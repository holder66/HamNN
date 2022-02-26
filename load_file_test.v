// load_file_test.v
module hamnn

import math
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

// test_file_type
fn test_file_type() {
	assert file_type('datasets/developer.tab') == 'orange_newer'
	assert file_type('datasets/iris.tab') == 'orange_older'
	assert file_type('datasets/ESL.arff') == 'arff'
}

// test_load_file
fn test_load_file() {
	mut ds := Dataset{}
	ds = load_file('datasets/developer.tab')
	assert ds.Class == Class{
		class_name: 'gender'
		class_values: ['m', 'm', 'm', 'f', 'f', 'm', 'X', 'f', 'm', 'm', 'm', 'X', 'm']
		class_counts: {
			'm': 8
			'f': 3
			'X': 2
		}
		lcm_class_counts: 0
	}
	assert ds.attribute_names == ['firstname', 'lastname', 'age', 'gender', 'height', 'weight',
		'SEC', 'city', 'number', 'negative']
	assert ds.inferred_attribute_types == ['i', 'D', 'C', 'c', 'C', 'C', 'D', 'D', 'C', 'C']
	assert ds.useful_continuous_attributes[9][9] == -math.max_f32
	assert ds.useful_discrete_attributes[6] == ['4', '5', '3', '?', '2', '4', '2', '4', '2', '4',
		'4', '3', '3']

	ds = load_file('datasets/iris.tab')
	assert ds.class_counts == {
		'Iris-setosa':     50
		'Iris-versicolor': 50
		'Iris-virginica':  50
	}
	assert ds.lcm_class_counts == 0
	assert ds.attribute_names == ['sepal length', 'sepal width', 'petal length', 'petal width',
		'iris']
	assert ds.data[0][0..4] == ['5.1', '4.9', '4.7', '4.6']
	assert ds.inferred_attribute_types == ['C', 'C', 'C', 'C', 'c']
	assert ds.useful_continuous_attributes[1][0] == 3.5
	assert ds.useful_discrete_attributes == {}

	// test that header lines get padded out
	ds = load_file('datasets/wine.tab')
	assert ds.attribute_flags == ['class', '', '', '', '', '', '', '', '', '', '', '', '', '']

	// test arff files
	ds = load_file('datasets/contact-lenses.arff')
	assert ds.attribute_names == ['age', 'spectacle-prescrip', 'astigmatism', 'tear-prod-rate',
		'contact-lenses']
	assert ds.attribute_flags == ['young, pre-presbyopic, presbyopic', 'myope, hypermetrope',
		'no, yes', 'reduced, normal', 'soft, hard, none']
	assert ds.attribute_types == ['string', 'string', 'string', 'string', 'string']
	assert ds.inferred_attribute_types == ['D', 'D', 'D', 'D', 'c']
	assert ds.useful_continuous_attributes == {}

	ds = load_file('datasets/UCI/iris.arff')
	assert ds.attribute_names == ['sepallength', 'sepalwidth', 'petallength', 'petalwidth', 'class']
	assert ds.attribute_flags == ['', '', '', '', 'iris-setosa,iris-versicolor,iris-virginica']
	assert ds.attribute_types == ['real', 'real', 'real', 'real', 'string']
	assert ds.inferred_attribute_types == ['C', 'C', 'C', 'C', 'c']
	assert ds.useful_discrete_attributes == {}
}

// test_load_classifier_file
fn test_load_classifier_file() ? {
	mut ds := Dataset{}
	mut cl := Classifier{}
	mut tcl := Classifier{}
	mut opts := Options{
		outputfile_path: 'tempfolder/classifierfile'
		command: 'make' // the make command is necessary to create a proper file
	}
	opts.bins = [2, 4]
	opts.number_of_attributes = [4]
	ds = load_file('datasets/developer.tab')
	cl = make_classifier(ds, opts)
	tcl = load_classifier_file('tempfolder/classifierfile') ?
	assert cl.Options == tcl.Options
	assert cl.Class == tcl.Class
	assert cl.attribute_ordering == tcl.attribute_ordering
	assert cl.trained_attributes == tcl.trained_attributes
	assert cl.history[0].event == tcl.history[0].event
	// assert cl.history[0].event_date == tcl.history[0].event_date

	opts.bins = [3, 6]
	opts.number_of_attributes = [2]
	ds = load_file('datasets/iris.tab')
	cl = make_classifier(ds, opts)
	tcl = load_classifier_file('tempfolder/classifierfile') ?
	assert cl.Options == tcl.Options
	assert cl.Class == tcl.Class
	assert cl.attribute_ordering == tcl.attribute_ordering
	assert cl.trained_attributes == tcl.trained_attributes
	assert cl.history[0].event == tcl.history[0].event
	// assert cl.history[0].event_date == tcl.history[0].event_date
}

// test_load_instances_file
fn test_load_instances_file() ? {
	mut ds := Dataset{}
	mut cl := Classifier{}
	mut vr := ValidateResult{}
	mut tvr := ValidateResult{}
	mut opts := Options{
		outputfile_path: 'tempfolder/validate_result.json'
	}
	opts.testfile_path = 'datasets/test_validate.tab'
	ds = load_file('datasets/test.tab')
	cl = make_classifier(ds, opts)
	vr = validate(cl, opts) ?
	tvr = load_instances_file('tempfolder/validate_result.json') ?
	assert vr.Class == tvr.Class
	assert vr.inferred_classes == tvr.inferred_classes
	assert vr.counts == tvr.counts

	opts.testfile_path = 'datasets/soybean-large-validate.tab'
	ds = load_file('datasets/soybean-large-train.tab')
	cl = make_classifier(ds, opts)
	vr = validate(cl, opts) ?
	tvr = load_instances_file('tempfolder/validate_result.json') ?
	assert vr.Class == tvr.Class
	assert vr.inferred_classes == tvr.inferred_classes
	assert vr.counts == tvr.counts
}
