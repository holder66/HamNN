// plot_test.v
import vsl.plot
import vsl.util
fn test_hovertemplate() {
  y := [0., 1, 3, 1, 0, -1, -3, -1]
  text := ['a','b','c','d','e','f','g']
  x := util.arange(y.len).map(f64(it))
  mut plt := plot.new_plot()
  plt.add_trace(
    trace_type: .scatter
    x: x
    y: y
    text: text
    mode: 'lines+markers'
    marker: plot.Marker{
      size: []f64{len: x.len, init: 10.}
      color: []string{len: x.len, init: '#FF0000'}
    }
    line: plot.Line{
      color: '#FF0000'
    },
    hovertemplate: '<b>X value:</b>%{x}<br><i>Y value:</i>%{y}<br>text: %{text}'
  )
  plt.set_layout(
    title: 'Scatter plot example'
  )
  plt.show() or { panic(err) }
}