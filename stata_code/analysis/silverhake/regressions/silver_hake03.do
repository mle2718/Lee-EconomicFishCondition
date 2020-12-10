/* code to run some preliminary regressions on Silver Hake. Regressions here have a better chance of being well specified compared to silver_hake01.do and silver_hake02.do 
Most of the models here use IVREGHDFE to condition out "many" fixed effects. 


Differences from silver_hake02
	Exclude permit=0 and dealnum=0 from the dataset
	
	Exclude fzone==4
	Exclude landings in ("DE", "PA","NK")
	
	Include our recession dummy variable. USRECM

	account for shifts in the market categories in 2004
	
	
	I set up some functionality to handle a weighted regression. 
*/
cap log close

vintage_lookup_and_reset
local logfile "silver_hake03_${vintage_string}.smcl"

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


global linear_table3 ${silverhake_tables}/silver_hake3A.tex

global condition_table ${silverhake_tables}/silver_hake_conditionA.tex
global ihs_table ${silverhake_tables}/silver_hake_ihsA.tex


global year_table ${silverhake_tables}/silver_hake_yearsA.tex
global month_week_table ${silverhake_tables}/silver_hake_month_weekA.tex
global bse ${silverhake_tables}/bseA.dta


local  ster_out ${silverhake_results}/silver_hake03_${vintage_string}.ster 




/* don't show year or month coeficients in outreg */
local months 1.month 2.month 3.month 4.month 5.month 6.month 7.month 8.month 9.month 10.month 11.month 12.month 0.month 0b.month 12o.month
local years 1995.year 1996.year 1997.year 1998.year 1999.year 2000.year 2001.year 2002.year 2003.year 2004.year 2005.year 2006.year 2007.year 2008.year 2009.year 2010.year 2011.year 2012.year 2013.year 2014.year 2015.year 2016.year 2017.year 2018.year 2019.year 2020.year
local dow 1.dow 2.dow 3.dow  4.dow  5.dow  6.dow 
local sizes 5091.nespp4 5092.nespp4  5093.nespp4  5094.nespp4  5095.nespp4  5096.nespp4 

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
label var lnq "Log Daily Landings"
label var daily_landings "Daily Landings"

label var lnprice_allIMP_R_GDPDEF "Log Real Import Price"
label var lnrGDPcapita "Log Real GDP cap"
label var rGDPcapita "Real GDP cap"

label var price_allIMP_R_GDPDEF "Real Import Price"
/**************************************************/

gen mkt_shift=date>=mdy(1,1,2004)

/*  MODEL IV41: Same as IV31, but added indicators for state.  Should have been there all along.*/
local modelname iv_log_fe`wtype'
local replacer1 replace
local depvars lnrGDPcapita ib7.month  i.year  i.dow  i.fzone i.BSA  ib5090.nespp4##i.mkt_shift i.USRECM  i.statecd
local endog lnq  lnprice_allIMP_R_GDPDEF
local excluded lnq_lag1 lnprice_allIMP_lag1_R_GDPDEF


ivreghdfe lnpriceR_GDPDEF  `depvars' (`endog' = `excluded') `ifconditional' `weighted', absorb(permit dealnum) robust
est title: IV, Log-log, FE. No condition.
est store iv_log`wtype'
est save `ster_out', `replacer1'
local replacer1 append



/*  MODEL IV42: Same as IV41, but I added in quarterly landings as an extra explanatory variable I wanted to see if this was explaining prices.*/


/* IVs log-log  with permit and dealer effects; */
local modelname iv_log_fe`wtype'2
local depvars lnrGDPcapita ib7.month  i.year  i.dow  i.fzone i.BSA  ib5090.nespp4##i.mkt_shift i.USRECM  i.statecd lnql
local endog lnq  lnprice_allIMP_R_GDPDEF
local excluded lnq_lag1 lnprice_allIMP_lag1_R_GDPDEF


ivreghdfe lnpriceR_GDPDEF  `depvars' (`endog' = `excluded') `ifconditional' `weighted', absorb(permit dealnum) robust
est title: IV, Log-log, FE. No condition.
est store iv_log`wtype'2
est save `ster_out', `replacer1'




