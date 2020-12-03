/* code to run some preliminary regressions on Silver Hake */
cap log close


local logfile "silver_hake02.smcl"
log using ${my_results}/`logfile', replace


version 15.1
pause off
vintage_lookup_and_reset
/* tidy ups */
postutil clear
estimates clear


global working_nespp3 509
local  in_data ${data_main}/dealer_prices_final_spp_${working_nespp3}_${vintage_string}.dta 
local  marketcats ${data_raw}/dealer_nespp4_codes${vintage_string}.dta 

global linear_table3 ${my_tables}/silver_hake3.tex

global condition_table ${my_tables}/silver_hake_condition.tex
global ihs_table ${my_tables}/silver_hake_ihs.tex


global year_table ${my_tables}/silver_hake_years.tex
global month_week_table ${my_tables}/silver_hake_month_week.tex
global bse ${my_tables}/bse.dta


/* don't show year or month coeficients in outreg */
local months 1.month 2.month 3.month 4.month 5.month 6.month 7.month 8.month 9.month 10.month 11.month 12.month 0.month 0b.month 12o.month
local years 1995.year 1996.year 1997.year 1998.year 1999.year 2000.year 2001.year 2002.year 2003.year 2004.year 2005.year 2006.year 2007.year 2008.year 2009.year 2010.year 2011.year 2012.year 2013.year 2014.year 2015.year 2016.year 2017.year 2018.year 2019.year 2020.year
local dow 1.dow 2.dow 3.dow  4.dow  5.dow  6.dow 
local sizes 5091.nespp4 5092.nespp4  5093.nespp4  5094.nespp4  5095.nespp4  5096.nespp4 

clear
use `in_data', clear
cap drop _merge
keep if nespp3==509
gen nominal=value/landings

/* construct silver_hake broad stock areas */
destring area, replace
silver_hake_bsa area BSA


coastal_stat_areas area inshore

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


label define fishing_zones 1 "Inshore" 3 "Offshore" 4 "International" 9 "Missing"
label values fzone fishing_zones





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


