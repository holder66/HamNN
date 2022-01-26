// main_test.v
module main

import os
import tools

// testsuite_begin 
fn testsuite_begin() {
	os.execute_or_panic('v hamnn.v')
}

// run_command_line_tests 
fn run_command_line_tests(s []string) {
	for item in s {
		println(item)
		println(os.execute_or_panic(item).output)
	}
}

// test_load_file_newer verify that load_file works with an orange-newer datafile
fn test_load_file_newer() {
	path := 'datasets/developer.tab'
	ds := tools.load_file(path)
	assert ds.attribute_names == ['firstname', 'lastname', 'age', 'gender', 'height', 'weight',
		'SEC', 'city', 'number', 'negative']
	assert ds.data[0] == ['Henry', 'John', 'Will', 'Flo', 'Star', 'Jonathan', 'Aislin', 'Agatha',
		'Job', 'Broderick', 'Tom', 'Dick', 'Harry']
}

// // test_analyze_datafile
// fn test_analyze_datafile() {
// 	s := [
// 	'./hamnn',
// 	'./hamnn analyze datasets/developer.tab',
// 	'./hamnn analyze datasets/bcw174test',
// 	'./hamnn analyze datasets/iris.tab'
// 	]
// 	run_command_line_tests(s)
// }

// // test_rank_attributes
// fn test_rank_attributes() {
// 	s := [
// 	'./hamnn rank -h',
// 	'./hamnn rank',
// 	'./hamnn rank datasets/developer.tab',
// 	'./hamnn rank -x true -r 3,3 -s  datasets/iris.tab',
// 	'./hamnn rank -r 2,6 -x true --show  datasets/iris.tab',
// 	'./hamnn rank -s --range 2,6 -x true  datasets/iris.tab',
// 	'./hamnn rank -x false --show datasets/iris.tab',
// 	'./hamnn rank -x true -s datasets/anneal.tab',
// 	'./hamnn rank --range 3,5 -s datasets/developer.tab',
// 	'./hamnn rank -s -r 2,6 datasets/developer.tab'
// 	]
// 	run_command_line_tests(s)	
// }

// // test_make_classifier 
// fn test_make_classifier() {
// 	s := [
// 	'./hamnn make -h',
// 	'./hamnn make',
// 	'./hamnn make datasets/developer.tab',
// 	'./hamnn make -x true -r 3,3 -s datasets/iris.tab',
// 	'./hamnn make -r 2,6 -x true --show datasets/iris.tab',
// 	'./hamnn make -s --range 2,6 -x true datasets/iris.tab',
// 	'./hamnn make -x false --show datasets/iris.tab',
// 	'./hamnn make -x true -s datasets/anneal.tab',
// 	'./hamnn make --range 3,5 -s datasets/developer.tab',
// 	'./hamnn make -s -r 2,6 -o testdata/developer.cl datasets/developer.tab'
// 	]
// 	run_command_line_tests(s)
// }

// test_cross_validate 
fn test_cross_validate() {
	s := [
	'./hamnn cross',
	'./hamnn cross -a 2 -b 3,3 -s -c datasets/iris.tab',
	'./hamnn cross -a 2 -b 3,3 -e -c datasets/iris.tab',
	'./hamnn cross -a 2 -b 3,3 -e -f 10 -r 3 datasets/iris.tab']
	run_command_line_tests(s)
}

// test_flag
fn test_flag() {
	mut args := ['rank', '-h']
	assert flag(args, ['-h', '--help', 'help']) == true
}

// test_option
fn test_option() {
	println('option returned: ${option(['2,6', '-x', 'true', 'datasets/iris.tab'], [
		'-x',
		'--exclude',
	])}')
	assert option(['--bins', '2,6', '-x', 'true', 'datasets/iris.tab'], ['-x', '--exclude']) == 'true'
	assert option(['--bins', '2,6', '--exclude', 'false', 'datasets/iris.tab'], ['-x', '--exclude']) == 'false'
	assert option(['-b', '2,6', '-x', 'true', 'datasets/iris.tab'], ['-b', '--bins']) == '2,6'
	assert option(['--bins', '2,6', '-x', 'true', 'datasets/iris.tab'], ['-b', '--bins']) == '2,6'
}
