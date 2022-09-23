/* this is a wrapper to get some exploratory data for hedonics
I've put in in the aceprice folder, but  there is not good reason for it to be here.*/
version 15.1
#delimit cr

vintage_lookup_and_reset


cap log close
log using "${data_processing_results}\wrapper3_data_processing_species_specific.smcl", replace

/*args for this wrapper, load and save data*/
local  price_done ${data_main}/dealer_prices_full_${vintage_string}.dta 
local  subset_stub_out ${data_main}/dealer_prices_final_spp


/*args for do "${processing_code}/A04_imports_month_509.do"*/
global whiting_trade ${data_external}/whiting_trade${vintage_string}.dta 
global whiting_trade_out ${data_main}/whiting_trade_monthly${vintage_string}.dta 


/*args for do "${processing_code}/A04_imports_month_147.do"*/
global haddock_trade ${data_external}/haddock_trade${vintage_string}.dta 
global haddock_trade_out ${data_main}/haddock_trade_monthly${vintage_string}.dta 

/* split the data into separate files.
use `price_done', clear
levelsof nespp3, local(species)
foreach sp of local species{
local  savename `subset_stub'_`sp'_${vintage_string}.dta 
di "`savename'"
preserve
keep if nespp3==`sp'
save `savename', replace 
restore
}
 */


/* Save the name of the dofile to a global.  This will assist in troubleshooting which code broke. */
/* If you get an error message, type 
display "$running_dofile"  
to narrow down where things broke
*/

/* merge trade data by species */
/******************************whiting *******************************/
local working_nespp3 509 
/* Tidy up the trade data*/
global running_dofile "${processing_code}/A04_imports_month_`working_nespp3'.do"

do "${running_dofile}"
/*Load in data */
use `price_done' if inlist(nespp3,`working_nespp3'), clear




/* merge in trade data */
merge m:1 year month using $whiting_trade_out, keep(1 3)
assert month==0 if _merge==1
drop _merge

save `subset_stub_out'_`working_nespp3'_${vintage_string}.dta 
/******************************end whiting *******************************/






/******************************ADJUST AS NEEDED *******************************/
/*
/* haddock */
local working_nespp3 147

/* Tidy up the trade data*/
global running_dofile "${processing_code}/A04_imports_month_`working_nespp3'.do"

do "${running_dofile}"
/*Load in data */
use `price_done' if inlist(nespp3,`working_nespp3'), clear


/* merge in trade data */
merge m:1 year month using $trade_out, keep(1 3)
assert month==0 if _merge==1
drop _merge

save `subset_stub_out'_`working_nespp3'_${vintage_string}.dta 
*/
/******************************ADJUST AS NEEDED *******************************/

log close