foreach var of varlist priceR_GDPDEF rGDPcapita  realDPIcapita personal_income_capita price_allIMP_R_GDPDEF meancond_Annual stddevcond_Annual pounds_noblueIMP pounds_allIMP pounds_noblueIMP_lag1 pounds_allIMP_lag1{
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
I'm doing this to set up Driscoll-Kraay SE's in ivreg2, but I think that might not work because of gaps. D-K needs panel, not multiple obs on a day */

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

/**************************************************/
/* label variables so the tables are pretty */
label var lnq "Log Daily Landings"
label var daily_landings "Daily Landings"

label var lnprice_allIMP_R_GDPDEF "Log Real Import Price"
label var lnrGDPcapita "Log Real GDP cap"
label var rGDPcapita "Real GDP cap"

label var price_allIMP_R_GDPDEF "Real Import Price"
/**************************************************/

gen mkt_shift=date>=mdy(1,1,2004)


/* IVs log-log  with permit and dealer effects; */
local modelname iv_log_fe

local depvars lnrGDPcapita ib7.month  i.year  i.dow  i.fzone i.BSA i1.mkt_shift#ib5090.nespp4 i0.mkt_shift#io(5093 5095 5096 5097).nespp4
local depvars lnrGDPcapita ib5090.nespp4 ib7.month  i.year  i.dow  i.fzone i.BSA
local endog lnq  lnprice_allIMP_R_GDPDEF
local excluded lnq_lag1 lnprice_allIMP_lag1_R_GDPDEF


ivreghdfe lnpriceR_GDPDEF  `depvars' (`endog' = `excluded') `ifconditional', absorb(permit dealnum) robust
est store iv_log

local months2 1.month 2.month 3.month 4.month 5.month 6.month 7b.month 8.month 9.month 10.month 11.month 12.month 
local years2 1995.year 1996.year 1997.year 1998.year 1999.year 2000.year 2001.year 2002.year 2003.year 2004.year 2005.year 2006.year 2007.year 2008.year 2009.year 2010.year 2011.year 2012.year 2013.year 2014.year 2015.year 2016.year 2017.year 2018.year 2019.year 
local dow 1.dow 2.dow 3.dow  4.dow  5.dow  6.dow 
local sizes 5091.nespp4 5092.nespp4  5093.nespp4  5094.nespp4  5095.nespp4  5096.nespp4 
local areas  1.BSA 2.BSA 3.fzone 9.fzone


local replacer replace

postfile handle str32 modelname str32 varname  b se using $bse, `replacer'
local regression_vars lnrGDPcapita `months2' `years2' `dow' `sizes' `areas' `endog'  
foreach r of local regression_vars {
    post handle ("`modelname'")  ("`r'")  (_b[`r']) (_se[`r'])
}





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

local table_opts addtext(Model,IV,Year effects, Yes, Month Effects, Yes, Vessel Effects, Yes, Dealer Effects, Yes) ctitle("Log Price") 

outreg2 using ${linear_table3}, tex(frag) label adds(ll, e(ll), rmse, e(rmse))  drop(`months' `years' `dow') `table_opts' `replacer'
outreg2 using ${year_table}, tex(frag) label  keep(`years')   `table_opts' `replacer' 
outreg2 using ${month_week_table}, tex(frag) label   keep(`months' `dow')  `table_opts' `replacer'



local replacer 




/* IVs log-log  WITHOUT permit and dealer effects; */
local modelname iv_log_nofe

local depvars lnrGDPcapita ib5090.nespp4   i.dow  i.fzone i.BSA ib7.month i.year
local endog lnq  lnprice_allIMP_R_GDPDEF
local excluded lnq_lag1 lnprice_allIMP_lag1_R_GDPDEF

ivreg2 lnpriceR_GDPDEF  `depvars' (`endog' = `excluded') `ifconditional', robust
est store iv_log_nofe



local regression_vars lnrGDPcapita `months2' `years2' `dow' `sizes' `areas' `endog'  
foreach r of local regression_vars {
    post handle ("`modelname'")  ("`r'")  (_b[`r']) (_se[`r'])
}




local table_opts addtext(Model,IV, Year effects, Yes, Month Effects, Yes, Vessel Effects, No, Dealer Effects, No)  ctitle("Log Price")
outreg2 using ${linear_table3}, tex(frag) label adds(ll, e(ll), rmse, e(rmse))  drop(`months' `years' `dow') `table_opts'  `replacer'
outreg2 using ${year_table}, tex(frag) label  keep(`years')   `table_opts' `replacer' 
outreg2 using ${month_week_table}, tex(frag) label   keep(`months' `dow')  `table_opts' `replacer'





/* OLS in logs log-log  is okay-ish; */
local modelname ols_log_fe

local depvars  lnrGDPcapita lnq  lnprice_allIMP_R_GDPDEF ib5090.nespp4 ib7.month  i.year  i.dow  i.fzone i.BSA 
reghdfe lnpriceR_GDPDEF `depvars' `ifconditional', absorb(permit dealnum) vce(robust)



local regression_vars lnrGDPcapita lnq lnprice_allIMP_R_GDPDEF  `months2' `years2' `dow' `sizes' `areas' 
foreach r of local regression_vars {
    post handle ("`modelname'")  ("`r'")  (_b[`r']) (_se[`r'])
}


/* OLS in logs log-log  is okay-ish; 

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

local table_opts addtext(Model,OLS, Year effects, Yes, Month Effects, Yes, Vessel Effects, Yes, Dealer Effects, Yes) ctitle("Log Price")
outreg2 using ${linear_table3}, tex(frag) label adds(ll, e(ll), rmse, e(rmse))  drop(`months' `years' `dow') `table_opts'  `replacer'
outreg2 using ${year_table}, tex(frag) label  keep(`years')   `table_opts' `replacer' 
outreg2 using ${month_week_table}, tex(frag) label   keep(`months' `dow')  `table_opts' `replacer'









/* ols in levels */
local modelname ols_linear_fe

local depvars daily_landings rGDPcapita price_allIMP_R_GDPDEF ib5090.nespp4 ib7.month  i.year  i.dow  i.fzone i.BSA 


reghdfe priceR_GDPDEF `depvars' `ifconditional', absorb(permit dealnum) vce(robust)
est store ols

local regression_vars daily_landings rGDPcapita price_allIMP_R_GDPDEF  `months2' `years2' `dow' `sizes' `areas' 
foreach r of local regression_vars {
    post handle ("`modelname'")  ("`r'")  (_b[`r']) (_se[`r'])
}


local table_opts  addtext(Model,OLS,Year effects, Yes, Month Effects, Yes, Vessel Effects, Yes, Dealer Effects, Yes) ctitle("Real Price")
outreg2 using ${linear_table3}, tex(frag) label adds(ll, e(ll), rmse, e(rmse))  drop(`months' `years' `dow') `table_opts'  `replacer'
outreg2 using ${year_table}, tex(frag) label  keep(`years')   `table_opts' `replacer' 
outreg2 using ${month_week_table}, tex(frag) label   keep(`months' `dow')  `table_opts' `replacer'


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


/* linear IV*/
local modelname iv_linear_fe

local depvars rGDPcapita   ib5090.nespp4 ib7.month  i.year ib7.month i.dow  i.fzone i.BSA
local endog daily_landings price_allIMP_R_GDPDEF
local excluded q_lag1 price_allIMP_lag1_R_GDPDEF


ivreghdfe priceR_GDPDEF     `depvars' (`endog' = `excluded') `ifconditional', absorb(permit dealnum) robust
est store iv_linear


local regression_vars rGDPcapita `months2' `years2' `dow' `sizes' `areas' `endog'  
foreach r of local regression_vars {
    post handle ("`modelname'")  ("`r'")  (_b[`r']) (_se[`r'])
}


local table_opts addtext(Model,IV,Year effects, Yes, Month Effects, Yes, Vessel Effects, Yes, Dealer Effects, Yes)  ctitle("Price")
outreg2 using ${linear_table3}, tex(frag) label adds(ll, e(ll), rmse, e(rmse))  drop(`months' `years' `dow')  `table_opts' `replacer'
outreg2 using ${year_table}, tex(frag) label  keep(`years')   `table_opts' `replacer' 
outreg2 using ${month_week_table}, tex(frag) label   keep(`months' `dow')  `table_opts' `replacer'








/* IVs log-log condition factor with permit and dealer effects

Cannot include FY specific effects */
local modelname iv_log_condition
local depvars lnrGDPcapita ib5090.nespp4 ib7.month  i.dow  i.fzone i.BSA meancond_Annual stddevcond_Annual
local endog lnq  lnprice_allIMP_R_GDPDEF
local excluded lnq_lag1 lnprice_allIMP_lag1_R_GDPDEF


ivreghdfe lnpriceR_GDPDEF  `depvars' (`endog' = `excluded') `ifconditional', absorb(permit dealnum) robust
est store iv_log_condition

local replacer replace
local table_opts addtext(Model,IV,Year effects, No, Month Effects, Yes, Vessel Effects, Yes, Dealer Effects, Yes)  ctitle("log Price")
outreg2 using ${condition_table}, tex(frag) label adds(ll, e(ll), rmse, e(rmse))  drop(`months' `years' `dow')  `table_opts' `replacer'
local replacer


local regression_vars lnrGDPcapita meancond_Annual stddevcond_Annual `months2' `dow' `sizes' `areas' `endog'  
foreach r of local regression_vars {
    post handle ("`modelname'")  ("`r'")  (_b[`r']) (_se[`r'])
}


/* IVs log-log condition factor with permit and dealer effects

Cannot include FY specific effects */
local modelname iv_log_condition2
local depvars lnrGDPcapita ib5090.nespp4 ib7.month  i.dow  i.fzone i.BSA lnmeancond_Annual lnstddevcond_Annual
local endog lnq  lnprice_allIMP_R_GDPDEF
local excluded lnq_lag1 lnprice_allIMP_lag1_R_GDPDEF


ivreghdfe lnpriceR_GDPDEF  `depvars' (`endog' = `excluded') `ifconditional', absorb(permit dealnum) robust
est store iv_log2_condition

local table_opts addtext(Model,IV,Year effects, No, Month Effects, Yes, Vessel Effects, Yes, Dealer Effects, Yes)  ctitle("log Price")
outreg2 using ${condition_table}, tex(frag) label adds(ll, e(ll), rmse, e(rmse))  drop(`months' `years' `dow')  `table_opts' `replacer'



local regression_vars lnrGDPcapita lnmeancond_Annual lnstddevcond_Annual `months2' `dow' `sizes' `areas' `endog'  
foreach r of local regression_vars {
    post handle ("`modelname'")  ("`r'")  (_b[`r']) (_se[`r'])
}






/* IVs ihs and disaggregate the quantities */
local modelname iv_ihs
local depvars ihsrGDPcapita ib5090.nespp4 ib7.month  i.dow i.year i.fzone i.BSA 
local endog ihs_ownq ihs_other_landings          ihsprice_allIMP_R_GDPDEF
local excluded ihs_other_landings_lag1 ihsownq_lag1         ihsimport_lag1


ivreghdfe ihspriceR_GDPDEF  `depvars' (`endog' = `excluded') `ifconditional', absorb(permit dealnum) robust
est store iv_ihs

local replacer replace
local table_opts addtext(Model,IV,Year effects, No, Month Effects, Yes, Vessel Effects, Yes, Dealer Effects, Yes)  ctitle("IHS Price")
outreg2 using ${ihs_table}, tex(frag) label adds(ll, e(ll), rmse, e(rmse))  drop(`months2' `years' `dow')  `table_opts' `replacer'


local regression_vars ihsrGDPcapita  `months2' `dow' `sizes' `areas' `endog'  `years2'
foreach r of local regression_vars {
    post handle ("`modelname'")  ("`r'")  (_b[`r']) (_se[`r'])
}





/* IVs ihs with condition */
local modelname iv_ihs_cond
local depvars ihsrGDPcapita ib5090.nespp4 ib7.month  i.dow i.fzone i.BSA ihsmeancond_Annual ihsstddevcond_Annual
local endog ihs_ownq ihs_other_landings          ihsprice_allIMP_R_GDPDEF
local excluded ihs_other_landings_lag1 ihsownq_lag1         ihsimport_lag1


ivreghdfe ihspriceR_GDPDEF  `depvars' (`endog' = `excluded') `ifconditional', absorb(permit dealnum) robust
est store iv_ihs

local table_opts addtext(Model,IV,Year effects, No, Month Effects, Yes, Vessel Effects, Yes, Dealer Effects, Yes)  ctitle("IHS Price")
outreg2 using ${ihs_table}, tex(frag) label adds(ll, e(ll), rmse, e(rmse))  drop(`months2' `years2' `dow')  `table_opts' `replacer'


local regression_vars ihsrGDPcapita ihsmeancond_Annual ihsstddevcond_Annual `months2' `dow' `sizes' `areas' `endog'  
foreach r of local regression_vars {
    post handle ("`modelname'")  ("`r'")  (_b[`r']) (_se[`r'])
}









/* IVs ihs with condition and dpi */
local modelname iv_ihs_dpi
local depvars ihsrealDPIcapita ib5090.nespp4 ib7.month  i.dow i.fzone i.BSA ihsmeancond_Annual ihsstddevcond_Annual
local endog ihs_ownq ihs_other_landings          ihsprice_allIMP_R_GDPDEF
local excluded ihs_other_landings_lag1 ihsownq_lag1         ihspounds_allIMP_lag1



ivreghdfe ihspriceR_GDPDEF  `depvars' (`endog' = `excluded') `ifconditional', absorb(permit dealnum) robust
est store iv_ihs_dpi

local table_opts addtext(Model,IV,Year effects, No, Month Effects, Yes, Vessel Effects, Yes, Dealer Effects, Yes)  ctitle("IHS Price")
outreg2 using ${ihs_table}, tex(frag) label adds(ll, e(ll), rmse, e(rmse))  drop(`months2' `years2' `dow')  `table_opts' `replacer'


local regression_vars ihsrealDPIcapita ihsmeancond_Annual ihsstddevcond_Annual `months2' `dow' `sizes' `areas' `endog'  
foreach r of local regression_vars {
    post handle ("`modelname'")  ("`r'")  (_b[`r']) (_se[`r'])
}




/* IVs ihs with condition and personal_income */
local modelname iv_ihs_pi
local depvars ihspersonal_income_capita ib5090.nespp4 ib7.month  i.dow i.fzone i.BSA ihsmeancond_Annual ihsstddevcond_Annual
local endog ihs_ownq ihs_other_landings          ihsprice_allIMP_R_GDPDEF
local excluded ihs_other_landings_lag1 ihsownq_lag1         ihspounds_allIMP_lag1



ivreghdfe ihspriceR_GDPDEF  `depvars' (`endog' = `excluded') `ifconditional', absorb(permit dealnum) robust
est store iv_ihs_pi

local table_opts addtext(Model,IV,Year effects, No, Month Effects, Yes, Vessel Effects, Yes, Dealer Effects, Yes)  ctitle("IHS Price")
outreg2 using ${ihs_table}, tex(frag) label adds(ll, e(ll), rmse, e(rmse))  drop(`months2' `years2' `dow')  `table_opts' `replacer'


local regression_vars ihspersonal_income_capita ihsmeancond_Annual ihsstddevcond_Annual `months2' `dow' `sizes' `areas' `endog'  
foreach r of local regression_vars {
    post handle ("`modelname'")  ("`r'")  (_b[`r']) (_se[`r'])
}
postclose handle


log close


/*

/*models with condition factor */
 
 ivregress 2sls priceR_GDPDEF rGDPcapita ib5090.nespp4  i.month meancond_Annual stddevcond_Annual (lnq=lnq_lag1)  `ifconditional' , robust
est store IVcondition
 
 
  ivregress 2sls ihspriceR ihsrGDPcapita ib5090.nespp4   meancond_Annual stddevcond_Annual price_allIMP_R_GDPDEF i.dow (ihs_ownq ihs_other_landings=ihsownq_lag1 ihs_other_landings_lag1)  `ifconditional', cluster(date)
est store IHScondition


  ivregress 2sls priceR_GDPDEF rGDPcapita ib5090.nespp4##(c.meancond_Annual c.stddevcond_Annual)  i.dow (price_allIMP_R_GDPDEF own4landings other_landings=ownq_lag1 other_landings_lag1 price_allIMP_lag1_R_GDPDEF price_allIMP_lag12_R_GDPDEF )   `ifconditional', cluster(date)
  est store LEVELcondition

  
    ivregress 2sls ihspriceR ihsrGDPcapita ib5090.nespp4   meancond_Annual stddevcond_Annual i.month i.dow (ihsimportR ihs_ownq ihs_other_landings=ihsownq_lag1 ihs_other_landings_lag1 ihsimport_lag1 ihsimport_lag12)  `ifconditional', cluster(date)
*/
