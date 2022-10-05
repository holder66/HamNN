// oxplot_test.v

module hamnn

import os
import strconv
import vplot

fn testsuite_begin() ? {
	if os.is_dir('tempfolder1') {
		os.rmdir_all('tempfolder1')?
	}
	os.mkdir_all('tempfolder1')?
}

fn testsuite_end() ? {
	os.rmdir_all('tempfolder1')?
}

fn inds(a []f64) []f64 {
	mut s := []f64{}
	for i in 0 .. a.len { s << i}
	return s
}

// test_load_file
fn test_load_file() {
	mut ds := Dataset{}
	ds = load_file('/Users/henryolders/Oxford-train.tab')
	// println(ds.data[4])
	println('ds.data[4].len: ${ds.data[4].len}')
	println('ds.useful_continuous_attributes[3].len: ${ds.useful_continuous_attributes[3].len}')
	path := '/Users/henryolders/Oxford-train.tab'
	content := os.read_lines(path.trim_space()) or { panic('failed to open $path') }
	mut spectra := content[1..].map(extract_words(it))
	println(spectra[0].len)
	mut nums := []f64{}
	mut p1 := vplot.new()
	p1.style('lines')
	for a in spectra {
		nums = []
		nums << a.map(f64(strconv.atof_quick(it)))
		p1.plot2(inds(nums[3..]),nums[3..], 'Spectra') or {
			println('ERROR: ${err.msg()}')
	}
}
	os.input('Press any key to continue')
	p1.close()

}
	// println(nums)

