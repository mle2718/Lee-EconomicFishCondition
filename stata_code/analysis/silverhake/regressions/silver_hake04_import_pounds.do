/* code to run some  regressions on Silver Hake. Regressions here have a better chance of being well specified compared to silver_hake01.do and silver_hake02.do 
These are really similar to the silver_hake03.do file.
Most of the models here use IVREGHDFE to condition out "many" fixed effects. 

The bigger difference is that I'm using import pounds instead of import prices as a RHS variable.
*/
cap log close

vintage_lookup_and_reset
local logfile "silver_hake04import_${vintage_string}.smcl"

global silverhake_results ${my_results}/silverhake
global silverhake_tables ${my_tables}/silverhake


log using ${silverhake_results}/`logfile', replace

version 15.1
pause off
/* tidy ups */
postutil clear
estimates clear

/*setup input and output files */
global working_nespp3 509
local  in_data ${data_main}/dealer_prices_final_spp_${working_nespp3}_${vintage_string}.dta 
local  marketcats ${data_raw}/dealer_nespp4_codes${vintage_string}.dta 
local  statecodes ${data_raw}/state_codes${vintage_string}.dta 


global linear_table3 ${silverhake_tables}/silver_hake4Q.tex

global condition_table ${silverhake_tables}/silver_hake_condition4Q.tex


global year_table ${silverhake_tables}/silver_hake_years4Q.tex
global month_week_table ${silverhake_tables}/silver_hake_month_week4Q.tex
global bse ${silverhake_tables}/bse_silver_hake4Q.dta

global ihs_table ${silverhake_tables}/silver_hake_ihs4Q.tex
global ihsyear_table ${silverhake_tables}/silver_hake_yearsihs4Q.tex
global  ihsmonth_week_table ${silverhake_tables}/silver_hake_month_weekihs4Q.tex

/* don't show year or month coeficients in outreg */
local months 1.month 2.month 3.month 4.month 5.month 6.month 7.month 8.month 9.month 10.month 11.month 12.month 0.month 0b.month 12o.month
local years 1995.year 1996.year 1997.year 1998.year 1999.year 2000.year 2001.year 2002.year 2003.year 2004.year 2005.year 2006.year 2007.year 2008.year 2009.year 2010.year 2011.year 2012.year 2013.year 2014.year 2015.year 2016.year 2017.year 2018.year 2019.year 2020.year
local dow 1.dow 2.dow 3.dow  4.dow  5.dow  6.dow 
local sizes 5091.nespp4 5092.nespp4  5093.nespp4  5094.nespp4  5095.nespp4  5096.nespp4 
local states 7.statecd 22.statecd 23.statecd 24.statecd 32.statecd 33.statecd 35.statecd 36.statecd 42.statecd 49.statecd 
clear
use `in_data' , clear
assert nespp3==${working_nespp3}
cap drop _merge
gen nominal=value/landings

/* construct silver_hake broad stock areas */
destring area, replace

/* wrote a couple ados for these */
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


/* construct states */
gen statecd=floor(port/10000)
merge m:1 statecd using `statecodes', keep(1 3)
assert _merge==3
labmask statecd, value(stateabb)



gen priceR_GDPDEF=valueR_GDPDEF/landings

/* Normalize 
Need to deflate */
foreach var of varlist price_noblueEXP price_allEXP price_noblueIMP price_allIMP price_noblueREX price_allREX price_*IMP_lag* aggregateV aggregateV_lag1{
gen `var'_R_GDPDEF=`var'/fGDP
}


foreach var of varlist priceR_GDPDEF rGDPcapita  realDPIcapita personal_income_capita price_allIMP_R_GDPDEF meancond_Annual stddevcond_Annual pounds_noblueIMP pounds_allIMP pounds_noblueIMP_lag1 pounds_allIMP_lag1 aggregateV_R_GDPDEF aggregateV_lag1_R_GDPDEF {
gen ihs`var'=asinh(`var')
gen ln`var'=ln(`var')
}



