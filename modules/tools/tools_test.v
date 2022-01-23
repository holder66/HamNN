// tools_test.v
module tools

// import arrays

fn test_transpose() {
	matrix := [['1', '2', '3'], ['4', '5', '6']]
	assert transpose(matrix) == [['1', '4'], ['2', '5'], ['3', '6']]
	matrix2 := [[1, 2, 3], [4, 5, 6]]
	assert transpose(matrix2) == [[1, 4], [2, 5], [3, 6]]
}

fn test_element_counts() {
	assert string_element_counts(['i']) == {
		'i': 1
	}
	assert string_element_counts([]) == map[string]int{}
	mut elements := ['i', '', 'w', 'cD', 'C', 'm', '', 'T', 'S', '']
	assert string_element_counts(elements) == {
		'i':  1
		'':   3
		'w':  1
		'cD': 1
		'C':  1
		'm':  1
		'T':  1
		'S':  1
	}
}

/*
The existing attribute type codes are, for orange-newer:
Attribute names in the column header can be preceded with a label followed by a hash. Use c for class and m for meta attribute, i to ignore a column, w for weights column, and C, D, T, S for continuous, discrete, time, and string attribute types. Examples: C#mph, mS#name, i#dummy.
If no prefix, treat numbers as continuous, otherwise discrete
*/
fn test_infer_attribute_types_newer() {
	mut ds := load_orange_newer_file('datasets/developer.tab')
	// println('types from file: $ds.attribute_types')
	types := ds.attribute_types
	ds.attribute_types = ['i', '', 'w', 'cD', 'C', 'm', '', 'T', 'S', '']
	assert infer_attribute_types_newer(ds) == ['i', 'D', 'i', 'c', 'C', 'i', 'D', 'i', 'i', 'C']
}

fn test_infer_type_from_data() {
	assert infer_type_from_data([]) == 'i' // ignore if no data
	assert infer_type_from_data(['1', '2', '3']) == 'D' // all integers,
	assert infer_type_from_data(['3', '3', '3']) == 'i'
	assert infer_type_from_data(['', '', '', '?']) == 'i'
	assert infer_type_from_data(['', '?', '1', '2', '3']) == 'D'
	assert infer_type_from_data(['', '?', '1', '2', '3', '15']) == 'C'
	assert infer_type_from_data(['i', '', 'w', 'cD', 'C', 'm', '', 'T', 'S', '']) == 'D'
	assert infer_type_from_data(['3.14', '2']) == 'C'
	assert infer_type_from_data(['?', '', '3.14', '2']) == 'C'
	assert infer_type_from_data(['?', '', '4800', '3.14', '2']) == 'C'
}

fn test_parse_range() {
	assert parse_range('256,257') == [256, 257]
	assert parse_range('') == [0]
	assert parse_range('256,257,abc') == [256, 257, 0]
	assert parse_range('abc,3') == [0, 3]
	assert parse_range('3,3') == [3, 3]
	assert parse_range('4,5,2') == [4, 5, 2]
	assert parse_range('0') == [0]
	assert parse_range('5') == [5]
}

// test_min
// fn test_min() {
// 	// mut values := []{}f32
// 	// values = [1.0, 2.0, 3.0]
// 	println(min([1.0, 2.0, 3.0]))
// }

// test_discretize_attribute
fn test_discretize_attribute() {
	mut values := [1.0, 2, 0, 3.0]
	assert discretize_attribute(values, min(values), max(values), 3) == [
		2,
		3,
		1,
		3,
	]
	mut values_int := [-10, -5, 0, 5, 10, 15, 19, 20]
	assert discretize_attribute(values_int, min(values_int), max(values_int), 3) == [
		1,
		1,
		2,
		2,
		3,
		3,
		3,
		3,
	]
	assert discretize_attribute(values_int, min(values_int), max(values_int), 2) == [
		1,
		1,
		1,
		2,
		2,
		2,
		2,
		2,
	]
	assert discretize_attribute(values_int, min(values_int), max(values_int), 1) == [
		1,
		1,
		1,
		1,
		1,
		1,
		1,
		1,
	]
	values = [1.0, 2, 0, -3.4028234663852886e+38, 3.0]
	assert discretize_attribute(values, 0.0, max(values), 3) == [2, 3, 1, 0, 3]
	values = [-10.0, -5, 0, 5, -3.4028234663852886e+38, 10, 15, 19, 20]
	assert discretize_attribute(values, -10.0, max(values), 3) == [1, 1, 2, 2, 0, 3, 3, 3, 3]
}

// test_get_map_values
fn test_get_map_values() {
	mut elements := ['i', '', 'w', 'cD', 'C', 'm', '', 'T', 'S', '']
	assert get_map_values(string_element_counts(elements)) == [1, 3, 1, 1, 1, 1, 1, 1]
}

// test_convert_to_one_bit
fn test_convert_to_one_bit() {
	assert convert_to_one_bit(0) == 0
	assert convert_to_one_bit(1) == 1
	assert convert_to_one_bit(3) == 8
	assert convert_to_one_bit(8) == 256
	assert convert_to_one_bit(16) == 65536
	assert convert_to_one_bit(31) == 2147483648
	assert convert_to_one_bit(32) == 1 // wraps around
}

// test_hamming_distance
fn test_hamming_distance() {
	assert hamming_distance([u32(1)], [u32(0)]) == 1
	assert hamming_distance([u32(1)], [u32(2)]) == 2
	assert hamming_distance([u32(1)], [u32(1)]) == 0
	assert hamming_distance([u32(0)], [u32(0)]) == 0
	assert hamming_distance([u32(1), u32(1), u32(1), u32(0)], [u32(0), u32(2), u32(1), u32(0)]) == 3
}

// test_lcm
fn test_lcm() {
	mut arr := [2, 3, 8]
	assert lcm(arr) == 24
	arr = [11, 22, 33, 44, 55, 66]
	assert lcm(arr) == 660
	arr = [5421, 5923, 6742, 5949, 5958, 6131, 5918, 6265, 5851]
	assert lcm(arr) == 2726317818350369934
}
