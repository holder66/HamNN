// show.v
// in order to establish style consistency, aim to use magenta underline
// for the first line of each output, and blue underline for table headings.
// ie, println(chalk.fg(chalk.style('\nfirst line', 'underline'), 'magenta'))
// println(chalk.fg(chalk.style('table header','underline'), 'blue'))

module hamnn

import etienne_napoleone.chalk
// import math

// show_analyze
pub fn show_analyze(result AnalyzeResult) {
	// println(result)
	mut show := []string{}
	show << [
		'',
		'Analysis of Dataset "$result.datafile_path" (File Type $result.datafile_type)',
		'All Attributes',
		'Index  Name                          Count  Uniques  Missing      %  Type',
		'_____  __________________________  _______  _______  _______  _____  ____',
	]
	for attr in result.attributes {
		show << '${attr.id:5}  ${attr.name:-27}  ${attr.count:6}  ${attr.uniques:7}  ${attr.missing:7}  ${attr.missing * 100 / f32(attr.count):5.1f}  ${attr.att_type:4}'
	}
	mut total_count := 0
	mut total_missings := 0
	for attr in result.attributes {
		total_count += attr.count
		total_missings += attr.missing
	}
	show << [
		'______                             _______           _______  _____',
		'Totals (less Class attribute)   ${total_count:10}        ${total_missings:10}  ${total_missings * 100 / f32(total_count):5.2f}%',
	]
	show << [
		'',
		'Counts of Attributes by Type',
		'Type        Count',
		'____        _____',
	]
	mut types := []string{}
	for attr in result.attributes {
		types << attr.att_type
	}
	for key, value in string_element_counts(types) {
		show << '$key          ${value:6}'
	}
	show << 'Total:     ${types.len:6}'
	show << [
		'',
		'Discrete Attributes for Training',
		' Index  Name                        Uniques',
		' _____  __________________________  _______',
	]
	for attr in result.attributes.filter(it.for_training && it.att_type == 'D') {
		show << '${attr.id:6}  ${attr.name:-27} ${attr.uniques:7}'
	}
	show << [
		'',
		'Continuous Attributes for Training',
		' Index  Name                               Min         Max',
		' _____  __________________________  __________  __________',
	]
	for attr in result.attributes.filter(it.for_training && it.att_type == 'C') {
		show << '${attr.id:6}  ${attr.name:-27} ${attr.min:10.3g}  ${attr.max:10.3g}'
	}
	show << [
		'',
		'The Class Attribute: "$result.class_name"',
		'Class Value           Cases',
		'____________________  _____',
	]
	for key, value in result.class_counts {
		show << '${key:-20}  ${value:5}'
	}
	print_array(show)
}

// show_rank_attributes
fn show_rank_attributes(result RankingResult) {
	mut exclude_phrase := 'included'
	if result.exclude_flag {
		exclude_phrase = 'excluded'
	}
	weight_string := if result.weighting_flag { 'yes' } else { 'no' }
	println(chalk.fg(chalk.style('\n\nAttributes Sorted by Rank Value, for $result.path',
		'underline'), 'magenta'))
	println('Missing values: $exclude_phrase')
	println('Bin range for continuous attributes: from ${result.bins[0]} to ${result.bins[1]}')
	println('Prevalence weighting of nearest neighbor counts: $weight_string ')
	println(chalk.fg(chalk.style(' Index  Name                         Type   Rank Value   Bins',
		'underline'), 'blue'))
	mut array_to_print := []string{}
	for attr in result.array_of_ranked_attributes {
		array_to_print << '${attr.attribute_index:6}  ${attr.attribute_name:-27} ${attr.inferred_attribute_type:2}         ${attr.rank_value:7.2f} ${attr.bins:6}'
	}
	print_array(array_to_print)
}

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

