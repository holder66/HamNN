// show.v
module tools

// show_results 
pub fn show_results(result VerifyResult, opts Options) {
	if opts.show_flag {
		match opts.command {
			'verify' {
				percent := (f32(result.correct_count) * 100 / result.labeled_classes.len)
		println('correct inferences: $result.correct_count out of $result.labeled_classes.len (${percent:5.2f}%)')
			}
			'cross' {
				show_crossvalidation_result(result, opts)
			}
			'explore' {
				percent := (f32(result.correct_count) * 100 / result.labeled_classes.len)
			println('${opts.number_of_attributes[0]:10}  ${opts.bins[0]:4}  ${result.correct_count:7}  ${result.labeled_classes.len - result.correct_count:10}  ${percent:7.2f}')
			}
			else { println('Nothing to show!')}
		}
	}
	if opts.expanded_flag {
		match opts.command {
			'verify' {
				println('opts: $opts')
				show_expanded_result(result, opts)
			}
			'cross' {
				println('opts: $opts')
				show_expanded_result(result, opts)
			}
			'explore' {
				show_expanded_explore_result(result, opts)
			}
			else { println('Nothing to expand on!')}
		}
	}
}
// show_expanded_result
pub fn show_expanded_result(result VerifyResult, opts Options) {
	mut show_result := [
		'Class                          Cases in         Correctly        Incorrectly  Wrongly classified',
		'                               test set          inferred           inferred     into this class',
	]
	mut total_cases := 0
	mut total_correct := 0
	mut total_incorrect := 0
	mut total_wrong := 0
	for class, value in result.class_table {
		show_result << '${class:-27}       ${value.labeled_instances:5}   ${value.correct_inferences:5} (${f32(value.correct_inferences) * 100 / value.labeled_instances:6.2f}%)    ${value.missed_inferences:5} (${f32(value.missed_inferences) * 100 / value.labeled_instances:6.2f}%)     ${value.wrong_inferences:5} (${f32(value.wrong_inferences) * 100 / value.labeled_instances:6.2f}%)'
		total_cases += value.labeled_instances
		total_correct += value.correct_inferences
		total_incorrect += value.missed_inferences
		total_wrong += value.wrong_inferences
	}
	show_result << '\nTotals                            ${total_cases:5}   ${total_correct:5} (${f32(total_correct) * 100 / total_cases:6.2f}%)    ${total_incorrect:5} (${f32(total_incorrect) * 100 / total_cases:6.2f}%)     ${total_wrong:5} (${f32(total_wrong) * 100 / total_cases:6.2f}%)'
	print_array(show_result)

	if result.class_table.len == 2 {
		println('A correct classification to "${result.pos_neg_classes[0]}" is a True Positive (TP);\nA correct classification to "${result.pos_neg_classes[1]}" is a True Negative (TN).')
		println('   TP    FP    TN    FN Sensitivity Specificity   PPV   NPV  Balanced Accuracy')
		println('${get_binary_stats(result)}')
	}	
}


// get_binary_stats 
fn get_binary_stats(result VerifyResult) string {
	pos_class := result.pos_neg_classes[0]
	neg_class := result.pos_neg_classes[1]
	t_p := result.class_table[pos_class].correct_inferences
	t_n := result.class_table[neg_class].correct_inferences
	f_p := result.class_table[pos_class].missed_inferences
	f_n := result.class_table[neg_class].missed_inferences
	sens := t_p / f64(t_p + f_n)
	spec := t_n / f64(t_n + f_p)
	ppv := t_p / f64(t_p + f_p)
	npv := t_n / f64(t_n + f_n)
	ba := (sens + spec) / 2
	return '${t_p:5} ${f_p:5} ${t_n:5} ${f_n:5} ${sens:11.3f} ${spec:11.3f} ${ppv:5.3f} ${npv:5.3f} ${ba:18.3f}'
}

// show_expanded_explore_result 
fn show_expanded_explore_result(result VerifyResult, opts Options) {
	if result.pos_neg_classes[0] != '' {
		println('${opts.number_of_attributes[0]:10} ${opts.bins[0]:5}  ${get_binary_stats(result)}')
		} else {
			println('multiple classes')
		}
}

// show_crossvalidation_result
pub fn show_crossvalidation_result(cross_result VerifyResult, opts Options) {
	percent := (f32(cross_result.correct_count) * 100 / cross_result.labeled_classes.len)
	folding_string := if opts.folds == 0 { 'leave-one-out' } else { '$opts.folds-fold' }
	exclude_string := if opts.exclude_flag {
		'excluding missing values'
	} else {
		'including missing values'
	}
	attr_string := if opts.number_of_attributes[0] == 0 {
		'all'
	} else {
		opts.number_of_attributes[0].str()
	}
	weight_string := if opts.weighting_flag { '' } else { 'not' }

	println('Cross-validation of "$opts.datafile_path" using $folding_string partitioning,\n$attr_string attributes, $exclude_string,\nbin range for continuous attributes from ${opts.bins[0]} to ${opts.bins[1]},\nand $weight_string weighting the number of nearest neighbor counts by class prevalences.\ncorrect inferences: $cross_result.correct_count out of $cross_result.labeled_classes.len  ${percent:5.2f}%')
}

// show_explore_header
pub fn show_explore_header(opts Options) {
	println('\nExplore "$opts.datafile_path"')
	println('Exclude: $opts.exclude_flag; Weighting: $opts.weighting_flag')
	println('Attributes  Bins  Matches  Nonmatches  Percent')
	println('__________  ____  _______  __________  _______')
}

// expanded_explore_header 
pub fn expanded_explore_header(result VerifyResult, opts Options) {
	println('Options: $opts')
	if result.pos_neg_classes[0] != '' {
		println('A correct classification to "${result.pos_neg_classes[0]}" is a True Positive (TP);\nA correct classification to "${result.pos_neg_classes[1]}" is a True Negative (TN).')
	println('Attributes  Bins     TP    FP    TN    FN Sensitivity Specificity   PPV   NPV  Balanced Accuracy')
	} else {
		println('for multiple classes')
	}
}

// get_pos_neg_classes 
pub fn get_pos_neg_classes(class_counts map[string]int) []string {
	mut pos_class := ''
	mut neg_class := ''
	if class_counts.len == 2 {
		mut keys := []string{}
		mut counts := []int{}
		for key, value in class_counts {
			keys << key 
			counts << value
		}
		// use the class with fewer instances as the true positive class
		pos_class = keys[0]
		neg_class = keys[1]
		if counts[0] > counts[1] {
			pos_class = keys[1]
			neg_class = keys[0]
		}
	}
	return [pos_class, neg_class]
}