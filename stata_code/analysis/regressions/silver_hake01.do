/* code to run some preliminary regressions on Silver Hake */




version 15.1
pause off

timer on 1

global oracle_cxn " $mysole_conn lower"
local in_data ${data_intermediate}/dealer_prices_real${vintage_string}.dta 

global linear_table1 ${my_tables}/silver_hake1.tex

/* don't show year or month coeficients 
 drop(1999.year 2000.year)*/
local months 1.month 2.month 3.month 4.month 5.month 6.month 7.month 8.month 9.month 10.month 11.month 12.month
local years 1995.year 1996.year 1997.year 1998.year 1999.year 2000.year 2001.year 2002.year 2003.year 2004.year 2005.year 2006.year 2007.year 2008.year 2009.year 2010.year 2011.year 2012.year 2013.year 2014.year 2015.year 2016.year 2017.year 2018.year 2019.year 2020.year


clear
use `in_data', clear
label define marketcats 5090 "Round" 5091 "King" 5092 "Small" 5093 "Dressed" 5094 "Juvenile" 5095 "Large" 5096 "Medium", replace

label values nespp4 marketcats

gen nespp3=floor(nespp4/10)
keep if nespp3==509

gen priceR_GDPDEF=valueR_GDPDEF/landings
drop if date==.
assert _merge==3
drop _merge

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
outreg2 using ${linear_table1}, tex(frag) label adds(ll, e(ll), rmse, e(rmse)) addtext(Year effects, Yes, Month Effects, No, Model, OLS) drop(`years') replace

reg price lnq ibn.nespp4 i.month  i.year
outreg2 using ${linear_table1}, tex(frag) label adds(ll, e(ll), rmse, e(rmse)) addtext(Year effects, Yes, Month Effects, Yes,Model, OLS) drop(`months' `years')

areg price lnq ib5091.nespp4 ib7.month  i.year, absorb(permit)
outreg2 using ${linear_table1}, tex(frag) label adds(ll, e(ll), rmse, e(rmse)) addtext(Year effects, Yes, Month Effects, Yes, vessel, Yes, Model,OLS) drop(`months' `years')


/*IV, using lag of quantities as an instrument */
ivregress 2sls price ibn.nespp4  i.year (lnq=lnq_lag1)

outreg2 using ${linear_table1}, tex(frag) label adds(rmse, e(rmse)) addtext(Year effects, Yes, Month Effects, No, Model, IV) drop(`years')

ivregress 2sls price ibn.nespp4 i.month  i.year (lnq=lnq_lag1)
outreg2 using ${linear_table1}, tex(frag) label adds(rmse, e(rmse)) addtext(Year effects, Yes, Month Effects, Yes, Model, IV) drop(`months' `years')
 

/*
reghdfe price lnq ib5091.nespp4 ib7.month  i.year, absorb(permit dealnum)
*/
