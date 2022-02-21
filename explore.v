// explore.v
module hamnn

import json
import os
import math

// explore runs a series of cross-validations or verifications,
// over a range of attributes and a range of binning values.
// ```sh
// Options (also see the Options struct):
// bins: range for binning or slicing of continuous attributes;
// uniform_bins: same number of bins for continuous attributes;
// number_of_attributes: range for attributes to include;
// exclude_flag: excludes missing values when ranking attributes;
// weighting_flag: rank attributes and count nearest neighbors accounting
// 	for class prevalences;
// folds: number of folds n to use for n-fold cross-validation (default
// 	is leave-one-out cross-validation);
// repetitions: number of times to repeat n-fold cross-validations;
// random-pick: choose instances randomly for n-fold cross-validations.
// Output options:
// show_flag: print results to the console;
// expanded_flag: print additional information to the console, including
// 		a confusion matrix.
// graph_flag: generate plots of Receiver Operating Characteristics (ROC)
// 		by attributes used; ROC by bins used, and accuracy by attributes
//		used.
// outputfile_path, saves the result as json.
// ```
pub fn explore(ds Dataset, opts Options) ExploreResult {
	mut ex_opts := opts
	mut results := ExploreResult{
		path: opts.datafile_path
		testfile_path: opts.testfile_path
		exclude_flag: opts.exclude_flag
		weighting_flag: opts.weighting_flag
		bins: opts.bins
		uniform_bins: opts.uniform_bins
		number_of_attributes: opts.number_of_attributes
		folds: opts.folds
		repetitions: opts.repetitions
		random_pick: opts.random_pick
	}
	pos_neg_classes := get_pos_neg_classes(ds.class_counts)
	mut result := CrossVerifyResult{
		pos_neg_classes: pos_neg_classes
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
	mut end_attr := attribute_max
	mut interval_attr := 1

	// if ex_opts.number_of_attributes == [0] { // ie, range over all attributes
	// 	end_attr = attribute_max
	// } else if ex_opts.number_of_attributes.len == 1 {
	// 	end_attr = ex_opts.number_of_attributes[0]
	// } else if ex_opts.number_of_attributes.len >= 2 {
	// 	start_attr = ex_opts.number_of_attributes[0]
	// 	end_attr = ex_opts.number_of_attributes[1]
	// 	if ex_opts.number_of_attributes.len == 3 {
	// 		interval_attr = ex_opts.number_of_attributes[2]
	// 	}
	// }

	att_range := ex_opts.number_of_attributes
	if att_range != [0] {
	if att_range.len == 3 {
		interval_attr = att_range.last()
		end_attr = math.min(attribute_max, att_range[1])
	}
	else {
		end_attr = math.min(attribute_max, att_range.last())
		if att_range.len == 2 {start_attr = math.min(attribute_max, att_range[0])}
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
	if opts.verbose_flag && opts.command == 'explore' {
		println('attributing: $start_attr $end_attr $interval_attr')
		println('binning: $start_bin $end_bin $interval_bin')
	}
	show_explore_header(pos_neg_classes, opts)
	mut atts := start_attr
	mut bin := start_bin
	mut cl := Classifier{}
	mut array_of_results := []CrossVerifyResult{}
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
			show_explore_line(result, ex_opts)
			result.bin_values = ex_opts.bins
			result.attributes_used = atts
			array_of_results << result
			bin += interval_bin
		}
		atts += interval_attr
	}
	results.array_of_results = array_of_results

	if opts.graph_flag {
		plot_explore(results, opts)
	}
	if opts.outputfile_path != '' {
		mut f := os.open_file(opts.outputfile_path, 'w') or { panic(err.msg) }
		f.write_string(json.encode(results)) or { panic(err.msg) }
		f.close()
	}
	return results
}
