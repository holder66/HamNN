// test_analyze
module hamnn

// import main
// import tools

fn test_analyze_dataset() ? {
	mut ds := load_file('datasets/developer.tab')
	mut pr := analyze_dataset(ds)
	print_array(pr)
	assert pr[2..3] == [
		'Analysis of Dataset "datasets/developer.tab" (File Type orange_newer)',
	]
	assert pr[(pr.len - 6)..] == [
		'The Class Attribute: "gender"',
		'Class Value           Cases',
		'____________________  _____',
		'm                         8',
		'f                         3',
		'X                         2',
	]

	ds = load_file('datasets/iris.tab')
	pr = analyze_dataset(ds)
	print_array(pr)

	// // ds = load_file('datasets/prostata.tab')
	// // pr = analyze_dataset(ds)
	// // print_array(pr)

	ds = load_file('datasets/anneal.tab')
	pr = analyze_dataset(ds)
	print_array(pr)
}
