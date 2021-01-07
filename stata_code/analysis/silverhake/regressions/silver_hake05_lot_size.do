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
local logfile "silver_hake05_${vintage_string}.smcl"

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


global linear_table3 ${silverhake_tables}/silver_hake5.tex

global condition_table ${silverhake_tables}/silver_hake_condition5.tex
global ihs_table ${silverhake_tables}/silver_hake_ihs5.tex


global year_table ${silverhake_tables}/silver_hake_years5.tex
global month_week_table ${silverhake_tables}/silver_hake_month_week5.tex
global bse ${silverhake_tables}/bse5.dta


local  ster_out ${silverhake_results}/silver_hake05_${vintage_string}.ster 




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


local replacer1 replace
/*  MODEL IV445: Same as IV44 but I added  lot size, assumed exog.*/

/* IVs log-log  with permit and dealer effects; */
local modelname iv_log_fe`wtype'445
local depvars ib7.month  i.year  i.dow  i.fzone i.BSA  ib5090.nespp4  i(5091 5092 5093 5094).nespp4#i0.mkt_shift  i.USRECM  i.statecd lnaggregateV_R_GDPDEF c.ln_lot##c.ln_lot
local endog lnq  lnprice_allIMP_R_GDPDEF
local excluded lnq_lag1 lnprice_allIMP_lag1_R_GDPDEF


ivreghdfe lnpriceR_GDPDEF  `depvars' (`endog' = `excluded') `ifconditional' `weighted', absorb(permit dealnum) robust
est title: IV, Log-log, FE. No condition.
est store iv_log`wtype'445
est save `ster_out', `replacer1'

local table_opts addtext(Model,IV,Year effects, Yes, Month Effects, Yes, Vessel Effects, Yes, Dealer Effects, Yes) ctitle("IV445 Log") 

