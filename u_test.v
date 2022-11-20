// u_test.v
module hamnn

// test_show_mult 
fn test_show_mult() {
	


saved_params := read_multiple_opts('/Users/henryolders/vlang/vhamnn/mult_classify_options/Oxford-train-bp.opts') or {
			MultipleOptions{}
		}
show_multiple_classifiers_options(saved_params)
	}