// verify_test.v
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

// test_verify
fn test_verify() ? {
	mut opts := Options{
		verbose_flag: false
		show_flag: false
		concurrency_flag: true
	}

	mut result := VerifyResult{}
	mut ds := Dataset{}
	mut cl := Classifier{}
	mut saved_cl := Classifier{}

	// test verify with a non-saved classifier
	opts.command = 'make'
	opts.datafile_path = 'datasets/test.tab'
	opts.testfile_path = 'datasets/test_verify.tab'
	opts.classifierfile_path = ''
	opts.bins = [2, 3]
	opts.number_of_attributes = [2]
	ds = load_file(opts.datafile_path)
	cl = make_classifier(ds, opts)
	assert verify(cl, opts).correct_count == 10

	println('Done with test.tab')

	opts.datafile_path = 'datasets/bcw350train'
	opts.testfile_path = 'datasets/bcw174test'
	opts.classifierfile_path = ''
	opts.number_of_attributes = [4]
	opts.bins = [2, 4]
	ds = load_file(opts.datafile_path)
	cl = make_classifier(ds, opts)
	result = verify(cl, opts)
	assert result.correct_count == 171
	assert result.wrong_count == 3

	println('Done with bcw350train')

	// now with a saved classifier
	opts.outputfile_path = 'tempfolder/classifierfile'
	cl = Classifier{}
	result = VerifyResult{}
	cl = make_classifier(ds, opts)
	cl = Classifier{}
	result = verify(load_classifier_file('tempfolder/classifierfile') ?, opts)
	assert result.correct_count == 171
	assert result.wrong_count == 3

	println('Done with bcw350train using saved classifier')

	opts.datafile_path = 'datasets/soybean-large-train.tab'
	opts.testfile_path = 'datasets/soybean-large-test.tab'
	opts.classifierfile_path = ''
	opts.number_of_attributes = [33]
	opts.bins = [2, 16]
	opts.weighting_flag = true
	ds = load_file(opts.datafile_path)
	cl = make_classifier(ds, opts)
	result = verify(cl, opts)
	assert result.correct_count == 340
	assert result.wrong_count == 36

	println('Done with soybean-large-train.tab')

	// now with a saved classifier
	opts.outputfile_path = 'tempfolder/classifierfile'
	cl = Classifier{}
	result = VerifyResult{}
	cl = make_classifier(ds, opts)
	cl = Classifier{}
	result = verify(load_classifier_file('tempfolder/classifierfile') ?, opts)
	assert result.correct_count == 340
	assert result.wrong_count == 36

	println('Done with soybean-large-train.tab using saved classifier')

	if get_environment().arch_details[0] != '4 cpus' {
		opts.datafile_path = 'datasets/mnist_test.tab'
		opts.testfile_path = 'datasets/mnist_test.tab'
		opts.classifierfile_path = ''
		opts.number_of_attributes = [313]
		opts.bins = [2, 2]
		ds = load_file(opts.datafile_path)
		cl = make_classifier(ds, opts)
		result = verify(cl, opts)
		assert result.correct_count == 8207
		assert result.wrong_count == 1793

		println('Done with mnist_test.tab')

		// now with a saved classifier
		opts.outputfile_path = 'tempfolder/classifierfile'
		cl = Classifier{}
		result = VerifyResult{}
		cl = make_classifier(ds, opts)
		cl = Classifier{}
		result = verify(load_classifier_file('tempfolder/classifierfile') ?, opts)
		assert result.correct_count == 8207
		assert result.wrong_count == 1793

		println('Done with mnist_test.tab using saved classifier')
	}

	// if get_environment().arch_details[0] != '4 cpus' {

	// 	cl = Classifier{}
	// 	ds = Dataset{}
	// 	result = VerifyResult{}
	// 	opts.datafile_path = '../../mnist_train.tab'
	// 	opts.testfile_path = ''
	// 	opts.outputfile_path = 'tempfolder/classifierfile'
	// 	opts.number_of_attributes = [313]
	// 	opts.bins = [2, 2]
	// 	opts.concurrency_flag = true
	// 	opts.weighting_flag = false
	// 	ds = load_file(opts.datafile_path)
	// 	cl = make_classifier(ds, opts)
	// 	opts.testfile_path = 'datasets/mnist_test.tab'
	// 	result = verify(load_classifier_file('tempfolder/classifierfile') ?, opts)
	// 	assert result.correct_count == 9566
	// 	assert result.wrong_count == 434

	// 	opts.weighting_flag = true
	// 	cl = make_classifier(ds, opts)
	// 	result = verify(cl, opts)
	// 	assert result.correct_count == 9279
	// 	assert result.wrong_count == 721
	// }
}