outreg2 using ${linear_table3}, tex(frag) label adds(ll, e(ll), rmse, e(rmse))  drop(`months' `years' `dow' `states') `table_opts' `replacer1'
outreg2 using ${year_table}, tex(frag) label  keep(`years')   `table_opts' `replacer1' 
outreg2 using ${month_week_table}, tex(frag) label   keep(`months' `dow')  `table_opts' `replacer1'


local replacer1 append

/*  MODEL IV455: Same as IV45 but I added  lot size, assumed exog.*/
local modelname iv_log_fe`wtype'455
local depvars ib7.month  i.year  i.dow  i.fzone i.BSA   ib5090.nespp4  i(5091 5092 5093 5094).nespp4#i0.mkt_shift  i.USRECM  i.statecd ln_aggregateL c.ln_lot##c.ln_lot
local endog lnq  lnprice_allIMP_R_GDPDEF
local excluded lnq_lag1 lnprice_allIMP_lag1_R_GDPDEF


ivreghdfe lnpriceR_GDPDEF  `depvars' (`endog' = `excluded') `ifconditional' `weighted', absorb(permit dealnum) robust
est title: IV, Log-log, FE. No condition.
est store iv_log`wtype'455
est save `ster_out', `replacer1'

local table_opts addtext(Model,IV,Year effects, Yes, Month Effects, Yes, Vessel Effects, Yes, Dealer Effects, Yes) ctitle("IV45 Log") 

outreg2 using ${linear_table3}, tex(frag) label adds(ll, e(ll), rmse, e(rmse))  drop(`months' `years' `dow' `states') `table_opts' `replacer1'
outreg2 using ${year_table}, tex(frag) label  keep(`years')   `table_opts' `replacer1' 
outreg2 using ${month_week_table}, tex(frag) label   keep(`months' `dow')  `table_opts' `replacer1'



/*  MODEL IV465: Same as IV46 but I added  lot size, assumed exog.   I'm assuming landings are endogenous to prices and instrumenting with 1 day lag .*/
local modelname iv_log_fe`wtype'465
local depvars ib7.month  i.year  i.dow  i.fzone i.BSA   ib5090.nespp4  i(5091 5092 5093 5094).nespp4#i0.mkt_shift  i.USRECM  i.statecd c.ln_lot##c.ln_lot
local endog lnq  lnprice_allIMP_R_GDPDEF ln_aggregateL
local excluded lnq_lag1 lnprice_allIMP_lag1_R_GDPDEF ln_aggregateL_lag1


ivreghdfe lnpriceR_GDPDEF  `depvars' (`endog' = `excluded') `ifconditional' `weighted', absorb(permit dealnum) robust
est title: IV, Log-log, FE. No condition.
est store iv_log`wtype'465
est save `ster_out', `replacer1'

local table_opts addtext(Model,IV,Year effects, Yes, Month Effects, Yes, Vessel Effects, Yes, Dealer Effects, Yes) ctitle("IV46 Log") 

outreg2 using ${linear_table3}, tex(frag) label adds(ll, e(ll), rmse, e(rmse))  drop(`months' `years' `dow' `states') `table_opts' `replacer1'
outreg2 using ${year_table}, tex(frag) label  keep(`years')   `table_opts' `replacer1' 
outreg2 using ${month_week_table}, tex(frag) label   keep(`months' `dow')  `table_opts' `replacer1'



/*  MODEL IV565: Same as IV46 but I added  lot size, assumed exog.   I'm assuming landed value are endogenous to prices and instrumenting with 1 day lag .*/
local modelname iv_log_fe`wtype'565
local depvars ib7.month  i.year  i.dow  i.fzone i.BSA   ib5090.nespp4  i(5091 5092 5093 5094).nespp4#i0.mkt_shift  i.USRECM  i.statecd c.ln_lot##c.ln_lot
local endog lnq  lnprice_allIMP_R_GDPDEF ln_aggregateV
local excluded lnq_lag1 lnprice_allIMP_lag1_R_GDPDEF ln_aggregateV_lag1


ivreghdfe lnpriceR_GDPDEF  `depvars' (`endog' = `excluded') `ifconditional' `weighted', absorb(permit dealnum) robust
est title: IV, Log-log, FE. No condition.
est store iv_log`wtype'565
est save `ster_out', `replacer1'

local table_opts addtext(Model,IV,Year effects, Yes, Month Effects, Yes, Vessel Effects, Yes, Dealer Effects, Yes) ctitle("IV46 Log") 

outreg2 using ${linear_table3}, tex(frag) label adds(ll, e(ll), rmse, e(rmse))  drop(`months' `years' `dow' `states') `table_opts' `replacer1'
outreg2 using ${year_table}, tex(frag) label  keep(`years')   `table_opts' `replacer1' 
outreg2 using ${month_week_table}, tex(frag) label   keep(`months' `dow')  `table_opts' `replacer1'





/***** ONCE YOU GET TO HERE, you should pick whether you want to include value or landings of all fish as a RHS value and go forward with it.*************************/



/*


/*  MODEL IV515 log -log with condition factors, permit and dealer effects. no year dummies */

local modelname iv_log_condition`wtype'
local depvars   ib7.month  i.USRECM i.dow  i.fzone i.BSA   ib5090.nespp4  i(5091 5092 5093 5094).nespp4#i0.mkt_shift  meancond_Annual stddevcond_Annual  i.statecd ln_lot
local endog lnq  lnprice_allIMP_R_GDPDEF
local excluded lnq_lag1 lnprice_allIMP_lag1_R_GDPDEF



ivreghdfe lnpriceR_GDPDEF  `depvars' (`endog' = `excluded') `ifconditional' `weighted', absorb(permit dealnum) robust
est title: IV, Log-log, no year effects. Condition in levels.

est store iv_log_condition`wtype'
est save `ster_out', `replacer1'

local table_opts addtext(Model,IV,Year effects, No, Month Effects, Yes, Vessel Effects, Yes, Dealer Effects, Yes) ctitle("IV515 Log") 

outreg2 using ${condition_table}, tex(frag) label adds(ll, e(ll), rmse, e(rmse))  drop(`months' `years' `dow' `states') `table_opts' replace


/*  MODEL IV52 log -log with log-condition factors, permit and dealer effects. no year dummies */

local modelname iv_log_condition2`wtype'
local depvars   ib7.month  i.USRECM  i.dow  i.fzone i.BSA   ib5090.nespp4  i(5091 5092 5093 5094).nespp4#i0.mkt_shift  lnmeancond_Annual lnstddevcond_Annual  i.statecd ln_lot

local endog lnq  lnprice_allIMP_R_GDPDEF
local excluded lnq_lag1 lnprice_allIMP_lag1_R_GDPDEF


ivreghdfe lnpriceR_GDPDEF  `depvars' (`endog' = `excluded') `ifconditional' `weighted', absorb(permit dealnum) robust
est title: IV, Log-log, no year effects. Condition in logs.

est store iv_log2_condition`wtype'
est save `ster_out', `replacer1'

local table_opts addtext(Model,IV,Year effects, No, Month Effects, Yes, Vessel Effects, Yes, Dealer Effects, Yes) ctitle("IV525 Log") 

outreg2 using ${condition_table}, tex(frag) label adds(ll, e(ll), rmse, e(rmse))  drop(`months' `years' `dow' `states') `table_opts' `replacer1'



/*  MODEL IV54 ihs where silver hake quantities are disaggregated. No quarterly income variable*/

local modelname iv_ihs`wtype'
local depvars   ib7.month  i.year i.USRECM  i.dow  i.fzone i.BSA   ib5090.nespp4  i(5091 5092 5093 5094).nespp4#i0.mkt_shift    i.statecd ln_lot

local endog ihs_ownq ihs_other_landings          ihsprice_allIMP_R_GDPDEF
local excluded ihs_other_landings_lag1 ihsownq_lag1         ihsimport_lag1


ivreghdfe ihspriceR_GDPDEF  `depvars' (`endog' = `excluded') `ifconditional' `weighted', absorb(permit dealnum) robust
est title: IV, IHS, year effects disaggregated quantities. 

est store iv_ihs2`wtype'
est save `ster_out', `replacer1'





/*  MODEL IV55:  Model 54 with condition*/

/* IVs ihs with condition */
local modelname iv_ihs_cond`wtype'
local depvars   ib7.month   i.USRECM i.dow  i.fzone i.BSA  ib5090.nespp4  i(5091 5092 5093 5094).nespp4#i0.mkt_shift  ihsmeancond_Annual ihsstddevcond_Annual  i.statecd

local endog ihs_ownq ihs_other_landings ihsprice_allIMP_R_GDPDEF
local excluded ihs_other_landings_lag1 ihsownq_lag1         ihsimport_lag1


ivreghdfe ihspriceR_GDPDEF  `depvars' (`endog' = `excluded') `ifconditional' `weighted', absorb(permit dealnum) robust
est title: IV, IHS, no year effects, disaggregated quantities, condition. 

est store iv_ihs_cond`wtype'
est save `ster_out', `replacer1'


local table_opts addtext(Model,IV,Year effects, No, Month Effects, Yes, Vessel Effects, Yes, Dealer Effects, Yes) ctitle("IV55 ihs") 

outreg2 using ${condition_table}, tex(frag) label adds(ll, e(ll), rmse, e(rmse))  drop(`months' `years' `dow' `states') `table_opts' `replacer1'



/*  MODEL IV56:  Model 53, but with condition   This facititates comparison with the model in logs. No quarterly income variable*/
local modelname iv_ihs_cond`wtype'
local depvars  ib7.month   i.USRECM i.dow  i.fzone i.BSA   ib5090.nespp4  i(5091 5092 5093 5094).nespp4#i0.mkt_shift  ihsmeancond_Annual ihsstddevcond_Annual  i.statecd

local endog  ihsq ihsprice_allIMP_R_GDPDEF
local excluded ihsq_lag1 ihsimport_lag1


ivreghdfe ihspriceR_GDPDEF  `depvars' (`endog' = `excluded') `ifconditional' `weighted', absorb(permit dealnum) robust
est title: IV, IHS, no year effects, aggregated quantities, condition. 

est store iv_ihs_cond`wtype'
est save `ster_out', `replacer1'


local table_opts addtext(Model,IV,Year effects, No, Month Effects, Yes, Vessel Effects, Yes, Dealer Effects, Yes) ctitle("IV55 ihs") 

outreg2 using ${condition_table}, tex(frag) label adds(ll, e(ll), rmse, e(rmse))  drop(`months' `years' `dow' `states') `table_opts' `replacer1'



*/









log close

