// hamnn.v
module hamnn

import os
// import tools
// import analyze
// import append
// import rank
// import make
// import query
// import verify
// import validate
// import cross
// import explore
import os.cmdline as oscmdline
import time
import math

// the command line interface for using hamnn. In a terminal, type: `v run hamnn.v --help`
// ```sh
// Usage: v run hamnn [command] [flags] datafile
// Commands: analyze | append | cross | explore | make | orange |
//           query | rank | validate | verify
// Flags and options:
// -a --attributes, can be one, two, or 3 integers; a single integer will
//    be used by make_classifier to produce a classifier with that number
//    of attributes. More than one integer will be used by
//    explore to provide a range and an interval.
// -b --bins, can be one, two, or 3 integers; a single integer for one bin
//    value to be used for all attributes; two integers for a range of bin
//    values; a third integer specifies an interval for the range (note that
//    the binning range is from the upper to the lower value);
//    note: when doing an explore, the first integer specifies the lower
//    limit for the number of bins, and the second gives the upper value
//    for the explore range. Example: explore -b 3,6 would first use 3 - 3,
//    then 3 - 4, then 3 - 5, and finally 3 - 6 for the binning ranges.
//    If the uniform flag is true, then a single integer specifies
//    the number of bins for all continuous attributes; two integers for a
//    range of uniform bin values for the explore command; a third integer
//    for the interval to be used over the explore range.
// -c --concurrent, permit parallel processing to use multiple cores;
// -d --display, output to the console or graph previously saved results;
// -e --expanded, expanded results on the console;
// -f --folds, default is leave-one-out;
// -g --graph, displays a plot;
// -h --help,
// -k --classifier, followed by the path to a file for a saved Classifier
// -o --output, followed by the path to a file in which a classifier, a
//    result, instances used for validation, or a query instance will be stored;
// -r --reps, number of repetitions; if > 1, a random selection of
// 	instances to be included in each fold will be applied
// -s --show, output results to the console;
// -t --test, followed by the path to the datafile to be verified or validated;
// -u --uniform, specifies if uniform binning is to be used for the explore
//    command;
// -v --verbose
// -w --weight, when classifying, weight the nearest neighbour counts by class prevalences;
// -x --exclude, do not take into account missing values when ranking attributes;
// ```
fn main() ? {
	// get the command line string and use it to create an Options struct
	sw := time.new_stopwatch()
	// println('nr_cpus: ${runtime.nr_cpus()} nr_jobs: ${runtime.nr_jobs()}')
	mut opts := get_options(os.args[1..])

	if opts.help_flag {
		println(show_help(opts))
	} else {
		match opts.command {
			'analyze' { analyze(opts) }
			'append' { do_append(opts) ? }
			'cross' { cross(opts) }
			// 'display' { display(opts) }
			'explore' { do_explore(opts) }
			'make' { make(opts) ? }
			'orange' { orange() }
			'query' { do_query(opts) ? }
			'rank' { rank(opts) }
			'validate' { do_validate(opts) ? }
			'verify' { do_verify(opts) ? }
			else { println('unrecognized command') }
		}
	}
	mut duration := sw.elapsed()
	// println('duration: $duration')
	println('processing time: ${int(duration.hours())} hrs ${int(math.fmod(duration.minutes(),
		60))} min ${math.fmod(duration.seconds(), 60):6.3f} sec')
}

