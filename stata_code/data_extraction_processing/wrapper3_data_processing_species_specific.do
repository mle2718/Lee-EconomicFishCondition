/* this is a wrapper to get some exploratory data for hedonics
I've put in in the aceprice folder, but  there is not good reason for it to be here.*/
version 15.1
#delimit cr


/*args for this wrapper, load and save data*/
local  price_done ${data_main}/dealer_prices_full_${vintage_string}.dta 
local  subset_stub ${data_main}/dealer_prices_spp
local  subset_stub_out ${data_main}/dealer_prices_final_spp


/*args for do "${processing_code}/A04_imports_month_509.do"*/
global whiting_trade ${data_external}/whiting_trade${vintage_string}.dta 
global whiting_trade_out ${data_main}/whiting_trade_monthly${vintage_string}.dta 



/*args for do "${processing_code}/A04_imports_month_147.do"*/
global haddock_trade ${data_external}/haddock_trade${vintage_string}.dta 
global haddock_trade_out ${data_main}/haddock_trade_monthly${vintage_string}.dta 



/* merge trade data by species */
/* whiting */
local working_nespp3 509 
/* Tidy up the trade data*/
do "${processing_code}/A04_imports_month_`working_nespp3'.do"

/*Load in data 
use `price_done' if nespp3==`working_nespp3' OR
*/

use `subset_stub'_`working_nespp3'_${vintage_string}.dta 


/* merge in trade data */
merge m:1 year month using $whiting_trade_out, keep(1 3)
assert month==0 if _merge==1
drop _merge

save `subset_stub_out'_`working_nespp3'_${vintage_string}.dta 



/* haddock */
local working_nespp3 147
/******************************ADJUST AS NEEDED *******************************/
/*
/* Tidy up the trade data*/
do "${processing_code}/A04_imports_month_`working_nespp3'.do"

/*Load in data 
use `price_done' if nespp3==`working_nespp3' OR
*/

use `subset_stub'_`working_nespp3'_${vintage_string}.dta 


/* merge in trade data */
merge m:1 year month using $trade_out, keep(1 3)
assert month==0 if _merge==1
drop _merge

save `subset_stub_out'_`working_nespp3'_${vintage_string}.dta 
*/
/******************************ADJUST AS NEEDED *******************************/

