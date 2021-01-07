/* this is a wrapper to get some exploratory data for hedonics
I've put in in the aceprice folder, but  there is not good reason for it to be here.*/
version 15.1
#delimit cr

vintage_lookup_and_reset

global silverhake_images ${my_images}/silverhake

/**/
do "${analysis_code}/silverhake/figure_code/plotsA01_dealer_lengths.do"

do "${analysis_code}/silverhake/figure_code/plotsA02_prices.do"

do "${analysis_code}/silverhake/figure_code/plotsA02_prices_quantities.do"


/* graph fish conditions */
do "${analysis_code}/silverhake/figure_code/plotsA03_fish_conditions_annual.do"




/* done to here 

check delimits*/
do "${analysis_code}/silverhake/figure_code/plotsA04_fish_condition_and_macro.do"



do "${analysis_code}/silverhake/figure_code/plotsA05_quantities_by_time.do"

do "${analysis_code}/silverhake/figure_code/plotsA06_silverhake_and_allqs_by_time.do"


do "${analysis_code}/silverhake/figure_code/plotsA07_prices_and_macro.do"
