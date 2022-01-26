// make_classifier
// TODO: not necessary to rank attributes if all usable attributes will be used
// TODO: have a "compressed" flag which only uses the appropriate number of bits for each attribute, in the attr_one_bit_values array, with each attribute's value concatenated with the next and the results squeezed into u64 values.
// actually, more fruitful might be just to use the u8 type, since it is unlikely that there would be more than 255 values for discrete attributes. And in this situation, compression is unnecessary, since we do not need bitstrings to get Hamming distances when only positive integers are involved.
module make

import tools
import rank
// import arrays
import math
import time
import os
import json
// import v.util

// make_classifier returns a Classifier struct, given a Dataset (as created by
// tools.load_file). Type: `v run hamnn.v make --help`
/*
Options: bins = number of bins or slices for continuous
attributes; number_of_attributes = the number of attributes to include in
the classifier (chosen from the list of ranked attributes); exclude_flag
(set to true to exclude missing values when ranking attributes)*/
pub fn make_classifier(ds tools.Dataset, opts tools.Options) tools.Classifier {
	mut cl := tools.Classifier{
		utc_date_time: time.utc()
		// vlang_version: util.full_v_version(true)
		hamnn_version: '0.1.0'
		Class: ds.Class
		Options: opts
	}
	// calculate the least common multiple for class_counts, for use
	// when the weighting_flag is set
	if opts.weighting_flag {
		cl.lcm_class_counts = i64(tools.lcm(tools.get_map_values(ds.class_counts)))
	}
	// first, rank the attributes using the bins and exclude params, and take
	// the highest-ranked number_of_attributes (all the usable attributes if
	// number_of_attributes is 0)
	mut ranked_attributes := rank.rank_attributes(ds, opts)
	if opts.number_of_attributes[0] != 0 {
		ranked_attributes = ranked_attributes[..opts.number_of_attributes[0]]
	}
	// for continuous attributes, discretize and get binned values
	// for discrete attributes, create a translation table to go from
	// strings to integers (note that this table needs to be saved)
	mut attr_values := []f32{}
	mut attr_string_values := []string{}
	mut min := f32(0.0)
	mut max := f32(0.0)
	mut binned_values := [1]
	mut translation_table := map[string]int{}
	mut attr_binned_values := [][]byte{}
	mut attr_names := []string{}
	for ra in ranked_attributes {
		attr_names << ra.attribute_name
		if ra.inferred_attribute_type == 'C' {
			attr_values = ds.useful_continuous_attributes[ra.attribute_index]
			min = tools.min(attr_values.filter(it != -math.max_f32))
			max = tools.max(attr_values)
			binned_values = tools.discretize_attribute(attr_values, min, max, ra.bins)
			cl.trained_attributes[ra.attribute_name] = tools.TrainedAttribute{
				attribute_type: ra.inferred_attribute_type
				minimum: min
				maximum: max
				bins: ra.bins
			}
		} else { // ie for discrete attributes
			attr_string_values = ds.useful_discrete_attributes[ra.attribute_index]
			translation_table = make_translation_table(attr_string_values)
			// use the translation table to generate an array of translated values
			binned_values = attr_string_values.map(translation_table[it])
			cl.trained_attributes[ra.attribute_name] = tools.TrainedAttribute{
				attribute_type: ra.inferred_attribute_type
				translation_table: translation_table
			}
		}
		attr_binned_values << binned_values.map(byte(it))
	}
	cl.instances = tools.transpose(attr_binned_values)
	cl.attribute_ordering = attr_names
	if opts.show_flag && opts.command == 'make' {
		tools.show_classifier(cl)
	}
	if opts.outputfile_path != '' && opts.command == 'make' {
		// get the environment used in generating this classifier
		cl.Environment = tools.get_environment()
		outputfile := opts.outputfile_path
		s := json.encode(cl)
		// println('After json encoding, before writing:\n $s')
		mut f := os.open_file(outputfile, 'w') or { panic(err.msg) }
		f.write_string(s) or { panic(err.msg) }
		f.close()
	}

	return cl
}

// make_translation_table returns a map with the integer for each element in
// an array of strings; 0 for missing values. This makes discrete attributes
// resemble binned continuous attributes for subsequent processing
fn make_translation_table(array []string) map[string]int {
	mut val := map[string]int{}
	mut i := 1
	for word in array {
		if word in tools.missings {
			val[word] = 0
			continue
		} else if val[word] == 0 {
			val[word] = i
			i += 1
		}
	}
	return val
}
