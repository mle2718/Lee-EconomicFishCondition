/* code to construct/merge the annual fish condition data */




version 15.1
pause off

timer on 1

/* files for Relative condition data */
local in_relcond ${data_external}/RelCond2019_EPU.csv
local in_relcond_leng ${data_external}/RelCond2019_EPU_length.csv
local in_relcond_Year ${data_external}/RelCond2019_Year.csv

local codes ${data_raw}/dealer_nespp4_codes${vintage_string}.dta 
local  out_dataYear ${data_raw}/annual_condition_index_${vintage_string}.dta 
local  out_dataEPUYear ${data_raw}/annual_condition_indexEPU_${vintage_string}.dta 
local  out_dataEPUlengthYear ${data_raw}/annual_condition_indexEPU_length_${vintage_string}.dta 


/* better was is to link svspp--itis--nespp */
/* get svspp codes from dealer_nespp4 codes */




/* YEARLY data */ 
/* read in data with a global/local  */
import delimited `in_relcond_Year', clear
levelsof svspp, local(mysp) sep(,)
preserve

use `codes', clear

keep nespp3 svspp
drop if svspp==.
drop if svspp<=0
keep if inlist(svspp,`mysp')
drop if nespp3==215
/* deal with species that span multiple nespp3 groups */
do "${extraction_code}/extractA01a_rebin_nespp3.do"
drop OG_nespp3
duplicates drop
tempfile sp


save `sp'


restore

merge m:1 svspp using `sp'

/*patch spotted hake */
replace nespp3=662 if svspp==78 & nespp3==.
assert nespp3==662 if _merge==1
drop _merge

drop if strmatch(year,"NA")
drop n
replace stddevcond="" if stddevcond=="NaN"
destring, replace
foreach var of varlist meancond stddevcond ncond{
rename `var' `var'_Annual
}

save `out_dataYear', replace



/* This won't work until the input data has svspp in it */
/*
/* YEARLY EPU data */ 
/* read in data with a global/local  */
import delimited `in_relcond', clear

merge m:1 svspp using `sp'

/*patch spotted hake */
replace nespp3=662 if svspp==78 & nespp3==.
assert nespp3==662 if _merge==1
drop _merge

drop if strmatch(year,"NA")
drop n
capture replace stddevcond="" if stddevcond=="NaN"
destring, replace
foreach var of varlist meancond stddevcond ncond{
rename `var' `var'_EPU
}
save `out_dataEPUYear', replace
*/






/* YEARLY EPU-length data */ 
/* read in data with a global/local  */
import delimited `in_relcond_leng', clear

merge m:1 svspp using `sp'

/*patch spotted hake */
replace nespp3=662 if svspp==78 & nespp3==.
assert nespp3==662 if _merge==1
drop _merge

drop if strmatch(year,"NA")
drop n
capture replace stddevcond="" if stddevcond=="NaN"
destring, replace
foreach var of varlist meancond stddevcond ncond{
rename `var' `var'_EPU_length
}
save `out_dataEPUlengthYear', replace





