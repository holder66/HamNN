// hamnn.v
module main
import os
import tools
import analyze
import rank
import make
import query
import verify
import validate
import cross
import explore
import display
import os.cmdline as oscmdline
import time
import math

// the command line interface for using hamnn. In a terminal, type: `v run hamnn.v --help`
// ```sh
// Usage: v run hamnn [command] [flags] datafile
// Commands: analyze | classify | cross | explore | make | orange |
//           partition | query | rank | validate | verify
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
// -k --classifier, followed by the path to a file for a saved Classifier struct
// -o --output, followed by the path to a file in which a classifier or a
//    result will be stored;
// -p --part, followed by an integer indicating partition number (note that
// 	partition number might be called fold number in other settings);
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
pub fn main() {
	// get the command line string and use it to create an Options struct
	sw := time.new_stopwatch()
	// println('nr_cpus: ${runtime.nr_cpus()} nr_jobs: ${runtime.nr_jobs()}')
	mut opts := get_options(os.args[1..])

	if opts.help_flag {
		println(show_help(opts))
	} else {
		match opts.command {
			'analyze' { analyze(opts) }
			'classify' { classify(opts) }
			'cross' { cross(opts) }
			'display' { display(opts) }
			'explore' { explore(opts) }
			'make' { make(opts) }
			'orange' { orange() }
			'partition' { partition(opts) }
			'query' { query(opts) }
			'rank' { rank(opts) }
			'validate' { validate(opts) }
			'verify' { verify(opts)? }
			// 'partition' { partition(opts) }
			else { println('unrecognized command') }
		}
	}
	mut duration := sw.elapsed()
	// println('duration: $duration')
	println('processing time: ${int(duration.hours())} hrs ${int(math.fmod(duration.minutes(),
		60))} min ${math.fmod(duration.seconds(), 60):6.3f} sec')
}

// get_options fills an Options struct with values from the command line
fn get_options(args []string) tools.Options {
	mut opts := tools.Options{
		args: args
	}
	if (flag(args, ['-h', '--help', 'help']) && args.len == 2) || args.len <= 1 {
		opts.help_flag = true
	}
	opts.non_options = oscmdline.only_non_options(args)
	if opts.non_options.len > 0 {
		opts.command = opts.non_options[0]
		opts.datafile_path = tools.last(opts.non_options)
	}
	if option(args, ['-b', '--bins']) != '' {
		opts.bins = tools.parse_range(option(args, ['-b', '--bins']))
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
		opts.number_of_attributes = tools.parse_range(option(args, ['-a', '--attributes']))
	}
	if option(args, ['-f', '--folds']) != '' {
		opts.folds = option(args, ['-f', '--folds']).int()
	}
	if option(args, ['-r', '--reps']) != '' {
		opts.repetitions = option(args, ['-r', '--reps']).int()
	}
	// if option(args, ['-p', '--part']) != '' {
	// 	opts.current_fold = option(args, ['-p', '--part']).int()
	// }
	opts.testfile_path = option(args, ['-t', '--test'])
	opts.outputfile_path = option(args, ['-o', '--output'])
	opts.classifierfile_path = option(args, ['-k', '--classifier'])
	return opts
}

// show_help
fn show_help(opts tools.Options) string {
	return match opts.command {
		'rank' { tools.rank_help }
		'query' { tools.query_help }
		'classify' { tools.classify_help }
		'analyze' { tools.analyze_help }
		'make' { tools.make_help }
		'orange' { tools.orange_help }
		'verify' { tools.verify_help }
		'partition' { tools.partition_help }
		'cross' { tools.cross_help }
		'explore' { tools.explore_help }
		'validate' { tools.validate_help }
		'display' { tools.display_help }
		else { tools.hamnn_help }
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
fn analyze(opts tools.Options) {
	tools.print_array(analyze.analyze_dataset(tools.load_file(opts.datafile_path)))
}

// query
fn query(opts tools.Options) {
	query.query(make(opts), opts)
}

// verify
fn verify(opts tools.Options) ? {
	if opts.classifierfile_path == '' {
		verify.verify(make(opts), opts)
	} else {
		verify.verify(tools.load_classifier_file(opts.classifierfile_path)?, opts)
	}
}

// validate
fn validate(opts tools.Options) {
	validate.validate(make(opts), opts)
}

// cross
fn cross(opts tools.Options) {
	cross.cross_validate(tools.load_file(opts.datafile_path), opts)
}

// explore
fn explore(opts tools.Options) {
	explore.explore(tools.load_file(opts.datafile_path), opts)
}

// classify
fn classify(opts tools.Options) {
}

// orange
fn orange() {
}

// partition
fn partition(opts tools.Options) {
}

// rank returns an array of attributes sorted
// according to their capacity to separate the classes
fn rank(opts tools.Options) []tools.RankedAttribute {
	return rank.rank_attributes(tools.load_file(opts.datafile_path), opts)
}

// make returns a Classifier struct
fn make(opts tools.Options) tools.Classifier {
	return make.make_classifier(tools.load_file(opts.datafile_path), opts)
}

// display outputs to the console or graphs a previously saved result
fn display(opts tools.Options) {
	display.display(opts)
}
