// query.v
module hamnn

import readline
import strconv
import json
import os

// query takes a trained classifier and performs an interactive session
// with the user at the console, asking the user to input a value for each
// trained attribute. It then asks to confirm or redo the responses. Once
// confirmed, the instance is classified and the inferred class is shown.
// The classified instance can optionally be saved in a file.
// The saved instance can be appended to the classifier using append.append().
pub fn query(cl Classifier, opts Options) ClassifyResult {
	mut answer := ''
	mut classify_result := ClassifyResult{}
	mut validate_result := ValidateResult{
		Class: cl.Class
	}
	mut byte_values := []byte{}
	mut responses := map[string]string{}
	// for testing, skip the query by putting some values in responses
	// and run with -a 2
	// responses = map{
	// 	'lastname': 'Booker'
	// 	'height':   '120'
	// }
	if responses.len == 0 {
		for _ in 0 .. 3 {
			// for each attribute in cl, create a prompt and collect responses
			for attr in cl.attribute_ordering {
				if cl.trained_attributes[attr].attribute_type == 'D' {
					println('Possible values for "$attr": $cl.trained_attributes[attr].translation_table.keys()')
					responses[attr] = readline.read_line('Please enter one of these values for attribute "$attr": ') or {
						'error'
					}.trim_space()
				} else {
					responses[attr] = readline.read_line('Enter a value between ${cl.trained_attributes[attr].minimum} and ${cl.trained_attributes[attr].maximum} for "$attr": ') or {
						'error'
					}.trim_space()
				}
			}
			// show the entries and provide an opportunity to revise them
			println('Your responses were:')
			for attr in cl.attribute_ordering {
				println('${attr:-18} ${responses[attr]}')
			}
			answer = readline.read_line('Do you want to proceed? (y/n) ') or { 'error' }.trim_space()
			if answer in ['y', 'Y'] {
				break
			}
		}
	}
	byte_values = get_byte_values(cl, responses)
	if opts.verbose_flag {
		println('byte_values: $byte_values')
	}
	// to classify, get Hamming distances between the entered instance and
	// all the instances in the classifier; return the class for the instance
	// giving the lowest Hamming distance.
	classify_result = classify_instance(cl, byte_values, opts)
	if classify_result.weighting_flag {
		println("For the classes $classify_result.classes the prevalence-weighted nearest neighbor counts are $classify_result.nearest_neighbors_by_class, so the inferred class is '$classify_result.inferred_class'")
	} else {
		println("For the classes $classify_result.classes the numbers of nearest neighbors are $classify_result.nearest_neighbors_by_class, so the inferred class is '$classify_result.inferred_class'")
	}
	if opts.outputfile_path != '' {
		validate_result.instances = [byte_values]
		validate_result.inferred_classes = [classify_result.inferred_class]
		validate_result.counts = [classify_result.nearest_neighbors_by_class]
		s := json.encode(validate_result)
		// println('After json encoding, before writing:\n $s')
		mut f := os.open_file(opts.outputfile_path, 'w') or { panic(err.msg) }
		f.write_string(s) or { panic(err.msg) }
		f.close()
	}
	return classify_result
}

// get_byte_values
fn get_byte_values(cl Classifier, responses map[string]string) []byte {
	mut byte_values := []byte{}
	for attr in cl.attribute_ordering {
		// if discrete, use translation table to get a "binned value" equivalent
		if cl.trained_attributes[attr].attribute_type == 'D' {
			byte_values << byte(cl.trained_attributes[attr].translation_table[responses[attr]])
		} else {
			if responses[attr] == '' {
				byte_values << byte(0)
			} else {
				byte_values << bin_single_value(f32(strconv.atof_quick(responses[attr])),
					cl.trained_attributes[attr].minimum, cl.trained_attributes[attr].maximum,
					cl.trained_attributes[attr].bins)
			}
		}
	}

	return byte_values
}
