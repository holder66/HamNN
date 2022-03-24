[![HamNN Continuous Integration](https://github.com/holder66/hamnn/actions/workflows/HamNN%20Continuous%20Integration.yml/badge.svg)](https://github.com/holder66/hamnn/actions/workflows/HamNN%20Continuous%20Integration.yml)
![GitHub](https://img.shields.io/github/license/holder66/HamNN)
# HamNN

A machine learning (ML) library for classification using a nearest neighbor algorithm based on Hamming distances. [hamnn documentation](https://holder66.github.io)

There is an associated Command Line Interface app, [VHamNN](https://github.com/holder66/vhamnn), which facilitates using the hamnn library.

You can use the library with your own datasets, or with a selection of publicly available datasets that are widely used for demonstrating and testing ML classifiers, in the `datasets` directory. These files are either in [ARFF (Attribute-Relation File Format)](https://waikato.github.io/weka-wiki/formats_and_processing/arff_stable/) or in [Orange file format](https://orange3.readthedocs.io/projects/orange-data-mining-library/en/latest/reference/data.io.html).

Do we really need another ML library? [Read this!](https://github.com/holder66/vhamnn/blob/master/AI_for_rest_of_us.md)

And have a look here for a more complete [description and potential use cases](https://github.com/holder66/vhamnn/blob/master/description.md). 

## To use the HamNN library

`v install holder66.hamnn`

And (optionally) libraries used by HamNN for generating plots and for colored output on the console:

`v install vsl`

`v install etienne_napoleone.chalk`

In your V code:

`import holder66.hamnn`

Example source code:
```v
module main

import holder66.hamnn
import os

fn main() {
    opts := hamnn.Options{
        show_flag: true
    }
    datafile_path := os.home_dir() + '/.vmodules/holder66/hamnn/datasets/iris.tab'
    println(datafile_path)

    ds := hamnn.load_file(datafile_path)
    result := hamnn.analyze_dataset(ds, opts)
    println(result)
}
```

## Installation of the command line interface app VHamNN:
First, install V, if not already installed. On MacOS, Linux etc. you need `git` and a C compiler (For windows or android environments, see the [v lang documentation](https://github.com/vlang/v/blob/master/doc/docs.md#windows)) In a terminal:
```sh
git clone https://github.com/vlang/v
cd v
make
sudo ./v symlink	# add v to your PATH
```
Clone the github repository for holder66/vhamnn, and run the algorithms:
```sh
git clone https://github.com/holder66/vhamnn
cd vhamnn
v .                     # compiles all the files in the folder
./hamnn --help    # displays help information about the various commands
# and options available. More specific help information
# is available for each command.
```

## Tutorial for using VHamNN:
In the vhamnn directory:

`v run . examples go`

## Memory leak problem:

At the present time, if your code using the HamNN library (especially memory-intensive operations such as cross-validate or explore) dies without going to completion, it may be due to memory leaks caused by the V lang compiler. The best way to prevent these memory leaks is to compile with the gc flag, eg:

 ```sh
 v -gc boehm .
 ```
You may need to install the libgc or libgc-dev library, using "brew" or "apt".

## Getting help:
The V lang community meets on [Discord](https://discord.gg/vlang)

For bug reports, feature requests, etc., please raise an issue on github:

[for VHamNN](https://github.com/holder66/vhamnn)

[for HamNN](https://github.com/holder66/hamnn)


## Previous versions
The most recent version (2012) was written in python; one can experiment with it via a [web-based interface](http://hammingnn.olders.ca). I’ve [posted test results](https://henry.olders.ca/wordpress/?p=613) using this classifier with a number of publicly accessible datasets. Here are some [additional test results](https://henry.olders.ca/wordpress/?p=381) with genomics datasets.

The process of development in its early stages is described in [this essay](https://henry.olders.ca/wordpress/?p=731) written in 1989.



Copyright (c) 2017, 2022: Henry Olders.
