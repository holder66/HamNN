// partition_test.v
module partition

import tools

// test_get_partition_indices
fn test_get_partition_indices() {
	mut arr := [11, 22, 33, 44, 55, 66]
	mut len := arr.len
	// leave-one-out, first fold
	mut s, mut e := get_partition_indices(len, 0, 0)
	assert s == 0 && e == 1
	assert arr[s..e] == [11]
	assert get_rest_of_array(arr, s, e) == [22, 33, 44, 55, 66]
	s, e = get_partition_indices(len, 0, 1)
	assert s == 1 && e == 2
	assert arr[s..e] == [22]
	assert get_rest_of_array(arr, s, e) == [11, 33, 44, 55, 66]

	s, e = get_partition_indices(len, 0, 5)
	assert s == 5 && e == 6
	assert arr[s..e] == [66]
	assert get_rest_of_array(arr, s, e) == [11, 22, 33, 44, 55]

	s, e = get_partition_indices(len, 3, 2)
	assert s == 4 && e == 6
	assert arr[s..e] == [55, 66]
	assert get_rest_of_array(arr, s, e) == [11, 22, 33, 44]

	arr = [11, 22, 33, 44, 55, 66, 77, 88, 99, 100, 111, 122, 133]
	len = arr.len
	s, e = get_partition_indices(len, 2, 0)
	assert s == 0
	assert e == 7
	assert arr[s..e] == [11, 22, 33, 44, 55, 66, 77]
	assert get_rest_of_array(arr, s, e) == [88, 99, 100, 111, 122, 133]

	s, e = get_partition_indices(len, 2, 1)
	assert s == 7
	assert e == 13
	assert arr[s..e] == [88, 99, 100, 111, 122, 133]
	assert get_rest_of_array(arr, s, e) == [11, 22, 33, 44, 55, 66, 77]

	s, e = get_partition_indices(len, 3, 1)
	assert s == 4
	assert e == 8
	assert arr[s..e] == [55, 66, 77, 88]
	assert get_rest_of_array(arr, s, e) == [11, 22, 33, 44, 99, 100, 111, 122, 133]

	s, e = get_partition_indices(len, 3, 2)
	assert s == 8
	assert e == 13
	assert arr[s..e] == [99, 100, 111, 122, 133]
	assert get_rest_of_array(arr, s, e) == [11, 22, 33, 44, 55, 66, 77, 88]

	s, e = get_partition_indices(len, 4, 2)
	assert s == 6
	assert e == 9
	assert arr[s..e] == [77, 88, 99]
	assert get_rest_of_array(arr, s, e) == [11, 22, 33, 44, 55, 66, 100, 111, 122, 133]

	s, e = get_partition_indices(len, 4, 3)
	assert s == 9
	assert e == 13
	assert arr[s..e] == [100, 111, 122, 133]
	assert get_rest_of_array(arr, s, e) == [11, 22, 33, 44, 55, 66, 77, 88, 99]

	s, e = get_partition_indices(len, 5, 2)
	assert s == 6
	assert e == 9
	assert arr[s..e] == [77, 88, 99]
	assert get_rest_of_array(arr, s, e) == [11, 22, 33, 44, 55, 66, 100, 111, 122, 133]

	s, e = get_partition_indices(len, 5, 4)
	assert s == 12
	assert e == 13
	assert arr[s..e] == [133]
	assert get_rest_of_array(arr, s, e) == [11, 22, 33, 44, 55, 66, 77, 88, 99, 100, 111, 122]

	s, e = get_partition_indices(len, 6, 5)
	assert s == 10
	assert e == 13
	assert arr[s..e] == [111, 122, 133]
	assert get_rest_of_array(arr, s, e) == [11, 22, 33, 44, 55, 66, 77, 88, 99, 100]
}

// test_partition
fn test_partition() {
	mut opts := tools.Options{}
	mut part_ds, mut fold := partition(0, 2, tools.load_file('datasets/developer.tab'),
		opts)
	assert fold.Class.class_values == ['m', 'm', 'm', 'f', 'f', 'm', 'X']
	assert part_ds.Class.class_counts == {
		'X': 1
		'f': 1
		'm': 4
	}

	// part_ds, fold = partition(0, 149, tools.load_file('datasets/iris.tab'), opts)
	// println(fold)
}
