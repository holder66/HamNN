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
fn test_append() ? {
	mut opts := Options{}
	opts.datafile_path = 'datasets/breast-cancer-wisconsin-disc.tab'
	opts.number_of_attributes = [9]
	ds := load_file(opts.datafile_path)
	result := cross_validate(ds, opts)
	mut c_s := ClassifierSettings{
		classifier_options: result.Parameters
		binary_metrics: result.BinaryMetrics
	}
	append_json_file(c_s, 'tempfolder5/append_file.opts')
	saved := read_multiple_opts('tempfolder5/append_file.opts')!
	assert saved.multiple_classifiers[0] == c_s
	opts.number_of_attributes = [3]
	opts.weighting_flag = true
	result2 := cross_validate(ds, opts)
	mut c_s2 := ClassifierSettings{
		classifier_options: result2.Parameters
		binary_metrics: result2.BinaryMetrics
	}
	append_json_file(c_s2, 'tempfolder5/append_file.opts')
	saved2 := read_multiple_opts('tempfolder5/append_file.opts')!
	assert saved2.multiple_classifiers[0] == c_s
	assert saved2.multiple_classifiers[1] == c_s2
}