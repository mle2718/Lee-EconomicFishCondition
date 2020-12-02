/* code to merge in fish condition data  */




version 15.1
pause off

timer on 1

vintage_lookup_and_reset

/* files for Relative condition data, which one are you using?*/
local  in_relcond ${data_raw}/annual_condition_indexEPU_${vintage_string}.dta 
local  in_relcond_leng ${data_raw}/annual_condition_indexEPU_length_${vintage_string}.dta 
local in_relcond_Year ${data_raw}/annual_condition_index_${vintage_string}.dta 


local prices ${data_raw}/annual_nespp4_${vintage_string}.dta 
local deflators $data_external/deflatorsY_${vintage_string}.dta
/* bring in deflators and construct real compensation */



use `prices', clear

collapse (sum) landings value, by(nespp3 year)
merge m:1 year using `deflators', keep(1 3)
assert _merge==3
drop _merge

gen valueR_GDPDEF=value/fGDP

gen priceR_GDPDEF=valueR_GDPDEF/landings

bysort nespp3: egen pbar=mean(priceR_GDPDEF)
gen delp=(priceR_GDPDEF-pbar)/pbar
tempfile p2
save `p2'



use  `in_relcond_Year',clear
bysort nespp3: gen N=_N
tsset nespp3 year

egen t=tag(nespp3)
browse if t==1 & N<=27
tsfill, full
bysort nespp3: replace svspp=l1.svspp if svspp==.
bysort nespp3: replace species=species[_n-1] if strmatch(species,"")
browse if meancond==.

labmask svspp, values(species)
labmask nespp3, values(species)

gen upper=meancond+stddev
gen lower=meancond-stddev

bysort nespp3: egen mm=mean(meancond) 
replace mm=. if meancond==.
label var mm "mean condition over time series"
xtline meancond  mm if nespp3~=344, tmtick(##5) cmissing(n)
graph export ${my_images}/fish_conditions.png, replace as(png)  width(2000)


gen del=10*(meancond-mm)/mm
xtline del, tmtick(##5) cmissing(n)
graph export ${my_images}/delta_conditions.png, replace as(png)  width(2000)

merge 1:m nespp3 year using `p2'

xtline del delp, tmtick(##5) cmissing(n) legend(order( 1 "deviations in condition factor" 2 "deviations in real prices"))
graph export ${my_images}/delta_conditions_and_prices.png, replace as(png) width(2000)

scatter delp del if inlist(nespp3, 250, 366)==0, ytitle("Deviation in real prices" ) xtitle("Deviations in condition factor")
graph export ${my_images}/scatter_conditions_and_prices.png, replace as(png) width(2000)
