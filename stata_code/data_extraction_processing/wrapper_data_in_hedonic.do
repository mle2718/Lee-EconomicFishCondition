/* this is a wrapper to get some exploratory data for hedonics
I've put in in the aceprice folder, but  there is not good reason for it to be here.*/
version 15.1
#delimit cr


global yearstart 1994
global yearend 2019


global specieslist 011, 012, 147, 148, 509 


/* globals for where to store the raw data */
/* prices */
global dealer_prices ${data_raw}/raw_dealer_prices_${vintage_string}.dta 
global length_data ${data_raw}/raw_dealer_length_${vintage_string}.dta 
global nespp4 ${data_raw}/dealer_nespp4_codes${vintage_string}.dta 
global itis ${data_raw}/species_itis_ne${vintage_string}.dta 


/*don't extract observations with prices higher thatn 40 per pound */
global upper_price   40



/********************************************/
/*extract 
A01: landings at nespp4-permit-vtrserno
A02: lengths at the nespp4 level
Takes a long while
Requires VPN*/

do "${extraction_code}/extractA01_dealer_prices_hedonic.do"


do "${extraction_code}/extractA02_dealer_length.do"


do "${extraction_code}/extractA03_dealer_code_names.do"
