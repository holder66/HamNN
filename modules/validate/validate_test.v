// validate_test.v
module validate

import tools
import make

// test_validate
fn test_validate() ? {
	mut opts := tools.Options{
		verbose_flag: false
		command: 'validate'
		show_flag: false
		concurrency_flag: true
	}

	mut result := tools.ValidateResult{}
	mut ds := tools.Dataset{}
	mut cl := tools.Classifier{}
	mut saved_cl := tools.Classifier{}

	// test validate with a non-saved classifier
	opts.command = 'make'
	opts.datafile_path = 'datasets/test.tab'
	opts.testfile_path = 'datasets/test_validate.tab'
	opts.classifierfile_path = ''
	opts.bins = [2, 3]
	opts.number_of_attributes = [2]
	ds = tools.load_file(opts.datafile_path)
	cl = make.make_classifier(ds, opts)
	result = validate(cl, opts) ?
	assert result.inferred_classes == ['f', 'f', 'f', 'm', 'm', 'm', 'f', 'f', 'm', 'f']
	assert result.counts == [[1, 0], [1, 0], [1, 0], [0, 1], [0, 1],
		[0, 1], [1, 0], [1, 0], [0, 1], [3, 0]]

	opts.datafile_path = 'datasets/bcw350train'
	opts.testfile_path = 'datasets/bcw174validate'
	opts.classifierfile_path = ''
	opts.number_of_attributes = [4]
	opts.bins = [2, 4]
	ds = tools.load_file(opts.datafile_path)
	cl = make.make_classifier(ds, opts)
	result = validate(cl, opts) ?
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
		[99, 0], [99, 0], [4, 0], [16, 10], [99, 0], [1, 0], [1, 0],
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
		[1, 0], [99, 0], [0, 2], [1, 6], [0, 1]]

	// repeat with weighting
	opts.weighting_flag = true
	cl = make.make_classifier(ds, opts)
	result = validate(cl, opts) ?
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

	// // now with a saved classifier
	// opts.outputfile_path = 'testdata/bcw350train.cl'
	// cl = tools.Classifier{}
	// result = tools.ValidateResult{}
	// cl = make.make_classifier(ds, opts)
	// cl = tools.Classifier{}
	// opts.classifierfile_path = 'testdata/bcw350train.cl'
	// result = validate(tools.load_classifier_file(opts.classifierfile_path) ?, opts) ?
	// assert result.correct_count == 171
	// assert result.wrong_count == 3

	// 	opts.datafile_path = 'datasets/mnist_test.tab'
	// 	opts.testfile_path = 'datasets/mnist_test.tab'
	// 	opts.classifierfile_path = ''
	// 	opts.number_of_attributes = [50]
	// 	opts.bins = [2, 2]
	// 	ds = tools.load_file(opts.datafile_path)
	// 	cl = make.make_classifier(ds, opts)
	// 	result = verify(cl, opts) ?
	// 	assert result.correct_count == 9982
	// 	assert result.wrong_count == 18

	// 	// now with a saved classifier
	// 	opts.outputfile_path = 'testdata/mnist_test.cl'
	// 	cl = tools.Classifier{}
	// 	result = tools.VerifyResult{}
	// 	cl = make.make_classifier(ds, opts)
	// 	cl = tools.Classifier{}
	// 	opts.classifierfile_path = 'testdata/mnist_test.cl'
	// 	result = verify(tools.load_classifier_file(opts.classifierfile_path) ?, opts) ?
	// 	assert result.correct_count == 9982
	// 	assert result.wrong_count == 18

	// 	opts.datafile_path = 'datasets/soybean-large-train.tab'
	// 	opts.testfile_path = 'datasets/soybean-large-test.tab'
	// 	opts.classifierfile_path = ''
	// 	opts.number_of_attributes = [33]
	// 	opts.bins = [2, 16]
	// 	opts.weighting_flag = true
	// 	ds = tools.load_file(opts.datafile_path)
	// 	cl = make.make_classifier(ds, opts)
	// 	result = verify(cl, opts) ?
	// 	assert result.correct_count == 340
	// 	assert result.wrong_count == 36

	// 	// now with a saved classifier
	// 	opts.outputfile_path = 'testdata/soybean-large-train.cl'
	// 	cl = tools.Classifier{}
	// 	result = tools.VerifyResult{}
	// 	cl = make.make_classifier(ds, opts)
	// 	cl = tools.Classifier{}
	// 	opts.classifierfile_path = 'testdata/soybean-large-train.cl'
	// 	result = verify(tools.load_classifier_file(opts.classifierfile_path) ?, opts) ?
	// 	assert result.correct_count == 340
	// 	assert result.wrong_count == 36

	// 	cl = tools.Classifier{}
	// 	ds = tools.Dataset{}
	// 	result = tools.VerifyResult{}
	// 	opts.datafile_path = '/Users/henryolders/mnist_train.tab'
	// 	opts.testfile_path = ''
	// 	opts.outputfile_path = 'testdata/mnist_train.cl'
	// 	opts.number_of_attributes = [313]
	// 	opts.bins = [2, 2]
	// 	opts.concurrency_flag = true
	// 	opts.weighting_flag = false
	// 	ds = tools.load_file(opts.datafile_path)
	// 	cl = make.make_classifier(ds, opts)
	// 	opts.testfile_path = 'datasets/mnist_test.tab'
	// 	opts.classifierfile_path = 'testdata/mnist_train.cl'
	// 	result = verify(tools.load_classifier_file(opts.classifierfile_path) ?, opts) ?
	// 	assert result.correct_count == 9566
	// 	assert result.wrong_count == 434

	// 	opts.weighting_flag = true
	// 	cl = make.make_classifier(ds, opts)
	// 	result = verify(cl, opts) ?
	// 	assert result.correct_count == 9279
	// 	assert result.wrong_count == 721
	// }
}