gen ihsimport_lag1=asinh(price_allIMP_lag1_R_GDPDEF)
gen ihsimport_lag12=asinh(price_allIMP_lag12_R_GDPDEF)
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
cap drop quarterly

gen date=mdy(month,day,year)


gen qtr=quarter(date)
gen quarterly=qofd(date)
bysort quarterly: egen quarterly_land=total(landings)
gen lnql=ln(quarterly_land)

gen markin=1
replace markin=0 if date==.
replace markin=0 if inlist(nespp4,5097)==1
replace markin=0 if nominal>8 
replace markin=0 if nominal<=0.05
replace markin=0 if fzone==4
replace markin=0 if inlist(stateabb,"DE", "PA","NK")
local ifconditional "if markin==1"
cap drop _merge

/*set a local for weights */

local wtype "U"
if "`wtype'"=="A"{
local weighted [aw=landings]
display "Estimating with analytic weights"
} 
else if "`wtype'"=="F" {
local weighted [fw=landings]
display "Estimating with frequency weights"

} 
else if "`wtype'"=="U" {
local weighted
display "Estimating unweighted"
}

gen lnprice_allIMP_lag1_R_GDPDEF=ln(price_allIMP_lag1_R_GDPDEF)



/**************************************************/
/* label variables so the tables are pretty */
cap label var lnq "Log Daily Landings"
cap label var daily_landings "Daily Landings"

cap label var lnprice_allIMP_R_GDPDEF "Log Real Import Price"
cap label var lnrGDPcapita "Log Real GDP cap"
cap label var rGDPcapita "Real GDP cap"

cap label var price_allIMP_R_GDPDEF "Real Import Price"
cap label var USRECM "Recession Indicator"
cap label var pounds_allIMP "Import Quantity"
cap label var pounds_allIMP_lag1 "Import Quantity, 1 month lag"

cap label var lnpounds_allIMP "Log Import Quantity"
cap label var lnpounds_allIMP_lag1 "Log Import Quantity, 1 month lag"

cap label var ihspounds_allIMP "IHS Import Quantity"
cap label var ihspounds_allIMP_lag1 "IHS Import Quantity, 1 month lag"
cap label var USRECM "Recession Indicator"

cap label var lnql "Log Quarterly Landings"
cap label var lnaggregateV_R_GDPDEF "Log Aggregate NER Value"
cap label var ln_aggregateL "Log Aggregate NER Landings"
cap label var lnpounds_allIMP "Log Imports"

gen ln_lot=ln(landings)
gen ihs_lot=asinh(landings)

cap label var landings "Lot size"
cap label var ln_lot "ln of lot size"
cap label var ihs_lot "ihs of Lot size"
/**************************************************/


gen mkt_shift=date>=mdy(1,1,2004)

/* MODEL IV51: Same as IV41, but with import POUNDS on the RHS instead of prices  */
local modelname iv_log_fe
local depvars lnrGDPcapita ib7.month  i.year  i.dow  i.fzone i.BSA  ib5090.nespp4  i(5091 5092 5093 5094).nespp4#i0.mkt_shift  i.USRECM  i.statecd
local endog lnq  lnpounds_allIMP
local excluded lnq_lag1 lnpounds_allIMP_lag1


