// purge
module hamnn

// purge returns a Classifier struct with duplicate instances removed,
// given a Classifier (as created by make_classifier()).

// purge 
fn purge(cl Classifier) Classifier {
	// println('purging...')
	mut pcl := cl
	// find duplicate instances
	mut i := 1
	mut j := 0
	// for k in 0..pcl.class_values.len {
	// 	println('$k, ${pcl.class_values[k]}, ${pcl.instances[k]}')
	// }
	for {
		j = 0
		for {
			if i >= pcl.class_values.len {
				break
			}
			if test_dup(pcl.class_values[i], pcl.class_values[j], pcl.instances[i], pcl.instances[j]) {
				// println('i: $i, j: $j')
				// println('length of instances before delete: $pcl.instances.len')
				pcl.instances.delete(i)
				pcl.class_values.delete(i)
				// println('length of instances after delete: $pcl.instances.len')
			}
			else {
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
	// for k in 0..pcl.class_values.len {
	// 	println('$k, ${pcl.class_values[k]}, ${pcl.instances[k]}')
	// }
	// println('length of instances after purge: $pcl.instances.len')
	return pcl
}

// test_dup 
fn test_dup(l_class string, r_class string, l_instance []u8, r_instance []u8) bool {
	if l_class == r_class && l_instance == r_instance {
		return true
	} else {
		return false
	}
}
