// explore_test.v
module explore

import tools

// test_explore
fn test_explore() {
	mut opts := tools.Options{
		verbose_flag: false
		number_of_attributes: [1,4]
		bins: [2,12]
		show_flag: false
		datafile_path: 'datasets/iris.tab'
	}
	mut ds := tools.load_file(opts.datafile_path)
	explore(ds, opts)

	opts.folds = 10
	opts.datafile_path = 'datasets/anneal.tab'
	ds = tools.load_file(opts.datafile_path)
	explore(ds, opts)
}
