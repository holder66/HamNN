# hamnn

A machine learning (ML) library for classification using a nearest neighbor algorithm based on Hamming distances.

There is an associated Command Line Interface app, `vhamnn`, which facilitates 
using the hamnn library.

You can use the library with your own datasets, or with a selection of publicly available datasets that are widely used for demonstrating and testing ML classifiers, in the `datasets` directory. These datasets are in [Orange file format](https://orange3.readthedocs.io/projects/orange-data-mining-library/en/latest/reference/data.io.html) (see [Orange Data Mining](https://orangedatamining.com)), a useful way to specify information about feature types and relevance. 
The Command Line Interface (CLI) app, `vhamnn` (see below) provides a command `orange` to quickly review Orange file format.
## Description

### What it is
- technology for pattern classification - making sense of what our senses tell us
- based on the physiology (mimics the functioning) of the central nervous system

### What it can do
- classify static patterns (eg images, microarray data, medical symptoms and test results, demographic data, survey results, etc.)
- classify serial (time-based) patterns (eg speech, movies, real-time sensor data, radar information, etc.) (under development)
- works with multiple classes
- handles missing data gracefully
- easily and accurately deals with situations where classes are not [linearly separable](https://en.wikipedia.org/wiki/Linear_separability). This applies to 
many cases in physiology, biology,  and medicine (see [hormesis.](https://en.wikipedia.org/wiki/Hormesis))

### What makes it special
- one-trial learning - learns in a single pass
- robust - accommodates missing information, damage, or noise gracefully
- easy to convert into hardware - in silicon, possibly optical, molecular, or quantum computing
- lends itself to parallel computing
- has an exceptionally tiny footprint in terms of memory and computing resources needed

### What problems can it solve
#### data reduction
identifies and uses only those variables which are most likely to contribute to classification accuracy
#### image preprocessing
eliminates the need to correct for variations in size, skew, or rotation (under development)
#### noisy data
quickly identifies and removes from consideration variables which add noise

### Where it can be applied - potential use cases
- speech recognition
- emotion recognition (from facial expression, body language, speech prosody)
- prediction of weather, earthquakes, traffic patterns
- aircraft collision avoidance
- data mining (eg, for targeted advertising)
- diagnostic aid (medical, equipment maintenance, etc.)
- risk identification and management (loans, risk calculators for heart disease, etc.)
- real-time problem detection (bridges, computer networks, automobiles, railroads, aircraft, etc.)
- robotics
- neural prosthetic devices, to enhance our senses, processing capacity and speed, memory

## To use the hamnn library
`v install holder66.hamnn`

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

## Installation of the command line interface app vhamnn:
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
## Memory leak problem:

At the present time, if your code using the hamnn library (especially memory-intensive operations such as cross-validate or explore) dies without going to completion, it may be due to memory leaks caused by the V lang compiler. The best way to prevent these memory leaks is to compile with the gc flag, eg:

 ```sh
 v -gc boehm .
 ```
You may need to install the libgc or libgc-dev library, using "brew" or "apt".

## Glossary of terms
**instances:** synonyms: cases; records; examples
- instances can be grouped into sets, eg training set, test set, validation set
- corresponds to a table row in a tabular data base

**dataset:** consists of a number of instances (cases, or examples)

**attributes:** synonyms: variables; fields; features
- corresponds to a column in a tabular data base. The attribute name is the column header
- one of the attribute will be the class attribute or class variable (also called the target variable, or class feature)
- attributes can be combined in various ways, to create new attributes

**attribute ranking:** the process of finding those attributes which provide the best classification performance

**classes:** the set of values that the class attribute can take

**parameters:** eg, the k in k-nearest-neighbors
- often, the work involved in applying machine learning to a problem is to find appropriate or optimal values for the parameters used by a given ML methodology

**Hamming distance:** (may also be called "overlap metric") the Hamming distance between two strings of equal length is the number of positions at which the corresponding symbols are different. In other words, it measures the minimum number of substitutions required to change one string into the other, or the minimum number of errors that could have transformed one string into the other. For binary strings a and b the Hamming distance is equal to the number of ones (population count) in a XOR b.

**bins:** the number of bins or slices to be applied for a given continuous attribute

**binning:** the process of converting a continuous attribute into a discrete attribute

**discrete:** (as applied to a attribute or variable): nominal or ordinal data

**continuous:** (as applied to a attribute or variable): real-valued
- ordinal data with a range greater than a certain parameter may also be treated as continous data


## Previous versions
The most recent version (2012) was written in python; one can experiment with it via a [web-based interface](http://hammingnn.olders.ca). I’ve [posted test results](https://henry.olders.ca/wordpress/?p=613) using this classifier with a number of publicly accessible datasets. Here are some [additional test results](https://henry.olders.ca/wordpress/?p=381) with genomics datasets.

The process of development in its early stages is described in [this essay](https://henry.olders.ca/wordpress/?p=731) written in 1989.



Copyright (c) 2017, 2022: Henry Olders.
