// structs.v
module tools

import time

pub struct Class {
pub mut:
	// class_index  int
	class_name       string
	class_values     []string
	class_counts     map[string]int
	lcm_class_counts i64
}

pub struct ContinuousAttribute {
	values  []f32
	minimum f32
	maximum f32
}

pub struct Dataset {
	Class
pub mut:
	path                         string
	attribute_names              []string
	attribute_flags              []string
	attribute_types              []string
	inferred_attribute_types     []string
	data                         [][]string
	useful_continuous_attributes map[int][]f32
	useful_discrete_attributes   map[int][]string
}

pub struct Fold {
	Class
pub mut:
	fold_number     int
	attribute_names []string
	data            [][]string
}

pub struct RankedAttribute {
pub mut:
	attribute_index         int
	attribute_name          string
	inferred_attribute_type string
	rank_value              f32
	rank_value_array        []f32
	bins                    int
}

pub struct TrainedAttribute {
pub mut:
	attribute_type    string
	translation_table map[string]int
	minimum           f32
	maximum           f32
	bins              int
}

pub struct Classifier {
	Options
	Class
pub mut:
	// TrainedAttribute
	datafile_path      string
	utc_date_time      time.Time
	vlang_version      string
	hamnn_version      string
	attribute_ordering []string
	// class_values       []string
	trained_attributes map[string]TrainedAttribute
	options            []string
	instances          [][]byte
}

pub struct Options {
pub mut:
	args                 []string
	non_options          []string
	command              string
	bins                 []int = [2, 16]
	uniform_bins         bool
	concurrency_flag     bool = true
	exclude_flag         bool
	graph_flag           bool
	verbose_flag         bool
	number_of_attributes []int = [0]
	show_flag            bool
	expanded_flag        bool
	datafile_path        string = 'datasets/developer.tab'
	testfile_path        string
	outputfile_path      string
	classifierfile_path	 string
	help_flag            bool
	weighting_flag       bool
	folds                int
	repetitions          int
	random_pick          bool
}

pub struct Environment {
pub mut:
	cached_cpuinfo 		map[string]string
	os_kind				string
	os_details			string
	arch_details 		[]string
	vexe_mtime			string
	v_full_version		string
	vflags				string
}

pub struct ClassifyResult {
pub mut:
	inferred_class             string
	labeled_class              string
	nearest_neighbors_by_class []int
	classes                    []string
	weighting_flag             bool
}

pub struct ResultForClass {
pub mut:
	labeled_instances    int
	correct_inferences   int
	missed_inferences    int
	wrong_inferences     int
	confusion_matrix_row map[string]int
}

pub struct VerifyResult {
pub mut:
	// inferred_classes []string
	labeled_classes []string
	// matches          []int
	// counts           map[int]int
	class_table      map[string]ResultForClass
	pos_neg_classes  []string
	correct_count    int
	misses_count     int
	wrong_count      int
	total_count      int
	bin_values       []int
	attributes_used  int
	confusion_matrix [][]string
}

pub struct PlotResult {
pub mut:
	bin             int
	attributes_used int
	correct_count   int
	total_count     int
}

pub struct ValidateResult {
pub mut:
	inferred_classes []string
}
