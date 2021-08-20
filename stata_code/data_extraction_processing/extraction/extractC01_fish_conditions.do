/* code to construct/merge the annual fish condition data */




version 15.1


/* better was is to link svspp--itis--nespp */
/* get svspp codes from dealer_nespp4 codes */




/* YEARLY data */ 
/* read in data with a global/local  */
import delimited ${in_relcond_Year}, clear
levelsof svspp, local(mysp) sep(,)
preserve

use $nespp4, clear

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

capture	drop if strmatch(year,"NA")
drop n

capture replace stddevcond="" if stddevcond=="NaN"

destring, replace
foreach var of varlist meancond stddevcond ncond{
rename `var' `var'_Annual
}
replace species=proper(species)
replace species="Windowpane Flounder" if species=="Windowpane"
replace species="Fourspot Flounder" if species=="Fourspot"
replace species="Atlantic Cod" if species=="Atl Cod"
replace species="Atlantic Herring" if species=="Atl Herring"
replace species="Atlantic Mackerel" if species=="Mackerel"
replace species="Fourspot Flounder" if species=="Fourspot"
replace species="Yellowtail Flounder" if species=="Yellowtail"

save ${out_dataYear}, replace

/* keyfile of species, svspp, nespp3 */
keep species svspp nespp3
duplicates drop
tempfile keyfile1
save `keyfile1', replace

/* This won't work until the input data has svspp in it */

/* YEARLY EPU data */ 
/* read in data with a global/local  */
import delimited ${in_relcond}, clear
replace species=proper(species)
replace species="Windowpane Flounder" if species=="Windowpane"
replace species="Fourspot Flounder" if species=="Fourspot"
replace species="Atlantic Cod" if species=="Atl Cod"
replace species="Atlantic Herring" if species=="Atl Herring"
replace species="Atlantic Mackerel" if species=="Mackerel"
replace species="Fourspot Flounder" if species=="Fourspot"
replace species="Yellowtail Flounder" if species=="Yellowtail"


merge m:1 species using `keyfile1', keep(1 3)
assert _merge==3
drop if strmatch(year,"NA")
drop n
capture replace stddevcond="" if stddevcond=="NaN"
destring, replace
foreach var of varlist meancond ncond{
rename `var' `var'_EPU
}
save ${out_dataEPUYear}, replace







/* YEARLY EPU-length data */ 
/* read in data with a global/local  */
import delimited ${in_relcond_leng}, clear

merge m:1 svspp using `sp'

/*patch spotted hake */
replace nespp3=662 if svspp==78 & nespp3==.
assert nespp3==662 if _merge==1
drop _merge
replace species=proper(species)
replace species="Windowpane Flounder" if species=="Windowpane"
replace species="Fourspot Flounder" if species=="Fourspot"
replace species="Atlantic Cod" if species=="Atl Cod"
replace species="Atlantic Herring" if species=="Atl Herring"
replace species="Atlantic Mackerel" if species=="Mackerel"
replace species="Fourspot Flounder" if species=="Fourspot"
replace species="Yellowtail Flounder" if species=="Yellowtail"


capture	drop if strmatch(year,"NA")

drop n


capture replace stddevcond="" if stddevcond=="NaN"
destring, replace
foreach var of varlist meancond stddevcond ncond{
rename `var' `var'_EPU_length
}
save ${out_dataEPUlengthYear}, replace





