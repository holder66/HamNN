// append.v
module hamnn

// import tools
import json
import os
import time

// do_append appends instances to a classifier.
// It returns the extended classifier.
pub fn append_instances(cl Classifier, instances_to_append ValidateResult, opts Options) Classifier {
	// append needs to append the array of byte values for each new instance
	// to cl.instances, and append the class value for each new instance
	// cl.class_values, update the cl.class_counts map, and calculate a new lcm
	// println(cl)
	if opts.verbose_flag {
		println('$cl\n$instances_to_append')
	}
	mut ext_cl := cl
	mut event := HistoryEvent{
		instances_count: instances_to_append.inferred_classes.len
		event_date: time.utc()
		event_environment: get_environment()
		event: 'append'
	}
	ext_cl.history << event
	ext_cl.instances << instances_to_append.instances
	ext_cl.class_values << instances_to_append.inferred_classes
	ext_cl.class_counts = string_element_counts(ext_cl.class_values)
	// when the weighting_flag is set
	if opts.weighting_flag {
		ext_cl.lcm_class_counts = i64(lcm(get_map_values(ext_cl.class_counts)))
	}

	return ext_cl
}

// append extends the classifier in the file specified by
// opts.classifierfile_path, with the instances in the file specified
// by opts.instancesfile_path, and returns the extended classifier.
// Optionally, it writes the extended classifier to a file
// specified by opts.outputfile_path.
pub fn append(opts Options) ?Classifier {
	// println(opts)
	mut cl := load_classifier_file(opts.classifierfile_path) ?
	mut instances_to_append := load_instances_file(opts.instancesfile_path) ?
	mut ext_cl := append_instances(cl, instances_to_append, opts)
	mut event := HistoryEvent{
		instances_count: instances_to_append.inferred_classes.len
		event_date: time.utc()
		event_environment: get_environment()
		event: 'append'
		file_path: opts.instancesfile_path
	}
	ext_cl.history << event
	if opts.show_flag {
		show_classifier(ext_cl)
	}
	if opts.outputfile_path != '' {
		mut f := os.open_file(opts.outputfile_path, 'w') or { panic(err.msg) }
		f.write_string(json.encode(ext_cl)) or { panic(err.msg) }
		f.close()
	}
	println(ext_cl.history)
	return ext_cl
}
