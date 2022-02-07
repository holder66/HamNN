// explore_test.v
module hamnn

fn test_explore_cross() {
	println(get_environment())
	mut results := []VerifyResult{}
	mut opts := Options{
		verbose_flag: false
		number_of_attributes: [1, 4]
		bins: [2, 7]
		show_flag: false
		concurrency_flag: true
		uniform_bins: true
		datafile_path: 'datasets/iris.tab'
	}
	mut ds := load_file(opts.datafile_path)
	results = explore(ds, opts)
	// println(results)
	assert results[0].correct_count == 100
	assert results[0].misses_count == 50
	assert results[0].wrong_count == 50
	assert results[0].total_count == 150

	// opts.uniform_bins = false
	// opts.bins = [10,12]
	// results = explore(ds, opts)
	// // println(results)
	// assert results.last().correct_count == 141
	// assert results.last().misses_count == 9
	// assert results.last().wrong_count == 9
	// assert results.last().total_count == 150

	println('Done with iris.tab')

	// opts.folds = 10
	// opts.number_of_attributes = [27, 29]
	// opts.bins = [20, 22]
	// opts.weighting_flag = true
	// opts.datafile_path = 'datasets/anneal.tab'
	// opts.uniform_bins = true
	// ds = load_file(opts.datafile_path)
	// results = explore(ds, opts)
	// assert results[1].correct_count == 875
	// assert results[1].misses_count == 23
	// assert results[1].wrong_count == 23
	// assert results[1].total_count == 898

	// opts.uniform_bins = false
	// results = explore(ds, opts)
	// assert results[1].correct_count == 878
	// assert results[1].misses_count == 20
	// assert results[1].wrong_count == 20
	// assert results[1].total_count == 898

	// println('Done with anneal.tab')
}

// fn test_explore_verify() {
// 	mut opts := Options{
// 		concurrency_flag: true
// 		weighting_flag: true
// 		testfile_path: 'datasets/bcw174test'
// 		datafile_path: 'datasets/bcw350train'
// 	}
// 	mut ds := load_file(opts.datafile_path)
// 	mut results := explore(ds, opts)
// 	assert results[7].correct_count == 170
// 	assert results[7].wrong_count == 4
// }
