// partition.v
module hamnn

// partition splits a dataset into a fold set of instances, and the remainder
// of the dataset (ie with the fold instances taken out).
fn partition(pick_list []int, current_fold int, folds int, ds Dataset, opts Options) (Dataset, Fold) {
	// fold will be the fold instance, part_ds will be the rest of the dataset.
	mut part_ds := ds
	mut total_instances := ds.Class.class_values.len
	mut fold_data := [][]string{}
	mut fold_class_values := []string{}
	mut part_ds_class_values := []string{}

	// calculate array indices for partitioning
	mut s, mut e := get_partition_indices(total_instances, folds, current_fold)
	// println('s: $s e: $e')
	mut fold_indices := pick_list[s..e]
	mut part_indices := get_rest_of_array(pick_list, s, e)
	println('fold_indices, part_indices: $fold_indices $part_indices')
	// update the Class struct for the rest of the dataset
	part_ds_class_values = get_rest_of_array(ds.Class.class_values, s, e)
	// println('part_ds.Class: $part_ds.Class')
	part_ds.Class = Class{
		class_name: ds.Class.class_name // for some reason, this gets emptied
		class_values: part_ds_class_values
		class_counts: string_element_counts(part_ds_class_values)
	}
	// update the rest of the Dataset struct for the rest
	part_ds.data = transpose(get_rest_of_array(transpose(ds.data), s, e))
	part_ds.useful_continuous_attributes = get_useful_continuous_attributes(part_ds)
	part_ds.useful_discrete_attributes = get_useful_discrete_attributes(part_ds)
	fold_class_values = ds.Class.class_values[s..e]
	fold_data = transpose(transpose(ds.data)[s..e])

	mut fold := Fold{
		fold_number: current_fold
		attribute_names: ds.attribute_names
		data: fold_data
	}
	fold.Class = Class{
		class_name: ds.Class.class_name
		class_values: fold_class_values
		class_counts: string_element_counts(fold_class_values)
	}

	// get fold info using
	return part_ds, fold
}

// get_partition_indices returns indices start & end, for the start and end of a fold, given the total number of indices `total`, the number of folds `n`, and the fold number `curr`
fn get_partition_indices(total int, n int, curr int) (int, int) {
	mut start := 0
	mut end := 0
	if n == 0 { // ie each fold will be length 1, thus the total number of folds
		// will be the same as the array length
		return curr, curr + 1
	}
	if curr > n || n == 1 {
		return 0, 0
	}
	mut n1 := f64(n)
	real := total / n1
	mut fold_size := int(real) + 1
	r := (n * fold_size) - total
	if curr < r {
		start = curr * (fold_size - 1)
		end = start + fold_size - 1
	} else {
		start = curr * fold_size - r
		end = start + fold_size
	}
	return start, end
}

// get_rest_of_array given the start s and the end e of the slice to be removed,
// returns the rest of the array
fn get_rest_of_array<T>(arr []T, s int, e int) []T {
	mut rest := []T{}
	for i, val in arr {
		if i < s || i >= e {
			rest << val
		}
	}
	return rest
}

// get_rest_after_random takes out of an array, the elements whose indices are
// given in `indices`
fn get_rest_after_random<T>(arr []T, indices []int) []T {
	mut rest := []T{}
	for i, val in arr {
		if i in indices {
			continue
		} else {
			rest << val
		}
	}
	return rest
}
