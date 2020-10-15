/* code to merge in fish condition data  */




version 15.1
pause off

timer on 1

/* files for Relative condition data, which one are you using?*/
local  in_relcond ${data_raw}/annual_condition_indexEPU_${vintage_string}.dta 
local  in_relcond_leng ${data_raw}/annual_condition_indexEPU_length_${vintage_string}.dta 
local in_relcond_Year ${data_raw}/annual_condition_index_${vintage_string}.dta 


local deflators $data_external/deflatorsQ_${vintage_string}.dta
local income $data_external/incomeQ_${vintage_string}.dta 


use  `in_relcond_Year', clear

keep if nespp3==509
tsset year

tempfile cond
save `cond'



use `income', clear
gen year=yofd(dofq(dateq))
merge m:1 year using `cond', keep(3)

tsset dateq
gen qtr=quarter(dofq(dateq))
twoway( tsline rGDPcapita) (tsline meancond, yaxis(2))
graph export ${my_images}/condition509_GDPC.png, replace as(png)

twoway( tsline realDPIcapita) (tsline meancond, yaxis(2))
graph export ${my_images}/condition509_DPIC.png, replace as(png)


twoway( tsline personal_income_capita) (tsline meancond, yaxis(2))
graph export ${my_images}/condition509_PIC.png, replace as(png)


corr rGDPcapita personal_income_capita realDPIcapita meancond_Annual if qtr==1


scatter meancond_Annual realDPIcapita

graph export ${my_images}/scatter_condition509_DPIC.png, replace as(png)




tsline rGDPcapita personal_income_capita realDPIcapita
graph export ${my_images}/macro_income.png, replace as(png)
