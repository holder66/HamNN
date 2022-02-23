// temp_test.v
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

fn test_rank_attributes() {
	mut result := RankingResult{}
	mut opts := Options{
		verbose_flag: false
		command: 'rank'
		number_of_attributes: [3, 5]
		bins: [7]
		show_flag: true
		graph_flag: true
		concurrency_flag: true
		uniform_bins: false
		datafile_path: 'datasets/iris.tab'
	}
	result = rank_attributes(load_file(opts.datafile_path), opts)

	opts.bins = [2, 7]
	result = rank_attributes(load_file(opts.datafile_path), opts)
	opts.bins = [2, 7, 2]
	result = rank_attributes(load_file(opts.datafile_path), opts)
	opts.bins = [6, 6]
	result = rank_attributes(load_file(opts.datafile_path), opts)
	opts.uniform_bins = true

	opts.bins = [7]
	result = rank_attributes(load_file(opts.datafile_path), opts)
	opts.bins = [2, 7]
	result = rank_attributes(load_file(opts.datafile_path), opts)
	opts.bins = [2, 7, 2]
	result = rank_attributes(load_file(opts.datafile_path), opts)

	println('Done with iris.tab')
}

fn test_explore_cross() {
	mut result := ExploreResult{}
	mut opts := Options{
		verbose_flag: false
		graph_flag: true
		command: 'explore'
		number_of_attributes: [3, 5]
		bins: [7]
		show_flag: true
		concurrency_flag: true
		uniform_bins: false
		datafile_path: 'datasets/iris.tab'
	}
	result = explore(load_file(opts.datafile_path), opts)

	opts.bins = [2, 7]
	result = explore(load_file(opts.datafile_path), opts)
	opts.bins = [2, 7, 2]
	result = explore(load_file(opts.datafile_path), opts)

	opts.bins = [6, 6]
	result = explore(load_file(opts.datafile_path), opts)

	opts.uniform_bins = true

	opts.bins = [7]
	result = explore(load_file(opts.datafile_path), opts)
	opts.bins = [2, 7]
	result = explore(load_file(opts.datafile_path), opts)
	opts.bins = [2, 7, 2]
	result = explore(load_file(opts.datafile_path), opts)

	println('Done with iris.tab')
}
