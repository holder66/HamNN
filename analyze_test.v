// test_analyze
module hamnn

fn test_analyze_dataset() ? {
	opts := Options{
		show_flag: false
	}
	// orange_newer file
	mut ds := load_file('datasets/developer.tab')
	mut pr := analyze_dataset(ds, opts)
	assert pr.datafile_path == 'datasets/developer.tab'
	assert pr.datafile_type == 'orange_newer'
	assert pr.attributes[2].name == 'age'
	assert pr.attributes[9].min == -90
	assert pr.class_counts == {
		'm': 8
		'f': 3
		'X': 2
	}

	// orange_older file
	ds = load_file('datasets/iris.tab')
	pr = analyze_dataset(ds, opts)
	assert pr.datafile_path == 'datasets/iris.tab'
	assert pr.datafile_type == 'orange_older'
	assert pr.attributes[2].name == 'petal length'
	assert pr.attributes[3].max == 2.5
	assert pr.class_counts == {
		'Iris-setosa':     50
		'Iris-versicolor': 50
		'Iris-virginica':  50
	}
}
