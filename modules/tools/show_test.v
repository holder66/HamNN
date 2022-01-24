// show_test.v
module tools

import os
// test_setup 

fn test_setup() {
	os.execute_or_panic('v -gc boehm hamnn.v')
}

// test_show_classifier
fn test_show_classifier() {
	mut s := './hamnn make -s -a 2 -b 3,6 datasets/iris.tab'
	println(s)
	println(os.execute_or_panic(s))
}

// test_show_verify
fn test_show_verify() {
	mut s := './hamnn verify -c -s -t datasets/bcw174test datasets/bcw350train'
	println(s)
	println(os.execute_or_panic(s))
	s = './hamnn verify -c -e -t datasets/bcw174test datasets/bcw350train'
	println(s)
	println(os.execute_or_panic(s))
	s = './hamnn verify -c -s -t datasets/soybean-large-test.tab datasets/soybean-large-train.tab'
	println(s)
	println(os.execute_or_panic(s))
	s = './hamnn verify -c -e -t datasets/soybean-large-test.tab datasets/soybean-large-train.tab'
	println(s)
	println(os.execute_or_panic(s))
}

// test_show_cross
fn test_show_cross() {
	mut s := './hamnn cross -c -s -a 2 -b 3,3 datasets/iris.tab'
	println(s)
	println(os.execute_or_panic(s))
	s = './hamnn cross -c -e -a 2 -b 3,3 datasets/iris.tab'
	println(s)
	println(os.execute_or_panic(s))
	s = './hamnn cross -c -s datasets/breast-cancer-wisconsin-disc.tab'
	println(s)
	println(os.execute_or_panic(s))
	s = './hamnn cross -c -e datasets/breast-cancer-wisconsin-disc.tab'
	println(s)
	println(os.execute_or_panic(s))
}

// test_show_explore
fn test_show_explore() {
	mut s := './hamnn explore -c -s  -b 3,6 datasets/iris.tab'
	println(s)
	println(os.execute_or_panic(s))
	s = './hamnn explore -c -e  -b 3,6 datasets/iris.tab'
	println(s)
	println(os.execute_or_panic(s))
	s = './hamnn explore -c -s datasets/breast-cancer-wisconsin-disc.tab'
	println(s)
	println(os.execute_or_panic(s))
	s = './hamnn explore -c -e datasets/breast-cancer-wisconsin-disc.tab'
	println(s)
	println(os.execute_or_panic(s))
}
