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

gen price_all=nominal_value/pounds

keep year month source price_all


tempfile all
save `all', replace
restore


drop if inlist(name,"GROUNDFISH BLUE WHITING*")
collapse (sum) pounds nominal_value, by(year month source)
gen price_noblue=nominal_value/pounds
keep year month source price_noblue
merge 1:1 year month source using `all'

drop _merge


reshape wide price_noblue price_all, i(year month) j(source) string



save $trade_out, replace
