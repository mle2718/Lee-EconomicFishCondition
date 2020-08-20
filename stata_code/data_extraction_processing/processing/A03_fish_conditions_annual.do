/* code to construct/merge the annual fish condition data */




version 15.1
pause off

timer on 1


local in_relcond ${data_external}/RelCond2019_EPU.csv
local in_relcond_leng ${data_external}/RelCond2019_EPU_length.csv

local price_raw ${data_raw}/raw_dealer_prices_${vintage_string}.dta 


local  out_data ${data_raw}/annual_condition_index_${vintage_string}.dta 




/* read in data with a global/local  */
import delimited `in_relcond', clear

import delimited `in_relcond_leng', clear
keep if svspp==72

gen group=length>=30
collapse (mean) meancond[fw=ncond], by(svspp year group)
destring, replace

tsset group year
/*
xtline mean, overlay
*/


import delimited `in_relcond_leng', clear
keep if svspp==72

gen group=length>=30
collapse (mean) meancond[fw=ncond], by(svspp year group epu)
destring, replace
egen gid=group(group year epu)
tsset gid year
/*
xtline mean, overlay
*/

/* aggregate, by() */

/* keep a subset? */

/* attach nespp3 codes to merge to cfdbs */

/* save

save  `out_data', replace 
 */
