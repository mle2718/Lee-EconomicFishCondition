/* code to run some preliminary regressions on Silver Hake */
version 15.1
pause off

local  in_data ${data_main}/dealer_prices_real_lags_condition${vintage_string}.dta 
local  marketcats ${data_raw}/dealer_nespp4_codes${vintage_string}.dta 

global linear_table1 ${my_tables}/silver_hake1.tex

/* don't show year or month coeficients in outreg */
local months 1.month 2.month 3.month 4.month 5.month 6.month 7.month 8.month 9.month 10.month 11.month 12.month
local years 1995.year 1996.year 1997.year 1998.year 1999.year 2000.year 2001.year 2002.year 2003.year 2004.year 2005.year 2006.year 2007.year 2008.year 2009.year 2010.year 2011.year 2012.year 2013.year 2014.year 2015.year 2016.year 2017.year 2018.year 2019.year 2020.year
local dow 1.dow 2.dow 3.dow  4.dow  5.dow  6.dow 


clear
use `in_data', clear
cap drop _merge
keep if nespp3==509

/* pull in market categories*/

merge m:1 nespp4 using `marketcats', keep(1 3)
assert _merge==3
labmask nespp4, value(sp_mkt)
drop _merge



/* Normalize */
gen priceR_GDPDEF=valueR_GDPDEF/landings
gen ihspriceR=asinh(priceR_GDPDEF)
gen ihsrGDPcapita=asinh(rGDPcapita)

foreach var of varlist nominal_value_trade_noblueEXP nominal_value_trade_allEXP nominal_value_trade_noblueIMP nominal_value_trade_allIMP nominal_value_trade_noblueREX nominal_value_trade_allREX{
local newvar: subinstr local var "nominal_" ""
gen `newvar'R_GDPDEF=`var'/fGDP
}

gen import_priceR_GDPDEF=value_trade_allIMPR_GDPDEF/whiting_trade_all_poundsIMP

/********************************************************/
/********************************************************/
/* you really need to do more data cleaning and look at some descriptive statistics */
/********************************************************/
/********************************************************/

/* mark the estimation sample */
cap drop date
cap drop markin
gen date=mdy(month,day,year)

gen markin=1
replace markin=0 if date==.
replace markin=0 if price>8 
replace markin=0 if inlist(nespp4,5097)==1

local ifconditional "if markin==1"
cap drop _merge

/* Verify the merge worked properly. There will be some rows that do not match, because the day or month field =0 so date is broken.*/
/* there will also be a few rows that do not match because there are zero landings. */


/* don't estimate for invalid dates, prices that are too high, or 5097 market category*/



/* Some of these models aren't really well thought out. Here are some ideas for improvement.
We don't really want to estimate a full blown demand system (for whiting).  One specification allows the own-quantity and other-quantity effects to be different.
		However, another way to do it might be to group them into three groups: own, smaller-, and larger-sized

		
	We could allow the condition effects to vary across the market categories : c.meancond_Annual c.stddevcond_Annual)##ib5090.nespp4 
	I'm not sure how to interpret these either.
	
	
	*/




/* ols, absorbing various things */
reg price lnq rGDPcapita ib5090.nespp4 i.year `ifconditional', robust
pause
outreg2 using ${linear_table1}, tex(frag) label adds(ll, e(ll), rmse, e(rmse)) addtext(Year effects, Yes, Month Effects, No, Day of week effects, No, Vessel Effects, No,  Model, OLS) drop(`years') replace ctitle("Real Price")

reg price lnq rGDPcapita ib5090.nespp4 i.month  i.year  `ifconditional',robust
outreg2 using ${linear_table1}, tex(frag) label adds(ll, e(ll), rmse, e(rmse)) addtext(Year effects, Yes, Month Effects, Yes,  Day of week effects, No, Vessel Effects, No, Model, OLS) drop(`months' `years')  ctitle("Real Price")

