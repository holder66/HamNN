# hamnn
A machine learning library, and stand-alone CLI app, for classification using a nearest neighbor algorithm based on Hamming distances.

## Description

### What it is
- technology for pattern classification - making sense of what our senses tell us
- based on the physiology (mimics the functioning) of the central nervous system

### What it can do
- classify static patterns (eg images, microarray data, medical symptoms and test results, demographic data, survey results, etc.)
- classify serial (time-based) patterns (eg speech, movies, real-time sensor data, radar information, etc.) (under development)

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
eliminates the need to correct for variations in size, skew, or rotation
#### noisy data
quickly identifies and removes from consideration variables which add noise

### Where it can be applied
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

## Installation of the stand-alone command line interface app:
First, install V, if not already installed. On MacOS, Linux etc. you need `git` and a C compiler (For windows or android environments, see the [v lang documentation](https://github.com/vlang/v/blob/master/doc/docs.md#windows)) In a terminal:
```sh
git clone https://github.com/vlang/v
cd v
make
sudo ./v symlink	# add v to your PATH
```
Clone this github repository, and run the algorithms:
```sh
git clone https://github.com/holder66/hamnn
cd hamnn
v .                     # compiles all the files in the folder
./hamnn --help    # displays help information about the various commands
# and options available. More specific help information
# is available for each command.
```
## Memory leak problem:

At the present time, the best way to prevent a memory leak (which may eventually
 cause the program to be "killed" by the OS when the available memory is exceeded) is to compile with the gc flag, eg:

 ```sh
 v -gc boehm .
 ```
You may need to install the libgc or libgc-dev library, using "brew" or "apt".

## Examples showing use of the Command Line Interface
Please see [examples_of_command_line_usage.md](https://github.com/holder66/hamnn/blob/main/examples_of_command_line_usage.md)

## Example: typical use case, a clinical risk calculator

Health care professionals frequently make use of calculators to inform clinical decision-making. Data regarding symptoms, findings on physical examination, laboratory and imaging results, and outcome information such as diagnosis, risk for developing a condition, or response to specific treatments, is collected for a sample of patients, and then used to form the basis of a formula that can be used to predict the outcome information of interest for a new patient, based on how their symptoms and findings, etc. compare to those in the dataset.

Please see [clinical_calculator_example.md](https://github.com/holder66/hamnn/blob/main/clinical_calculator_example.md).

## Example: finding useful information embedded in noise

Please see a worked example here: [noisy_data.md](https://github.com/holder66/hamnn/blob/main/noisy_data.md)


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
