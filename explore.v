// explore.v
module hamnn

// explore runs a series of cross-validations or verifications,
// over a range of attributes and a range of binning values.
// ```sh
// Options (also see the Options struct):
// bins: range for binning or slicing of continuous attributes;
// uniform_bins: same number of bins for all continuous attributes;
// number_of_attributes: range for attributes to include;
// exclude_flag: excludes missing values when ranking attributes;
// weighting_flag: nearest neighbor counts are weighted by
// 	class prevalences;
// folds: number of folds n to use for n-fold cross-validation (default
// 	is leave-one-out cross-validation);
// repetitions: number of times to repeat n-fold cross-validations;
// random-pick: choose instances randomly for n-fold cross-validations.
// Output options:
// show_flag: display results on the console;
// expanded_flag: display additional information on the console, including
// 	a confusion matrix for each explore step;
// graph_flag: generate plots of Receiver Operating Characteristics (ROC)
// 	by attributes used; ROC by bins used, and accuracy by attributes
//	used.
// outputfile_path: saves the result to a file.
// ```
pub fn explore(ds Dataset, opts Options) ?ExploreResult {
	mut ex_opts := opts
	mut results := ExploreResult{
		path: opts.datafile_path
		testfile_path: opts.testfile_path
		Parameters: opts.Parameters
		DisplaySettings: opts.DisplaySettings
		AttributeRange: get_attribute_range(opts.number_of_attributes,
			ds.useful_continuous_attributes.len + ds.useful_discrete_attributes.len)
		folds: opts.folds
		repetitions: opts.repetitions
		random_pick: opts.random_pick
		pos_neg_classes: get_pos_neg_classes(ds.class_counts)
	}
	mut result := CrossVerifyResult{
		pos_neg_classes: results.pos_neg_classes
	}
	mut attribute_max := ds.useful_continuous_attributes.len + ds.useful_discrete_attributes.len
	if ex_opts.verbose_flag && opts.command == 'explore' {
		println('ex_opts in explore: $ex_opts')
		println('number of usable attributes: $attribute_max')
	}
	// if there are no useful continuous attributes, skip the binning
	if ds.useful_continuous_attributes.len == 0 {
		ex_opts.bins = [0]
	}
	results.binning = get_binning(ex_opts.bins)

	binning := results.binning

	if opts.verbose_flag && opts.command == 'explore' {
		println('attributing: $results.AttributeRange')
		println('binning: $results.binning')
	}
	if opts.command == 'explore' && (opts.show_flag || opts.expanded_flag) {
		// show_explore_header(pos_neg_classes, binning, opts)
		show_explore_header(results, results.DisplaySettings)
	}
	mut atts := results.start
	mut bin := binning.lower
	mut cl := Classifier{}
	mut array_of_results := []CrossVerifyResult{}
	// mut plot_data := [][]PlotResult{}

	for atts <= results.end {
		ex_opts.number_of_attributes = [atts]
		bin = binning.lower
		for bin <= binning.upper {
			if ex_opts.uniform_bins {
				ex_opts.bins = [bin, bin]
			} else {
				ex_opts.bins = [2, bin]
			}
			if ex_opts.testfile_path == '' {
				result = cross_validate(ds, ex_opts) ?
			} else {
				cl = make_classifier(ds, ex_opts)
				result = verify(cl, ex_opts) ?
			}
			result.bin_values = ex_opts.bins
			result.attributes_used = atts
			show_explore_line(result, results.DisplaySettings) ?

			array_of_results << result
			bin += binning.interval
		}
		atts += results.att_interval
	}
	results.array_of_results = array_of_results
	if opts.graph_flag {
		plot_explore(results, opts) ?
		if ds.Class.class_counts.len == 2 {
			plot_roc(results, opts)
		}
	}
	if opts.outputfile_path != '' {
		save_json_file(results, opts.outputfile_path)
	}
	return results
}

// get_attribute_range
fn get_attribute_range(atts []int, max int) AttributeRange {
	if atts == [0] {
		return AttributeRange{
			start: 1
			end: max
			att_interval: 1
		}
	}
	if atts.len == 1 {
		return AttributeRange{
			start: 1
			end: atts[0]
			att_interval: 1
		}
	}
	if atts.len == 2 {
		return AttributeRange{
			start: atts[0]
			end: atts[1]
			att_interval: 1
		}
	}
	return AttributeRange{
		start: atts[0]
		end: atts[1]
		att_interval: atts[2]
	}
}
