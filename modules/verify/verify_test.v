// verify_test.v
module verify

import tools
import make

// test_load_classifier_file
fn test_load_classifier_file() {
	mut opts := tools.Options{}
	mut ds := tools.Dataset{}
	mut cl := tools.Classifier{}
	mut tcl := tools.Classifier{}

	opts.command = 'make'
	opts.outputfile_path = 'testdata/classifierfile'
	opts.classifierfile_path = 'testdata/classifierfile'
	ds = tools.load_file('datasets/developer.tab')
	cl = make.make_classifier(ds, opts)

	tcl = tools.load_classifier_file(opts.classifierfile_path) or { panic(err.msg) }
	assert cl.instances == tcl.instances
	assert cl.trained_attributes == tcl.trained_attributes

	ds = tools.load_file('datasets/leukemia38train.tab')
	cl = make.make_classifier(ds, opts)
	tcl = tools.load_classifier_file(opts.classifierfile_path) or { panic(err.msg) }
	assert cl.instances == tcl.instances
	assert cl.trained_attributes == tcl.trained_attributes

	opts.bins = [3, 3]
	opts.number_of_attributes = [2]

	ds = tools.load_file('datasets/iris.tab')
	cl = make.make_classifier(ds, opts)
	tcl = tools.load_classifier_file(opts.classifierfile_path) or { panic(err.msg) }
	tools.show_classifier(tcl)
	assert cl.instances == tcl.instances
	assert cl.trained_attributes == tcl.trained_attributes
}

// test_verify
fn test_verify() ? {
	mut opts := tools.Options{
		verbose_flag: false
		command: 'verify'
		show_flag: false
		concurrency_flag: true
	}

	mut result := tools.VerifyResult{}
	mut ds := tools.Dataset{}
	mut cl := tools.Classifier{}
	mut saved_cl := tools.Classifier{}

	// test verify with a non-saved classifier
	opts.command = 'make'
	opts.datafile_path = 'datasets/test.tab'
	opts.testfile_path = 'datasets/test_verify.tab'
	opts.classifierfile_path = ''
	opts.bins = [2, 3]
	opts.number_of_attributes = [2]
	ds = tools.load_file(opts.datafile_path)
	cl = make.make_classifier(ds, opts)
	assert verify(cl, opts) ?.correct_count == 10

	opts.datafile_path = 'datasets/bcw350train'
	opts.testfile_path = 'datasets/bcw174test'
	opts.classifierfile_path = ''
	opts.number_of_attributes = [4]
	opts.bins = [2, 4]
	ds = tools.load_file(opts.datafile_path)
	cl = make.make_classifier(ds, opts)
	result = verify(cl, opts) ?
	assert result.correct_count == 171
	assert result.wrong_count == 3

	// now with a saved classifier
	opts.outputfile_path = 'testdata/bcw350train.cl'
	cl = tools.Classifier{}
	result = tools.VerifyResult{}
	cl = make.make_classifier(ds, opts)
	cl = tools.Classifier{}
	opts.classifierfile_path = 'testdata/bcw350train.cl'
	result = verify(tools.load_classifier_file(opts.classifierfile_path) ?, opts) ?
	assert result.correct_count == 171
	assert result.wrong_count == 3

	opts.datafile_path = 'datasets/mnist_test.tab'
	opts.testfile_path = 'datasets/mnist_test.tab'
	opts.classifierfile_path = ''
	opts.number_of_attributes = [50]
	opts.bins = [2, 2]
	ds = tools.load_file(opts.datafile_path)
	cl = make.make_classifier(ds, opts)
	result = verify(cl, opts) ?
	assert result.correct_count == 9982
	assert result.wrong_count == 18

	// now with a saved classifier
	opts.outputfile_path = 'testdata/mnist_test.cl'
	cl = tools.Classifier{}
	result = tools.VerifyResult{}
	cl = make.make_classifier(ds, opts)
	cl = tools.Classifier{}
	opts.classifierfile_path = 'testdata/mnist_test.cl'
	result = verify(tools.load_classifier_file(opts.classifierfile_path) ?, opts) ?
	assert result.correct_count == 9982
	assert result.wrong_count == 18

	opts.datafile_path = 'datasets/soybean-large-train.tab'
	opts.testfile_path = 'datasets/soybean-large-test.tab'
	opts.classifierfile_path = ''
	opts.number_of_attributes = [33]
	opts.bins = [2, 16]
	opts.weighting_flag = true
	ds = tools.load_file(opts.datafile_path)
	cl = make.make_classifier(ds, opts)
	result = verify(cl, opts) ?
	assert result.correct_count == 340
	assert result.wrong_count == 36

	// now with a saved classifier
	opts.outputfile_path = 'testdata/soybean-large-train.cl'
	cl = tools.Classifier{}
	result = tools.VerifyResult{}
	cl = make.make_classifier(ds, opts)
	cl = tools.Classifier{}
	opts.classifierfile_path = 'testdata/soybean-large-train.cl'
	result = verify(tools.load_classifier_file(opts.classifierfile_path) ?, opts) ?
	assert result.correct_count == 340
	assert result.wrong_count == 36

	cl = tools.Classifier{}
	ds = tools.Dataset{}
	result = tools.VerifyResult{}
	opts.datafile_path = '/Users/henryolders/mnist_train.tab'
	opts.testfile_path = ''
	opts.outputfile_path = 'testdata/mnist_train.cl'
	opts.number_of_attributes = [313]
	opts.bins = [2, 2]
	opts.concurrency_flag = true
	opts.weighting_flag = false
	ds = tools.load_file(opts.datafile_path)
	cl = make.make_classifier(ds, opts)
	opts.testfile_path = 'datasets/mnist_test.tab'
	opts.classifierfile_path = 'testdata/mnist_train.cl'
	result = verify(tools.load_classifier_file(opts.classifierfile_path) ?, opts) ?
	assert result.correct_count == 9566
	assert result.wrong_count == 434

	opts.weighting_flag = true
	cl = make.make_classifier(ds, opts)
	result = verify(cl, opts) ?
	assert result.correct_count == 9279
	assert result.wrong_count == 721
}