/*  MODEL IV43: Same as IV42, but I took out the income effect.*/

/* IVs log-log  with permit and dealer effects; */
local modelname iv_log_fe`wtype'3
local depvars ib7.month  i.year  i.dow  i.fzone i.BSA  ib5090.nespp4##i.mkt_shift i.USRECM  i.statecd lnql
local endog lnq  lnprice_allIMP_R_GDPDEF
local excluded lnq_lag1 lnprice_allIMP_lag1_R_GDPDEF


ivreghdfe lnpriceR_GDPDEF  `depvars' (`endog' = `excluded') `ifconditional' `weighted', absorb(permit dealnum) robust
est title: IV, Log-log, FE. No condition.
est store iv_log`wtype'3
est save `ster_out', `replacer1'




/*  MODEL IV44: Same as IV43 but I added in log of aggregate value of landed fish.  I'm assuming this is exogenous to the price of whiting.*/

/* IVs log-log  with permit and dealer effects; */
local modelname iv_log_fe`wtype'4
local depvars ib7.month  i.year  i.dow  i.fzone i.BSA  ib5090.nespp4##i.mkt_shift i.USRECM  i.statecd lnaggregateV_R_GDPDEF
local endog lnq  lnprice_allIMP_R_GDPDEF
local excluded lnq_lag1 lnprice_allIMP_lag1_R_GDPDEF


ivreghdfe lnpriceR_GDPDEF  `depvars' (`endog' = `excluded') `ifconditional' `weighted', absorb(permit dealnum) robust
est title: IV, Log-log, FE. No condition.
est store iv_log`wtype'4
est save `ster_out', `replacer1'



/*  MODEL IV45: Same as IV44 but I added in log of aggregate daily landings (quantities).  I'm assuming this is exogenous to the price of whiting.*/
local modelname iv_log_fe`wtype'5
local depvars ib7.month  i.year  i.dow  i.fzone i.BSA  ib5090.nespp4##i.mkt_shift i.USRECM  i.statecd ln_aggregateL 
local endog lnq  lnprice_allIMP_R_GDPDEF
local excluded lnq_lag1 lnprice_allIMP_lag1_R_GDPDEF


ivreghdfe lnpriceR_GDPDEF  `depvars' (`endog' = `excluded') `ifconditional' `weighted', absorb(permit dealnum) robust
est title: IV, Log-log, FE. No condition.
est store iv_log`wtype'5
est save `ster_out', `replacer1'


/*  MODEL IV46: Same as IV45 but I'm assuming landings are endogenous to prices and instrumenting with 1 day lag .*/
local modelname iv_log_fe`wtype'6
local depvars ib7.month  i.year  i.dow  i.fzone i.BSA  ib5090.nespp4##i.mkt_shift i.USRECM  i.statecd  
local endog lnq  lnprice_allIMP_R_GDPDEF ln_aggregateL
local excluded lnq_lag1 lnprice_allIMP_lag1_R_GDPDEF ln_aggregateL_lag1


ivreghdfe lnpriceR_GDPDEF  `depvars' (`endog' = `excluded') `ifconditional' `weighted', absorb(permit dealnum) robust
est title: IV, Log-log, FE. No condition.
est store iv_log`wtype'5
est save `ster_out', `replacer1'



/*  MODEL IV47: Similar to IV41 but no ermit - dealer- fixed effects */


local modelname iv_log_nofe`wtype'

local depvars lnrGDPcapita ib7.month  i.year  i.dow  i.fzone i.BSA  ib5090.nespp4##i.mkt_shift i.USRECM  i.statecd

local endog lnq  lnprice_allIMP_R_GDPDEF
local excluded lnq_lag1 lnprice_allIMP_lag1_R_GDPDEF

ivreg2 lnpriceR_GDPDEF  `depvars' (`endog' = `excluded') `ifconditional' `weighted', robust
est title: IV, Log-log, No FE. No condition.

