/* code to run some preliminary regressions on Silver Hake */
version 15.1
pause off

local  in_data ${data_main}/dealer_prices_real_lags_condition${vintage_string}.dta 
local  marketcats ${data_raw}/dealer_nespp4_codes${vintage_string}.dta 

global linear_table3 ${my_tables}/silver_hake3.tex

global linear_table4 ${my_tables}/silver_hake4.tex


/* don't show year or month coeficients in outreg */
local months 1.month 2.month 3.month 4.month 5.month 6.month 7.month 8.month 9.month 10.month 11.month 12.month 0.month 0b.month 12o.month
local years 1995.year 1996.year 1997.year 1998.year 1999.year 2000.year 2001.year 2002.year 2003.year 2004.year 2005.year 2006.year 2007.year 2008.year 2009.year 2010.year 2011.year 2012.year 2013.year 2014.year 2015.year 2016.year 2017.year 2018.year 2019.year 2020.year
local dow 1.dow 2.dow 3.dow  4.dow  5.dow  6.dow 


clear
use `in_data', clear
cap drop _merge
keep if nespp3==509
gen nominal=value/landings

/* construct silver_hake broad stock areas */
destring area, replace
silver_hake_bsa area BSA

/* there's a few area=0*/


/* there some fzone tidy ups, many nulls 
now fzone=1 (less than 12mi)
fzone=3 more than 12
4 - intl water (dropped)
9 missing
*/

rename fzone fzone_backup
clonevar fzone= fzone_backup
replace fzone=1 if inlist(fzone,0,1,2)
replace fzone=9 if fzone==.


/* pull in market categories*/

merge m:1 nespp4 using `marketcats', keep(1 3)
assert _merge==3
labmask nespp4, value(sp_mkt)
drop _merge



/* Normalize 
Need to deflate */
gen priceR_GDPDEF=valueR_GDPDEF/landings

foreach var of varlist price_noblueEXP price_allEXP price_noblueIMP price_allIMP price_noblueREX price_allREX price_*IMP_lag* {
gen `var'_R_GDPDEF=`var'/fGDP
}


foreach var of varlist priceR_GDPDEF rGDPcapita price_allIMP_R_GDPDEF{
gen ihs`var'=asinh(`var')
gen ln`var'=ln(`var')
}


gen ihsimport_lag1=asinh(price_allIMP_lag1_R_GDPDEF)
gen ihsimport_lag12=asinh(price_allIMP_lag12_R_GDPDEF)

/********************************************************/
/********************************************************/
/* you really need to do more data cleaning and look at some descriptive statistics */
/********************************************************/
/********************************************************/

/*tsset -- generate an xid variable that doesn't mean anything
And date is the time variable 
I'm doing this to set up Driscoll-Kraay SE's in ivreg2, but I think that might not work because of gaps */

bysort date (link): gen xid=_n
order xid date
format date %td
tsset xid date



/* mark the estimation sample */
cap drop date
cap drop markin
gen date=mdy(month,day,year)

gen markin=1
replace markin=0 if date==.
replace markin=0 if nominal>8 
replace markin=0 if inlist(nespp4,5097)==1
replace markin=0 if nominal==0
replace markin=0 if fzone==4

local ifconditional "if markin==1"
cap drop _merge


gen lnprice_allIMP_lag1_R_GDPDEF=ln(price_allIMP_lag1_R_GDPDEF)
/* there will also be a few rows that do not match because there are zero landings. */


/* 	*/




/* ols, absorbing various things */
local replacer replace
reghdfe priceR_GDPDEF daily_landings rGDPcapita price_allIMP_R_GDPDEF ib5090.nespp4 ib7.month  i.year  i.dow  i.fzone i.BSA `ifconditional', absorb(permit dealnum) vce(robust)
est store ols
outreg2 using ${linear_table3}, tex(frag) label adds(ll, e(ll), rmse, e(rmse)) addtext(Model,OLS,Year effects, Yes, Month Effects, Yes, Vessel Effects, Yes, Dealer Effects, Yes) drop(`months' `years' `dow')  ctitle("Real Price") `replacer'
local replacer 

/* OLS is okay-ish ; 

1.  however, the coefficient on import prices is the wrong sign. An increase in the price of imports should increase the price of domestics  This is totally endogeneity.
2. The Elasticity of price wrt income (atmeans) is very large (-2.40).  Not sure what's going on here.  
The order of prices is:"
King & Large

Round
Dressed
Juvenile


Medium
Small
*/


reghdfe lnpriceR_GDPDEF lnrGDPcapita lnq  lnprice_allIMP_R_GDPDEF ib5090.nespp4 ib7.month  i.year  i.dow  i.fzone i.BSA  `ifconditional', absorb(permit dealnum) vce(robust)
/* log-log  is okay-ish; 

1.  however, the coefficient on import prices is the wrong sign. This is totally endogeneity.
2. The Elasticity of price wrt income (atmeans) is very large (-1.21).  
The order of prices is:"
King & Large

Round
Dressed
Juvenile


Medium
Small
*/


est store ols_log
outreg2 using ${linear_table3}, tex(frag) label adds(ll, e(ll), rmse, e(rmse)) addtext(Model,OLS, Year effects, Yes, Month Effects, Yes, Vessel Effects, Yes, Dealer Effects, Yes) drop(`months' `years' `dow')  ctitle("Log Price") `replacer'


