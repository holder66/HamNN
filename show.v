// show.v

module hamnn

import etienne_napoleone.chalk
// import math

// show
pub fn show<T>(a []T) string {
	return typeof(a).name
}

// show_analyze prints to the console, information regarding a dataset:
// ```sh
// 1. a list of attributes, their types, the unique values, and a count of
// missing values;
// 2. a table with counts for each type of attribute;
// 3. a list of discrete attributes useful for training a classifier;
// 4. a list of continuous attributes useful for training a classifier;
// 5. a breakdown of the class attribute, showing counts for each class.
// ```
// pub fn show_analyze(ds Dataset) {
// 	cases_count := ds.data[0].len
// 	mut show_dataset := ['']
// 	mut missing_vals := ds.data.map(missing_values(it))
// 	missing_vals << 0
// 	mut show_attributes := ['', 'Analysis of Dataset "$ds.path" (File Type ${file_type(ds.path)})',
// 		'All Attributes', 'Index  Name                          Count  Uniques  Missing     %   Type',
// 		'_____  __________________________  _______  _______  _______  ____   ____']
// 	for i, name in ds.attribute_names {
// 		show_attributes << '${i:5}  ${name:-27}   ${ds.data[i].len:5}    ${uniques(ds.data[i]):5}     ${missing_vals[i]:4} ${f32(missing_vals[i]) / f32(cases_count) * 100.0:5.1f}   ${ds.inferred_attribute_types[i]}'
// 	}
// 	show_attributes << '______                             _______           _______ _____'
// 	show_attributes << 'Totals (less Class attribute)   ${cases_count * (ds.data.len - 1):10}        ${array_sum<int>(missing_vals):10}  ${f32(array_sum<int>(missing_vals)) / (cases_count * (ds.data.len - 1)) * 100.0:5.2f}%'
// 	mut show_types := ['', 'Counts of Attributes by Type', 'Type        Count', '____        _____']
// 	for key, value in string_element_counts(ds.inferred_attribute_types) {
// 		show_types << '$key          ${value:6}'
// 	}
// 	show_types << 'Total:     ${ds.inferred_attribute_types.len:6}'

// 	mut show_discrete_attributes := ['', 'Discrete Attributes for Training',
// 		' Index  Name                           Uniques',
// 		' _____  __________________________     _______']
// 	for key, value in ds.useful_discrete_attributes {
// 		show_discrete_attributes << '${key:6}  ${ds.attribute_names[key]:-27}      ${uniques(value):5}'
// 	}

// 	mut show_continuous_attributes := ['', 'Continuous Attributes for Training',
// 		' Index  Name                           Min         Max',
// 		' _____  __________________________  ______      ______']
// 	mut min := 0.0
// 	for key, value in ds.useful_continuous_attributes {
// 		// to calculate the minimum, strip out missing values (placeholder is -math.max_f32)
// 		min = f32_abs(array_min(value.filter(it != -math.max_f32)))

// 		show_continuous_attributes << '${key:6}  ${ds.attribute_names[key]:-27} ${min:6.3g}      ${array_max(value):6}'
// 	}

// 	mut show_class := ['', 'The Class Attribute: "$ds.Class.class_name"',
// 		'Class Value           Cases', '____________________  _____']
// 	for key, value in ds.Class.class_counts {
// 		show_class << '${key:-20}  ${value:5}'
// 	}

// 	show_dataset << show_attributes
// 	show_dataset << show_types
// 	show_dataset << show_discrete_attributes
// 	show_dataset << show_continuous_attributes
// 	show_dataset << show_class
// 	print_array(show_dataset)
// }

// show_classifier outputs to the console information about a classifier
pub fn show_classifier(cl Classifier) {
	// println(cl.Environment)
	mut show_classifier_array := ['\nClassifier for "$cl.Options.datafile_path"',
		
		'options: missing values ' + if cl.exclude_flag { 'excluded' } else { 'included' } +
		' when calculating rank values',
		'Included attributes: $cl.trained_attributes.len', 'Trained on $cl.instances.len instances.',
		'Name                        Type  Rank Value  Uniques        Min        Max  Bins',
		'__________________________  ____  __________  _______  _________  _________  ____']
	mut line := ''
	for attr, val in cl.trained_attributes {
		line = '${attr:-27} ${val.attribute_type:-4}  ${val.rank_value:10.2f}' +
			if val.attribute_type == 'C' { '          ${val.minimum:10.2f} ${val.maximum:10.2f} ${val.bins:5}' } else { '      ${val.translation_table.len:4}' }
		show_classifier_array << line
	}
	print_array(show_classifier_array)
	println('')
	print_array(show_classifier_history(cl.history))
	println('\n\n')
}

// show_classifier_history history []HistoryEvent
fn show_classifier_history(history []HistoryEvent) []string {
	mut array := ['Classifier History:',
		'Date & Time (UTC)    Event   From file                            Instances',
		'_________________    _____   _________                            _________']
	for events in history {
		array << '${events.event_date:-19}  ${events.event:-6}  ${events.file_path:-35} ${events.instances_count:10}'
	}
	return array
}

// show_cross_validate
fn show_cross_validate(result VerifyResult, opts Options) {
}

// show_explore
fn show_explore(result []VerifyResult, opts Options) {
}

// show_make
fn show_make(cl Classifier, opts Options) {
}

// show_rank
fn show_rank(result RankingResult, opts Options) {
}

// show_validate
fn show_validate(result ValidateResult, opts Options) {
}

// show_verify
fn show_verify(result VerifyResult, opts Options) {
}

// show_results
// note that in the case of `explore` and the expanded_flag, explore.v
// initiates the printing of headers to the console, while the printing
// of each line of the result is initiated in either cross.v or verify.v
fn show_results(result VerifyResult, opts Options) {
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
fn show_expanded_result(result VerifyResult, opts Options) {
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
fn print_confusion_matrix(result VerifyResult) {
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
fn show_crossvalidation_result(cross_result VerifyResult, opts Options) {
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
fn show_explore_header(opts Options) {
	println('\nExplore "$opts.datafile_path"')
	println('Exclude: $opts.exclude_flag; Weighting: $opts.weighting_flag')
	println('Attributes     Bins  Matches  Nonmatches  Percent')
	println('__________  _______  _______  __________  _______')
}

// expanded_explore_header
fn expanded_explore_header(result VerifyResult, opts Options) {
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
fn get_pos_neg_classes(class_counts map[string]int) []string {
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
