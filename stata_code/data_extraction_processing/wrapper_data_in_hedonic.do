/* this is a wrapper to get some exploratory data for hedonics
I've put in in the aceprice folder, but  there is not good reason for it to be here.*/
version 15.1
#delimit cr

/* args for do "${extraction_code}/extractA01_dealer_prices_hedonic.do"*/
/*don't extract observations with prices higher thatn 40 per pound */
global upper_price 40
global yearstart 1994
global yearend 2019
global specieslist 011, 012, 147, 148, 509,119,120, 121,122,123,124
global dealer_prices ${data_raw}/raw_dealer_prices_${vintage_string}.dta 


/* args for do "${extraction_code}/extractA01b_aggregate_wild_fish.do"*/
/* These are useful to exclude things from the aggregate_wild_fish.do"  extraction */
/* herring, alewife, menhaden */ 
global herrings 001, 166, 167, 168, 221
/*salmon */
global salmons 305, 306, 307, 308, 309
global exclude_me "nespp3 not in (${herrings},${salmons}) and nespp3<=700"
global aggregate_fishing ${data_raw}/raw_entire_fishery_${vintage_string}.dta 


/*args for do "${extraction_code}/extractA02_dealer_length.do"*/
global length_data ${data_raw}/raw_dealer_length_${vintage_string}.dta 

/*args for do "${extraction_code}/extractA03_dealer_code_names.do"*/
global nespp4 ${data_raw}/dealer_nespp4_codes${vintage_string}.dta 
global itis ${data_raw}/species_itis_ne${vintage_string}.dta 
global svdbs ${data_raw}/svdbs_itis_lookup${vintage_string}.dta 




/* args for do "${extraction_code}/extractA10_state_codes.do"*/
global state_codes ${data_raw}/state_codes${vintage_string}.dta 




/* args for do "${extraction_code}/extractC01_fish_conditions.do" */
global in_relcond ${data_external}/RelCond2019_EPU.csv
global in_relcond_leng ${data_external}/RelCond2019_EPU_length.csv
global in_relcond_Year ${data_external}/RelCond2019_Year.csv

global  out_dataYear ${data_raw}/annual_condition_index_${vintage_string}.dta 
global  out_dataEPUYear ${data_raw}/annual_condition_indexEPU_${vintage_string}.dta 
global  out_dataEPUlengthYear ${data_raw}/annual_condition_indexEPU_length_${vintage_string}.dta 






/* args for do "${extraction_code}/extractZ01_external_data_FRED.do"*/
global deflatorsY "$data_external/deflatorsY_${vintage_string}.dta" 
global deflatorsQ "$data_external/deflatorsQ_${vintage_string}.dta" 
global incomeQ "$data_external/incomeQ_${vintage_string}.dta" 


/*args for do "${extraction_code}/extractZ02_external_data_NMFS_trade_whiting.do"*/
global whiting_trade ${data_external}/whiting_trade${vintage_string}.dta 

/*args for do "${extraction_code}/extractZ03_external_data_FRED_recession.do" */
global recession "$data_external/recessionM_${vintage_string}.dta" 



/********************************************/
/*extract data: these take a long time and 
Takes a long while
Requires VPN
*/

do "${extraction_code}/extractA01_dealer_prices_hedonic.do"



do "${extraction_code}/extractA01b_aggregate_wild_fish.do"

do "${extraction_code}/extractA02_dealer_length.do"


do "${extraction_code}/extractA03_dealer_code_names.do"

do "${extraction_code}/extractA10_state_codes.do"






/* External data extraction: These are pretty small and run quickly. */

do "${extraction_code}/extractC01_fish_conditions.do"

do "${extraction_code}/extractZ01_external_data_FRED.do"
do "${extraction_code}/extractZ03_external_data_FRED_recession.do"

/* note, this does a trade data extraction unique to whiting. I'd suggest saving this do file with a new name and modifying it. Then just add it to the list */
do "${extraction_code}/extractZ02_external_data_NMFS_trade_whiting.do"

/*for example:
do "${extraction_code}/extractZ02_external_data_NMFS_trade_haddock.do"
*/

