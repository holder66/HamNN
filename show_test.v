// show_test.v
module hamnn

// import os

// test_show_analyze has no asserts; the console output needs
// to be verified visually.
fn test_show_analyze() {
	mut opts := Options{
		show_flag: false
	}
	mut ar := AnalyzeResult{}

	ar = analyze_dataset(load_file('datasets/developer.tab'), opts)
	show_analyze(ar)

	ar = analyze_dataset(load_file('datasets/iris.tab'), opts)
	show_analyze(ar)
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
