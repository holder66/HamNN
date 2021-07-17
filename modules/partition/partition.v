// partition.v
module partition

import tools
// import make
import math

// partition splits a dataset into a fold set of instances, and the remainder
// of the dataset (ie with the fold instances taken out). Type: `v run hamnn.v partition --help`
/*
Specify in Options
'fold', the total number of folds and 'current_fold', the fold number for this fold to be returned (the first fold is fold 1).*/
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
	part_ds.Class = {
		class_name: ds.Class.class_name // for some reason, this gets emptied
		class_values: part_ds_class_values
		class_counts: tools.string_element_counts(part_ds_class_values)
	}
	// update the rest of the Dataset struct for the rest
	part_ds.data = tools.transpose(get_rest_of_array(tools.transpose(ds.data), s, e))
	part_ds.useful_continuous_attributes = tools.get_useful_continuous_attributes(part_ds)
	part_ds.useful_discrete_attributes = tools.get_useful_discrete_attributes(part_ds)

	fold_class_values := get_fold(ds.Class.class_values, s, e)
	fold_data := tools.transpose(get_fold(tools.transpose(ds.data), s, e))
	mut fold := tools.Fold{
		fold_number: current_fold
		attribute_names: ds.attribute_names
		data: fold_data
	}
	fold.Class = {
		class_name: ds.Class.class_name
		class_values: fold_class_values
		class_counts: tools.string_element_counts(fold_class_values)
	}
	// println('fold: $fold')
	return part_ds, fold
}

// get_partition_indices returns indices s & e, for the start and end of a fold,
// given the total number of indices total, the number of folds n, and the fold number
// curr of current fold (using 1-based counting, ie the first fold is curr = 1)
// changing this to zero-based counting 2021-7-13
fn get_partition_indices(total int, n int, curr int) (int, int) {
	mut n1 := n
	if n == 0 {
		n1 = total
	}
	round := int(math.round(total / n1))
	// s := (curr - 1) * round
	s := curr * round
	mut e := s + round
	if e > total {
		e = total
	}
	return s, e
}

// get_fold given start and end indices s & e, returns an array slice
fn get_fold<T>(arr []T, s int, e int) []T {
	// println('$arr $s $e')
	return arr[s..e]
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
