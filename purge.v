// purge
module hamnn

// purge returns a Classifier struct with duplicate instances removed,
// given a Classifier (as created by make_classifier()).

// purge
fn purge(cl Classifier) Classifier {
	mut pcl := cl
	// find duplicate instances
	mut i := 1
	mut j := 0
	for {
		j = 0
		for {
			if i >= pcl.class_values.len {
				break
			}
			if pcl.class_values[i] == pcl.class_values[j] && pcl.instances[i] == pcl.instances[j] {
				pcl.instances.delete(i)
				pcl.class_values.delete(i)
			} else {
				j++
				if j >= i {
					break
				}
			}
		}
		i++
		if i >= pcl.class_values.len {
			break
		}
	}
	return pcl
}
