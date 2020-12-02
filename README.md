# EconomicFishCondition
Code to extract and wrestle data; perform some analysis of prices in support of the Fish Condition project.

# Project Logistics 
Go here  https://github.com/minyanglee/EconomicFishCondition/blob/master/documentation/project_logistics.md

# Required stata commands

1. renvarlab
1. labmask
1. insheetjson
1. libjson
1. egenmore
1. outreg2

Therefore, your life will be easier if you do this
```
ssc install renvarlab
ssc install labmask
ssc install insheetjson
ssc install libjson
ssc install egenmore
ssc install outreg2
```
before running any code.

# External data

We get external data from from https://fred.stlouisfed.org/.  You'll need an API key. 
