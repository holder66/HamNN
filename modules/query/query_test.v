// query_test.v
module query

import tools
import make
import os

// Because query requires input from the console, and V does not
// have a way to "mock" those inputs, this test file should be
// disabled when running the entire hamnn test suite.

// fn testsuite_begin() ? {
// 	if os.is_dir('tempfolder') {
// 	os.rmdir_all('tempfolder') ?
// }
// 	os.mkdir_all('tempfolder') ?
// }

// fn testsuite_end() ? {
// 	os.rmdir_all('tempfolder') ?
// }

// // test_query
// fn test_query() {
// 	mut opts := tools.Options{
// 		number_of_attributes: [2]
// 		bins: [2, 2]
// 		exclude_flag: false
// 		verbose_flag: false
// 	}
// 	responses := map{
// 		'lastname': 'Booker'
// 		'height':   '120'
// 	}
// 	mut cl := make.make_classifier(tools.load_file('datasets/developer.tab'), opts)
// 	println(query(cl, opts))

// }