ivreghdfe lnpriceR_GDPDEF  `depvars' (`endog' = `excluded') `ifconditional', absorb(permit dealnum) robust
est store iv_log

local months2 1.month 2.month 3.month 4.month 5.month 6.month 7b.month 8.month 9.month 10.month 11.month 12.month 
local years2 1995.year 1996.year 1997.year 1998.year 1999.year 2000.year 2001.year 2002.year 2003.year 2004.year 2005.year 2006.year 2007.year 2008.year 2009.year 2010.year 2011.year 2012.year 2013.year 2014.year 2015.year 2016.year 2017.year 2018.year 2019.year 
local dow 1.dow 2.dow 3.dow  4.dow  5.dow  6.dow 
local sizes 5091.nespp4 5092.nespp4  5093.nespp4  5094.nespp4  5095.nespp4  5096.nespp4 
local areas  1.BSA 2.BSA 3.fzone 9.fzone
local states 7.statecd 22.statecd 23.statecd 24.statecd 32.statecd 33.statecd 35.statecd 36.statecd 42.statecd 49.statecd 

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

local table_opts addtext(Model,IV,Year effects, Yes, Month Effects, Yes, Vessel Effects, Yes, Dealer Effects, Yes) ctitle("IV51 Log") 

outreg2 using ${linear_table3}, tex(frag) label adds(ll, e(ll), rmse, e(rmse))  drop(`months' `years' `dow' `states') `table_opts' `replacer'
outreg2 using ${year_table}, tex(frag) label  keep(`years')   `table_opts' `replacer' 
outreg2 using ${month_week_table}, tex(frag) label   keep(`months' `dow' `states')  `table_opts' `replacer'



local replacer 




/* IV52: IVs log-log  WITHOUT permit and dealer effects; */
local modelname iv_log_nofe

local depvars lnrGDPcapita ib5090.nespp4  i(5091 5092 5093 5094).nespp4#i0.mkt_shift   i.dow  i.fzone i.BSA ib7.month i.year i.statecd
local endog lnq  lnpounds_allIMP
local excluded lnq_lag1 lnpounds_allIMP_lag1

ivreg2 lnpriceR_GDPDEF  `depvars' (`endog' = `excluded') `ifconditional', robust
est store iv_log_nofe



local regression_vars lnrGDPcapita `months2' `years2' `dow' `sizes' `areas' `endog'  
foreach r of local regression_vars {
    post handle ("`modelname'")  ("`r'")  (_b[`r']) (_se[`r'])
}




