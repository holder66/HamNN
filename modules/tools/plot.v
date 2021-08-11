module tools

import vsl.plot
import vsl.util

pub fn plot() {
    mut plt := plot.new_plot()

    
      y := [
        0.,
        1,
        3,
        1,
        0,
        -1,
        -3,
        -1,
        0,
        1,
        3,
        1,
        0,
    ]
    x := util.arange(y.len).map(f64(it))


    println(plt)

    plt.add_trace(
        trace_type: .scatter
        x: x
        y: y
        mode: 'lines+markers'
        marker: plot.Marker{
            size: []f64{len: x.len, init: 10.}
            color: []string{len: x.len, init: '#FF0000'}
        }
        line: plot.Line{
            color: '#FF0000'
        }
    )
    plt.set_layout(
        title: 'Scatter plot example'
    )    
    println(plt)
    plt.show() or { panic(err) }
}

// plot_rank ranked_atts
pub fn plot_rank(ranked_atts []RankedAttribute, opts Options) {
    mut plt := plot.new_plot()
    println(ranked_atts)
    mut x := []f64{}
    for i in opts.bins[0] .. opts.bins[1] + 1 { x << i }
    println(x)
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
        title: 'Rank Values for Continuous Attributes'
        autosize: true
        width: 800
        xaxis: plot.Axis{
            title: plot.AxisTitle{
                text: 'Number of bins'
            }
        }
        yaxis: plot.Axis{
            title: plot.AxisTitle{
                text: "Rank Value"
            }
        }
        )
    plt.show() or { panic(err) }

}
