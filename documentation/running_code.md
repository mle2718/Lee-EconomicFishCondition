# Running code for the project

The code is split into three parts: 
1.  Data extraction
2.  Data Processing
3.  Analysis





# Data Extraction

Data extraction is done with the set of data extraction do files.  It is probably best to do the data extraction using the file "wrapper1_data_extraction.do". You can adjust the global parameters there to customize your data query.  The do files called in this wrapper just extract data, although there are minor bits of data cleaning that occur. 

One of those bits of datacleaning is re-classifying  species that span multiple nespp3 groups 

I have code written to extract trade data. It is specific to whiting, and the best move is to examine the output of that file  and see how to customize it for your species.  See also: https://github.com/cameronspeir/NOAA-Foreign-Fishery-Trade-Data-API

# Data processing
Most of the data processing is done with the set of data processing do files.  Again, its probably best to do the data processing with  the file "wrapper2_data_processing.do". This constructs things like daily landings, lags of those for use as IVs, and merges data, like deflators, fish condition, and macroeconomic conditions.  


Some data processing will need to be customized. Mostly, I'm thinking of the data processing for bringing in Trade data. This is handled in wrapper3_data_processing_species_specific.do. When you run this, you end up with a dataset that has just the species that you are working on.  


You can get the outputs of wrapper2_data_processing_common.do from /home2/mlee/EconomicFishCondition/data_folder/external and /home2/mlee/EconomicFishCondition/data_folder/main. These will be updated sporadically.  


# Analysis
Analysis code is in the analysis folder.  I have a wrapper to make images -- this might only work if you actually run the data processing code.  I have a do file to explore fish conditions and silver hake.    This is a work in progress. It should probably be reorganized.

# Replicability test 1

1. Copy the data files from /home2/mlee/EconomicFishCondition/data_folder into the appropriate  directories
1. Unzip as necessary.
1. Run the file ./stata_code/analysis/regressions/silver_hake01.do

You should get a handful of misspecified econometric models for silver hake.



# Replicability test 2

1. Run these do files:
    * ./stata_code/data_extraction_processing/wrapper1_data_extraction.do
    * ./stata_code/data_extraction_processing/wrapper2_data_processing_common.do
    * ./stata_code/data_extraction_processing/wrapper2_data_processing_species_specific.do
1. Run the file ./stata_code/analysis/regressions/silver_hake01.do

You should get a handful of misspecified econometric models for silver hake.