local table_opts addtext(Model,IV, Year effects, Yes, Month Effects, Yes, Vessel Effects, No, Dealer Effects, No)   ctitle("IV52 Log") 
outreg2 using ${linear_table3}, tex(frag) label adds(ll, e(ll), rmse, e(rmse))  drop(`months' `years' `dow' `states') `table_opts'  `replacer'
outreg2 using ${year_table}, tex(frag) label  keep(`years')   `table_opts' `replacer' 
outreg2 using ${month_week_table}, tex(frag) label   keep(`months' `dow' `states')  `table_opts' `replacer'





/* OLS51 in logs log-log  is okay-ish; */
local modelname ols_log_fe

local depvars  lnrGDPcapita lnq  lnpounds_allIMP  ib5090.nespp4  i(5091 5092 5093 5094).nespp4#i0.mkt_shift  ib7.month  i.year  i.dow  i.fzone i.BSA i.statecd
reghdfe lnpriceR_GDPDEF `depvars' `ifconditional', absorb(permit dealnum) vce(robust)



local regression_vars lnrGDPcapita lnq  lnpounds_allIMP  `months2' `years2' `dow' `sizes' `areas' 
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

local table_opts addtext(Model,OLS, Year effects, Yes, Month Effects, Yes, Vessel Effects, Yes, Dealer Effects, Yes) ctitle("OLS51 Log")
outreg2 using ${linear_table3}, tex(frag) label adds(ll, e(ll), rmse, e(rmse))  drop(`months' `years' `dow' `states') `table_opts'  `replacer'
outreg2 using ${year_table}, tex(frag) label  keep(`years')   `table_opts' `replacer' 
outreg2 using ${month_week_table}, tex(frag) label   keep(`months' `dow')  `table_opts' `replacer'









/* OLS52 ols in levels */
local modelname ols_linear_fe

local depvars daily_landings rGDPcapita pounds_allIMP ib5090.nespp4  i(5091 5092 5093 5094).nespp4#i0.mkt_shift  ib7.month  i.year  i.dow  i.fzone i.BSA  i.statecd


reghdfe priceR_GDPDEF `depvars' `ifconditional', absorb(permit dealnum) vce(robust)
est store ols

local regression_vars daily_landings rGDPcapita pounds_allIMP  `months2' `years2' `dow' `sizes' `areas' 
foreach r of local regression_vars {
    post handle ("`modelname'")  ("`r'")  (_b[`r']) (_se[`r'])
}


local table_opts  addtext(Model,OLS,Year effects, Yes, Month Effects, Yes, Vessel Effects, Yes, Dealer Effects, Yes) ctitle("OLS52 Lin")
outreg2 using ${linear_table3}, tex(frag) label adds(ll, e(ll), rmse, e(rmse))  drop(`months' `years' `dow' `states') `table_opts'  `replacer'
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


/* IV53 linear IV*/
local modelname iv_linear_fe

local depvars rGDPcapita    ib5090.nespp4  i(5091 5092 5093 5094).nespp4#i0.mkt_shift  ib7.month  i.year ib7.month i.dow  i.fzone i.BSA i.statecd
local endog daily_landings pounds_allIMP
local excluded q_lag1 lnpounds_allIMP_lag1







ivreghdfe priceR_GDPDEF     `depvars' (`endog' = `excluded') `ifconditional', absorb(permit dealnum) robust
est store iv_linear


local regression_vars rGDPcapita `months2' `years2' `dow' `sizes' `areas' `endog'  
foreach r of local regression_vars {
    post handle ("`modelname'")  ("`r'")  (_b[`r']) (_se[`r'])
}


local table_opts addtext(Model,IV,Year effects, Yes, Month Effects, Yes, Vessel Effects, Yes, Dealer Effects, Yes)  ctitle("IV52 Lin")
outreg2 using ${linear_table3}, tex(frag) label adds(ll, e(ll), rmse, e(rmse))  drop(`months' `years' `dow' `states')  `table_opts' `replacer'
outreg2 using ${year_table}, tex(frag) label  keep(`years')   `table_opts' `replacer' 
outreg2 using ${month_week_table}, tex(frag) label   keep(`months' `dow')  `table_opts' `replacer'








/* IV54: IVs log-log condition factor with permit and dealer effects

Cannot include FY specific effects */
local modelname iv_log_condition
local depvars lnrGDPcapita  ib5090.nespp4  i(5091 5092 5093 5094).nespp4#i0.mkt_shift  ib7.month  i.dow  i.fzone i.BSA meancond_Annual stddevcond_Annual i.statecd
local endog lnq  lnpounds_allIMP
local excluded lnq_lag1 lnpounds_allIMP_lag1


ivreghdfe lnpriceR_GDPDEF  `depvars' (`endog' = `excluded') `ifconditional', absorb(permit dealnum) robust
est store iv_log_condition

local replacer replace
local table_opts addtext(Model,IV,Year effects, No, Month Effects, Yes, Vessel Effects, Yes, Dealer Effects, Yes)  ctitle("IV54 Log")
outreg2 using ${condition_table}, tex(frag) label adds(ll, e(ll), rmse, e(rmse))  drop(`months' `years' `dow' `states')  `table_opts' `replacer'

local replacer


local regression_vars lnrGDPcapita meancond_Annual stddevcond_Annual `months2' `dow' `sizes' `areas' `endog'  
foreach r of local regression_vars {
    post handle ("`modelname'")  ("`r'")  (_b[`r']) (_se[`r'])
}

local table_opts addtext(Model,IV,Year effects, Yes, Month Effects, Yes, Vessel Effects, Yes, Dealer Effects, Yes)  ctitle("IV54 Log")
outreg2 using ${linear_table3}, tex(frag) label adds(ll, e(ll), rmse, e(rmse))  drop(`months' `years' `dow' `states')  `table_opts' `replacer'
outreg2 using ${year_table}, tex(frag) label  keep(`years')   `table_opts' `replacer' 
outreg2 using ${month_week_table}, tex(frag) label   keep(`months' `dow')  `table_opts' `replacer'




/*IV55:  IVs log-log condition factor with permit and dealer effects

Cannot include FY specific effects */
local modelname iv_log_condition2
local depvars lnrGDPcapita  ib5090.nespp4  i(5091 5092 5093 5094).nespp4#i0.mkt_shift  ib7.month  i.dow  i.fzone i.BSA lnmeancond_Annual lnstddevcond_Annual i.statecd
local endog lnq  lnpounds_allIMP
local excluded lnq_lag1 lnpounds_allIMP_lag1


ivreghdfe lnpriceR_GDPDEF  `depvars' (`endog' = `excluded') `ifconditional', absorb(permit dealnum) robust
est store iv_log2_condition

local table_opts addtext(Model,IV,Year effects, No, Month Effects, Yes, Vessel Effects, Yes, Dealer Effects, Yes)  ctitle("IV55 Log")
outreg2 using ${condition_table}, tex(frag) label adds(ll, e(ll), rmse, e(rmse))  drop(`months' `years' `dow' `states')   `table_opts' `replacer'



local regression_vars lnrGDPcapita lnmeancond_Annual lnstddevcond_Annual `months2' `dow' `sizes' `areas' `endog'  
foreach r of local regression_vars {
    post handle ("`modelname'")  ("`r'")  (_b[`r']) (_se[`r'])
}


local table_opts addtext(Model,IV,Year effects, Yes, Month Effects, Yes, Vessel Effects, Yes, Dealer Effects, Yes)  ctitle("IV55 Log")
outreg2 using ${linear_table3}, tex(frag) label adds(ll, e(ll), rmse, e(rmse))  drop(`months' `years' `dow' `states')  `table_opts' `replacer'
outreg2 using ${year_table}, tex(frag) label  keep(`years')   `table_opts' `replacer' 
outreg2 using ${month_week_table}, tex(frag) label   keep(`months' `dow')  `table_opts' `replacer'





/* IV56 IVs ihs and disaggregate the quantities */
local modelname iv_ihs
local depvars ihsrGDPcapita ib5090.nespp4  i(5091 5092 5093 5094).nespp4#i0.mkt_shift  ib7.month  i.dow i.year i.fzone i.BSA  i.statecd
local endog ihs_ownq ihs_other_landings          ihspounds_allIMP
local excluded ihs_other_landings_lag1 ihsownq_lag1         ihspounds_allIMP_lag1



ivreghdfe ihspriceR_GDPDEF  `depvars' (`endog' = `excluded') `ifconditional', absorb(permit dealnum) robust
est store iv_ihs

local replacer replace
local table_opts addtext(Model,IV,Year effects, No, Month Effects, Yes, Vessel Effects, Yes, Dealer Effects, Yes)  ctitle("IV56 IHS")
outreg2 using ${ihs_table}, tex(frag) label adds(ll, e(ll), rmse, e(rmse))  drop(`months2' `years' `dow' `states')   `table_opts' `replacer'
local replacer


local regression_vars ihsrGDPcapita  `months2' `dow' `sizes' `areas' `endog'  `years2'
foreach r of local regression_vars {
    post handle ("`modelname'")  ("`r'")  (_b[`r']) (_se[`r'])
}


local table_opts addtext(Model,IV,Year effects, Yes, Month Effects, Yes, Vessel Effects, Yes, Dealer Effects, Yes)  ctitle("IV56 IHS")
outreg2 using ${ihs_table}, tex(frag) label adds(ll, e(ll), rmse, e(rmse))  drop(`months' `years' `dow' `states')  `table_opts' `replacer'
outreg2 using ${ihsyear_table}, tex(frag) label  keep(`years')   `table_opts' `replacer' 
outreg2 using ${ihsmonth_week_table}, tex(frag) label   keep(`months' `dow')  `table_opts' `replacer'

 


/* IV57 IVs ihs with condition */
local modelname iv_ihs_cond
local depvars ihsrGDPcapita  ib5090.nespp4  i(5091 5092 5093 5094).nespp4#i0.mkt_shift  ib7.month  i.dow i.fzone i.BSA ihsmeancond_Annual ihsstddevcond_Annual i.statecd
local endog ihs_ownq ihs_other_landings          ihspounds_allIMP
local excluded ihs_other_landings_lag1 ihsownq_lag1         ihspounds_allIMP_lag1



ivreghdfe ihspriceR_GDPDEF  `depvars' (`endog' = `excluded') `ifconditional', absorb(permit dealnum) robust
est store iv_ihs

local table_opts addtext(Model,IV,Year effects, No, Month Effects, Yes, Vessel Effects, Yes, Dealer Effects, Yes)  ctitle("IV57 IHS")
outreg2 using ${ihs_table}, tex(frag) label adds(ll, e(ll), rmse, e(rmse))  drop(`months2' `years2' `dow' `states')   `table_opts' `replacer'
outreg2 using ${ihsyear_table}, tex(frag) label  keep(`years')   `table_opts' `replacer' 
outreg2 using ${ihsmonth_week_table}, tex(frag) label   keep(`months' `dow')  `table_opts' `replacer'

local replacer


local regression_vars ihsrGDPcapita ihsmeancond_Annual ihsstddevcond_Annual `months2' `dow' `sizes' `areas' `endog'  
foreach r of local regression_vars {
    post handle ("`modelname'")  ("`r'")  (_b[`r']) (_se[`r'])
}





postclose handle


/*IV58  IVs ihs with condition and dpi */
local modelname iv_ihs_dpi
local depvars ihsrealDPIcapita  ib5090.nespp4  i(5091 5092 5093 5094).nespp4#i0.mkt_shift  ib7.month  i.dow i.fzone i.BSA ihsmeancond_Annual ihsstddevcond_Annual i.statecd
local endog ihs_ownq ihs_other_landings          ihspounds_allIMP
local excluded ihs_other_landings_lag1 ihsownq_lag1         ihspounds_allIMP_lag1



ivreghdfe ihspriceR_GDPDEF  `depvars' (`endog' = `excluded') `ifconditional', absorb(permit dealnum) robust
est store iv_ihs_dpi

local table_opts addtext(Model,IV,Year effects, No, Month Effects, Yes, Vessel Effects, Yes, Dealer Effects, Yes)  ctitle("IV58 IHS Price")
outreg2 using ${ihs_table}, tex(frag) label adds(ll, e(ll), rmse, e(rmse))  drop(`months2' `years2' `dow' `states')  `table_opts' `replacer'




/* IV59 IVs ihs with condition and personal_income */
local modelname iv_ihs_pi
local depvars ihspersonal_income_capita  ib5090.nespp4  i(5091 5092 5093 5094).nespp4#i0.mkt_shift  ib7.month  i.dow i.fzone i.BSA ihsmeancond_Annual ihsstddevcond_Annual i.statecd
local endog ihs_ownq ihs_other_landings          ihspounds_allIMP
local excluded ihs_other_landings_lag1 ihsownq_lag1         ihspounds_allIMP_lag1



ivreghdfe ihspriceR_GDPDEF  `depvars' (`endog' = `excluded') `ifconditional', absorb(permit dealnum) robust
est store iv_ihs_pi

local table_opts addtext(Model,IV,Year effects, No, Month Effects, Yes, Vessel Effects, Yes, Dealer Effects, Yes)  ctitle("IV59 IHS Price")
outreg2 using ${ihs_table}, tex(frag) label adds(ll, e(ll), rmse, e(rmse))  drop(`months2' `years2' `dow' `states')  `table_opts' `replacer'
outreg2 using ${ihsyear_table}, tex(frag) label  keep(`years')   `table_opts' `replacer' 
outreg2 using ${ihsmonth_week_table}, tex(frag) label   keep(`months' `dow')  `table_opts' `replacer'




log close

