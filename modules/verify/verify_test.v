// verify_test.v
module verify

import tools
import make

// test_verify
fn test_verify() {
	mut opts := tools.Options{
		datafile_path: 'datasets/test.tab'
		testfile_path: 'datasets/test_verify.tab'
		number_of_attributes: [0]
		bins: [2, 3]
		verbose_flag: false
		command: 'verify'
		show_flag: false
		concurrency_flag: true
	}
	mut ds := tools.load_file(opts.datafile_path)
	mut cl := make.make_classifier(ds, opts)

	assert verify(cl, opts).correct_count == 10

	opts.datafile_path = 'datasets/bcw350train'
	opts.testfile_path = 'datasets/bcw174test'
	opts.number_of_attributes = [4]
	opts.bins = [2, 4]
	ds = tools.load_file(opts.datafile_path)
	cl = make.make_classifier(ds, opts)
	mut result := verify(cl, opts)
	assert result.correct_count == 171
	assert result.wrong_count == 3

	opts.datafile_path = 'datasets/mnist_test.tab'
	opts.testfile_path = 'datasets/mnist_test.tab'
	opts.number_of_attributes = [50]
	opts.bins = [2,2]
	ds = tools.load_file(opts.datafile_path)
	cl = make.make_classifier(ds, opts)
	result = verify(cl, opts)
	assert result.correct_count == 9982
	assert result.wrong_count == 18

	opts.datafile_path = 'datasets/soybean-large-train.tab'
	opts.testfile_path = 'datasets/soybean-large-test.tab'
	opts.number_of_attributes = [33]
	opts.bins = [2, 16]
	opts.weighting_flag = true 
	opts.expanded_flag = false
	ds = tools.load_file(opts.datafile_path)
	cl = make.make_classifier(ds, opts)
	result = verify(cl, opts)
	assert result.correct_count == 335
	assert result.wrong_count == 41

	opts.datafile_path = '/Users/henryolders/mnist_train.tab'
	opts.testfile_path = 'datasets/mnist_test.tab'
	opts.number_of_attributes = [313]
	opts.bins = [2,2]
	opts.concurrency_flag = true
	opts.weighting_flag = false
	ds = tools.load_file(opts.datafile_path)
	cl = make.make_classifier(ds, opts)
	result = verify(cl, opts)
	assert result.correct_count == 9566
	assert result.wrong_count == 434
	
	opts.weighting_flag = true
	cl = make.make_classifier(ds, opts)
	result = verify(cl, opts)
	assert result.correct_count == 9279
	assert result.wrong_count == 721
}
