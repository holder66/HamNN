## Compile the app
`cd hamnn`
`v -gc boehm .`
## Getting help
`./hamnn --help` or `./hamnn -h` or simply, `./hamnn`
For individual commands, use this pattern:
`./hamnn analyze --help` or `./hamnn analyze -h` or `./hamnn analyze`
## Analyzing a dataset
`./hamnn analyze datasets/anneal.tab`
## Discovering which attributes are most useful
`./hamnn rank --show --graph datasets/anneal.tab` or 
`./hamnn rank -s -g datasets/anneal.tab`
To specify a range for the number of bins for continuous attributes (if unspecified, the default range is 2 through 16 inclusive):
`./hamnn rank --show --bins 3,6 datasets/iris.tab` or 
`./hamnn rank -s -b 3,6 datasets/iris.tab`
To calculate rank values using the same number of bins for all attributes:
`./hamnn rank -s -b 3,3 datasets/iris.tab`
To exclude missing values from the rank value calculations:
`./hamnn rank -- exclude --show --graph datasets/anneal.tab` or 
`./hamnn rank -s -g -e datasets/anneal.tab`
## To explore how varying parameters affect classification accuracy
`./hamnn explore --expand --graph --concurrent --weight datasets/breast-cancer-wisconsin-disc.tab` or
`./hamnn explore -e -g -c -w datasets/breast-cancer-wisconsin-disc.tab`
To specify how the number of attributes should be varied (eg, from 2 through 8 attributes, inclusive, stepping by 2):
`./hamnn explore -e -g -c -w --attributes 2,8,2 datasets/breast-cancer-wisconsin-disc.tab`
For datasets with continuous attributes, specify the binning range (eg, from 3 through 30 bins, stepping by 3):
`./hamnn explore -s -g -c -w --bins 3,30,3 datasets/iris.tab`
To use the same number of bins for each attribute, add the -u or --uniform flag:
`./hamnn explore -s -g -c -w -b 3,30,3 -u datasets/iris.tab`
