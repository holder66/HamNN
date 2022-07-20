// make_classifier
// TODO: not necessary to rank attributes if all usable attributes will be used
// TODO: have a "compressed" flag which only uses the appropriate number of bits for each attribute, in the attr_one_bit_values array, with each attribute's value concatenated with the next and the results squeezed into u64 values.
// actually, more fruitful might be just to use the u8 type, since it is unlikely that there would be more than 255 values for discrete attributes. And in this situation, compression is unnecessary, since we do not need bitstrings to get Hamming distances when only positive integers are involved.
module hamnn

import math
import time

// make_classifier returns a Classifier struct, given a Dataset (as created by
// load_file).
// ```sh
// Options (also see the Options struct):
// bins: range for binning or slicing of continuous attributes;
// uniform_bins: same number of bins for continuous attributes;
// number_of_attributes: the number of highest-ranked attributes to include;
// exclude_flag: excludes missing values when ranking attributes;
// purge_flag: remove those instances which are duplicates, after
//     binning and based on only the attributes to be used;
// outputfile_path: if specified, saves the classifier to this file.
// ```
pub fn make_classifier(ds Dataset, opts Options) Classifier {
	mut cl := Classifier{
		Class: ds.Class
		Parameters: opts.Parameters
		datafile_path: ds.path
		struct_type: '.Classifier'
		binning: get_binning(opts.bins)
	}
	// calculate the least common multiple for class_counts, for use
	// when the weighting_flag is set
	cl.lcm_class_counts = i64(lcm(get_map_values(ds.class_counts)))

	// first, rank the attributes using the bins and exclude params, and take
	// the highest-ranked number_of_attributes (all the usable attributes if
	// number_of_attributes is 0)
	ranking_result := rank_attributes(ds, opts)
	mut ranked_attributes := ranking_result.array_of_ranked_attributes
	cl.binning = ranking_result.binning
	// println('binning in make_classifier: $cl.binning')
	// println('opts.number_of_attributes: $opts.number_of_attributes')
	if opts.number_of_attributes[0] != 0 && opts.number_of_attributes[0] < ranked_attributes.len {
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
	mut attr_binned_values := [][]u8{}
	mut attr_names := []string{}
	for ra in ranked_attributes {
		attr_names << ra.attribute_name
		if ra.inferred_attribute_type == 'C' {
			attr_values = ds.useful_continuous_attributes[ra.attribute_index]
			min = array_min(attr_values.filter(it != -math.max_f32))
			max = array_max(attr_values)
			binned_values = discretize_attribute(attr_values, min, max, ra.bins)
			cl.trained_attributes[ra.attribute_name] = TrainedAttribute{
				attribute_type: ra.inferred_attribute_type
				minimum: min
				maximum: max
				bins: ra.bins
				rank_value: ra.rank_value
				index: ra.attribute_index
			}
		} else { // ie for discrete attributes
			attr_string_values = ds.useful_discrete_attributes[ra.attribute_index]
			translation_table = make_translation_table(attr_string_values)
			// use the translation table to generate an array of translated values
			binned_values = attr_string_values.map(translation_table[it])
			cl.trained_attributes[ra.attribute_name] = TrainedAttribute{
				attribute_type: ra.inferred_attribute_type
				translation_table: translation_table
				rank_value: ra.rank_value
				index: ra.attribute_index
			}
		}
		attr_binned_values << binned_values.map(u8(it))
	}
	cl.instances = transpose(attr_binned_values)
	cl.attribute_ordering = attr_names
	if opts.purge_flag {
		cl = purge(cl)
	}
	// create an event
	if opts.command == 'make' || opts.command == 'append' {
		mut event := HistoryEvent{
			event: 'make'
			file_path: ds.path
			event_date: time.utc()
			event_environment: get_environment()
			instances_count: cl.instances.len
		}
		cl.history << event
	}
	
	if (opts.show_flag || opts.expanded_flag) && opts.command == 'make' {
		show_classifier(cl)
	}
	if opts.outputfile_path != '' {
		save_json_file(cl, opts.outputfile_path)
	}
	// println(cl)
	return cl
}

// make_translation_table returns a map with the integer for each element in
// an array of strings; 0 for missing values. This makes discrete attributes
// resemble binned continuous attributes for subsequent processing
fn make_translation_table(array []string) map[string]int {
	mut val := map[string]int{}
	mut i := 1
	for word in array {
		if word in missings {
			val[word] = 0
			continue
		} else if val[word] == 0 {
			val[word] = i
			i += 1
		}
	}
	return val
}
