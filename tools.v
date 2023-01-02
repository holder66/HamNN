// v contains functions used elsewhere in hamnn
module hamnn

// import arrays
import math
import os
import json

// save_json_file
fn save_json_file[T](u T, path string) {
	s := json.encode(u)
	mut f := os.open_file(path, 'w') or { panic(err.msg()) }
	f.write_string(s) or { panic(err.msg()) }
	f.close()
}

// append_json_file 
fn append_json_file[T](u T, path string) {
	s := json.encode(u)
	mut f := os.open_append(path) or { panic(err.msg()) }
	f.write_string(s) or { panic(err.msg()) }
	f.close()
}

// idx_true returns the index of the first true element in boolean array a.
// Returns -1 if no true element found.
fn idx_true(a []bool) int {
	for i, val in a {
		if val {
			return i
		}
	}
	return -1
}

// transpose a 2d array
fn transpose[T](matrix [][]T) [][]T {
	mut matrix_t := [][]T{len: matrix[0].len, init: []T{len: matrix.len}}
	for i, row_element in matrix {
		for j, col_element in row_element {
			matrix_t[j][i] = col_element
		}
	}
	return matrix_t
}

// string_element_counts returns a map with the counts for each element in an array of strings
fn string_element_counts(array []string) map[string]int {
	mut counts := map[string]int{}
	for word in array {
		counts[word]++
	}
	return counts
}

// integer_element_counts returns a map with the counts for each element in an array of integers
fn integer_element_counts(array []int) map[int]int {
	mut counts := map[int]int{}
	for word in array {
		counts[word]++
	}
	return counts
}

pub fn element_counts[T](array []T) map[T]int {
	mut counts := map[T]int{}
	for element in array {
		counts[element]++
	}
	return counts
}

// parse_range takes a string like '3,6,8' and returns [3, 6, 8]
fn parse_range(arg string) []int {
	mut str := arg
	mut res := [arg.int()]
	for _ in 0 .. (arg.len - 1) {
		str = str[1..]
		if str[0] == 44 {
			res << str[1..].int()
		}
	}
	return res
}

// last returns the last element of a string array
fn last(array []string) string {
	return array[array.len - 1]
}

// print_array
fn print_array(array []string) {
	for line in array {
		println(line)
	}
}

// get_map_values returns an array of a map's values (for integer values)
fn get_map_values(input map[string]int) []int {
	mut values := []int{}
	for _, value in input {
		values << value
	}
	return values
}

// get_integer_keys returns the keys for an integer map
fn get_integer_keys(input map[int]int) []int {
	mut keys := []int{}
	for key, _ in input {
		keys << key
	}
	return keys
}

// get_string_keys returns the string keys for a map
fn get_string_keys(input map[string]int) []string {
	mut keys := []string{}
	for key, _ in input {
		keys << key
	}
	return keys
}

// discretize_attribute returns an array of integers representing bin numbers
// bin numbers start at 1; bin 0 is for missing values (represented by
// -math.max_f32 for f32 values; TBD for integer values)
/*
plan for dealing with missing values in continuous attributes:
first, calculate the minimum and maximum values, filtering for missing values
create an index (for cases) for missing values
alternatively, substitute -max_f32 for missing values
use the previously calculated min and max to discretize. The routine should set the bin number to 0 when it encounters -max_f32
*/
// pub fn discretize_attribute(values []f32, min f32, max f32, bins int) []int {
fn discretize_attribute[T](values []T, min T, max T, bins int) []int {
	// println('$min  $max  $bins')
	mut bin_values := []int{}
	mut bin := bins
	bin_size := (max - min) / bins
	for value in values {
		if value == -math.max_f32 {
			bin = 0
		} else if value == max {
			bin = bins
		} else {
			bin = int((value - min) / bin_size) + 1
		}
		bin_values << bin
	}
	return bin_values
}

