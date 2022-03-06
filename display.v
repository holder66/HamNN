// display.v
module hamnn

import os
import json

// display_file 
pub fn display_file(path string, settings DisplaySettings) ? {
	// determine what kind of file, then call the appropriate functions in show and plot
	// path := opts.datafile_path
	// println(opts)
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
		if settings.graph_flag { 
			println(settings)
			plot_rank(saved_rr)}
		}
		s.contains('"struct_type":".AnalyzeResult"') {
			saved_ar := json.decode(AnalyzeResult, s) or { panic('Failed to parse json') }
		show_analyze(saved_ar)
		}
		s.contains('"struct_type":".ValidateResult"') {
			saved_valr := json.decode(ValidateResult, s) or { panic('Failed to parse json') }
		show_validate(saved_valr)
		}
		s.contains('"struct_type":".CrossVerifyResult"') {
			saved_vr := json.decode(CrossVerifyResult, s) or { panic('Failed to parse json') }
		show_verify(saved_vr)?
		}
		else { println('File type not recognized!') }
	}
	

}