/* code to explore annual_condition_EPU data  */
cap log close


local logfile "exploratory_conditionEPU_${vintage_string}.smcl"
global common_results ${my_results}/common
global common_tables ${my_tables}/common
global common_images ${my_images}/common

log using ${common_results}/`logfile', replace




version 15.1
pause on
timer on 1


/* files for Relative condition data, which one are you using?*/
local  in_relcond ${data_raw}/annual_condition_indexEPU_${vintage_string}.dta 
local  in_relcond_leng ${data_raw}/annual_condition_indexEPU_length_${vintage_string}.dta 
local in_relcond_Year ${data_raw}/annual_condition_index_${vintage_string}.dta 


local prices ${data_raw}/annual_nespp4_${vintage_string}.dta 
local deflators $data_external/deflatorsY_${vintage_string}.dta
/* bring in deflators and construct real compensation */

/* unconditional */
local outfile explore_price_condition_${vintage_string}.dta
local regress_out price_condition_reg.tex

/* control for quantities */
local outfile2 explore_price_condition2_${vintage_string}.dta
local regress_out2 price_condition_reg2.tex


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



/* This has Male and Female */
/* try graphs of the fish condition (at the EPU) against annual prices (for the species ) */





use  `in_relcond',clear
cap drop _merge

/* multiple obs per fish */

egen group_id=group(species sex epu), lname(species_sex_epu)
bysort group_id: gen N=_N
tsset group_id year

egen t=tag(group_id)
browse if t==1 & N<=27
tsfill, full
bysort group_id: replace svspp=l1.svspp if svspp==.
bysort group_id: replace nespp3=nespp3[_n-1] if nespp3==.
bysort group_id: replace species=species[_n-1] if strmatch(species,"")
bysort group_id: replace epu=epu[_n-1] if strmatch(epu,"")
bysort group_id: replace sex=sex[_n-1] if strmatch(sex,"")



bysort group_id: replace svspp=F1.svspp if svspp==.
bysort group_id: replace nespp3=nespp3[_n+1] if nespp3==.
bysort group_id: replace species=species[_n+1] if strmatch(species,"")
bysort group_id: replace epu=epu[_n+1] if strmatch(epu,"")
bysort group_id: replace sex=sex[_n+1] if strmatch(sex,"")



bysort group_id: replace ncond_EPU=0 if ncond_EPU==. 

browse if meancond==.

labmask svspp, values(species)
labmask nespp3, values(species)
/*
gen upper=meancond+stddev
gen lower=meancond-stddev
*/
bysort group_id: egen mm=mean(meancond) 
replace mm=. if meancond==.
label var mm "mean condition over time series"
/* exclude Ocean Pout, Spotted Hake, Sea Raven, */
local excludelist 250, 344, 366, 370, 662

xtline meancond  mm if inlist(nespp3, `excludelist')==0 , tmtick(##5) cmissing(n)


graph export ${common_images}/fish_conditions_epu_sex_${vintage_string}.png, replace as(png)  width(2000)


gen del=10*(meancond-mm)/mm
xtline del if inlist(nespp3, `excludelist')==0 , tmtick(##5) cmissing(n)
graph export ${common_images}/delta_conditions_epu_sex${vintage_string}.png, replace as(png)  width(2000)

merge m:1 nespp3 year using `p2', keep(1 3)

pause

local ex2: subinstr local excludelist "," "", all

levelsof nespp3, local(mysp)
local mysp : list mysp - ex2
foreach l of local mysp{
	preserve
	keep if nespp3==`l'

	local graphopts tmtick(##5) cmissing(n) legend(order( 1 "deviations in condition factor" 2 "deviations in real prices"))
	capture xtline del delp, `graphopts'

	capture graph export xtline_EPU_sex_`l'_${vintage_string}.png, replace as(png) width(2000)
	
	restore
}






log close




