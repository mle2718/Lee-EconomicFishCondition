

cap log close

global working_nespp3 509
local  in_data ${data_main}/dealer_prices_final_spp_${working_nespp3}_${vintage_string}.dta 
use `in_data' , clear

gen nominal=value/landings
gen qtr=qofd(date)
format qtr %tq

gen markin=1
replace markin=0 if date==.
replace markin=0 if inlist(nespp4,5097)==1
replace markin=0 if nominal>8 
replace markin=0 if nominal<=0
replace markin=0 if fzone==4

keep if markin==1
collapse (sum) valueR_GDP value landings (first) rGDPcapita realDPIcapita , by(year qtr nespp4)

gen priceR_GDPDEF=valueR_GDPDEF/landings




tsset nespp4 qtr
format qtr %tq
gen quarter=quarter(dofq(qtr))
xtline priceR_GDPDEF rGDPcapita
gen lnp=ln(priceR)
gen lnI=ln(rGDPc)
twoway (lfit priceR_GDPDEF qtr if nespp4==5090) (tsline priceR_GDPDEF if nespp4==5090) (lfit lnI qtr if nespp4==5090,yaxis(2)) (tsline lnI if nespp4==5090, yaxis(2)), legend(order( 2 "Price" 4 "Log GDPc")) ytitle("price") ytitle("Log Income", axis(2))
graph export ${silverhake_images}/quarterly_Ptrends_5090_${vintage_string}.png, replace as(png)

twoway (lfit priceR_GDPDEF qtr if nespp4==5091) (tsline priceR_GDPDEF if nespp4==5091) (lfit lnI qtr if nespp4==5090,yaxis(2)) (tsline lnI if nespp4==5090, yaxis(2)), legend(order( 2 "Price" 4 "Log GDPc")) ytitle("price") ytitle("Log Income", axis(2))
graph export ${silverhake_images}/quarterly_Ptrends_5091_${vintage_string}.png, replace as(png)

twoway (lfit priceR_GDPDEF qtr if nespp4==5092) (tsline priceR_GDPDEF if nespp4==5092) (lfit lnI qtr if nespp4==5090,yaxis(2)) (tsline lnI if nespp4==5090, yaxis(2)), legend(order( 2 "Price" 4 "Log GDPc")) ytitle("price") ytitle("Log Income", axis(2))
graph export ${silverhake_images}/quarterly_Ptrends_5092_${vintage_string}.png, replace as(png)

twoway (lfit priceR_GDPDEF qtr if nespp4==5095) (tsline priceR_GDPDEF if nespp4==5095) (lfit lnI qtr if nespp4==5090,yaxis(2)) (tsline lnI if nespp4==5090, yaxis(2)), legend(order( 2 "Price" 4 "Log GDPc")) ytitle("price") ytitle("Log Income", axis(2))
graph export ${silverhake_images}/quarterly_Ptrends_5095_${vintage_string}.png, replace as(png)

twoway (lfit priceR_GDPDEF qtr if nespp4==5096) (tsline priceR_GDPDEF if nespp4==5096) (lfit lnI qtr if nespp4==5090,yaxis(2)) (tsline lnI if nespp4==5090, yaxis(2)), legend(order( 2 "Price" 4 "Log GDPc")) ytitle("price") ytitle("Log Income", axis(2))
graph export ${silverhake_images}/quarterly_Ptrends_5096_${vintage_string}.png, replace as(png)


twoway (lfit landings qtr if nespp4==5090) (tsline landings if nespp4==5090) (lfit lnI qtr if nespp4==5090,yaxis(2)) (tsline lnI if nespp4==5090, yaxis(2)), legend(order( 2 "Price" 4 "Log GDPc")) ytitle("price") ytitle("Log Income", axis(2))
graph export ${silverhake_images}/quarterly_Qtrends_5090_${vintage_string}.png, replace as(png)

twoway (lfit landings qtr if nespp4==5091) (tsline landings if nespp4==5091) (lfit lnI qtr if nespp4==5090,yaxis(2)) (tsline lnI if nespp4==5090, yaxis(2)), legend(order( 2 "Price" 4 "Log GDPc")) ytitle("price") ytitle("Log Income", axis(2))
graph export ${silverhake_images}/quarterly_Qtrends_5091_${vintage_string}.png, replace as(png)

twoway (lfit landings qtr if nespp4==5092) (tsline landings if nespp4==5092) (lfit lnI qtr if nespp4==5090,yaxis(2)) (tsline lnI if nespp4==5090, yaxis(2)), legend(order( 2 "Price" 4 "Log GDPc")) ytitle("price") ytitle("Log Income", axis(2))
graph export ${silverhake_images}/quarterly_Qtrends_5092_${vintage_string}.png, replace as(png)


twoway (lfit landings qtr if nespp4==5095) (tsline landings if nespp4==5095) (lfit lnI qtr if nespp4==5090,yaxis(2)) (tsline lnI if nespp4==5090, yaxis(2)), legend(order( 2 "Price" 4 "Log GDPc")) ytitle("price") ytitle("Log Income", axis(2))
graph export ${silverhake_images}/quarterly_Qtrends_5095_${vintage_string}.png, replace as(png)

twoway (lfit landings qtr if nespp4==5096) (tsline landings if nespp4==5096) (lfit lnI qtr if nespp4==5090,yaxis(2)) (tsline lnI if nespp4==5090, yaxis(2)), legend(order( 2 "Price" 4 "Log GDPc")) ytitle("price") ytitle("Log Income", axis(2))
graph export ${silverhake_images}/quarterly_Qtrends_5096_${vintage_string}.png, replace as(png)

preserve
keep if nespp4==5090

bysort year: egen ybar=mean(rGDPcapita)
bysort quarter: egen mbar=mean(rGDPcapita)

egen gm=mean(rGDPcapita)
gen dm2=rGDPcapita-ybar-mbar+gm
gen devY=rGDPcapita-ybar
gen devM=rGDPcapita-mbar




bysort year: egen Pybar=mean(priceR_GDPDEF)
bysort quarter: egen Pmbar=mean(priceR_GDPDEF)

egen Pgm=mean(priceR_GDPDEF)
gen Pdm2=priceR_GDPDEF-Pybar-Pmbar+Pgm

gen PdevY=priceR_GDPDEF-Pybar
gen PdevM=priceR_GDPDEF-Pmbar


twoway (tsline Pdm2  if nespp4==5090) (tsline dm2 if nespp4==5090, yaxis(2)), legend(order( 1 "Demeaned Price" 2 "Demeaned Income")) ytitle("price") ytitle("Income", axis(2))
graph export ${silverhake_images}/quarterly_demeanedPrends_5090_${vintage_string}.png, replace as(png)


restore
