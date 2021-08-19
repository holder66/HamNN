module tools

import arrays
import vsl.plot

struct RankTrace {
    mut:
    label           string
    rank_values        []f64
    maximum_rank_value    f32
}

// plot_rank ranked_atts
pub fn plot_rank(ranked_atts []RankedAttribute, opts Options) {
    mut traces := []RankTrace{}
	mut plt := plot.new_plot()
	mut x := []f64{}
	for i in opts.bins[0] .. opts.bins[1] + 1 {
		x << i
	}
	for attr in ranked_atts.filter(it.inferred_attribute_type == 'C') {
        traces << RankTrace{
            label: '$attr.attribute_name ${arrays.max(attr.rank_value_array):5.2f}'
            rank_values: attr.rank_value_array.map(f64(it)).reverse()
            maximum_rank_value: arrays.max(attr.rank_value_array)
        }
	}
    // sort in descending order of maximum_rank_value
    traces.sort(a.maximum_rank_value > b.maximum_rank_value)

    for value in traces {
        plt.add_trace(
            trace_type: .scatter
            x: x
            y: value.rank_values
            mode: 'lines+markers'
            name: value.label
        )
    }
	plt.set_layout(
		title: 'Rank Values for Continuous Attributes for $opts.datafile_path'
		autosize: false
		width: 800
		xaxis: plot.Axis{
			title: plot.AxisTitle{
				text: 'Number of bins'
			}
		}
		yaxis: plot.Axis{
			title: plot.AxisTitle{
				text: 'Rank Value'
			}
			range: [0., 100]
		}
	)
	plt.show() or { panic(err) }
}

struct ExploreTrace {
mut:
	label           string
	percents        []f64
    max_percents    f64
	attributes_used []f64
}

// plot_explore
pub fn plot_explore(results []VerifyResult, opts Options) {
	mut plt := plot.new_plot()
	mut traces := []ExploreTrace{}
	mut x := []f64{}
	mut y := []f64{}
	mut bin_values := []string{}
    mut y_value := 1.
    mut percents := []f64{}
    mut max_percents := 0.
	for result in results {
        y_value = (f32(result.correct_count) * 100 / result.total_count)
		x << f64(result.attributes_used)
		y << y_value
        // create strings that can be used for filtering
        if result.bin_values.len == 1 {
            bin_values << '${result.bin_values[0]} bins'
        } else {
            bin_values << 'bin range ${result.bin_values[0]} - ${result.bin_values[1]}'
        }
	}
    // get the unique bin_values, each one will generate a separate trace
	for key, _ in string_element_counts(bin_values) {
        percents = filter(key, bin_values, y)
        max_percents = arrays.max(percents)
		traces << ExploreTrace{
			label: '$key ${arrays.max(percents):5.2f}'
			percents: percents
            max_percents: max_percents
			attributes_used: filter(key, bin_values, x)
		}
	}
    // sort the traces according to the maximum value of percents
    traces.sort(a.max_percents > b.max_percents)

	for value in traces {
		plt.add_trace(
			trace_type: .scatter
			x: value.attributes_used
			y: value.percents
			mode: 'lines+markers'
			name: value.label
		)
	}
	plt.set_layout(
		title: 'Accuracy (%) by Attributes Used'
		width: 800
		xaxis: plot.Axis{
			title: plot.AxisTitle{
				text: 'Attributes Used'
			}
		}
	)
	plt.show() or { panic(err) }
}

struct ROCTrace {
	mut:
	label           string
	sensitivity        []f64
    one_minus_specificity    []f64
	attributes_used []f64
}
// plot_roc plot receiver operating characteristic curve
pub fn plot_roc(results []VerifyResult, opts Options) {
	mut plt := plot.new_plot()
	mut traces := []ROCTrace{}
	mut z := []TwoArraySort{}
	mut x := []f64{}
	mut y := []f64{}
	mut bin_values := []string{}
	mut pos_class := ''
	mut neg_class := ''
	mut sensitivity := 0. 
	mut one_minus_specificity := 1. 

	// first, we'll do a series of curves, one per bin range, thus
	// with the number of attributes varying

z << TwoArraySort{
	x: 0. 
	y: 0. 
}
	for result in results {
		// println(result)
	pos_class = result.pos_neg_classes[0]
	neg_class = result.pos_neg_classes[1]
	sensitivity = result.class_table[pos_class].correct_inferences / f64(result.class_table[pos_class].correct_inferences + result.class_table[neg_class].missed_inferences)
	one_minus_specificity = 1. - (result.class_table[neg_class].correct_inferences / f64(result.class_table[neg_class].correct_inferences + result.class_table[pos_class].missed_inferences))
	x << one_minus_specificity
	y << sensitivity
	// create strings that can be used for filtering
        if result.bin_values.len == 1 {
            bin_values << '${result.bin_values[0]} bins'
        } else {
            bin_values << 'bin range ${result.bin_values[0]} - ${result.bin_values[1]}'
        }
	}
	// println(y)	

// get the unique bin_values, each one will generate a separate trace
	for key, _ in string_element_counts(bin_values) {
		// println(key)
		// x = 0. 
		// y = 0. 

		traces << ROCTrace{
			label: '$key'
			one_minus_specificity: filter(key, bin_values, x)
			sensitivity: filter(key, bin_values, y)
		}
	}
	// println(traces)
	
// z << TwoArraySort{
// 	x: 1 
// 	y: 1 
// }
	// z.sort(a.x < b.x)
	// for val in z {
	// 	x << val.x 
	// 	y << val.y
	// }
	for mut trace in traces {
		// append 0. and 1. to the beginning and end of the x and y arrays
		
		trace.sensitivity.prepend(0.)
		trace.one_minus_specificity.prepend(0.)
		trace.sensitivity << 1.
		trace.one_minus_specificity << 1.
		// println(trace.sensitivity)
	plt.add_trace(
			trace_type: .scatter
			x: trace.one_minus_specificity
			y: trace.sensitivity
			mode: 'lines+markers'
			name: trace.label
		)
	plt.set_layout(
		title: 'Receiver Operating Characteristic'
		width: 800
		xaxis: plot.Axis{
			title: plot.AxisTitle{
				text: '1 - specificity'
			}
		}
	)
}
	plt.show() or { panic(err) }
}

fn filter(match_value string, a []string, b []f64) []f64 {
	mut result := []f64{}
	for i, value in a {
		if match_value == value {
			result << b[i]
		}
	}
	return result
}

struct TwoArraySort {
	mut:
	x f64
	y f64
}