est store iv_log_nofe`wtype'

est save `ster_out', `replacer1'


/*  MODEL IV48: Similar to IV47 but no income effects */

local modelname iv_log_nofe`wtype'

local depvars ib7.month  i.year  i.dow  i.fzone i.BSA  ib5090.nespp4##i.mkt_shift i.USRECM  i.statecd

local endog lnq  lnprice_allIMP_R_GDPDEF
local excluded lnq_lag1 lnprice_allIMP_lag1_R_GDPDEF

ivreg2 lnpriceR_GDPDEF  `depvars' (`endog' = `excluded') `ifconditional' `weighted', robust
est title: IV, Log-log, No FE. No condition.

est store iv_log_nofe_noinc`wtype'

est save `ster_out', `replacer1'






/*  MODEL IV49: Similar to IV41 but no income effects */

local modelname iv_log_fe`wtype'
local depvars  ib7.month  i.year  i.dow  i.fzone i.BSA  ib5090.nespp4##i.mkt_shift i.USRECM  i.statecd
local endog lnq  lnpounds_allIMP
local excluded lnq_lag1 lnpounds_allIMP_lag1



ivreghdfe lnpriceR_GDPDEF  `depvars' (`endog' = `excluded') `ifconditional' `weighted', absorb(permit dealnum) robust
est title: IV, Log-log, import pounds on RHS.
est store iv_logQ`wtype'
est save `ster_out', `replacer1'
local replacer1 append




/* i should probably stop estimating OLS models */
/*  MODEL OLS40 log-log  is okay-ish; */
local modelname ols_log_fe`wtype'
local depvars  lnq  lnprice_allIMP_R_GDPDEF ib7.month  i.year  i.dow  i.fzone i.BSA  ib5090.nespp4##i.mkt_shift i.USRECM  i.statecd
reghdfe lnpriceR_GDPDEF `depvars' `ifconditional' `weighted', absorb(permit dealnum) vce(robust)
est title: least squares, Log-log, FE. No condition.

est store ols_log`wtype'
est save `ster_out', `replacer1'


/*  MODEL OLS41 linear */
local modelname ols_linear_fe`wtype'
local depvars daily_landings  price_allIMP_R_GDPDEF ib7.month  i.year  i.dow  i.fzone i.BSA  ib5090.nespp4##i.mkt_shift i.USRECM  i.statecd
reghdfe priceR_GDPDEF `depvars' `ifconditional' `weighted', absorb(permit dealnum) vce(robust)
est title: IV, linear , FE. No condition.

est store ols`wtype'
est save `ster_out', `replacer1'

/* linear IV
The linear model is poorly scaled  - problem seems to be worst when I include permit + Dealer FEs in a weighted regression.  It goes away when I don't have any permit FE's in a non-weighted regression.
*/
local modelname iv_linear_fe`wtype'
local depvars   ib7.month  i.year  i.dow  i.fzone i.BSA  ib5090.nespp4##i.mkt_shift i.USRECM  i.statecd
local endog daily_landings price_allIMP_R_GDPDEF
local excluded q_lag1 price_allIMP_lag1_R_GDPDEF
ivreghdfe priceR_GDPDEF     `depvars' (`endog' = `excluded') `ifconditional' `weighted', absorb(permit dealnum) robust
est title: IV, linear, FE. No condition.

est store iv_linear`wtype'
est save `ster_out', `replacer1'






/*  MODEL IV51 log -log with condition factors, permit and dealer effects. no year dummies */

local modelname iv_log_condition`wtype'
local depvars   ib7.month  i.USRECM i.dow  i.fzone i.BSA  ib5090.nespp4##i.mkt_shift meancond_Annual stddevcond_Annual  i.statecd
local endog lnq  lnprice_allIMP_R_GDPDEF
local excluded lnq_lag1 lnprice_allIMP_lag1_R_GDPDEF



ivreghdfe lnpriceR_GDPDEF  `depvars' (`endog' = `excluded') `ifconditional' `weighted', absorb(permit dealnum) robust
est title: IV, Log-log, no year effects. Condition in levels.

