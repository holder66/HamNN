module tools

import vsl.plot
// import vsl.util

// plot_rank ranked_atts
pub fn plot_rank(ranked_atts []RankedAttribute, opts Options) {
	mut plt := plot.new_plot()
	mut x := []f64{}
	for i in opts.bins[0] .. opts.bins[1] + 1 {
		x << i
	}
	for attr in ranked_atts.filter(it.inferred_attribute_type == 'C') {
		plt.add_trace(
			trace_type: .scatter
			x: x
			y: attr.rank_value_array.map(f64(it)).reverse()
			mode: 'lines+markers'
			name: attr.attribute_name
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
			dtick: 100.
		}
	)
	plt.show() or { panic(err) }
}

struct ExploreTrace {
mut:
	label           string
	percents        []f64
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
	for value in results {
		x << f64(value.attributes_used)
		y << (f32(value.correct_count) * 100 / value.total_count)
		if value.bin_values.len == 1 {
			bin_values << '${value.bin_values[0]} bins'
		} else {
			bin_values << 'bin range ${value.bin_values[0]} - ${value.bin_values[1]}'
		}
	}
	for key, _ in string_element_counts(bin_values) {
		traces << ExploreTrace{
			label: key
			percents: filter(key, bin_values, y)
			attributes_used: filter(key, bin_values, x)
		}
	}
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
