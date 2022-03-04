// display.v
module hamnn

import os
import json

// display_file 
pub fn display_file(opts Options) ? {
	// determine what kind of file, then call the appropriate functions in show and plot
	path := opts.datafile_path
	s := os.read_file(path.trim_space()) or { panic('failed to open $path') }
	// println(s.contains('"struct_type":".Classifier"'))
	match true {
		s.contains('"struct_type":".Classifier"') {
			saved_cl := json.decode(Classifier, s) or { panic('Failed to parse json') }
		show_classifier(saved_cl)
		}
		s.contains('"struct_type":".RankingResult"') {
			saved_rr := json.decode(RankingResult, s) or { panic('Failed to parse json') }
		show_rank_attributes(saved_rr)
		}
		s.contains('"struct_type":".AnalyzeResult"') {
			saved_ar := json.decode(AnalyzeResult, s) or { panic('Failed to parse json') }
		show_analyze(saved_ar)
		}
		// s.contains('"struct_type":".Classifier"') {
		// 	saved_cl := json.decode(Classifier, s) or { panic('Failed to parse json') }
		// show_classifier(saved_cl)
		// }
		else { println('File type not recognized!') }
	}
	

}