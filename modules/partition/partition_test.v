// partition_test.v
module partition

import tools

// test_get_partition_indices
fn test_get_partition_indices() {
	arr := [11, 22, 33, 44, 55, 66]
	len := arr.len
	// leave-one-out, first fold
	mut s, mut e := get_partition_indices(len, 0, 1)
	assert s == 0
	assert e == 1
	s, e = get_partition_indices(len, 0, 2)
	assert s == 1
	assert e == 2
	s, e = get_partition_indices(len, 0, 6)
	assert s == 5
	assert e == 6
	s, e = get_partition_indices(len, 0, 7)
	assert s == 6
	assert e == 6
	s, e = get_partition_indices(len, 3, 1)
	assert s == 0
	assert e == 2
	s, e = get_partition_indices(len, 3, 2)
	assert s == 2
	assert e == 4
	s, e = get_partition_indices(len, 3, 3)
	assert s == 4
	assert e == 6
	s, e = get_partition_indices(len, 2, 1)
	assert s == 0
	assert e == 3
	s, e = get_partition_indices(len, 2, 2)
	assert s == 3
	assert e == 6
	s, e = get_partition_indices(len, 2, 3)
	assert s == 6
	assert e == 6
}

// test_get_fold
fn test_get_fold() {
	arr := [11, 22, 33, 44, 55, 66]
	assert get_fold(arr, 0, 1) == [11]
	assert get_fold(arr, 1, 2) == [22]
	assert get_fold(arr, 5, 6) == [66]
	assert get_fold(arr, 0, 2) == [11, 22]
	assert get_fold(arr, 2, 4) == [33, 44]
	assert get_fold(arr, 4, 6) == [55, 66]
	assert get_fold(arr, 0, 3) == [11, 22, 33]
	assert get_fold(arr, 3, 6) == [44, 55, 66]
	assert get_fold(arr, 6, 6) == []
	assert get_fold(arr, 0, 0) == []
	assert get_fold(arr, 2, 2) == []
}

// test_get_rest_of_array
fn test_get_rest_of_array() {
	arr := [11, 22, 33, 44, 55, 66]
	assert get_rest_of_array(arr, 0, 1) == [22, 33, 44, 55, 66]
	assert get_rest_of_array(arr, 1, 2) == [11, 33, 44, 55, 66]
	assert get_rest_of_array(arr, 5, 6) == [11, 22, 33, 44, 55]
	assert get_rest_of_array(arr, 0, 2) == [33, 44, 55, 66]
	assert get_rest_of_array(arr, 2, 4) == [11, 22, 55, 66]
	assert get_rest_of_array(arr, 4, 6) == [11, 22, 33, 44]
	assert get_rest_of_array(arr, 0, 3) == [44, 55, 66]
	assert get_rest_of_array(arr, 3, 6) == [11, 22, 33]
	assert get_rest_of_array(arr, 6, 6) == [11, 22, 33, 44, 55, 66]
	assert get_rest_of_array(arr, 0, 0) == [11, 22, 33, 44, 55, 66]
	assert get_rest_of_array(arr, 2, 2) == [11, 22, 33, 44, 55, 66]
}

// test_partition
fn test_partition() {
	mut opts := tools.Options{}
	opts.current_fold = 1 // ie the first fold or partition
	opts.folds = 2
	mut part_ds, fold := partition(tools.load_file('datasets/developer.tab'), opts)
	assert fold.Class.class_values == ['m', 'm', 'm', 'f', 'f', 'm']
	assert part_ds.Class.class_counts == map{
		'X': 2
		'f': 1
		'm': 4
	}
}

// test_classify_fold
fn test_classify_fold() {
	mut opts := tools.Options{
		current_fold: 1 // ie the first fold or partition
		folds: 0
		bins: [2, 2]
		exclude_flag: false
		verbose_flag: false
		number_of_attributes: [2]
	}

	mut part_ds, fold := partition(tools.load_file('datasets/developer.tab'), opts)
	// println(classify_fold(part_ds, fold, opts))
}
