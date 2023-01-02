// save_settings_test.v

module hamnn

import os

fn testsuite_begin() ? {
	if os.is_dir('tempfolder5') {
		os.rmdir_all('tempfolder5')!
	}
	os.mkdir_all('tempfolder5')!
}

// fn testsuite_end() ? {
// 	os.rmdir_all('tempfolder5')!
// }

// test_append 
// fn test_append() ? {
// 	mut opts := Options{}
// 	opts.datafile_path = 'datasets/breast-cancer-wisconsin-disc.tab'
// 	opts.number_of_attributes = [9]
// 	ds := load_file(opts.datafile_path)
// 	result := cross_validate(ds, opts)
// 	// println(result)
// 	mut mult_opts := MultipleOptions{}
// 		mult_opts.classifier_options << result.Parameters
// 		mult_opts.binary_metrics << result.BinaryMetrics
// 	// println(mult_opts)
// 	append_json_file(mult_opts, 'tempfolder5/append_file.opts')
// 	// saved := read_multiple_opts('tempfolder5/append_file.opts')!
// 	// assert saved == mult_opts
// 	opts.number_of_attributes = [3]
// 	opts.weighting_flag = true
// 	result2 := cross_validate(ds, opts)
// 	// println(result2)
// 	mut mult_opts2 := MultipleOptions{}
// 	mult_opts2.classifier_options << result2.Parameters
// 	mult_opts2.binary_metrics << result2.BinaryMetrics
// 	append_json_file(mult_opts2, 'tempfolder5/append_file.opts')
// 	saved2 := read_multiple_opts('tempfolder5/append_file.opts')!
// 	// println(saved2)
// }