// get_options fills an Options struct with values from the command line
fn get_options(args []string) Options {
	mut opts := Options{
		args: args
	}
	if (flag(args, ['-h', '--help', 'help']) && args.len == 2) || args.len <= 1 {
		opts.help_flag = true
	}
	opts.non_options = oscmdline.only_non_options(args)
	if opts.non_options.len > 0 {
		opts.command = opts.non_options[0]
		opts.datafile_path = last(opts.non_options)
	}
	if option(args, ['-b', '--bins']) != '' {
		opts.bins = parse_range(option(args, ['-b', '--bins']))
	}
	opts.concurrency_flag = flag(args, ['-c', '--concurrent'])
	opts.exclude_flag = flag(args, ['-x', '--exclude'])
	opts.graph_flag = flag(args, ['-g', '--graph'])
	opts.verbose_flag = flag(args, ['-v', '--verbose'])
	opts.weighting_flag = flag(args, ['-w', '--weight'])
	opts.uniform_bins = flag(args, ['-u', '--uniform'])
	opts.show_flag = flag(args, ['-s', '--show'])
	opts.expanded_flag = flag(args, ['-e', '--expanded'])
	if option(args, ['-a', '--attributes']) != '' {
		opts.number_of_attributes = parse_range(option(args, ['-a', '--attributes']))
	}
	if option(args, ['-f', '--folds']) != '' {
		opts.folds = option(args, ['-f', '--folds']).int()
	}
	if option(args, ['-r', '--reps']) != '' {
		opts.repetitions = option(args, ['-r', '--reps']).int()
	}
	opts.testfile_path = option(args, ['-t', '--test'])
	opts.outputfile_path = option(args, ['-o', '--output'])
	opts.classifierfile_path = option(args, ['-k', '--classifier'])
	return opts
}

// show_help
fn show_help(opts Options) string {
	return match opts.command {
		'rank' { rank_help }
		'query' { query_help }
		'analyze' { analyze_help }
		'append' { append_help }
		'make' { make_help }
		'orange' { orange_help }
		'verify' { verify_help }
		'cross' { cross_help }
		'explore' { explore_help }
		'validate' { validate_help }
		'display' { display_help }
		else { hamnn_help }
	}
}

// option returns the parameter following any of a list of options
fn option(args []string, what []string) string {
	mut found := false
	mut result := ''
	for arg in args {
		if found {
			result = arg
			break
		} else if arg in what {
			found = true
		}
	}
	return result
}

// flag returns true if a specific flag is found, false otherwise
fn flag(args []string, what []string) bool {
	mut result := false
	for arg in args {
		if arg in what {
			result = true
			break
		}
	}
	return result
}

// analyze
fn analyze(opts Options) {
	print_array(analyze_dataset(load_file(opts.datafile_path)))
}

// append appends instances in a file, to a classifier in a file specified
// by flag -k, and (optionally) stores the extended classifier in a file
// specified by -o. It returns the extended classifier.
fn do_append(opts Options) ?Classifier {
	return append(opts)
}

// query
fn do_query(opts Options) ?ClassifyResult {
	if opts.classifierfile_path == '' {
		return query(make(opts) ?, opts)
	} else {
		cl := load_classifier_file(opts.classifierfile_path) ?
		show_classifier(cl)
		return query(make(opts) ?, opts)
	}
}

// verify
fn do_verify(opts Options) ?VerifyResult {
	println(opts)
	if opts.classifierfile_path == '' {
		return verify(make(opts) ?, opts)
	} else {
		cl := load_classifier_file(opts.classifierfile_path) ?
		show_classifier(cl)
		return verify(cl, opts)
	}
}

// validate
fn do_validate(opts Options) ?ValidateResult {
	if opts.classifierfile_path == '' {
		return validate(make(opts) ?, opts)
	} else {
		cl := load_classifier_file(opts.classifierfile_path) ?
		show_classifier(cl)
		return validate(cl, opts)
	}
}

// cross
fn cross(opts Options) {
	cross_validate(load_file(opts.datafile_path), opts)
}

// explore
fn do_explore(opts Options) {
	explore(load_file(opts.datafile_path), opts)
}

// orange
fn orange() {
}

// rank returns an array of attributes sorted
// according to their capacity to separate the classes
fn rank(opts Options) []RankedAttribute {
	return rank_attributes(load_file(opts.datafile_path), opts)
}

// make returns a Classifier struct
fn make(opts Options) ?Classifier {
	return make_classifier(load_file(opts.datafile_path), opts)
}

// display outputs to the console or graphs a previously saved result
// fn display(opts Options) {
// 	display.display(opts)
// }