ivreg2 lnpriceR_GDPDEF lnrGDPcapita ib5090.nespp4   i.dow  i.fzone i.BSA i.month i.year  (lnq  lnprice_allIMP_R_GDPDEF = lnq_lag1 lnprice_allIMP_lag1_R_GDPDEF) `ifconditional', robust
est store iv_log_nofe




ivreghdfe lnpriceR_GDPDEF lnrGDPcapita ib5090.nespp4 ib7.month  i.year  i.dow  i.fzone i.BSA   (lnq  lnprice_allIMP_R_GDPDEF = lnq_lag1 lnprice_allIMP_lag1_R_GDPDEF) `ifconditional', absorb(permit dealnum) robust
est store iv_log

/* IVs log-log  is better fitting; 

1.  Coefficient on import prices is positive, as expected. The elasticity is 0.58.
2. The Elasticity of price wrt income (atmeans) is still a little too  negative (-.90).  
The order of prices is:"
King & Large

Round
Dressed
Juvenile


Medium
Small

Highest prices in the winter/spring.  Say December to April.
large DOW effects that arent' seen in the ols models. 
fzone 4= higher prices than others (by alot)
Norther has slighly higher prices than southern.
*/



outreg2 using ${linear_table3}, tex(frag) label adds(ll, e(ll), rmse, e(rmse)) addtext(Model,IV,Year effects, Yes, Month Effects, Yes, Vessel Effects, Yes, Dealer Effects, Yes) drop(`months' `years' `dow')  ctitle("Log Price") `replacer'

est table ols ols_log iv_log, drop(i.year i.month i.dow)



ivreghdfe priceR_GDPDEF  rGDPcapita   ib5090.nespp4 ib7.month  i.year i.month i.dow  i.fzone i.BSA   (daily_landings price_allIMP_R_GDPDEF = q_lag1 price_allIMP_lag1_R_GDPDEF) `ifconditional', absorb(permit dealnum) robust
est store iv_linear


/*

/*IV, using lag of quantities as an instrument */
ivregress 2sls priceR_GDPDEF rGDPcapita ib5090.nespp4  i.year (lnq=lnq_lag1)  `ifconditional' , robust

ivregress 2sls priceR_GDPDEF rGDPcapita ib5090.nespp4 i.month  i.year (lnq=lnq_lag1)  `ifconditional',robust
 
 
 
/* try the IV model using the inverse hyperbolic sin transform */
 ivregress 2sls priceR_GDPDEF ihsrGDPcapita ib5090.nespp4  i.year (ihs_ownq ihs_other_landings=ihsownq_lag1 ihs_other_landings_lag1)  `ifconditional', cluster(date)


/* try the IV model using the inverse hyperbolic sin transform */
 ivregress 2sls ihspriceR ihsrGDPcapita ib5090.nespp4  i.year i.dow (ihs_ownq ihs_other_landings=ihsownq_lag1 ihs_other_landings_lag1)  `ifconditional', cluster(date)
est store YearDums
 

 
 
 /* try the IV model using the inverse hyperbolic sin transform */
 ivregress 2sls ihspriceR ihsrGDPcapita ib5090.nespp4  i.month  i.dow (ihs_ownq ihs_other_landings=ihsownq_lag1 ihs_other_landings_lag1)  `ifconditional', cluster(date)

 est store YearMonthDums
 
  /* try the IV model using the inverse hyperbolic sin transform */
 ivregress 2sls ihspriceR ihsrGDPcapita ib5090.nespp4  i.dow (ihs_ownq ihs_other_landings=ihsownq_lag1 ihs_other_landings_lag1)  `ifconditional', cluster(date)

 est store Pooled

 
 gen qtr=quarter(date)
  gen quarterly=qofd(date)

  ivregress 2sls ihspriceR ihsrGDPcapita ib5090.nespp4  i.year i.qtr i.dow (ihs_ownq ihs_other_landings=ihsownq_lag1 ihs_other_landings_lag1)  `ifconditional', cluster(date)

  est store YearQtrDums
  
  
  
  
  
	
/*models with condition factor */
 
 ivregress 2sls priceR_GDPDEF rGDPcapita ib5090.nespp4  i.month meancond_Annual stddevcond_Annual (lnq=lnq_lag1)  `ifconditional' , robust
est store IVcondition
 
 
  ivregress 2sls ihspriceR ihsrGDPcapita ib5090.nespp4   meancond_Annual stddevcond_Annual price_allIMP_R_GDPDEF i.dow (ihs_ownq ihs_other_landings=ihsownq_lag1 ihs_other_landings_lag1)  `ifconditional', cluster(date)
est store IHScondition


  ivregress 2sls priceR_GDPDEF rGDPcapita ib5090.nespp4##(c.meancond_Annual c.stddevcond_Annual)  i.dow (price_allIMP_R_GDPDEF own4landings other_landings=ownq_lag1 other_landings_lag1 price_allIMP_lag1_R_GDPDEF price_allIMP_lag12_R_GDPDEF )   `ifconditional', cluster(date)
  est store LEVELcondition

  
    ivregress 2sls ihspriceR ihsrGDPcapita ib5090.nespp4   meancond_Annual stddevcond_Annual i.month i.dow (ihsimportR ihs_ownq ihs_other_landings=ihsownq_lag1 ihs_other_landings_lag1 ihsimport_lag1 ihsimport_lag12)  `ifconditional', cluster(date)
*/
