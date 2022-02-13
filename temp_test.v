// temp_test.v
module hamnn

fn test_temp() {
	mut result := RankingResult {}
	mut opts := Options{
		datafile_path: 'datasets/developer.tab'
		graph_flag: true
	}
	result = rank_attributes(load_file(opts.datafile_path), opts)
	opts.exclude_flag = true
	result = rank_attributes(load_file(opts.datafile_path), opts)
	opts.exclude_flag = false
	opts.datafile_path = 'datasets/anneal.tab'
	result = rank_attributes(load_file(opts.datafile_path), opts)
	opts.exclude_flag = true
	result = rank_attributes(load_file(opts.datafile_path), opts)

}