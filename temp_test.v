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
fn test_temp() {
}
