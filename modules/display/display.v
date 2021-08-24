// display.v
module display

import tools
import os

// display outputs to the console or generates plots for a previously saved
// result
pub fn display(opts tools.Options) {
	mut a := tools.Options{}
	mut b := []tools.VerifyResult{}

	println('opts in display: $opts')
	a, b = read_struct(opts)

	println(a)
	println(b)
}

fn read_struct(opts tools.Options) (tools.Options, []tools.VerifyResult) {
	mut f := os.open_file(opts.datafile_path, 'r') or { panic(err.msg) }
	println('success opening')
	mut result_opts := tools.Options{}
	f.read_struct(mut result_opts) or { panic(err.msg) }
	println('success reading opts')
	// println('result_opts: $result_opts')
	mut results := []tools.VerifyResult{}
	f.read_struct(mut results) or { panic(err.msg) }
	println('success reading results')
	f.close()
	println('success closing file')
	return result_opts, results
}