// bin_values_array
fn bin_values_array[T](values []T, min T, max T, bins int) []u8 {
	bin_size := (max - min) / bins
	mut bin_values := []u8{}
	mut bin := u8(0)
	for value in values {
		if value == -math.max_f32 {
			bin = u8(0)
		} else if value == max {
			bin = u8(bins)
		} else {
			bin = u8(int((value - min) / bin_size) + 1)
		}
		bin_values << bin
	}
	return bin_values
}

// bin_single_value
fn bin_single_value[T](value T, min T, max T, bins int) byte {
	bin_size := (max - min) / bins
	mut bin := u8(0)
	if value == -math.max_f32 {
		bin = u8(0)
	} else if value == max {
		bin = u8(bins)
	} else {
		bin = u8(int((value - min) / bin_size) + 1)
	}
	return bin
}

// convert_to_one_bit
fn convert_to_one_bit(value int) u32 {
	mut one_bit := u32(0)
	if value == 1 {
		one_bit = u32(1)
	} else if value > 1 {
		one_bit = 1 << value
	}
	return one_bit
}

// hamming_distance returns the Hamming distance between two arrays of bit
// values; it is predicated on each value having at most one bit set.
fn hamming_distance(a []u32, b []u32) int {
	mut sum := 0
	for i in 0 .. a.len {
		mut d := 0
		if a[i] ^ b[i] != 0 {
			if a[i] != 0 && b[i] != 0 {
				d = 2
			} else {
				d = 1
			}
		}
		sum += d
	}
	return sum
}

// lcm returns the least common multiple of an array of integers
fn lcm(arr []int) i64 {
	mut numbers := arr.clone()
	mut res := i64(1)
	mut x := 2
	mut indexes := []int{}
	for x <= array_max(numbers) {
		indexes = []
		for i, val in numbers {
			if val % x == 0 {
				indexes << i
			}
		}
		if indexes.len >= 2 {
			for index in indexes {
				numbers[index] = numbers[index] / x
			}
			res *= x
		} else {
			x += 1
		}
	}
	for val in numbers {
		res *= val
	}
	// println('res in lcm: $res')
	return res
}

// array_min returns the minimum value in the array
fn array_min[T](a []T) T {
	// if a.len == 0 {
	// 	return error('.min called on an empty array')
	// }
	mut val := a[0]
	for e in a {
		if e < val {
			val = e
		}
	}
	return val
}

// array_max returns the maximum value in the array
fn array_max[T](a []T) T {
	// if a.len == 0 {
	// 	return error('.max called on an empty array')
	// }
	mut val := a[0]
	for e in a {
		if e > val {
			val = e
		}
	}
	return val
}

// array_sum returns the sum of an array's numeric values
fn array_sum[T](list []T) T {
	// if list.len == 0 {
	// 	return error('Cannot sum up array of nothing.')
	// } else {
	mut head := list[0]

	for i, e in list {
		if i == 0 {
			continue
		} else {
			head += e
		}
	}

	return head
}

// uniques
fn uniques[T](list []T) []T {
	return element_counts(list).keys()
}

// find the index of b in arr
fn find[T](arr []T, b T) int {
	for i, a in arr {
		if a == b {
			return i
		}
	}
	return 0
}

// idx_max
fn idx_max[T](a []T) int {
	if a == [] {
		panic('idx_max was called on an empty array')
	}
	if a.len == 1 {
		return 0
	}
	mut idx := 0
	mut val := a[0]
	for i, e in a {
		if e > val {
			val = e
			idx = i
		}
	}
	return idx
}

// get_binning
fn get_binning(bins []int) Binning {
	if bins == [0] {
		return Binning{
			lower: 0
			upper: 0
			interval: 1
		}
	}
	if bins.len == 1 {
		return Binning{
			lower: 1
			upper: bins[0]
			interval: 1
		}
	}
	if bins.len == 2 {
		return Binning{
			lower: bins[0]
			upper: bins[1]
			interval: 1
		}
	}
	return Binning{
		lower: bins[0]
		upper: bins[1]
		interval: bins[2]
	}
}