est store iv_log_condition`wtype'
est save `ster_out', `replacer1'



/*  MODEL IV52 log -log with log-condition factors, permit and dealer effects. no year dummies */


local modelname iv_log_condition2`wtype'
local depvars   ib7.month  i.USRECM  i.dow  i.fzone i.BSA  ib5090.nespp4##i.mkt_shift lnmeancond_Annual lnstddevcond_Annual  i.statecd

local endog lnq  lnprice_allIMP_R_GDPDEF
local excluded lnq_lag1 lnprice_allIMP_lag1_R_GDPDEF


ivreghdfe lnpriceR_GDPDEF  `depvars' (`endog' = `excluded') `ifconditional' `weighted', absorb(permit dealnum) robust
est title: IV, Log-log, no year effects. Condition in logs.

est store iv_log2_condition`wtype'
est save `ster_out', `replacer1'



/*  MODEL IV52 ihs where silver hake quantities are aggregated together. This facititates comparison with the model in logs. No quarterly income variable*/
local modelname iv_ihs`wtype'
local depvars   ib7.month  i.year i.USRECM  i.dow  i.fzone i.BSA  ib5090.nespp4##i.mkt_shift  i.statecd

local endog ihsq ihsprice_allIMP_R_GDPDEF
local excluded ihsq_lag1 ihsimport_lag1


ivreghdfe ihspriceR_GDPDEF  `depvars' (`endog' = `excluded') `ifconditional' `weighted', absorb(permit dealnum) robust
est title: IV, IHS, year effects. 

est store iv_ihs1`wtype'
est save `ster_out', `replacer1'


/*  MODEL IV53 ihs where silver hake quantities are disaggregated. No quarterly income variable*/

local modelname iv_ihs`wtype'
local depvars   ib7.month  i.year i.USRECM  i.dow  i.fzone i.BSA  ib5090.nespp4##i.mkt_shift   i.statecd

local endog ihs_ownq ihs_other_landings          ihsprice_allIMP_R_GDPDEF
local excluded ihs_other_landings_lag1 ihsownq_lag1         ihsimport_lag1


ivreghdfe ihspriceR_GDPDEF  `depvars' (`endog' = `excluded') `ifconditional' `weighted', absorb(permit dealnum) robust
est title: IV, IHS, year effects disaggregated quantities. 

est store iv_ihs2`wtype'
est save `ster_out', `replacer1'





/*  MODEL IV54:  Model 53 with condition*/

/* IVs ihs with condition */
local modelname iv_ihs_cond`wtype'
local depvars   ib7.month   i.USRECM i.dow  i.fzone i.BSA  ib5090.nespp4##i.mkt_shift  ihsmeancond_Annual ihsstddevcond_Annual  i.statecd

local endog ihs_ownq ihs_other_landings ihsprice_allIMP_R_GDPDEF
local excluded ihs_other_landings_lag1 ihsownq_lag1         ihsimport_lag1


ivreghdfe ihspriceR_GDPDEF  `depvars' (`endog' = `excluded') `ifconditional' `weighted', absorb(permit dealnum) robust
est title: IV, IHS, no year effects, disaggregated quantities, condition. 

est store iv_ihs_cond`wtype'
est save `ster_out', `replacer1'





/*  MODEL IV54:  Model 52, but with condition   This facititates comparison with the model in logs. No quarterly income variable*/
local modelname iv_ihs_cond`wtype'
local depvars  ib7.month   i.USRECM i.dow  i.fzone i.BSA  ib5090.nespp4##i.mkt_shift  ihsmeancond_Annual ihsstddevcond_Annual  i.statecd

local endog  ihsq ihsprice_allIMP_R_GDPDEF
local excluded ihsq_lag1 ihsimport_lag1


ivreghdfe ihspriceR_GDPDEF  `depvars' (`endog' = `excluded') `ifconditional' `weighted', absorb(permit dealnum) robust
est title: IV, IHS, no year effects, aggregated quantities, condition. 

est store iv_ihs_cond`wtype'
est save `ster_out', `replacer1'















log close

