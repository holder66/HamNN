// partition.v
module main

import tools

// partition splits a dataset into a fold set of instances, and the remainder
// of the dataset (ie with the fold instances taken out). Type: `v run hamnn.v partition --help`
/*
Specify in Options
'fold', the total number of folds and 'current_fold', the fold number for this fold to be returned (the first fold is fold 1; changed to fold 0 on 2021-7-13).*/
pub fn partition(current_fold int, folds int, ds tools.Dataset, opts tools.Options) (tools.Dataset, tools.Fold) {
	// fold will be the fold instance, part_ds will be the rest of the dataset.
	mut part_ds := ds
	mut total_instances := ds.Class.class_values.len
	// calculate array indices for partitioning
	mut s, mut e := get_partition_indices(total_instances, folds, current_fold)
	// println('s: $s e: $e')
	// update the Class struct for the rest of the dataset
	part_ds_class_values := get_rest_of_array(ds.Class.class_values, s, e)
	// println('part_ds.Class: $part_ds.Class')
	part_ds.Class = tools.Class{
		class_name: ds.Class.class_name // for some reason, this gets emptied
		class_values: part_ds_class_values
		class_counts: tools.string_element_counts(part_ds_class_values)
	}
	// update the rest of the Dataset struct for the rest
	part_ds.data = tools.transpose(get_rest_of_array(tools.transpose(ds.data), s, e))
	part_ds.useful_continuous_attributes = tools.get_useful_continuous_attributes(part_ds)
	part_ds.useful_discrete_attributes = tools.get_useful_discrete_attributes(part_ds)
	fold_class_values := ds.Class.class_values[s..e]
	fold_data := tools.transpose(tools.transpose(ds.data)[s..e])
	// println('fold_data: $fold_data')
	mut fold := tools.Fold{
		fold_number: current_fold
		attribute_names: ds.attribute_names
		data: fold_data
	}
	fold.Class = tools.Class{
		class_name: ds.Class.class_name
		class_values: fold_class_values
		class_counts: tools.string_element_counts(fold_class_values)
	}
	// println('fold: $fold')
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
	// println('$total $n $curr $fold_size $r $start $end')
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
