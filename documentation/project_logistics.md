# Overview
In general, I'm trying to keep code, raw data, processed data, results, and images separate.  I have soft coded these directories; and only two files needs to be changed (the ones in project_logistics) to change the project directories and subdirectories.

Smaller bits of analysis that are related (or depend on previous) are collected together in a wrapper.

# Cloning from Github and other setup
Min-Yang is using Rstudio to write Rmd and it's git version controling to commit/push/pull from github. It works reasonably well.  You will also need git installed.

The easist thing to do is to clone this repository to a place on your computer. [Here's a starting guide](https://cfss.uchicago.edu/setup/git-with-rstudio/).  Don't put spaces in the name.  This will set up many, but not all of the folders.

His windows computer has put the aceprice project into:
```
C:\Users\Min-Yang.Lee\Documents\EconomicFishCondition
```
and his Linux computer has the aceprice project in:
```
/home/mlee/Documents/projects/EconomicFishCondition
```

## Set up the rest of the folders (Run this once)

1. Open up stata and the stata do file called "/stata_code/project_logistics/run_this_once_folder_setup.do"
2. In the "if loop" change the line

```
global myprojdir U:/this_project_directory
```
to your project directory. Min-Yang's says

```
global my_projdir "C:/Users/Min-Yang.Lee/Documents/EconomicFishCondition";
global my_projdir "/home/mlee/Documents/projects/EconomicFishCondition";
```

Make the same change to "/stata_code/project_logistics/folder_setup_globals.do"

3. In stata's console type
```
global user <your_name_here>
```
4. Run this file run_this_once_folder_setup.do

It will set up directories for you. The directories I use are
```
/stata_code/
/results/
/images/
/data_folder/
```
There are subdirectories in each. Put master data into **data_folder/master**.  Put the deflatorsQ.dta and deflatorsY.dta files into **data_folder/external** (or you can build your own from the stata_code/external_data/external_data_FRED.do file).


# Running code
Here are two ways to be ready to run the project.

## Automatic
1.  Modify or create your profile.do file that stata automatically runs on startup.  I've put mine in c:/ado/profile.do.  
add the following 2 lines

```
global user <your_name_here>
global fishcondition full\path\to\folder_setup_globals.do 
```
2. Restart stata
3. type do "$fishcondition"

Everything is set up and ready to go.

## By hand
Every time you want to work on the project in stata do this:
```
global user <your_user_name>
do "/stata_code/project_logistics/folder_setup_globals.do"
```
you will have to type in the full path for the second line.




## user written code stata code
As far as I can tell, we need these user written stata commands

1. renvarlab
1. egenmore
1. lambask
1. insheetjson
1. libjson
1. outreg2

You will also need an API key from https://fred.stlouisfed.org/ to get macroeconomic data.

# Description of the folders

## stata_code
This contains stata code organized in various folder. You shouldn't put any code into this directory.

### project_logistics
A pair of small do files to set up folders and then make stata aware of folders.  Plus a sample file to get your odbc connection set up.

### data_extraction_processing
Code to extract and process data from various places

### analysis
The code in here will do exploratory analysis and estimate models.

### fishcondition ado
There are a few small .ado files that might be re-used alot. 

## data_folder
This is where I store data.  The "final" data should be stored in /main/

## images
This is where I store figures and other images.  It probably make a second level here where I have subfolders for stocks.

## results
This is where I store log files and estimation results.



## tables
This is where I store .tex fragments containing tables.
