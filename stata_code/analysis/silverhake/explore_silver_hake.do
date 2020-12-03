/* code to examine quarterly prices, value, and macroeconomic */
version 15.1
pause on

vintage_lookup_and_reset

global silverhake_images ${my_images}/silverhake


local  in_data ${data_main}/dealer_prices_full_${vintage_string}.dta 
local  marketcats ${data_raw}/dealer_nespp4_codes${vintage_string}.dta 
local working_nespp3 509 


local  statecodes ${data_raw}/state_codes${vintage_string}.dta 

/* don't show year or month coeficients in outreg */
local months 1.month 2.month 3.month 4.month 5.month 6.month 7.month 8.month 9.month 10.month 11.month 12.month
local years 1995.year 1996.year 1997.year 1998.year 1999.year 2000.year 2001.year 2002.year 2003.year 2004.year 2005.year 2006.year 2007.year 2008.year 2009.year 2010.year 2011.year 2012.year 2013.year 2014.year 2015.year 2016.year 2017.year 2018.year 2019.year 2020.year
local dow 1.dow 2.dow 3.dow  4.dow  5.dow  6.dow 


use `in_data' if inlist(nespp3, `working_nespp3'), clear


/* pull in market categories*/

merge m:1 nespp4 using `marketcats', keep(1 3)
assert _merge==3
labmask nespp4, value(sp_mkt)
drop _merge


cap drop date
replace day=1 if day==0
gen date=mdy(month, day, year)
gen quarterly=qofd(date)
format quarterly %tq
/* Normalize */

preserve
collapse (sum) value valueR_GDPDEF landings (first) rGDPcapita personal_income_capita realDPIcapita fGDP ffresh_frozen fpreparedfish, by(year quarterly nespp4)

tsset nespp4 quarterly
gen priceR_GDPDEF=valueR_GDPDEF/landings
gen price=value/landings

twoway(tsline priceR if nespp4==5090) (tsline rGDPcapita realDPIcapita if nespp4==5090, yaxis(2)), legend(order(1 "Real Price" 2 "Real GDP/cap" 3 "real disposable pers income")) ytitle("Silver Hake Real Price(5090 Round)") tmtick(##5)
graph export ${silverhake_images}/silver_hake_5090macro.png, replace as(png)

twoway(tsline priceR if nespp4==5090) (tsline landings if nespp4==5090, yaxis(2)), legend(order(1 "Real Price" 2 "landings (000s)" )) ytitle("Silver Hake Real Price(5090 Round)") tmtick(##5)
graph export ${silverhake_images}/silver_hake_5090_pq.png, replace as(png)

twoway(tsline landings if nespp4==5090) (tsline rGDPcapita realDPIcapita if nespp4==5090, yaxis(2)), legend(order(1 "landings (000s)" 2 "Real GDP/cap" 3 "real disposable pers income")) ytitle("Silver Hake landings (5090 Round)") tmtick(##5)
graph export ${silverhake_images}/silver_hake_5090_qmacro.png, replace as(png)


xtline landings
graph export ${silverhake_images}/silver_hake_quarterly.png, replace as(png)

collapse (sum) value valueR_GDPDEF landings (first) rGDPcapita personal_income_capita realDPIcapita fGDP ffresh_frozen fpreparedfish, by(year quarterly)

tsset quarterly
gen priceR_GDPDEF=valueR_GDPDEF/landings
gen price=value/landings
twoway(tsline landings ) (tsline rGDPcapita realDPIcapita, yaxis(2)), legend(order(1 "landings (000s)" 2 "Real GDP/cap" 3 "real disposable pers income")) ytitle("All Silver Hake landings") tmtick(##5)
graph export ${silverhake_images}/silver_hake_qmacro.png, replace as(png)


twoway(tsline priceR ) (tsline rGDPcapita realDPIcapita, yaxis(2)), legend(order(1 "Real Price" 2 "Real GDP/cap" 3 "real disposable pers income")) ytitle("All Silver Hake prices") tmtick(##5)
graph export ${silverhake_images}/silver_hake_pmacro.png, replace as(png)

twoway(tsline priceR ) (tsline landings, yaxis(2)), legend(order(1 "Real Price" 2 "landings")) ytitle("All Silver Hake prices") tmtick(##5)
graph export ${silverhake_images}/silver_hake_pq.png, replace as(png)

restore

keep if nespp4==5090
gen priceR_GDPDEF=valueR_GDPDEF/landings
gen price=value/landings

graph box priceR, over(quarterly, label(angle(45))) nooutside


graph box priceR if quarterly<tq(2012q1), over(quarterly, label(format(%tq) angle(45))) nooutside cwhiskers lines(lwidth(none))
graph export ${silverhake_images}/silver_hake_early_box.png, replace as(png)


graph box priceR if quarterly>=tq(2012q1), over(quarterly, label(format(%tq) angle(45))) nooutside cwhiskers lines(lwidth(none))
graph export ${silverhake_images}/silver_hake_late_box.png, replace as(png)


/* landings by state over time */

gen statecd=floor(port/10000)
collapse (sum) landings value valueR_GDPDEF, by(state year)
label var landings "landings 000s "
merge m:1 statecd using `statecodes', keep(1 3)
assert _merge==3
drop _merge
gen priceR_GDPDEF=valueR_GDPDEF/landings

tsset statecd year
xtline priceR if inlist(stateabb,"VA","NC","DE","MD","ME","NH")==0
graph export ${silverhake_images}/silver_hake_state_prices.png, replace as(png)

xtline landings if inlist(stateabb,"VA","NC","DE","MD","ME","NH")==0
graph export ${silverhake_images}/silver_hake_state_landings.png, replace as(png)


bysort stateabb: egen tsl=total(landings)


graph bar (asis) landings, over(stateabb,sort(tsl)) over(year, label(angle(45))) stack asyvars legend(rows(3))
graph export ${silverhake_images}/silver_hake_stacked_bar.png, replace as(png)

bysort year: egen tl=total(landings)
gen share=landings/tl
graph bar (asis) share,  over(stateabb,sort(tsl)) over(year, label(angle(45))) stack asyvars legend(rows(3))
graph export ${silverhake_images}/silver_hake_share_stacked_bar.png, replace as(png)

