// explore.v
module hamnn

// import os

// explore runs a series of cross-validations, over a range of
// attributes and a range of binning values.
// If a second file is given (after the -t option), then explore
// runs a series of verifies. Type: `v run hamnn.v explore --help`
pub fn explore(ds Dataset, opts Options) []VerifyResult {
	mut ex_opts := opts
	mut result := VerifyResult{
		pos_neg_classes: get_pos_neg_classes(ds.class_counts)
	}
	// mut percent := 0.0
	mut attribute_max := ds.useful_continuous_attributes.len + ds.useful_discrete_attributes.len
	if ex_opts.verbose_flag && opts.command == 'explore' {
		println('ex_opts in explore: $ex_opts')
		println('number of usable attributes: $attribute_max')
	}
	// if there are no useful continuous attributes, skip the binning
	if ds.useful_continuous_attributes.len == 0 {
		ex_opts.bins = [0]
	}
	mut start_attr := 1
	mut end_attr := 2
	mut interval_attr := 1

	if ex_opts.number_of_attributes == [0] { // ie, range over all attributes
		end_attr = attribute_max
	} else if ex_opts.number_of_attributes.len == 1 {
		end_attr = ex_opts.number_of_attributes[0]
	} else if ex_opts.number_of_attributes.len >= 2 {
		start_attr = ex_opts.number_of_attributes[0]
		end_attr = ex_opts.number_of_attributes[1]
		if ex_opts.number_of_attributes.len == 3 {
			interval_attr = ex_opts.number_of_attributes[2]
		}
	}
	// for uniform binning (ie, the same number of bins
	// for all continuous attributes)
	mut start_bin := 2
	mut end_bin := start_bin
	mut interval_bin := 1
	if ex_opts.bins.len == 1 || (ex_opts.bins.len == 2 && ex_opts.bins[0] == ex_opts.bins[1]) {
		start_bin = ex_opts.bins[0]
		end_bin = start_bin
	} else if ex_opts.bins.len >= 2 {
		start_bin = ex_opts.bins[0]
		end_bin = ex_opts.bins[1]
		if ex_opts.bins.len == 3 {
			interval_bin = ex_opts.bins[2]
		}
	}
	if ex_opts.bins == [0] {
		start_bin = 0
		end_bin = 0
	}
	if opts.show_flag {
		show_explore_header(opts)
	}
	if opts.expanded_flag {
		expanded_explore_header(result, opts)
	}

	if opts.verbose_flag && opts.command == 'explore' {
		println('attributing: $start_attr $end_attr $interval_attr')
		println('binning: $start_bin $end_bin $interval_bin')
	}
	mut atts := start_attr
	mut bin := start_bin
	mut cl := Classifier{}
	mut results := []VerifyResult{}
	// mut plot_data := [][]PlotResult{}

	for atts <= end_attr {
		ex_opts.number_of_attributes = [atts]
		bin = start_bin
		for bin <= end_bin {
			if ex_opts.uniform_bins {
				ex_opts.bins = [bin]
			} else {
				ex_opts.bins = [start_bin, bin]
			}
			if ex_opts.testfile_path == '' {
				result = cross_validate(ds, ex_opts)
			} else {
				cl = make_classifier(ds, ex_opts)
				result = verify(cl, ex_opts)
			}
			result.bin_values = ex_opts.bins
			result.attributes_used = atts
			results << result
			bin += interval_bin
		}
		atts += interval_attr
	}
	if opts.graph_flag {
		plot_explore(results, opts)
		// println(results)
		if results[0].class_table.len == 2 {
			plot_roc(results, opts)
		}
	}

	return results
}
