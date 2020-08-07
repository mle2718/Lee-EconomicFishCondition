/* code to construct/merge the annual fish condition data */




version 15.1
pause off

timer on 1

local in_prices ${data_raw}/raw_dealer_prices_${vintage_string}.dta 
local  out_data ${data_intermediate}/dealer_prices_real${vintage_string}.dta 

local deflators $data_external/deflatorsQ_${vintage_string}.dta

/* bring in deflators and construct real compensation */


use  `deflators', clear
keep dateq  f*
rename fGDPDEF fGDP
rename fPCU3117103117102_2019Q1 ffresh_frozen
rename fPCU31171031171021_2019Q1 fpreparedfish

tempfile deflators
save `deflators'



use  `in_prices', replace 

gen date=mdy(month, day, year)
format date $td

gen dateq=qofd(date)
format dateq %tq
merge m:1 dateq using `deflators', keep(1 3)
drop dateq


gen valueR_GDPDEF=value/fGDP

gen valueR_fresh_frozen=value/ffresh_frozen
gen valueR_prepared=value/fprepared
save `out_data', replace
