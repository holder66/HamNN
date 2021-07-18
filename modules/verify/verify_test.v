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

	assert verify(cl, opts).correct_count == 171

	

	// opts.datafile_path = 'datasets/mnist_test.tab'
	// opts.testfile_path = 'datasets/mnist_test.tab'
	// opts.number_of_attributes = [50]
	// opts.bins = [2,2]
	// ds = tools.load_file(opts.datafile_path)
	// cl = make.make_classifier(ds, opts)
	// assert verify(cl, opts).correct_count == 9982

	// opts.datafile_path = '/Users/henryolders/mnist_train.tab'
	// opts.testfile_path = 'datasets/mnist_test.tab'
	// opts.number_of_attributes = [313]
	// opts.bins = [2,2]
	// ds = tools.load_file(opts.datafile_path)
	// cl = make.make_classifier(ds, opts)
	// assert verify(cl, opts).correct_count == 9566

}