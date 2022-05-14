// validate_test.v
module hamnn

import os

fn testsuite_begin() ? {
	if os.is_dir('tempfolder3') {
		os.rmdir_all('tempfolder3')?
	}
	os.mkdir_all('tempfolder3')?
}

fn testsuite_end() ? {
	os.rmdir_all('tempfolder3')?
}

// test_validate_save_result
// fn test_validate_save_result() ? {
// 	mut opts := Options{
// 		verbose_flag: false
// 		command: 'validate'
// 		show_flag: false
// 		concurrency_flag: true
// 		outputfile_path: 'tempfolder3/instancesfile'
// 	}

// 	mut result := ValidateResult{}
// 	mut test_result := ValidateResult{}
// 	mut ds := Dataset{}
// 	mut cl := Classifier{}
// 	mut saved_cl := Classifier{}
// }

// test_validate
fn test_validate() ? {
	mut opts := Options{
		verbose_flag: false
		show_flag: false
		concurrency_flag: true
	}

	mut result := ValidateResult{}
	mut test_result := ValidateResult{}
	mut ds := Dataset{}
	mut cl := Classifier{}
	mut saved_cl := Classifier{}

	// test validate with a non-saved classifier
	opts.command = 'validate'
	opts.datafile_path = 'datasets/test.tab'
	opts.testfile_path = 'datasets/test_validate.tab'
	opts.classifierfile_path = ''
	opts.bins = [2, 3]
	opts.number_of_attributes = [2]
	ds = load_file(opts.datafile_path)
	cl = make_classifier(ds, opts)
	result = validate(cl, opts)?
	assert result.inferred_classes == ['f', 'f', 'f', 'm', 'm', 'm', 'f', 'f', 'm', 'f']
	assert result.counts == [[1, 0], [1, 0], [1, 0], [0, 1], [0, 1],
		[0, 1], [1, 0], [1, 0], [0, 1], [3, 0]]

	println('Done test.tab')

	opts.datafile_path = 'datasets/bcw350train'
	opts.testfile_path = 'datasets/bcw174validate'
	opts.classifierfile_path = ''
	opts.number_of_attributes = [4]
	opts.bins = [2, 4]
	ds = load_file(opts.datafile_path)
	cl = make_classifier(ds, opts)
	result = validate(cl, opts)?
	assert result.inferred_classes == ['benign', 'benign', 'benign', 'benign', 'benign', 'malignant',
		'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign',
		'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'malignant', 'benign', 'benign',
		'malignant', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign',
		'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'malignant', 'benign',
		'benign', 'malignant', 'malignant', 'malignant', 'malignant', 'benign', 'benign', 'malignant',
		'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'malignant', 'malignant',
		'benign', 'benign', 'benign', 'malignant', 'benign', 'malignant', 'benign', 'malignant',
		'malignant', 'malignant', 'benign', 'malignant', 'benign', 'benign', 'benign', 'benign',
		'benign', 'benign', 'benign', 'benign', 'malignant', 'malignant', 'malignant', 'benign',
		'benign', 'malignant', 'benign', 'malignant', 'malignant', 'malignant', 'benign', 'benign',
		'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign',
		'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign',
		'malignant', 'benign', 'benign', 'malignant', 'benign', 'benign', 'benign', 'benign',
		'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'malignant', 'benign',
		'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'malignant',
		'malignant', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign',
		'benign', 'malignant', 'malignant', 'benign', 'benign', 'benign', 'benign', 'benign',
		'benign', 'benign', 'benign', 'benign', 'benign', 'malignant', 'malignant', 'benign',
		'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'malignant',
		'benign', 'benign', 'benign', 'benign', 'malignant', 'malignant', 'malignant']
	assert result.counts == [[99, 0], [99, 0], [99, 0], [4, 0],
		[14, 0], [2, 7], [4, 0], [14, 0], [99, 0], [99, 0], [4, 0],
		[99, 0], [5, 0], [99, 0], [99, 0], [6, 0], [99, 0], [1, 0],
		[99, 0], [4, 0], [99, 0], [0, 16], [14, 0], [14, 0], [0, 1],
		[99, 0], [99, 0], [4, 0], [18, 12], [99, 0], [1, 0], [1, 0],
		[99, 0], [99, 0], [99, 0], [99, 0], [99, 0], [99, 0],
		[99, 0], [99, 0], [0, 4], [5, 0], [3, 0], [0, 1], [0, 1],
		[0, 6], [0, 3], [99, 0], [99, 0], [0, 5], [5, 0], [99, 0],
		[99, 0], [99, 0], [99, 0], [5, 0], [0, 4], [0, 2], [99, 0],
		[5, 0], [99, 0], [0, 1], [99, 0], [0, 1], [99, 0], [0, 2],
		[0, 1], [0, 1], [5, 0], [0, 4], [99, 0], [5, 0], [4, 0],
		[99, 0], [3, 1], [99, 0], [14, 0], [99, 0], [1, 2], [0, 1],
		[0, 1], [99, 0], [99, 0], [0, 4], [99, 0], [0, 1], [0, 2],
		[0, 1], [1, 0], [14, 0], [4, 0], [99, 0], [1, 0], [99, 0],
		[99, 0], [99, 0], [2, 0], [5, 0], [99, 0], [14, 0], [3, 0],
		[2, 0], [4, 0], [99, 0], [99, 0], [1, 0], [99, 0], [99, 0],
		[1, 10], [99, 0], [2, 0], [0, 8], [2, 0], [99, 0], [99, 0],
		[99, 0], [99, 0], [99, 0], [99, 0], [99, 0], [99, 0],
		[4, 0], [99, 0], [0, 9], [99, 0], [6, 0], [2, 0], [99, 0],
		[99, 0], [99, 0], [99, 0], [99, 0], [0, 1], [1, 5], [99, 0],
		[99, 0], [99, 0], [4, 0], [4, 0], [99, 0], [99, 0], [4, 0],
		[99, 0], [3, 8], [0, 2], [1, 0], [2, 0], [99, 0], [1, 0],
		[99, 0], [2, 0], [5, 0], [99, 0], [99, 0], [99, 0], [0, 2],
		[0, 16], [99, 0], [99, 0], [99, 0], [99, 0], [99, 0],
		[99, 0], [99, 0], [99, 0], [99, 0], [0, 1], [99, 0], [99, 0],
		[1, 0], [99, 0], [0, 2], [3, 8], [0, 1]]

	println('Done with bcw350train')

	// repeat with weighting
	opts.weighting_flag = true
	cl = make_classifier(ds, opts)
	result = validate(cl, opts)?
	assert result.inferred_classes == ['benign', 'benign', 'benign', 'benign', 'benign', 'malignant',
		'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign',
		'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'malignant', 'benign', 'benign',
		'malignant', 'benign', 'benign', 'benign', 'malignant', 'benign', 'benign', 'benign',
		'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'malignant',
		'benign', 'benign', 'malignant', 'malignant', 'malignant', 'malignant', 'benign', 'benign',
		'malignant', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'malignant',
		'malignant', 'benign', 'benign', 'benign', 'malignant', 'benign', 'malignant', 'benign',
		'malignant', 'malignant', 'malignant', 'benign', 'malignant', 'benign', 'benign', 'benign',
		'benign', 'benign', 'benign', 'benign', 'benign', 'malignant', 'malignant', 'malignant',
		'benign', 'benign', 'malignant', 'benign', 'malignant', 'malignant', 'malignant', 'benign',
		'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign',
		'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign',
		'benign', 'malignant', 'benign', 'benign', 'malignant', 'benign', 'benign', 'benign',
		'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'malignant',
		'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'malignant',
		'malignant', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign',
		'benign', 'malignant', 'malignant', 'benign', 'benign', 'benign', 'benign', 'benign',
		'benign', 'benign', 'benign', 'benign', 'benign', 'malignant', 'malignant', 'benign',
		'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'malignant',
		'benign', 'benign', 'benign', 'benign', 'malignant', 'malignant', 'malignant']
	assert result.counts == [[15741, 0], [15741, 0], [15741, 0],
		[636, 0], [2226, 0], [318, 1337], [636, 0], [2226, 0],
		[15741, 0], [15741, 0], [636, 0], [15741, 0], [795, 0],
		[15741, 0], [15741, 0], [954, 0], [15741, 0], [159, 0],
		[15741, 0], [636, 0], [15741, 0], [0, 3056], [2226, 0],
		[2226, 0], [0, 191], [15741, 0], [15741, 0], [636, 0],
		[159, 191], [15741, 0], [159, 0], [159, 0], [15741, 0],
		[15741, 0], [15741, 0], [15741, 0], [15741, 0], [15741, 0],
		[15741, 0], [15741, 0], [0, 764], [795, 0], [477, 0],
		[0, 191], [0, 191], [0, 1146], [0, 573], [15741, 0], [15741, 0],
		[0, 955], [795, 0], [15741, 0], [15741, 0], [15741, 0],
		[15741, 0], [795, 0], [0, 764], [0, 382], [15741, 0],
		[795, 0], [15741, 0], [0, 191], [15741, 0], [0, 191],
		[15741, 0], [0, 382], [0, 191], [0, 191], [795, 0], [0, 764],
		[15741, 0], [795, 0], [636, 0], [15741, 0], [477, 191],
		[15741, 0], [2226, 0], [15741, 0], [159, 382], [0, 191],
		[0, 191], [15741, 0], [15741, 0], [0, 764], [15741, 0],
		[0, 191], [0, 382], [0, 191], [159, 0], [2226, 0], [636, 0],
		[15741, 0], [159, 0], [15741, 0], [15741, 0], [15741, 0],
		[318, 0], [795, 0], [15741, 0], [2226, 0], [477, 0], [318, 0],
		[636, 0], [15741, 0], [15741, 0], [159, 0], [15741, 0],
		[15741, 0], [159, 1910], [15741, 0], [318, 0], [0, 1528],
		[318, 0], [15741, 0], [15741, 0], [15741, 0], [15741, 0],
		[15741, 0], [15741, 0], [15741, 0], [15741, 0], [636, 0],
		[15741, 0], [0, 1719], [15741, 0], [954, 0], [318, 0],
		[15741, 0], [15741, 0], [15741, 0], [15741, 0], [15741, 0],
		[0, 191], [159, 955], [15741, 0], [15741, 0], [15741, 0],
		[636, 0], [636, 0], [15741, 0], [15741, 0], [636, 0],
		[15741, 0], [477, 1528], [0, 382], [159, 0], [318, 0],
		[15741, 0], [159, 0], [15741, 0], [318, 0], [795, 0],
		[15741, 0], [15741, 0], [15741, 0], [0, 382], [0, 3056],
		[15741, 0], [15741, 0], [15741, 0], [15741, 0], [15741, 0],
		[15741, 0], [15741, 0], [15741, 0], [15741, 0], [0, 191],
		[15741, 0], [15741, 0], [159, 0], [15741, 0], [0, 382],
		[159, 191], [0, 191]]

	println('Done with bcw350train and weighting')

	// now with a saved classifier
	opts.outputfile_path = 'tempfolder3/classifierfile'
	opts.weighting_flag = true
	cl = Classifier{}
	result = ValidateResult{}
	cl = make_classifier(ds, opts)
	cl = Classifier{}
	opts.classifierfile_path = opts.outputfile_path
	result = validate(load_classifier_file(opts.classifierfile_path)?, opts)?
	assert result.inferred_classes == ['benign', 'benign', 'benign', 'benign', 'benign', 'malignant',
		'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign',
		'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'malignant', 'benign', 'benign',
		'malignant', 'benign', 'benign', 'benign', 'malignant', 'benign', 'benign', 'benign',
		'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'malignant',
		'benign', 'benign', 'malignant', 'malignant', 'malignant', 'malignant', 'benign', 'benign',
		'malignant', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'malignant',
		'malignant', 'benign', 'benign', 'benign', 'malignant', 'benign', 'malignant', 'benign',
		'malignant', 'malignant', 'malignant', 'benign', 'malignant', 'benign', 'benign', 'benign',
		'benign', 'benign', 'benign', 'benign', 'benign', 'malignant', 'malignant', 'malignant',
		'benign', 'benign', 'malignant', 'benign', 'malignant', 'malignant', 'malignant', 'benign',
		'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign',
		'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign',
		'benign', 'malignant', 'benign', 'benign', 'malignant', 'benign', 'benign', 'benign',
		'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'malignant',
		'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'malignant',
		'malignant', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign',
		'benign', 'malignant', 'malignant', 'benign', 'benign', 'benign', 'benign', 'benign',
		'benign', 'benign', 'benign', 'benign', 'benign', 'malignant', 'malignant', 'benign',
		'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'malignant',
		'benign', 'benign', 'benign', 'benign', 'malignant', 'malignant', 'malignant']
	assert result.counts == [[15741, 0], [15741, 0], [15741, 0],
		[636, 0], [2226, 0], [318, 1337], [636, 0], [2226, 0],
		[15741, 0], [15741, 0], [636, 0], [15741, 0], [795, 0],
		[15741, 0], [15741, 0], [954, 0], [15741, 0], [159, 0],
		[15741, 0], [636, 0], [15741, 0], [0, 3056], [2226, 0],
		[2226, 0], [0, 191], [15741, 0], [15741, 0], [636, 0],
		[159, 191], [15741, 0], [159, 0], [159, 0], [15741, 0],
		[15741, 0], [15741, 0], [15741, 0], [15741, 0], [15741, 0],
		[15741, 0], [15741, 0], [0, 764], [795, 0], [477, 0],
		[0, 191], [0, 191], [0, 1146], [0, 573], [15741, 0], [15741, 0],
		[0, 955], [795, 0], [15741, 0], [15741, 0], [15741, 0],
		[15741, 0], [795, 0], [0, 764], [0, 382], [15741, 0],
		[795, 0], [15741, 0], [0, 191], [15741, 0], [0, 191],
		[15741, 0], [0, 382], [0, 191], [0, 191], [795, 0], [0, 764],
		[15741, 0], [795, 0], [636, 0], [15741, 0], [477, 191],
		[15741, 0], [2226, 0], [15741, 0], [159, 382], [0, 191],
		[0, 191], [15741, 0], [15741, 0], [0, 764], [15741, 0],
		[0, 191], [0, 382], [0, 191], [159, 0], [2226, 0], [636, 0],
		[15741, 0], [159, 0], [15741, 0], [15741, 0], [15741, 0],
		[318, 0], [795, 0], [15741, 0], [2226, 0], [477, 0], [318, 0],
		[636, 0], [15741, 0], [15741, 0], [159, 0], [15741, 0],
		[15741, 0], [159, 1910], [15741, 0], [318, 0], [0, 1528],
		[318, 0], [15741, 0], [15741, 0], [15741, 0], [15741, 0],
		[15741, 0], [15741, 0], [15741, 0], [15741, 0], [636, 0],
		[15741, 0], [0, 1719], [15741, 0], [954, 0], [318, 0],
		[15741, 0], [15741, 0], [15741, 0], [15741, 0], [15741, 0],
		[0, 191], [159, 955], [15741, 0], [15741, 0], [15741, 0],
		[636, 0], [636, 0], [15741, 0], [15741, 0], [636, 0],
		[15741, 0], [477, 1528], [0, 382], [159, 0], [318, 0],
		[15741, 0], [159, 0], [15741, 0], [318, 0], [795, 0],
		[15741, 0], [15741, 0], [15741, 0], [0, 382], [0, 3056],
		[15741, 0], [15741, 0], [15741, 0], [15741, 0], [15741, 0],
		[15741, 0], [15741, 0], [15741, 0], [15741, 0], [0, 191],
		[15741, 0], [15741, 0], [159, 0], [15741, 0], [0, 382],
		[159, 191], [0, 191]]

	println('Done with bcw350train saved classifier')

	opts.datafile_path = 'datasets/soybean-large-train.tab'
	opts.testfile_path = 'datasets/soybean-large-validate.tab'
	opts.outputfile_path = 'tempfolder3/classifierfile'
	opts.number_of_attributes = [33]
	opts.bins = [2, 16]
	opts.weighting_flag = true
	ds = load_file(opts.datafile_path)
	cl = make_classifier(ds, opts)
	// reset the outputfile_path so that validate won't overwrite the classifier
	opts.outputfile_path = ''
	result = validate(cl, opts)?
	assert result.counts[0] == [12, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	s := result.inferred_classes[0..4]
	assert s == ['diaporthe-stem-canker', 'diaporthe-stem-canker', 'diaporthe-stem-canker',
		'diaporthe-stem-canker']
	tcl := load_classifier_file('tempfolder3/classifierfile')?
	test_result = validate(tcl, opts)?

	assert result.inferred_classes == test_result.inferred_classes
	assert result.counts == test_result.counts
}
