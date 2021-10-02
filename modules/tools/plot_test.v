// plot_test.v

module tools
// import vsl.plot
// import vsl.util

// test_area_under_curve 
fn test_area_under_curve() {
  mut x := []f64{}
  mut y := []f64{}
  x = [0.0,1]
  y = [0.0,1]
  assert area_under_curve(x, y) == 0.5
  x = [0.2, 0.4]
  y = [0.3, 0.4]
  assert area_under_curve(x, y) == 0.07
  x = [0.2, 0.3, 0.4]
  y = [0.5, 0.3, 0.1]
  assert area_under_curve(x, y) == 0.06 
}