// show_classifier_history
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
	if opts.command == 'verify' && (opts.show_flag || opts.expanded_flag) {
		if !opts.expanded_flag {
			percent := (f32(result.correct_count) * 100 / result.labeled_classes.len)
			println('correct inferences: $result.correct_count out of $result.labeled_classes.len (${percent:5.2f}%)')
		} else {
			show_expanded_result(result, opts)
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
	println(chalk.fg(chalk.style('Confusion Matrix:', 'underline'), 'blue'))
	for i, rows in result.confusion_matrix {
		for j, item in rows {
			if i == 0 && j == 0 {
				// print first item in first row, ie 'predicted classes (columns)'
				print(chalk.fg('$item  ', 'red'))
			} else if i == 0 {
				// print column headers, ie classes
				print(chalk.fg('${item:20}  ', 'red'))
			} else if j == 0 {
				// print first item in remaining rows, ie classes
				print(chalk.fg('        ${item:21}', 'blue'))
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
	exclude_string := if opts.exclude_flag { 'excluded' } else { 'included' }
	attr_string := if opts.number_of_attributes[0] == 0 {
		'all'
	} else {
		opts.number_of_attributes[0].str()
	}
	weight_string := if opts.weighting_flag { 'yes' } else { 'no' }
	println(chalk.fg(chalk.style('\nCross-validation of "$opts.datafile_path"', 'underline'),
		'magenta'))
	results_array := ['Partioning: $folding_string', 'Attributes: $attr_string',
		'Missing values: $exclude_string',
		'Bin range for continuous attributes: from ${opts.bins[0]} to ${opts.bins[1]}',
		'Prevalence weighting of nearest neighbor counts: $weight_string ', 'Results:',
		'correct inferences: $cross_result.correct_count out of $cross_result.labeled_classes.len (${percent:5.2f}%)']
	print_array(results_array)
	if opts.expanded_flag {
		show_expanded_result(cross_result, opts)
	}
}

// show_explore_header
fn show_explore_header(pos_neg_classes []string, opts Options) {
	if opts.show_flag || opts.expanded_flag {
		mut explore_type_string := ''
		if opts.testfile_path == '' {
			explore_type_string = if opts.folds == 0 { 'leave-one-out ' } else { '$opts.folds-fold ' } + 'cross-validation' + if opts.repetitions > 0 { ' ($opts.repetitions repetitions' + if opts.random_pick { ', with random selection of instances)' } else { ')' }
			 } else { ''
			 }
		} else {
			explore_type_string = 'verification with "$opts.testfile_path"'
		}
		println(chalk.fg(chalk.style('Explore "$opts.datafile_path" using $explore_type_string',
			'underline'), 'magenta'))
		if opts.exclude_flag {
			println('Excluding missing values')
		}
		if opts.weighting_flag {
			println('Weighting attribute rankings and nearest neighbor counts by class prevalences')
		}
		if !opts.expanded_flag {
			println(chalk.fg(chalk.style('Attributes     Bins  Matches  Nonmatches  Percent',
				'underline'), 'blue'))
		} else {
			if pos_neg_classes[0] != '' {
				println('A correct classification to "${pos_neg_classes[0]}" is a True Positive (TP);\nA correct classification to "${pos_neg_classes[1]}" is a True Negative (TN).')
				println(chalk.fg(chalk.style('Attributes    Bins     TP    FP    TN    FN Sensitivity Specificity    PPV    NPV  Balanced Accuracy   F1 Score',
					'underline'), 'blue'))
			} else {
				println(chalk.fg('                                                    Cases in         Correctly        Incorrectly  Wrongly classified',
					'blue'))
				println(chalk.fg(chalk.style('Attributes    Bins   Class                          test set          inferred           inferred     into this class',
					'underline'), 'blue'))
			}
		}
	}
}

// show_explore_line
fn show_explore_line(result VerifyResult, opts Options) {
	if opts.show_flag || opts.expanded_flag {
		if !opts.expanded_flag {
			percent := (f32(result.correct_count) * 100 / result.labeled_classes.len)
			println('${opts.number_of_attributes[0]:10}  ${get_show_bins(opts.bins)}  ${result.correct_count:7}  ${result.labeled_classes.len - result.correct_count:10}  ${percent:7.2f}')
		} else {
			if result.pos_neg_classes[0] != '' {
				println('${opts.number_of_attributes[0]:10} ${get_show_bins(opts.bins)}  ${get_binary_stats(result)}')
			} else {
				println('${opts.number_of_attributes[0]:10} ${get_show_bins(opts.bins)}')
				show_multiple_classes_stats(result, 21)
			}
		}
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
