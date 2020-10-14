/* this is a wrapper to get some exploratory data for hedonics
I've put in in the aceprice folder, but  there is not good reason for it to be here.*/
version 15.1
#delimit cr


do "${analysis_code}/images/plotsA01_dealer_lengths.do"

do "${analysis_code}/images/plotsA02_prices.do"

do "${analysis_code}/images/plotsA02_prices_quantities.do"


/* process and merge fish conditions */
do "${analysis_code}/images/plotsA03_fish_conditions_annual.do"
