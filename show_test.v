// show_test.v
module hamnn

// import os

// test_show
fn test_show() {
	mut opts := Options{
		show_flag: true
	}
	mut ds := load_file('datasets/iris.tab')
	assert show(analyze_dataset(ds)) == '[]string'
	mut cl := make_classifier(ds, opts)
	mut s := typeof(cl).name
	println(typeof(s).name)
	// assert show(cl) == ''
}

fn test_show_analyze() {
	show_analyze(load_file('datasets/iris.tab'))
	show_analyze(load_file('datasets/anneal.tab'))
	// assert pr[2..3] == [
	// 	'Analysis of Dataset "datasets/developer.tab" (File Type orange_newer)',
	// ]

	// assert pr[9..11] == [
	// 	'    3  gender                           13        3        0   0.0   c',
	// 	'    4  height                           13        9        2  15.4   C',
	// ]

	// assert pr[(pr.len - 6)..] == [
	// 	'The Class Attribute: "gender"',
	// 	'Class Value           Cases',
	// 	'____________________  _____',
	// 	'm                         8',
	// 	'f                         3',
	// 	'X                         2',
	// ]

	// assert pr[21..24] == [
	// 	'____        _____',
	// 	'i               1',
	// 	'D               3',
	// ]

	// assert pr[31..34] == [
	// 	'     1  lastname                             7',
	// 	'     6  SEC                                  5',
	// 	'     7  city                                 5',
	// ]

	ds = load_file('datasets/iris.tab')
	pr = analyze_dataset(ds, opts)

	// assert pr[28..32] == [
	// 	'     0  sepal length                 4.300       7.900',
	// 	'     1  sepal width                      2       4.400',
	// 	'     2  petal length                     1       6.900',
	// 	'     3  petal width                  0.100       2.500',
	// ]

	// ds = load_file('datasets/anneal.tab')
	// pr = analyze_dataset(ds)

	// assert pr[8..12] == [
	// 	'    2  steel                           898        8       86   9.6   D',
	// 	'    3  carbon                          898       10        0   0.0   C',
	// 	'    4  hardness                        898        7        0   0.0   C',
	// 	'    5  temper_rolling                  898        2      761  84.7   D',
	// ]
}

// test_show_append
fn test_show_append() ? {
	opts := Options{
		show_flag: true
		testfile_path: 'datasets/test_validate.tab'
	}
	mut cl := Classifier{}
	mut ext_cl := Classifier{}
	cl = make_classifier(load_file('datasets/test.tab'), opts)
	mut instances_to_append := validate(cl, opts) ?
	show_classifier(append_instances(cl, instances_to_append, opts))
}

// test_show_classifier
fn test_show_classifier() {
	mut opts := Options{
		show_flag: true
	}
	mut ds := load_file('datasets/iris.tab')
	assert show(analyze_dataset(ds)) == '[]string'
	mut cl := make_classifier(ds, opts)
}

// test_show_verify
fn test_show_verify() {
	// mut s := './hamnn verify -c -s -t datasets/bcw174test datasets/bcw350train'
	// println(s)
	// println(os.execute_or_panic(s))
	// s = './hamnn verify -c -e -t datasets/bcw174test datasets/bcw350train'
	// println(s)
	// println(os.execute_or_panic(s))
	// s = './hamnn verify -c -s -t datasets/soybean-large-test.tab datasets/soybean-large-train.tab'
	// println(s)
	// println(os.execute_or_panic(s))
	// s = './hamnn verify -c -e -t datasets/soybean-large-test.tab datasets/soybean-large-train.tab'
	// println(s)
	// println(os.execute_or_panic(s))
}

// test_show_cross
fn test_show_cross() {
	// mut s := './hamnn cross -c -s -a 2 -b 3,3 datasets/iris.tab'
	// println(s)
	// println(os.execute_or_panic(s))
	// s = './hamnn cross -c -e -a 2 -b 3,3 datasets/iris.tab'
	// println(s)
	// println(os.execute_or_panic(s))
	// s = './hamnn cross -c -s datasets/breast-cancer-wisconsin-disc.tab'
	// println(s)
	// println(os.execute_or_panic(s))
	// s = './hamnn cross -c -e datasets/breast-cancer-wisconsin-disc.tab'
	// println(s)
	// println(os.execute_or_panic(s))
}

// test_show_explore
fn test_show_explore() {
	// mut s := './hamnn explore -c -s  -b 3,6 datasets/iris.tab'
	// println(s)
	// println(os.execute_or_panic(s))
	// s = './hamnn explore -c -e  -b 3,6 datasets/iris.tab'
	// println(s)
	// println(os.execute_or_panic(s))
	// s = './hamnn explore -c -s datasets/breast-cancer-wisconsin-disc.tab'
	// println(s)
	// println(os.execute_or_panic(s))
	// s = './hamnn explore -c -e datasets/breast-cancer-wisconsin-disc.tab'
	// println(s)
	// println(os.execute_or_panic(s))
}
