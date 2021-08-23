## Finding useful data in the noise
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
v -gc boehm run hamnn.v explore -c -e -g -w -b 2,12 -a 1,10 datasets/prostata.tab
```
Note the flags: -c calls for parallel processing, using all available CPU cores
on you machine; -e for expanded output to the console; -g results in graphical
plots of the results as ROC curves.
```
A correct classification to "normal" is a True Positive (TP);
A correct classification to "tumor" is a True Negative (TN).
Attributes    Bins     TP    FP    TN    FN Sensitivity Specificity   PPV   NPV  Balanced Accuracy
         1  2 - 2      49     1    37    15       0.766       0.974 0.980 0.712              0.870
         1  2 - 3      48     2    37    15       0.762       0.949 0.960 0.712              0.855
         1  2 - 4      46     4    30    22       0.676       0.882 0.920 0.577              0.779
         1  2 - 5      43     7    43     9       0.827       0.860 0.860 0.827              0.843
         1  2 - 6      35    15    40    12       0.745       0.727 0.700 0.769              0.736
         1  2 - 7      41     9    49     3       0.932       0.845 0.820 0.942              0.888
         1  2 - 8      39    11    49     3       0.929       0.817 0.780 0.942              0.873
         1  2 - 9      40    10    50     2       0.952       0.833 0.800 0.962              0.893
         1  2 - 10     39    11    50     2       0.951       0.820 0.780 0.962              0.885
         1  2 - 11     38    12    50     2       0.950       0.806 0.760 0.962              0.878
         1  2 - 12     38    12    50     2       0.950       0.806 0.760 0.962              0.878
         2  2 - 2      44     6    38    14       0.759       0.864 0.880 0.731              0.811
         2  2 - 3      46     4    38    14       0.767       0.905 0.920 0.731              0.836
         2  2 - 4      46     4    41    11       0.807       0.911 0.920 0.788              0.859
         2  2 - 5      46     4    37    15       0.754       0.902 0.920 0.712              0.828
         2  2 - 6      44     6    42    10       0.815       0.875 0.880 0.808              0.845
         2  2 - 7      46     4    45     7       0.868       0.918 0.920 0.865              0.893
         2  2 - 8      45     5    45     7       0.865       0.900 0.900 0.865              0.883
         2  2 - 9      45     5    49     3       0.938       0.907 0.900 0.942              0.922
         2  2 - 10     45     5    49     3       0.938       0.907 0.900 0.942              0.922
         2  2 - 11     45     5    49     3       0.938       0.907 0.900 0.942              0.922
         2  2 - 12     45     5    49     3       0.938       0.907 0.900 0.942              0.922
         3  2 - 2      47     3    39    13       0.783       0.929 0.940 0.750              0.856
         3  2 - 3      47     3    37    15       0.758       0.925 0.940 0.712              0.842
         3  2 - 4      47     3    41    11       0.810       0.932 0.940 0.788              0.871
         3  2 - 5      47     3    46     6       0.887       0.939 0.940 0.885              0.913
         3  2 - 6      49     1    45     7       0.875       0.978 0.980 0.865              0.927
         3  2 - 7      48     2    47     5       0.906       0.959 0.960 0.904              0.932
         3  2 - 8      47     3    49     3       0.940       0.942 0.940 0.942              0.941
         3  2 - 9      47     3    49     3       0.940       0.942 0.940 0.942              0.941
         3  2 - 10     47     3    49     3       0.940       0.942 0.940 0.942              0.941
         3  2 - 11     47     3    49     3       0.940       0.942 0.940 0.942              0.941
         3  2 - 12     47     3    48     4       0.922       0.941 0.940 0.923              0.931
         4  2 - 2      47     3    40    12       0.797       0.930 0.940 0.769              0.863
         4  2 - 3      39    11    40    12       0.765       0.784 0.780 0.769              0.775
         4  2 - 4      48     2    42    10       0.828       0.955 0.960 0.808              0.891
         4  2 - 5      45     5    42    10       0.818       0.894 0.900 0.808              0.856
         4  2 - 6      48     2    45     7       0.873       0.957 0.960 0.865              0.915
         4  2 - 7      47     3    47     5       0.904       0.940 0.940 0.904              0.922
         4  2 - 8      47     3    47     5       0.904       0.940 0.940 0.904              0.922
         4  2 - 9      47     3    48     4       0.922       0.941 0.940 0.923              0.931
         4  2 - 10     47     3    48     4       0.922       0.941 0.940 0.923              0.931
         4  2 - 11     48     2    48     4       0.923       0.960 0.960 0.923              0.942
         4  2 - 12     48     2    48     4       0.923       0.960 0.960 0.923              0.942
         5  2 - 2      47     3    43     9       0.839       0.935 0.940 0.827              0.887
         5  2 - 3      40    10    41    11       0.784       0.804 0.800 0.788              0.794
         5  2 - 4      44     6    42    10       0.815       0.875 0.880 0.808              0.845
         5  2 - 5      45     5    41    11       0.804       0.891 0.900 0.788              0.847
         5  2 - 6      47     3    45     7       0.870       0.938 0.940 0.865              0.904
         5  2 - 7      48     2    47     5       0.906       0.959 0.960 0.904              0.932
         5  2 - 8      48     2    47     5       0.906       0.959 0.960 0.904              0.932
         5  2 - 9      47     3    46     6       0.887       0.939 0.940 0.885              0.913
         5  2 - 10     47     3    46     6       0.887       0.939 0.940 0.885              0.913
         5  2 - 11     46     4    47     5       0.902       0.922 0.920 0.904              0.912
         5  2 - 12     45     5    47     5       0.900       0.904 0.900 0.904              0.902
         6  2 - 2      48     2    44     8       0.857       0.957 0.960 0.846              0.907
         6  2 - 3      41     9    43     9       0.820       0.827 0.820 0.827              0.823
         6  2 - 4      47     3    44     8       0.855       0.936 0.940 0.846              0.895
         6  2 - 5      47     3    39    13       0.783       0.929 0.940 0.750              0.856
         6  2 - 6      47     3    43     9       0.839       0.935 0.940 0.827              0.887
         6  2 - 7      44     6    47     5       0.898       0.887 0.880 0.904              0.892
         6  2 - 8      44     6    47     5       0.898       0.887 0.880 0.904              0.892
         6  2 - 9      46     4    46     6       0.885       0.920 0.920 0.885              0.902
         6  2 - 10     46     4    46     6       0.885       0.920 0.920 0.885              0.902
         6  2 - 11     45     5    47     5       0.900       0.904 0.900 0.904              0.902
         6  2 - 12     42     8    47     5       0.894       0.855 0.840 0.904              0.874
         7  2 - 2      48     2    43     9       0.842       0.956 0.960 0.827              0.899
         7  2 - 3      42     8    43     9       0.824       0.843 0.840 0.827              0.833
         7  2 - 4      45     5    44     8       0.849       0.898 0.900 0.846              0.874
         7  2 - 5      45     5    41    11       0.804       0.891 0.900 0.788              0.847
         7  2 - 6      48     2    43     9       0.842       0.956 0.960 0.827              0.899
         7  2 - 7      46     4    47     5       0.902       0.922 0.920 0.904              0.912
         7  2 - 8      46     4    47     5       0.902       0.922 0.920 0.904              0.912
         7  2 - 9      46     4    46     6       0.885       0.920 0.920 0.885              0.902
         7  2 - 10     46     4    46     6       0.885       0.920 0.920 0.885              0.902
         7  2 - 11     45     5    47     5       0.900       0.904 0.900 0.904              0.902
         7  2 - 12     45     5    47     5       0.900       0.904 0.900 0.904              0.902
         8  2 - 2      45     5    40    12       0.789       0.889 0.900 0.769              0.839
         8  2 - 3      42     8    44     8       0.840       0.846 0.840 0.846              0.843
         8  2 - 4      46     4    45     7       0.868       0.918 0.920 0.865              0.893
         8  2 - 5      46     4    43     9       0.836       0.915 0.920 0.827              0.876
         8  2 - 6      48     2    44     8       0.857       0.957 0.960 0.846              0.907
         8  2 - 7      46     4    48     4       0.920       0.923 0.920 0.923              0.922
         8  2 - 8      47     3    48     4       0.922       0.941 0.940 0.923              0.931
         8  2 - 9      47     3    45     7       0.870       0.938 0.940 0.865              0.904
         8  2 - 10     47     3    45     7       0.870       0.938 0.940 0.865              0.904
         8  2 - 11     46     4    46     6       0.885       0.920 0.920 0.885              0.902
         8  2 - 12     46     4    46     6       0.885       0.920 0.920 0.885              0.902
         9  2 - 2      45     5    41    11       0.804       0.891 0.900 0.788              0.847
         9  2 - 3      43     7    44     8       0.843       0.863 0.860 0.846              0.853
         9  2 - 4      45     5    44     8       0.849       0.898 0.900 0.846              0.874
         9  2 - 5      43     7    42    10       0.811       0.857 0.860 0.808              0.834
         9  2 - 6      49     1    46     6       0.891       0.979 0.980 0.885              0.935
         9  2 - 7      46     4    47     5       0.902       0.922 0.920 0.904              0.912
         9  2 - 8      46     4    47     5       0.902       0.922 0.920 0.904              0.912
         9  2 - 9      47     3    46     6       0.887       0.939 0.940 0.885              0.913
         9  2 - 10     47     3    46     6       0.887       0.939 0.940 0.885              0.913
         9  2 - 11     47     3    46     6       0.887       0.939 0.940 0.885              0.913
         9  2 - 12     48     2    46     6       0.889       0.958 0.960 0.885              0.924
        10  2 - 2      46     4    40    12       0.793       0.909 0.920 0.769              0.851
        10  2 - 3      42     8    45     7       0.857       0.849 0.840 0.865              0.853
        10  2 - 4      45     5    44     8       0.849       0.898 0.900 0.846              0.874
        10  2 - 5      44     6    42    10       0.815       0.875 0.880 0.808              0.845
        10  2 - 6      46     4    46     6       0.885       0.920 0.920 0.885              0.902
        10  2 - 7      48     2    46     6       0.889       0.958 0.960 0.885              0.924
        10  2 - 8      47     3    44     8       0.855       0.936 0.940 0.846              0.895
        10  2 - 9      46     4    45     7       0.868       0.918 0.920 0.865              0.893
        10  2 - 10     46     4    45     7       0.868       0.918 0.920 0.865              0.893
        10  2 - 11     46     4    46     6       0.885       0.920 0.920 0.885              0.902
        10  2 - 12     48     2    48     4       0.923       0.960 0.960 0.923              0.942


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