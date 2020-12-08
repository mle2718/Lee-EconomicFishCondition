# EconomicFishCondition
Code to extract and wrestle data; perform some analysis of prices in support of the Fish Condition project.

# Project Logistics and getting started
Go here  https://github.com/minyanglee/EconomicFishCondition/blob/master/documentation/project_logistics.md

# Required stata commands

1. renvarlab
1. labmask
1. insheetjson
1. libjson
1. egenmore
1. outreg2
1. sepscatter
1. estout
1. ivreghdfe - which requires ivreg2, reghdfe (version 5.x),  ftools, and moremata.  See https://github.com/sergiocorreia/ivreghdfe

Therefore, your life will be easier if you do this
```
ssc install renvarlab
ssc install labmask
ssc install insheetjson
ssc install libjson
ssc install egenmore
ssc install outreg2
ssc install sepscatter
ssc install estout
```
before running any code.

Installing ivreghdfe is a bit more involved
```
* Install ftools (remove program if it existed previously)
cap ado uninstall ftools
net install ftools, from("https://raw.githubusercontent.com/sergiocorreia/ftools/master/src/")

* Install reghdfe
cap ado uninstall reghdfe
net install reghdfe, from("https://raw.githubusercontent.com/sergiocorreia/reghdfe/master/src/")

* Install boottest (Stata 11 and 12)
if (c(version)<13) cap ado uninstall boottest
if (c(version)<13) ssc install boottest

* Install moremata (sometimes used by ftools but not needed for reghdfe)
cap ssc install moremata

* Install ivreg2, the core package
cap ado uninstall ivreg2
ssc install ivreg2

* Finally, install this package
cap ado uninstall ivreghdfe
net install ivreghdfe, from(https://raw.githubusercontent.com/sergiocorreia/ivreghdfe/master/src/)
```

See https://github.com/sergiocorreia/ivreghdfe


# External data

We get external data from from https://fred.stlouisfed.org/.  You'll need an API key. 

# Pre-processed data

You can get the outputs of wrapper1_data_extraction.do and wrapper2_data_processing_common.do from /home2/mlee/EconomicFishCondition/data_folder/external and /home2/mlee/EconomicFishCondition/data_folder/main.  These will be updated sporadically.  


# Running code

Go here  https://github.com/minyanglee/EconomicFishCondition/blob/master/documentation/running_code.md



