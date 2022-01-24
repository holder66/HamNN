// show.v

module tools

import etienne_napoleone.chalk

// show_results
// note that in the case of `explore` and the expanded_flag, explore.v
// initiates the printing of headers to the console, while the printing
// of each line of the result is initiated in either cross.v or verify.v
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
				println('${opts.number_of_attributes[0]:10}  ${get_show_bins(opts.bins)}  ${result.correct_count:7}  ${result.labeled_classes.len - result.correct_count:10}  ${percent:7.2f}')
			}
			else {
				println('Nothing to show!')
			}
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
			else {
				println('Nothing to expand on!')
			}
		}
	}
}

// show_classifier outputs to the console information about a classifier
pub fn show_classifier(cl Classifier) {
	mut show_classifier_array := ['\nClassifier for "$cl.Options.datafile_path"',
		'created: $cl.utc_date_time UTC, with hamnn version: $cl.hamnn_version',
		
			'options: missing values ' + if cl.exclude_flag { 'excluded' } else { 'included' } +
			' when calculating rank values',
		'included attributes: $cl.trained_attributes.len',
		'Name                        Type  Uniques        Min        Max  Bins',
		'__________________________  ____  _______  _________  _________  ____']
	mut line := ''
	for attr, val in cl.trained_attributes {
		line = '${attr:-27} ${val.attribute_type:-2} ' +
			if val.attribute_type == 'C' { '           ${val.minimum:10.2f} ${val.maximum:10.2f} ${val.bins:5}' } else { '      ${val.translation_table.len:4}' }
		show_classifier_array << line
	}
	tools.print_array(show_classifier_array)
}

// get_show_bins
fn get_show_bins(bins []int) string {
	mut show_bins := ''
	if bins.len == 1 {
		show_bins = '${bins[0]:7}'
	} else {
		show_bins = '${bins[0]:2} - ${bins[1]:-2}'
	}
	return show_bins
}

// show_expanded_result
pub fn show_expanded_result(result VerifyResult, opts Options) {
	println(chalk.fg('Class                          Cases in         Correctly        Incorrectly  Wrongly classified\n                               test set          inferred           inferred     into this class',
		'green'))

	show_multiple_classes_stats(result, 0)
	if result.class_table.len == 2 {
		println('A correct classification to "${result.pos_neg_classes[0]}" is a True Positive (TP);\nA correct classification to "${result.pos_neg_classes[1]}" is a True Negative (TN).')
		println('   TP    FP    TN    FN Sensitivity Specificity    PPV    NPV  Balanced Accuracy   F1 Score')
		println('${get_binary_stats(result)}')
	}
	// confusion matrix
	print_confusion_matrix(result)
}

// print_confusion_matrix
pub fn print_confusion_matrix(result VerifyResult) {
	// println(result.confusion_matrix)
	println(chalk.fg(chalk.style('                 Confusion Matrix', 'bold'), 'blue'))
	for i, rows in result.confusion_matrix {
		for j, item in rows {
			if i == 0 && j == 0 {
				// print first item in first row, ie 'predicted classes (columns)'
				print(chalk.fg(chalk.style('$item  ', 'bold'), 'red'))
			} else if i == 0 {
				// print column headers, ie classes
				print(chalk.fg(chalk.style('${item:20}  ', 'bold'), 'red'))
			} else if j == 0 {
				// print first item in remaining rows, ie classes
				print(chalk.fg(chalk.style('        ${item:21}', 'bold'), 'green'))
			} else {
				// print integers for each cell
				print('${item:20}  ')
			}
		}
		// carriage return at end of line
		println('')
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
	f1_score := t_p / f64(t_p + (0.5 * f64(f_p + f_n)))
	return '${t_p:5} ${f_p:5} ${t_n:5} ${f_n:5} ${sens:11.3f} ${spec:11.3f} ${ppv:6.3f} ${npv:6.3f} ${ba:18.3f} ${f1_score:10.3f}'
}

// show_expanded_explore_result
fn show_expanded_explore_result(result VerifyResult, opts Options) {
	if result.pos_neg_classes[0] != '' {
		println('${opts.number_of_attributes[0]:10} ${get_show_bins(opts.bins)}  ${get_binary_stats(result)}')
	} else {
		println('${opts.number_of_attributes[0]:10} ${get_show_bins(opts.bins)}')
		show_multiple_classes_stats(result, 21)
	}
}

// show_multiple_classes_stats
fn show_multiple_classes_stats(result VerifyResult, spacer_size int) {
	mut spacer := ''
	for _ in 0 .. spacer_size {
		spacer += ' '
	}
	mut show_result := []string{}
	for class, value in result.class_table {
		show_result << '$spacer${class:-27}       ${value.labeled_instances:5}   ${value.correct_inferences:5} (${f32(value.correct_inferences) * 100 / value.labeled_instances:6.2f}%)    ${value.missed_inferences:5} (${f32(value.missed_inferences) * 100 / value.labeled_instances:6.2f}%)     ${value.wrong_inferences:5} (${f32(value.wrong_inferences) * 100 / value.labeled_instances:6.2f}%)'
	}
	show_result << '$spacer   Totals                         ${result.total_count:5}   ${result.correct_count:5} (${f32(result.correct_count) * 100 / result.total_count:6.2f}%)    ${result.misses_count:5} (${f32(result.misses_count) * 100 / result.total_count:6.2f}%)     ${result.wrong_count:5} (${f32(result.wrong_count) * 100 / result.total_count:6.2f}%)'
	print_array(show_result)
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
	println('Attributes     Bins  Matches  Nonmatches  Percent')
	println('__________  _______  _______  __________  _______')
}

// expanded_explore_header
pub fn expanded_explore_header(result VerifyResult, opts Options) {
	// println('Options: $opts')
	if result.pos_neg_classes[0] != '' {
		println('A correct classification to "${result.pos_neg_classes[0]}" is a True Positive (TP);\nA correct classification to "${result.pos_neg_classes[1]}" is a True Negative (TN).')
		println('Attributes    Bins     TP    FP    TN    FN Sensitivity Specificity    PPV    NPV  Balanced Accuracy   F1 Score')
	} else {
		println('Attributes    Bins   Class                          Cases in         Correctly        Incorrectly  Wrongly classified')
		println('                                                    test set          inferred           inferred     into this class')
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
