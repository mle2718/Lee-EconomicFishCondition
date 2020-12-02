/* code to aggregate the NMFS trade data 
It's a little silly to bring along nominal values, pounds, and real values, when all I need at the end of the day are real prices.  But whatever.
*/
global kg_to_lbs 2.20462

use $whiting_trade, clear
cap replace kilos=round(kilos*$kg_to_lbs)
cap rename kilos pounds
replace pounds=pounds/1000
label var pounds "pounds 000s"

replace nominal_value=nominal_value/1000
label var nominal_value "nominal 000s"

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
rename pounds pounds_all
label var pounds_all "import pounds 000s"
keep year month source price_all pounds_all


tempfile all
save `all', replace
restore


drop if inlist(name,"GROUNDFISH BLUE WHITING*")
collapse (sum) pounds nominal_value, by(year month source)
gen price_noblue=nominal_value/pounds
rename pounds pounds_noblue
rename pounds_noblue pounds_noblue
label var pounds_noblue "import pounds , no blue whiting, 000s"

keep year month source price_noblue pounds_noblue
merge 1:1 year month source using `all'

drop _merge


reshape wide price_noblue price_all pounds_noblue pounds_all, i(year month) j(source) string
gen monthly=ym(year, month)
tsset monthly

foreach var of varlist price_noblue* price_all* pounds_noblue* pounds_all*{
	gen `var'_lag1=L1.`var'
	gen `var'_lag12=l12.`var'
}

save $whiting_trade_out, replace


/* I'm making 2 types of imports, with and without blue whiting 
I'm also making 1st and 12th lags.

*/
