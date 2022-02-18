// structs.v
module hamnn

import time

const (
	missings                   = ['?', '']

	integer_range_for_discrete = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
)

pub struct Class {
pub mut:
	class_name       string
	class_values     []string
	class_counts     map[string]int
	lcm_class_counts i64
}

struct ContinuousAttribute {
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

struct Fold {
	Class
mut:
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

pub struct RankingResult {
pub mut:
	path                       string
	exclude_flag               bool
	bins                       []int
	array_of_ranked_attributes []RankedAttribute
}

pub struct TrainedAttribute {
pub mut:
	attribute_type    string
	translation_table map[string]int
	minimum           f32
	maximum           f32
	bins              int
	rank_value        f32
}

pub struct Classifier {
	Options
	Class
pub mut:
	datafile_path      string
	attribute_ordering []string
	trained_attributes map[string]TrainedAttribute
	options            []string
	instances          [][]byte
	history            []HistoryEvent
}

struct HistoryEvent {
pub mut:
	event_date        time.Time
	instances_count   int
	event_environment Environment
	event             string
	file_path         string
}

// Options struct: can be used as the last parameter in a
// function's parameter list, to enable
// default values to be passed to functions.
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
	classifierfile_path  string
	instancesfile_path   string
	help_flag            bool
	weighting_flag       bool
	folds                int
	repetitions          int
	random_pick          bool
}

pub struct Environment {
pub mut:
	hamnn_version  string
	cached_cpuinfo map[string]string
	os_kind        string
	os_details     string
	arch_details   []string
	vexe_mtime     string
	v_full_version string
	vflags         string
}

pub struct Attribute {
pub mut:
	id           int
	name         string
	count        int
	uniques      int
	missing      int
	att_type     string
	for_training bool
	min          f32
	max          f32
}

pub struct AnalyzeResult {
pub mut:
	environment   Environment
	datafile_path string
	datafile_type string
	class_name    string
	class_counts  map[string]int
	attributes    []Attribute
}

pub struct ClassifyResult {
pub mut:
	index 	int 
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
	incorrect_inferences    int
	wrong_inferences     int
	confusion_matrix_row map[string]int
}

// Returned by cross_validate() and verify()
pub struct CrossVerifyResult {
pub mut:
	labeled_classes []string
	inferred_classes 	[]string
	class_counts map[string]int
	labeled_instances map[string]int 
	correct_inferences   map[string]int 
	incorrect_inferences    map[string]int 
	wrong_inferences     map[string]int 
	// outer key: actual class; inner key: predicted class
	confusion_matrix_map map[string]map[string]int
	pos_neg_classes  []string
	correct_count    int
	incorrects_count     int
	wrong_count      int
	total_count      int
	bin_values       []int
	attributes_used  int
	confusion_matrix [][]string
}

pub struct ExploreResult {
pub mut:
	path                 string
	testfile_path        string
	exclude_flag         bool
	weighting_flag       bool
	bins                 []int
	uniform_bins         bool
	number_of_attributes []int
	folds                int
	repetitions          int
	random_pick          bool
	array_of_results     []CrossVerifyResult
}

pub struct PlotResult {
pub mut:
	bin             int
	attributes_used int
	correct_count   int
	total_count     int
}

pub struct ValidateResult {
	Class
pub mut:
	path             string
	inferred_classes []string
	counts           [][]int
	instances        [][]byte
}
