// show.v
module tools

// show_expanded_result
pub fn show_expanded_result(result VerifyResult) {
	mut show_result := ['',
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
		mut keys := []string{}
		mut counts := []int{}
		for key, value in result.class_table {
			keys << key 
			counts << value.labeled_instances
		}
		// use the class with fewer instances as the true positive class
		mut pos_class := keys[0]
		mut neg_class := keys[1]
		if counts[0] > counts[1] {
			pos_class = keys[1]
			neg_class = keys[0]
		}
		t_p := result.class_table[pos_class].correct_inferences
		t_n := result.class_table[neg_class].correct_inferences
		f_p := result.class_table[pos_class].missed_inferences
		f_n := result.class_table[neg_class].missed_inferences
		sens := t_p / f64(t_p + f_n)
		spec := t_n / f64(t_n + f_p)
		ppv := t_p / f64(t_p + f_p)
		npv := t_n / f64(t_n + f_n)
		ba := (sens + spec) / 2
		println('\nFor a True Positive (TP) defined as a correct classification to class "$pos_class":')
		println('TP           ${t_p:5}')
		println('FP           ${f_p:5}')
		println('TN           ${t_n:5}')
		println('FN           ${f_n:5}')
		println('Sensitivity  ${sens:5.3f}')
		println('Specificity  ${spec:5.3f}')
		println('PPV          ${ppv:5.3f}')
		println('NPV          ${npv:5.3f}')
		println('Balanced Accuracy:  ${ba:5.3f}')
	}
}
