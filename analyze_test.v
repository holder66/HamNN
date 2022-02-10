// test_analyze
module hamnn

fn test_analyze_dataset() ? {
	opts := Options{
		show_flag: true
	}
	mut ds := load_file('datasets/developer.tab')
	mut pr := analyze_dataset(ds, opts)
	

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
