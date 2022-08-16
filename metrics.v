// metrics.v

// this website https://towardsdatascience.com/multi-class-metrics-made-simple-part-ii-the-f1-score-ebe8b2c2ca1 gives the
// best explanation of multiclass metrics and how they're calculated

module hamnn
import arrays

// import math

// show_multiple_classes_stats
fn show_multiple_classes_stats(metrics Metrics, result CrossVerifyResult) ? {
	mut show_result := []string{}
	for i, class in result.class_counts.keys() {
		show_result << '    ${class:-21}       ${result.labeled_instances[class]:5}   ${result.correct_inferences[class]:5} (${f32(result.correct_inferences[class]) * 100 / result.labeled_instances[class]:6.2f}%)        ${metrics.precision[i]:5.3f}     ${metrics.recall[i]:5.3f}       ${metrics.f1_score[i]:5.3f}'
	}
	show_result << '        Totals                  ${result.total_count:5}   ${result.correct_count:5} (accuracy: raw:${f32(result.correct_count) * 100 / result.total_count:6.2f}% multiclass balanced:${metrics.balanced_accuracy * 100:6.2f}%)'
	for i, avg_type in metrics.avg_type {
		show_result << '${avg_type.title():18} Averages:                                   ${metrics.avg_precision[i]:5.3f}     ${metrics.avg_recall[i]:5.3f}       ${metrics.avg_f1_score[i]:5.3f}'
	}
	print_array(show_result)
}

// append_metric
fn (mut m Metrics) append_metric(p f64, r f64, f1 f64) Metrics {
	m.precision << p
	m.recall << r
	m.f1_score << f1
	return m
}

// wt_avg takes an array of real values and an array of weights (typically 
// class counts), and computes a weighted average
fn wt_avg(a []f64, wts []int) ?f64 {
	mut wp := 0.0
	for i, wt in wts {
		wp += a[i] * wt
	}
	return wp / arrays.sum(wts)?
}

// avg_metrics
fn (mut m Metrics) avg_metrics() ?Metrics {
	count := m.precision.len

	m.avg_precision << arrays.sum(m.precision)? / count
	m.avg_recall << arrays.sum(m.recall)? / count
	m.avg_f1_score << arrays.sum(m.f1_score)? / count
	m.avg_type << 'macro'

	m.avg_precision << wt_avg(m.precision, m.class_counts)?
	m.avg_recall << wt_avg(m.recall, m.class_counts)?
	m.avg_f1_score << wt_avg(m.f1_score, m.class_counts)?
	m.avg_type << 'weighted'
	// multiclass balanced accuracy is the arithmetic mean of the recalls
	m.balanced_accuracy = m.avg_recall[0]
	return m
}

// get_metrics
fn get_metrics(result CrossVerifyResult) ?Metrics {
	mut metrics := Metrics{
		class_counts: get_map_values(result.class_counts)
	}
	for class in result.class_counts.keys() {
		precision, recall, f1_score := get_multiclass_stats(class, result)
		metrics.append_metric(precision, recall, f1_score)
	}
	metrics.avg_metrics()?
	return metrics
}

// get_multiclass_stats calculates precision, recall, and F1 score for one
// class of a multiclass result, using a one-vs-rest (OVR) strategy
fn get_multiclass_stats(class string, result CrossVerifyResult) (f64, f64, f64) {
	mut tp := 0
	// mut tn := 0
	mut fp := 0
	mut f_n := 0
	mut actual := ''
	for i, inf in result.inferred_classes {
		actual = result.actual_classes[i]
		if inf == class {
			if actual == inf {
				tp += 1
			} else {
				fp += 1
			}
		} else if actual == class {
			f_n += 1
		}
		// else {tn += 1}
	}
	precision := tp / f64(tp + fp)
	recall := tp / f64(tp + f_n)
	f1_score := 2 * precision * recall / (precision + recall)
	// println('class tp fp tn f_n $class $tp $fp $tn $f_n')
	return precision, recall, f1_score
}

// get_binary_stats
fn get_binary_stats(result CrossVerifyResult) string {
	pos_class := result.pos_neg_classes[0]
	neg_class := result.pos_neg_classes[1]
	t_p := result.correct_inferences[pos_class]
	t_n := result.correct_inferences[neg_class]
	f_p := result.incorrect_inferences[pos_class]
	f_n := result.incorrect_inferences[neg_class]
	raw_acc := result.correct_count * 100 / f64(result.total_count)
	sens := t_p / f64(t_p + f_n)
	spec := t_n / f64(t_n + f_p)
	ppv := t_p / f64(t_p + f_p)
	npv := t_n / f64(t_n + f_n)
	f1_score := t_p / f64(t_p + (0.5 * f64(f_p + f_n)))
	bal_acc := (sens + spec) * 50
	return '${t_p:5} ${f_p:5} ${t_n:5} ${f_n:5}  ${sens:5.3f}  ${spec:5.3f}  ${ppv:5.3f}  ${npv:5.3f}  ${f1_score:5.3f}     ${raw_acc:6.2f}%  ${bal_acc:6.2f}%'
}
// get_binary_stats_line
fn get_binary_stats_line(result CrossVerifyResult) string {
	pos_class := result.pos_neg_classes[0]
	neg_class := result.pos_neg_classes[1]
	t_p := result.correct_inferences[pos_class]
	t_n := result.correct_inferences[neg_class]
	f_p := result.incorrect_inferences[pos_class]
	f_n := result.incorrect_inferences[neg_class]
	raw_acc := result.correct_count * 100 / f64(result.total_count)
	sens := t_p / f64(t_p + f_n)
	spec := t_n / f64(t_n + f_p)
	ppv := t_p / f64(t_p + f_p)
	npv := t_n / f64(t_n + f_n)
	f1_score := t_p / f64(t_p + (0.5 * f64(f_p + f_n)))
	bal_acc := (sens + spec) * 50
	return '${t_p:5} ${f_p:5} ${t_n:5} ${f_n:5}  ${sens:5.3f}  ${spec:5.3f}  ${ppv:5.3f}  ${npv:5.3f}  ${f1_score:5.3f}     ${raw_acc:6.2f}%  ${bal_acc:6.2f}%'
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
