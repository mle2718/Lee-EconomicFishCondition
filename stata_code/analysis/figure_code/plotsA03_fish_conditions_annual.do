/* code to merge in fish condition data  */




version 15.1
pause off

timer on 1

/* files for Relative condition data, which one are you using?*/
local  in_relcond ${data_raw}/annual_condition_indexEPU_${vintage_string}.dta 
local  in_relcond_leng ${data_raw}/annual_condition_indexEPU_length_${vintage_string}.dta 
local in_relcond_Year ${data_raw}/annual_condition_index_${vintage_string}.dta 

use  `in_relcond_Year', clear

keep if nespp3==509
tsset year

twoway(tsline meancond ) (tsline stddevcond_Annual , yaxis(2) lpattern(dash)), tlabel(#7) tmtick(##5) legend(order(1 "Condition" 2 "Std. Dev.")) ytitle("Condition", axis(1)) ytitle("Std. Dev.", axis(2))
graph export ${my_images}/silver_hake_condition.png, replace as(png)
