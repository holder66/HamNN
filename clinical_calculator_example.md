## Example: typical use case, a clinical risk calculator

Health care professionals frequently make use of calculators to inform clinical decision-making. Data regarding symptoms, findings on physical examination, laboratory and imaging results, and outcome information such as diagnosis, risk for developing a condition, or response to specific treatments, is collected for a sample of patients, and then used to form the basis of a formula that can be used to predict the outcome information of interest for a new patient, based on how their symptoms and findings, etc. compare to those in the dataset.

Here we use the HamNN classifier to generate a clinical risk calculator, using the [Wisconsin Breast Cancer dataset](https://archive.ics.uci.edu/ml/datasets/Breast+Cancer+Wisconsin+%28Original%29). This data consists of the pathological findings on biopsies of breast lumps from 699 women; subsequent surgery in these patients determined whether the lump was benign or cancerous. Each case includes values for nine attributes (rating various aspects of the cell nucleus when examined under a microscope, on a scale from 1 to 10).

First, display information about the dataset:

```v
v run hamnn.v analyze datasets/breast-cancer-wisconsin-disc.tab
```
```
Analysis of Dataset "datasets/breast-cancer-wisconsin-disc.tab" (File Type orange_older)
All Attributes
Index  Name                          Count  Uniques  Missing    Type
_____  __________________________  _______  _______  _______    ____
    0  Sample ID                       699      645        0    i
    1  Clump Thickness                 699       10        0    D
    2  Uniformity of Cell Size         699       10        0    D
    3  Uniformity of Cell Shape        699       10        0    D
    4  Marginal Adhesion               699       10        0    D
    5  Single Epithelial Cell Size     699       10        0    D
    6  Bare Nuclei                     699       11       16    D
    7  Bland Chromatin                 699       10        0    D
    8  Normal Nucleoli                 699       10        0    D
    9  Mitoses                         699        9        0    D
   10  Class                           699        2        0    c

Counts of Attributes by Type
Type        Count
____        _____
i               1
D               9
c               1
Total:         11

Discrete Attributes for Training
 Index  Name                           Uniques
 _____  __________________________     _______
     1  Clump Thickness                     10
     2  Uniformity of Cell Size             10
     3  Uniformity of Cell Shape            10
     4  Marginal Adhesion                   10
     5  Single Epithelial Cell Size         10
     6  Bare Nuclei                         11
     7  Bland Chromatin                     10
     8  Normal Nucleoli                     10
     9  Mitoses                              9

Continuous Attributes for Training
 Index  Name                   Min         Max
 _____  __________________  ______      ______

The Class Attribute: "Class"
Class Value           Cases
____________________  _____
benign                  458
malignant               241
```

Rank order the attributes according to their contribution to separating the classes (flag -s: display the output on the console): 

```v
v run hamnn.v rank  -s datasets/breast-cancer-wisconsin-disc.tab 
```
```
Attributes Sorted by Rank Value, including missing values
For datafile: datasets/breast-cancer-wisconsin-disc.tab, binning range [2, 16]
 Index  Name                         Type   Rank Value   Bins
 _____  ___________________________  ____   __________   ____
     2  Uniformity of Cell Size      D           86.07      0
     3  Uniformity of Cell Shape     D           84.26      0
     6  Bare Nuclei                  D           81.35      0
     5  Single Epithelial Cell Size  D           79.34      0
     7  Bland Chromatin              D           76.96      0
     8  Normal Nucleoli              D           74.82      0
     4  Marginal Adhesion            D           68.60      0
     1  Clump Thickness              D           63.99      0
```

We can run a set of exploratory cross-validations using leave-one-out
folding, and with the -w flag to weight the results using class prevalences.

```v
v run hamnn.v explore -w -x datasets/breast-cancer-wisconsin-disc.tab
```
```
Explore "datasets/breast-cancer-wisconsin-disc.tab"
Exclude: true; Weighting: true
Attributes  Bins  Matches  Nonmatches  Percent
__________  ____  _______  __________  _______
         1     1      646          53    92.42
         2     1      659          40    94.28
         3     1      665          34    95.14
         4     1      666          33    95.28
         5     1      666          33    95.28
         6     1      662          37    94.71
         7     1      666          33    95.28
         8     1      669          30    95.71
         9     1      672          27    96.14
```

While using all 9 attributes gives the best classification result (96.14% correct) using only 4 attributes gives a quite good result of 95.28%.

Let us train our classifier using 4 attributes:

```v
v run hamnn.v make -a 4 -w -s datasets/breast-cancer-wisconsin-disc.tab 
```
```
Classifier for "datasets/breast-cancer-wisconsin-disc.tab"
created: 2021-05-30 02:24:26 UTC, with hamnn version: 0.1.0
options: missing values included when calculating rank values
included attributes: 4
Name                        Type  Uniques        Min        Max  Bins
__________________________  ____  _______  _________  _________  ____
Uniformity of Cell Size     D          10
Uniformity of Cell Shape    D          10
Bare Nuclei                 D          11
Single Epithelial Cell Size D          10
```

We can use this trained classifier as a clinical calculator, to classify a new sample of breast tissue (with values of 8, 9, 7, and 8 for the four attributes identified above) as either malignant or benign:

```v
v run hamnn.v query -a 4 -w datasets/breast-cancer-wisconsin-disc.tab
```
```
Possible values for "Uniformity of Cell Size": ['1', '4', '8', '10', '2', '3', '7', '5', '6', '9']
Please enter one of these values for attribute "Uniformity of Cell Size": 8
Possible values for "Uniformity of Cell Shape": ['1', '4', '8', '10', '2', '3', '5', '6', '7', '9']
Please enter one of these values for attribute "Uniformity of Cell Shape": 9
Possible values for "Bare Nuclei": ['1', '10', '2', '4', '3', '9', '7', '?', '5', '8', '6']
Please enter one of these values for attribute "Bare Nuclei": 7
Possible values for "Single Epithelial Cell Size": ['2', '7', '3', '1', '6', '4', '5', '8', '10', '9']
Please enter one of these values for attribute "Single Epithelial Cell Size": 8
Your responses were:
Uniformity of Cell Size 8
Uniformity of Cell Shape 9
Bare Nuclei        7
Single Epithelial Cell Size 8
Do you want to proceed? (y/n) y
For the classes ['benign', 'malignant'] the prevalence-weighted nearest neighbor counts are [0, 1832], so the inferred class is 'malignant'
```

The classifier imputes the class of the new sample as malignant. This is based on finding 1832 "malignant" nearest neighbours, vs no "benign" nearest neighbours (weighted values; without weighting by class prevalence, the nearest
neighbour counts would be 4 for malignant and 0 for benign).

In the real world, important information may not be available. Suppose we have a breast tissue sample where we only have information on the uniformity of cell shape which has a value of 2, and single epithelial cell size with a value of 3:

```v
v run hamnn.v query -a 4 -w datasets/breast-cancer-wisconsin-disc.tab
```
```
Possible values for "Uniformity of Cell Size": ['1', '4', '8', '10', '2', '3', '7', '5', '6', '9']
Please enter one of these values for attribute "Uniformity of Cell Size":  
Possible values for "Uniformity of Cell Shape": ['1', '4', '8', '10', '2', '3', '5', '6', '7', '9']
Please enter one of these values for attribute "Uniformity of Cell Shape": 2
Possible values for "Bare Nuclei": ['1', '10', '2', '4', '3', '9', '7', '?', '5', '8', '6']
Please enter one of these values for attribute "Bare Nuclei": 
Possible values for "Single Epithelial Cell Size": ['2', '7', '3', '1', '6', '4', '5', '8', '10', '9']
Please enter one of these values for attribute "Single Epithelial Cell Size": 3
Your responses were:
Uniformity of Cell Size 
Uniformity of Cell Shape 2
Bare Nuclei        
Single Epithelial Cell Size 3
Do you want to proceed? (y/n) y
For the classes ['benign', 'malignant'] the prevalence-weighted nearest neighbor counts are [241, 0], so the inferred class is 'benign'
```

This sample is classified as benign, with weighted nearest neighbours 241 for and none against this inferred classification.
