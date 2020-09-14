/* code to aggregate the NMFS trade data 
It's a little silly to bring along nominal values, pounds, and real values, when all I need at the end of the day are real prices.  But whatever.
This is especially so, since I need to get Lags anyway.
*/
global kg_to_lbs 2.20462

use $trade, clear
cap replace kilos=round(kilos*$kg_to_lbs)
cap rename kilos pounds
/*All CONUS */
drop if inlist(district_name,"SAN JUAN, PR", "ANCHORAGE, AK","HONOLULU, HI")


/* Filter out some species */
*drop if inlist(name,"GROUNDFISH BLUE WHITING*")
/*here's an FAO report on blue whiting 
http://www.fao.org/3/x5952e/x5952e01.htm
*/

/* Filter out frozen */
*drop if inlist(name,"*FROZEN*")

preserve
collapse (sum) pounds nominal_value, by(year month source)

rename pounds whiting_trade_all_pounds
rename nominal_value nominal_value_trade_all

tempfile all
save `all', replace
restore


drop if inlist(name,"GROUNDFISH BLUE WHITING*")
collapse (sum) pounds nominal_value, by(year month source)

rename pounds whiting_trade_noblue_pounds
rename nominal_value nominal_value_trade_noblue

merge 1:1 year month source using `all'

drop _merge

reshape wide  whiting_trade_noblue_pounds nominal_value_trade_noblue nominal_value_trade_all whiting_trade_all_pounds, i(year month) j(source) string

foreach var of varlist whiting_trade_noblue_pounds* nominal_value_trade_noblue* nominal_value_trade_all* whiting_trade_all_pounds*{
	replace `var'=0 if `var'==.
}
compress

save $trade_out, replace
