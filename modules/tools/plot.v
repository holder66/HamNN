module tools

import arrays
import vsl.plot
// import vsl.util

struct RankTrace {
    mut:
    label           string
    rank_values        []f64
    maximum_rank_value    f32
    // number_of_bins []f64
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
            // number_of_bins: x
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

fn filter(match_value string, a []string, b []f64) []f64 {
	mut result := []f64{}
	for i, value in a {
		if match_value == value {
			result << b[i]
		}
	}
	return result
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
	for value in results {
        y_value = (f32(value.correct_count) * 100 / value.total_count)
		x << f64(value.attributes_used)
		y << y_value
        // create strings that can be used for filtering
        if value.bin_values.len == 1 {
            bin_values << '${value.bin_values[0]} bins'
        } else {
            bin_values << 'bin range ${value.bin_values[0]} - ${value.bin_values[1]}'
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
