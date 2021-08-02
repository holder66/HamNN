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
}
