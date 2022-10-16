// multiple_test.v

// test_multiple_classifiers

module hamnn

import os
// import vtl

fn testsuite_begin() ? {
	if os.is_dir('tempfolder4') {
		os.rmdir_all('tempfolder4')!
	}
	os.mkdir_all('tempfolder4')!
}

fn testsuite_end() ? {
	os.rmdir_all('tempfolder4')!
}

// test_multiple_verify
fn test_multiple_verify() ? {
	mut opts := Options{
		verbose_flag: false
		show_flag: false
		expanded_flag: false
		concurrency_flag: true
	}

	mut result := CrossVerifyResult{}
	mut ds := Dataset{}
	mut cl1 := Classifier{}
	mut cl2 := Classifier{}
	mut saved_cl := Classifier{}
	mut vr1 := CrossVerifyResult{}
	mut vr2 := CrossVerifyResult{}
	mut mc_result := ClassifyResult{}

	// test verify with a non-saved classifier
	opts.command = 'make'
	opts.datafile_path = 'datasets/multiples-train.tab'
	opts.testfile_path = 'datasets/multiples-verify.tab'
	opts.classifierfile_path = ''
	opts.bins = [1,2]
	opts.number_of_attributes = [2]
	opts.weighting_flag = false
	ds = load_file(opts.datafile_path)
	// println(ds.class_values)
	cl1 = make_classifier(ds, opts)
	mut test_ds1 := load_file(opts.testfile_path)
	// println(test_ds1.class_values)
	mut test_instances1 := generate_test_instances_array(cl1, test_ds1)
	// opts.command = 'verify'
	// vr1 = verify(cl1, opts)?
	// println(vr1)
	opts.bins = [1,1]
	opts.number_of_attributes = [1]
	opts.weighting_flag = true
	cl2 = make_classifier(ds, opts)

	mut test_ds2 := load_file(opts.testfile_path)
	mut test_instances2 := generate_test_instances_array(cl2, test_ds1)
	// println('test_instances1: $test_instances1')
	// println('test_instances2: $test_instances2')
	for i in 0..test_instances1.len {
	// println(multiple_classifier_classify(i, [cl1, cl2], [test_instances1[i], test_instances2[i]], opts).inferred_class)
	}
	println('Done with multiples-train.tab')

	opts.datafile_path = 'datasets/bcw350train'
	opts.testfile_path = 'datasets/bcw174test'
	opts.classifierfile_path = ''
	opts.number_of_attributes = [1]
	opts.weighting_flag = true
	ds = load_file(opts.datafile_path)
	cl1 = make_classifier(ds, opts)
	test_ds1 = load_file(opts.testfile_path)
	// println(test_ds1.class_values)
	test_instances1 = generate_test_instances_array(cl1, test_ds1)
	opts.number_of_attributes = [6]
	opts.weighting_flag = true
	cl2 = make_classifier(ds, opts)
	test_ds2 = load_file(opts.testfile_path)
	// println(test_ds2)
	test_instances2 = generate_test_instances_array(cl2, test_ds1)
	// println('test_instances1: $test_instances1')
	// println('test_instances2: $test_instances2')
	mut correct_count := 0
	mut incorrect_count := 0
	mut raw_accuracy := 0.0
	for i in 0..test_instances1.len {
		mc_result = multiple_classifier_classify(i, [cl1, cl2], [test_instances1[i], test_instances2[i]], opts)
		if test_ds2.class_values[i] == mc_result.inferred_class {

			correct_count += 1
		} else {
		 	println('i: $i  actual class: ${test_ds2.class_values[i]} inferred_class: $mc_result.inferred_class')
		 	incorrect_count += 1
		 }
	}
	println('correct_count: $correct_count incorrect_count: $incorrect_count')


	println('Done with bcw350train')

	opts.datafile_path = 'datasets/leukemia38train.tab'
	opts.testfile_path = 'datasets/leukemia34test.tab'
	opts.classifierfile_path = ''
	opts.number_of_attributes = [1]
	opts.bins = [5,5]
	opts.weighting_flag = true
	ds = load_file(opts.datafile_path)
	cl1 = make_classifier(ds, opts)
	test_ds1 = load_file(opts.testfile_path)
	// println(test_ds1.class_values)
	test_instances1 = generate_test_instances_array(cl1, test_ds1)
	opts.number_of_attributes = [10]
	opts.bins = [1,3]
	opts.weighting_flag = false
	cl2 = make_classifier(ds, opts)
	test_ds2 = load_file(opts.testfile_path)
	// println(test_ds2)
	test_instances2 = generate_test_instances_array(cl2, test_ds1)
	// println('test_instances1: $test_instances1')
	// println('test_instances2: $test_instances2')
	correct_count = 0
	incorrect_count = 0
	raw_accuracy = 0.0
	for i in 0..test_instances1.len {
		mc_result = multiple_classifier_classify(i, [cl1, cl2], [test_instances1[i], test_instances2[i]], opts)
		if test_ds2.class_values[i] == mc_result.inferred_class {

			correct_count += 1
		} else {
		 	println('i: $i  actual class: ${test_ds2.class_values[i]} inferred_class: $mc_result.inferred_class')
		 	incorrect_count += 1
		 }
	}
	println('correct_count: $correct_count incorrect_count: $incorrect_count')


	println('Done with leukemia')

	// // now with a saved classifier
	// opts.outputfile_path = 'tempfolder4/classifierfile'
	// cl = Classifier{}
	// result = CrossVerifyResult{}
	// cl = make_classifier(ds, opts)
	// cl = Classifier{}
	// result = verify(load_classifier_file('tempfolder4/classifierfile')?, opts)?
	// assert result.correct_count == 171
	// assert result.wrong_count == 3

	// println('Done with bcw350train using saved classifier')

	// opts.datafile_path = 'datasets/soybean-large-train.tab'
	// opts.testfile_path = 'datasets/soybean-large-test.tab'
	// opts.classifierfile_path = ''
	// opts.number_of_attributes = [33]
	// opts.bins = [2, 16]
	// opts.weighting_flag = true
	// ds = load_file(opts.datafile_path)
	// cl = make_classifier(ds, opts)
	// result = verify(cl, opts)?
	// assert result.correct_count == 340
	// assert result.wrong_count == 36

	// println('Done with soybean-large-train.tab')

	// // now with a saved classifier
	// opts.outputfile_path = 'tempfolder4/classifierfile'
	// cl = Classifier{}
	// result = CrossVerifyResult{}
	// cl = make_classifier(ds, opts)
	// cl = Classifier{}
	// result = verify(load_classifier_file('tempfolder4/classifierfile')?, opts)?
	// assert result.correct_count == 340
	// assert result.wrong_count == 36

	// println('Done with soybean-large-train.tab using saved classifier')

	// if get_environment().arch_details[0] != '4 cpus' {
	// 	opts.datafile_path = 'datasets/mnist_test.tab'
	// 	opts.testfile_path = 'datasets/mnist_test.tab'
	// 	opts.classifierfile_path = ''
	// 	opts.outputfile_path = ''
	// 	opts.number_of_attributes = [50]
	// 	opts.bins = [2, 2]
	// 	opts.weighting_flag = false
	// 	opts.show_flag = false
	// 	ds = load_file(opts.datafile_path)
	// 	cl = make_classifier(ds, opts)
	// 	result = verify(cl, opts)?
	// 	assert result.correct_count == 9982
	// 	assert result.wrong_count == 18

	// 	println('Done with mnist_test.tab')

	// 	// now with a saved classifier
	// 	opts.outputfile_path = 'tempfolder4/classifierfile'
	// 	cl = Classifier{}
	// 	result = CrossVerifyResult{}
	// 	cl = make_classifier(ds, opts)
	// 	cl = Classifier{}
	// 	result = verify(load_classifier_file('tempfolder4/classifierfile')?, opts)?
	// 	assert result.correct_count == 9982
	// 	assert result.wrong_count == 18

	// 	println('Done with mnist_test.tab using saved classifier')
}

