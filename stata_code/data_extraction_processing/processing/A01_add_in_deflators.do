/* code to construct/merge the annual fish condition data */




version 15.1
pause off

timer on 1

local deflators $data_external/deflatorsQ_${vintage_string}.dta
local income $data_external/incomeQ_${vintage_string}.dta 

/* bring in deflators and construct real compensation */

preserve
use  `deflators', clear
keep dateq  f*
rename fGDPDEF fGDP
rename fPCU3117103117102_2019Q1 ffresh_frozen
rename fPCU31171031171021_2019Q1 fpreparedfish

tempfile deflatorsW
save `deflatorsW'
restore


gen ds=day
replace ds=1 if ds==0
gen date=mdy(month, ds, year)
drop ds
format date $td

gen dateq=qofd(date)
format dateq %tq
merge m:1 dateq using `deflatorsW', keep(1 3)
assert _merge~=2
drop _merge


gen valueR_GDPDEF=value/fGDP

gen valueR_fresh_frozen=value/ffresh_frozen
gen valueR_prepared=value/fprepared



/* bring in income */


merge m:1 dateq using `income', keep(1 3)


cap drop dateq 
cap drop date
notes: there are 12 observations without a month. such is life.
