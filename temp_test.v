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
// test_temp 
fn test_temp() ? {
	
println('\n\niris.tab')
	mut opts := Options{}
	opts.show_flag = true
	opts.command = 'cross'
	opts.expanded_flag = false
	opts.bins = [3, 6]
	opts.number_of_attributes = [2]
	mut cvr := cross_validate(load_file('datasets/iris.tab'), opts)
	println('\n\niris.tab with expanded results')
	opts.expanded_flag = true
	cvr = cross_validate(load_file('datasets/iris.tab'), opts)
}
