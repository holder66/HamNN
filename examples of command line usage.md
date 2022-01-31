## Getting help
`v run hamnn.v --help` or `v run hamnn.v -h` or simply, `v run hamnn.v`
For individual commands, use this pattern:
`v run hamnn.v analyze --help` or `v run hamnn.v analyze -h` or `v run hamnn.v analyze`
## Analyzing a dataset
`v run hamnn.v analyze datasets/anneal.tab`
## Discovering which attributes are most useful
`v run hamnn.v rank --show --graph datasets/anneal.tab` or 
`v run hamnn.v rank -s -g datasets/anneal.tab`
To specify a range for the number of bins for continuous attributes (if unspecified, the default range is 2 through 16 inclusive):
`v run hamnn.v rank --show --bins 3,6 datasets/iris.tab` or 
`v run hamnn.v rank -s -b 3,6 datasets/iris.tab`
To calculate rank values using the same number of bins for all attributes:
`v run hamnn.v rank -s -b 3,3 datasets/iris.tab`
To exclude missing values from the rank value calculations:
`v run hamnn.v rank -- exclude --show --graph datasets/anneal.tab` or 
`v run hamnn.v rank -s -g -e datasets/anneal.tab`
## To explore how varying parameters affect classification accuracy
`v -gc boehm run hamnn.v explore --expand --graph --concurrent --weight datasets/breast-cancer-wisconsin-disc.tab` or
`v -gc boehm run hamnn.v explore -e -g -c -w datasets/breast-cancer-wisconsin-disc.tab`
To specify how the number of attributes should be varied (eg, from 2 through 8 attributes, inclusive, stepping by 2):
`v -gc boehm run hamnn.v explore -e -g -c -w --attributes 2,8,2 datasets/breast-cancer-wisconsin-disc.tab`
For datasets with continuous attributes, specify the binning range (eg, from 3 through 30 bins, stepping by 3):
`v -gc boehm run hamnn.v explore -s -g -c -w --bins 3,30,3 datasets/iris.tab`
To use the same number of bins for each attribute, add the -u or --uniform flag:
`v -gc boehm run hamnn.v explore -s -g -c -w -b 3,30,3 -u datasets/iris.tab`
