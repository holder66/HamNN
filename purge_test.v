// purge_test.v
module hamnn

// test_purge
fn test_purge() ? {
	mut opts := Options{
		bins: [3, 3]
		exclude_flag: false
		verbose_flag: false
		command: 'make'
		number_of_attributes: [2]
		show_flag: false
		weighting_flag: false
	}
	mut ds := load_file('datasets/iris.tab')
	mut cl := make_classifier(ds, opts)
	assert cl.instances.len == 150
	mut pcl := purge(cl)
	assert pcl.instances.len == 12
}
