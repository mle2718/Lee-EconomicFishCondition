




version 15.1
pause off

timer on 1

global oracle_cxn " $mysole_conn lower"
local in_data ${data_raw}/raw_dealer_prices_${vintage_string}.dta 

clear
use `in_data', clear
label define marketcats 5090 "Round" 5091 "King" 5092 "Small" 5093 "Dressed" 5094 "Juvenile" 5095 "Large" 5096 "Medium", replace

label values nespp4 marketcats

gen nespp3=floor(nespp4/10)
keep if nespp3==509

gen price=value/landings
gen date=mdy(month,day, year)
drop if date==.


/* construct daily landings */
preserve
collapse (sum) landings, by(date) 
tsset date
tsfill, full
gen lnq=ln(landings)
gen lnq_lag1=l1.lnq

tempfile daily
save `daily'
restore
merge m:1 date using `daily'

drop if price>=8
drop if nespp4==5097
/* ols, absorbing various things */
reg price lnq ibn.nespp4 i.year
reg price lnq ibn.nespp4 i.month  i.year
areg price lnq ib5091.nespp4 ib7.month  i.year, absorb(permit)


/*IV, using lag of quantities as an instrument */
ivregress 2sls price ibn.nespp4  i.year (lnq=lnq_lag1)


ivregress 2sls price ibn.nespp4 i.month  i.year (lnq=lnq_lag1)

reghdfe price lnq ib5091.nespp4 ib7.month  i.year, absorb(permit dealnum)

