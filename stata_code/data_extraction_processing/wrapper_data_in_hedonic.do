/* this is a wrapper to get some exploratory data for hedonics
I've put in in the aceprice folder, but  there is not good reason for it to be here.*/
version 15.1
#delimit cr


global yearstart 1994
global yearend 2019


global specieslist 011, 012, 147, 148, 509,119,120, 121,122,123,124

global specieslist 509

/* herring, alewife, menhaden */ 
global herrings 001, 166, 167, 168, 221
/*salmon */

global salmons 305, 306, 307, 308, 309
/*invertebrates */

/* globals for where to store the raw data */
/* prices */
global dealer_prices ${data_raw}/raw_dealer_prices_${vintage_string}.dta 
global length_data ${data_raw}/raw_dealer_length_${vintage_string}.dta 
global nespp4 ${data_raw}/dealer_nespp4_codes${vintage_string}.dta 
global itis ${data_raw}/species_itis_ne${vintage_string}.dta 
global svdbs ${data_raw}/svdbs_itis_lookup${vintage_string}.dta 
global state_codes ${data_raw}/state_codes${vintage_string}.dta 
global aggregate_fishing ${data_raw}/raw_entire_fishery_${vintage_string}.dta 


global recession "$data_external/recessionM_${vintage_string}.dta" 
global deflatorsY "$data_external/deflatorsY_${vintage_string}.dta" 
global deflatorsQ "$data_external/deflatorsQ_${vintage_string}.dta" 
global incomeQ "$data_external/incomeQ_${vintage_string}.dta" 

global whiting_trade ${data_external}/whiting_trade${vintage_string}.dta 
/*don't extract observations with prices higher thatn 40 per pound */
global upper_price 40



/********************************************/
/*extract 
A01: landings at nespp4-permit-vtrserno
A02: lengths at the nespp4 level
Takes a long while
Requires VPN

do "${extraction_code}/extractA01_dealer_prices_hedonic.do"
*/
do "${extraction_code}/extractA01b_aggregate_wild_fish.do"

do "${extraction_code}/extractA02_dealer_length.do"


do "${extraction_code}/extractA03_dealer_code_names.do"

do "${extraction_code}/extractA10_state_codes.do"



do "${extraction_code}/extractC01_fish_conditions.do"

do "${extraction_code}/extractZ01_external_data_FRED.do"


do "${extraction_code}/extractZ02_external_data_NMFS_trade_whiting.do"

do "${extraction_code}/extractZ03_external_data_FRED_recession.do"
