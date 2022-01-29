// append.v
module append

import tools
import json
import os

// append 
pub fn append(cl tools.Classifier) ?tools.Classifier {
	// append needs to append the array of byte values for each new instance
	// to cl.instances, and append the class value for each new instance
	// cl.class_values, update the cl.class_counts map, and calculate a new lcm
	println(cl)
	return cl
}

// append_file_to_file extends the classifier in the file specified by
// opts.classifierfile_path, with the instances in the file specified
// by opts.datafile_path, and writes the extended classifier to a file
// specified by opts.outputfile_path
pub fn append_file_to_file(opts tools.Options) ?tools.Classifier {
	println(opts)
	mut cl := tools.Classifier{}
	cl = tools.load_classifier_file(opts.classifierfile_path) ?
	println(cl)
	if opts.outputfile_path != '' && opts.command == 'append' {
		outputfile := opts.outputfile_path
		s := json.encode(cl)
		// println('After json encoding, before writing:\n $s')
		mut f := os.open_file(outputfile, 'w') or { panic(err.msg) }
		f.write_string(s) or { panic(err.msg) }
		f.close()
	}
	return cl 
}