reg price lnq rGDPcapita ib5090.nespp4 i.month  i.year  i.dow `ifconditional', robust
outreg2 using ${linear_table1}, tex(frag) label adds(ll, e(ll), rmse, e(rmse)) addtext(Year effects, Yes, Month Effects, Yes,  Day of week effects, Yes, Vessel Effects, No, Model, OLS) drop(`months' `years' `dow')  ctitle("Real Price")


areg price lnq rGDPcapita ib5090.nespp4 ib7.month  i.year i.dow  `ifconditional', absorb(permit) robust
outreg2 using ${linear_table1}, tex(frag) label adds(ll, e(ll), rmse, e(rmse)) addtext(Year effects, Yes, Month Effects, Yes, Vessel Effects, Yes, Model,OLS) drop(`months' `years' `dow')  ctitle("Real Price")


/*IV, using lag of quantities as an instrument */
ivregress 2sls price rGDPcapita ib5090.nespp4  i.year (lnq=lnq_lag1)  `ifconditional' , robust
outreg2 using ${linear_table1}, tex(frag) label adds(rmse, e(rmse)) addtext(Year effects, Yes, Month Effects, No,  Day of week effects, No, Model, IV) drop(`years')  ctitle("Real Price")

ivregress 2sls price rGDPcapita ib5090.nespp4 i.month  i.year (lnq=lnq_lag1)  `ifconditional',robust
outreg2 using ${linear_table1}, tex(frag) label adds(rmse, e(rmse)) addtext(Year effects, Yes, Month Effects, Yes,  Day of week effects, No, Model, IV) drop(`months' `years')  ctitle("Real Price")
 
 
 
/* try the IV model using the inverse hyperbolic sin transform */
 ivregress 2sls price ihsrGDPcapita ib5090.nespp4  i.year (ihs_ownq ihs_other_landings=ihsownq_lag1 ihs_other_landings_lag1)  `ifconditional', cluster(date)

 *outreg2 using ${linear_table1}, tex(frag) label adds(rmse, e(rmse)) addtext(Year effects, Yes, Month Effects, No, Model, IV) drop(`years')  ctitle("Real Price")

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
  
  
  /* can't put in GDPcapita AND quarterly dummies */
    ivregress 2sls ihspriceR ib5090.nespp4  i.quarterly i.dow (ihs_ownq ihs_other_landings=ihsownq_lag1 ihs_other_landings_lag1)  `ifconditional', cluster(date)
  est store QuarterlyDums

  
    ivregress 2sls ihspriceR ihsrGDPcapita ib5090.nespp4  i.qtr i.dow (ihs_ownq ihs_other_landings=ihsownq_lag1 ihs_other_landings_lag1)  `ifconditional', cluster(date)
  est store QtrDums

  
  est table YearDums YearMonthDums Pooled YearQtrDums QtrDums QuarterlyDums, keep( ihsrGDPcapita ihs_ownq ihs_other_landings 5091.nespp4 5092.nespp4 5093.nespp4 5094.nespp4 5095.nespp4 5096.nespp4) b p

  
  
    est table YearDums YearMonthDums Pooled YearQtrDums QtrDums QuarterlyDums, drop( ihsrGDPcapita ihs_ownq ihs_other_landings  5091.nespp4 5092.nespp4 5093.nespp4 5094.nespp4 5095.nespp4 5096.nespp4) b p

	
	
/*models with condition factor */
 
 ivregress 2sls price rGDPcapita ib5090.nespp4  i.month meancond_Annual stddevcond_Annual (lnq=lnq_lag1)  `ifconditional' , robust
est store IVcondition
 
 
  ivregress 2sls ihspriceR ihsrGDPcapita ib5090.nespp4   meancond_Annual stddevcond_Annual import_priceR_GDPDEF i.dow (ihs_ownq ihs_other_landings=ihsownq_lag1 ihs_other_landings_lag1)  `ifconditional', cluster(date)
est store IHScondition


  ivregress 2sls price rGDPcapita ib5090.nespp4##(c.meancond_Annual c.stddevcond_Annual) import_priceR_GDPDEF i.dow (own4landings other_landings=ownq_lag1 other_landings_lag1)   `ifconditional', cluster(date)
est store LEVELcondition
