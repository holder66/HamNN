// trial.v
module explore

import tools
import cross

// explore runs a series of cross-validations, over a range of
// attributes and a range of binning values. Type: `v run hamnn.v explore --help`
pub fn explore(ds tools.Dataset, opts tools.Options) {
	mut ex_opts := opts
	mut result := tools.VerifyResult{}
	mut percent := 0.0
	mut attribute_max := ds.useful_continuous_attributes.len + ds.useful_discrete_attributes.len
	if ex_opts.verbose_flag && opts.command == 'explore' {
		println('ex_opts in explore: $ex_opts')
		println('number of usable attributes: $attribute_max')
	}
	// if there are no useful continuous attributes, skip the binning
	if ds.useful_continuous_attributes.len == 0 {
		ex_opts.bins = [1]
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

	mut start_bin := 2
	mut end_bin := start_bin
	mut interval_bin := 1
	if ex_opts.bins.len == 1 || (ex_opts.bins.len == 2 && ex_opts.bins[0] == ex_opts.bins[1]) {
		start_bin = ex_opts.bins[0]
		end_bin = start_bin
		ex_opts.uniform_bins = true
	} else if ex_opts.bins.len >= 2 {
		start_bin = ex_opts.bins[0]
		end_bin = ex_opts.bins[1]
		if ex_opts.bins.len == 3 {
			interval_bin = ex_opts.bins[2]
		}
	}
	if ex_opts.bins == [1] {
		start_bin = 1
		end_bin = 1
	}
	if opts.verbose_flag && opts.command == 'explore' {
		println('attributing: $start_attr $end_attr $interval_attr')
		println('binning: $start_bin $end_bin $interval_bin')
	}
	println('\nExplore "$opts.datafile_path"')
	println('Exclude: $opts.exclude_flag; Weighting: $opts.weighting_flag')
	println('Attributes  Bins  Matches  Nonmatches  Percent')
	println('__________  ____  _______  __________  _______')
	mut atts := start_attr
	mut bin := start_bin
	for atts <= end_attr {
		ex_opts.number_of_attributes = [atts]
		bin = start_bin
		for bin <= end_bin {
			ex_opts.bins = [bin]
			result = cross.cross_validate(ds, ex_opts)
			percent = (f32(result.correct_count) * 100 / result.labeled_classes.len)
			println('${atts:10}  ${bin:4}  ${result.correct_count:7}  ${result.labeled_classes.len - result.correct_count:10}  ${percent:7.2f}')
			bin += interval_bin
		}
		atts += interval_attr
	}
}
