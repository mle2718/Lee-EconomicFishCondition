/* code to construct/merge the annual fish condition data */




version 15.1
pause off

timer on 1

local daily ${data_raw}/raw_entire_fishery_${vintage_string}.dta 


merge m:1 year month day using `daily', keep(1 3)
drop _merge
