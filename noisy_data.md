## Finding useful data in the noise (Work in Progress)
Much real-world data consists of mostly noise, and only a small amount of information. The hammnn algorithm can be helpful in extracting the useful information.

An example is genomics data. The prostata dataset consists of genomic
microarray data from 102 subjects. Fifty of the 102 subjects were normal,
while the other 52 had a prostate tumor. For each case, there 
are 12534 data points, of which one is the class attribute. Can this
mass of data be used to predict whether a person has a tumor or is normal?


```v
v run hamnn.v rank -w -s datasets/prostata.tab 
```   
```
Attributes Sorted by Rank Value, including missing values
For datafile: datasets/prostata.tab, binning range [2, 16]
 Index  Name                         Type   Rank Value   Bins
 _____  ___________________________  ____   __________   ____
 10426  NELL2                        C           80.15      9
  6117  HPN                          C           78.15      7
  9104  PTGDS                        C           74.62      6
  6394  RBP1                         C           74.23     13
 10070  CALM1_4                      C           72.85     13
  8897  HSPD1                        C           72.77     13
  4297  TRGC2                        C           70.85     11 
	...
	...
	...
  2048  MR1_3                        C            8.77     16
  4056  CPA2                         C            8.54     13
  5692  SEDLP                        C            8.08     14
  4163  PIP                          C            2.00      2
  4852  SEMG2                        C            2.00      2
  7529  SEMG1                        C            2.00      2
```

Accumulated experience with the algorithm suggests that using a fixed number
of bins often gives good results. 
```v
v run hamnn.v rank -w -s -b 6 datasets/prostata.tab
```
```
Attributes Sorted by Rank Value, including missing values
For datafile: datasets/prostata.tab, binning range [6]
 Index  Name                         Type   Rank Value   Bins
 _____  ___________________________  ____   __________   ____
  9104  PTGDS                        C           74.62      6
  6117  HPN                          C           74.31      6
  8897  HSPD1                        C           71.08      6
 10426  NELL2                        C           66.15      6
  4297  TRGC2                        C           65.23      6
  8966  LMO3                         C           64.54      6
 12085  GSTM1_2                      C           64.08      6
  6394  RBP1                         C           62.08      6
  5498  HSD11B1                      C           61.08      6
   137  ANXA2                        C           60.85      6
   ...
   ...
   ...
  9490  PDCD4                        C            2.00      6
  2495  CPN1                         C            2.00      6
   579  PMCH                         C            2.00      6
  5692  SEDLP                        C            2.00      6
  5580  PRR4                         C            1.92      6
```

We can verify this by comparing cross-validation results over a range of 
attribute numbers, either with a fixed number of bins, or with bin number
which is optimized over a range.