// if get_environment().arch_details[0] != '4 cpus' {

// 	cl = Classifier{}
// 	ds = Dataset{}
// 	result = CrossVerifyResult{}
// 	opts.datafile_path = '../../mnist_train.tab'
// 	opts.testfile_path = ''
// 	opts.outputfile_path = 'tempfolder4/classifierfile'
// 	opts.number_of_attributes = [313]
// 	opts.bins = [2, 2]
// 	opts.concurrency_flag = true
// 	opts.weighting_flag = false
// 	ds = load_file(opts.datafile_path)
// 	cl = make_classifier(ds, opts)
// 	opts.testfile_path = 'datasets/mnist_test.tab'
// 	result = verify(load_classifier_file('tempfolder4/classifierfile') ?, opts)
// 	assert result.correct_count == 9566
// 	assert result.wrong_count == 434

// 	opts.weighting_flag = true
// 	cl = make_classifier(ds, opts)
// 	result = verify(cl, opts)
// 	assert result.correct_count == 9279
// 	assert result.wrong_count == 721
// }

// fn test_multiple_classifiers() {
// 	// for a two-class (binary classification)
// 	mut opts := Options{
// 		bins: [1,3]
// 		exclude_flag: false
// 		verbose_flag: false
// 		command: 'classify'
// 		number_of_attributes: [3]
// 		show_flag: false
// 		weighting_flag: false
// 		multiple_flag: true
// 	}
// 	mut ds := load_file('datasets/2_class_developer.tab')
// 	println(ds)
// 	mut cl1 := make_classifier(ds, opts)
// 	println(cl1)
// 	for i, instance in cl1.instances {
// 		println('$i $instance')
// 		println(classify_instance(i, cl1, instance, opts).inferred_class)
// 		println('actual class: ${cl1.class_values[i]}')
// 	}

// 	assert classify_instance(0, cl1, cl1.instances[0], opts).inferred_class == 'm'
// 	assert classify_instance(0, cl1, cl1.instances[0], opts).nearest_neighbors_by_class == [
// 		1,
// 		0
// 	]
// 	opts.weighting_flag = true
// 	opts.bins = [1,7]
// 	opts.number_of_attributes = [1]
// 	mut cl2 := make_classifier(ds, opts)
// 	assert classify_instance(0, cl2, cl2.instances[3], opts).inferred_class == 'f'
// 	assert classify_instance(0, cl2, cl2.instances[3], opts).nearest_neighbors_by_class == [
// 		0,
// 9
// 	]
// }