Here are the results for exploring over a range of attributes from 1 to 10, 
and a binning range from 2 to 12:
```v
v run hamnn.v explore -w -b 2,12 -a 1,10 datasets/prostata.tab
```
```
Explore "datasets/prostata.tab"
Exclude: false; Weighting: true
Attributes  Bins  Matches  Nonmatches  Percent
__________  ____  _______  __________  _______
         1     2       86          16    84.31
         1     3       68          34    66.67
         1     4       75          27    73.53
         1     5       86          16    84.31
         1     6       78          24    76.47
         1     7       91          11    89.22
         1     8       88          14    86.27
         1     9       90          12    88.24
         1    10       86          16    84.31
         1    11       86          16    84.31
         1    12       75          27    73.53
         2     2       82          20    80.39
         2     3       68          34    66.67
         2     4       84          18    82.35
         2     5       91          11    89.22
         2     6       92          10    90.20
         2     7       89          13    87.25
         2     8       93           9    91.18
         2     9       94           8    92.16
         2    10       85          17    83.33
         2    11       78          24    76.47
         2    12       92          10    90.20
         3     2       86          16    84.31
         3     3       76          26    74.51
         3     4       84          18    82.35
         3     5       88          14    86.27
         3     6       96           6    94.12
         3     7       92          10    90.20
         3     8       94           8    92.16
         3     9       92          10    90.20
         3    10       89          13    87.25
         3    11       82          20    80.39
         3    12       82          20    80.39
         4     2       87          15    85.29
         4     3       79          23    77.45
         4     4       90          12    88.24
         4     5       88          14    86.27
         4     6       90          12    88.24
         4     7       89          13    87.25
         4     8       93           9    91.18
         4     9       86          16    84.31
         4    10       85          17    83.33
         4    11       91          11    89.22
         4    12       87          15    85.29
         5     2       90          12    88.24
         5     3       83          19    81.37
         5     4       86          16    84.31
         5     5       91          11    89.22
         5     6       91          11    89.22
         5     7       92          10    90.20
         5     8       89          13    87.25
         5     9       88          14    86.27
         5    10       83          19    81.37
         5    11       92          10    90.20
         5    12       93           9    91.18
         6     2       92          10    90.20
         6     3       88          14    86.27
         6     4       91          11    89.22
         6     5       85          17    83.33
         6     6       93           9    91.18
         6     7       91          11    89.22
         6     8       91          11    89.22
         6     9       91          11    89.22
         6    10       81          21    79.41
         6    11       90          12    88.24
         6    12       94           8    92.16
         7     2       91          11    89.22
         7     3       90          12    88.24
         7     4       90          12    88.24
         7     5       84          18    82.35
         7     6       93           9    91.18
         7     7       89          13    87.25
         7     8       90          12    88.24
         7     9       92          10    90.20
         7    10       84          18    82.35
         7    11       91          11    89.22
         7    12       92          10    90.20
         8     2       85          17    83.33
         8     3       92          10    90.20
         8     4       89          13    87.25
         8     5       82          20    80.39
         8     6       92          10    90.20
         8     7       89          13    87.25
         8     8       92          10    90.20
         8     9       89          13    87.25
         8    10       85          17    83.33
         8    11       89          13    87.25
         8    12       92          10    90.20
         9     2       86          16    84.31
         9     3       89          13    87.25
         9     4       89          13    87.25
         9     5       82          20    80.39
         9     6       91          11    89.22
         9     7       94           8    92.16
         9     8       92          10    90.20
         9     9       88          14    86.27
         9    10       88          14    86.27
         9    11       91          11    89.22
         9    12       93           9    91.18
        10     2       86          16    84.31
        10     3       88          14    86.27
        10     4       88          14    86.27
        10     5       86          16    84.31
        10     6       89          13    87.25
        10     7       95           7    93.14
        10     8       92          10    90.20
        10     9       87          15    85.29
        10    10       87          15    85.29
        10    11       91          11    89.22
        10    12       91          11    89.22
```

Accuracy peaks for only 3 attributes, out of the total 12,533 available.

Doing an explore for just 6 bins:

```v
v run hamnn.v explore -w -b 6 -a 1,10 datasets/prostata.tab
```
```
Explore "datasets/prostata.tab"
Exclude: false; Weighting: true
Attributes  Bins  Matches  Nonmatches  Percent
__________  ____  _______  __________  _______
         1     6       78          24    76.47
         2     6       92          10    90.20
         3     6       96           6    94.12
         4     6       90          12    88.24
         5     6       91          11    89.22
         6     6       93           9    91.18
         7     6       93           9    91.18
         8     6       92          10    90.20
         9     6       91          11    89.22
        10     6       89          13    87.25
```


Does this ensure that using more attributes than 10 might give greater 
accuracy? It seems, from the above, that 6, 7, or 8 bins works best, so 
let's see what happens with more attributes:

```v
v run hamnn.v explore -w -b 6,8 -a 10,100,10 -v datasets/prostata.tab
```
```
```
Explore "datasets/prostata.tab"
Exclude: false; Weighting: true
Attributes  Bins  Matches  Nonmatches  Percent
__________  ____  _______  __________  _______
        10     6       89          13    87.25
        10     7       95           7    93.14
        10     8       92          10    90.20
        20     6       89          13    87.25
        20     7       91          11    89.22
        20     8       89          13    87.25
        30     6       84          18    82.35
        30     7       93           9    91.18
        30     8       86          16    84.31
        40     6       83          19    81.37
        40     7       86          16    84.31
        40     8       86          16    84.31
        50     6       84          18    82.35
        50     7       87          15    85.29
        50     8       85          17    83.33
        60     6       86          16    84.31
        60     7       85          17    83.33
        60     8       86          16    84.31
        70     6       88          14    86.27
        70     7       87          15    85.29
        70     8       87          15    85.29
        80     6       87          15    85.29
        80     7       85          17    83.33
        80     8       88          14    86.27
        90     6       88          14    86.27
        90     7       89          13    87.25
        90     8       87          15    85.29
       100     6       89          13    87.25
       100     7       91          11    89.22
       100     8       86          16    84.31
```

it doesn't appear likely that adding attributes improves accuracy. While
we haven't ruled out the possibility that there might be an isolated case 
of high accuracy for some combination of attribute number and bins, chances
are excellent that such an isolated case would be "overfitting" and not
generalizable. So let's stick with 3 attributes and 6 bins as giving a high 
accuracy and a low possibility of overfitting the data.