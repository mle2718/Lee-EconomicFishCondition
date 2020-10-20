/* code to construct/merge the annual fish condition data */




version 15.1
pause off

timer on 1

local recession $data_external/recessionM_${vintage_string}.dta


merge m:1 monthly using `recession', keep(1 3)
drop _merge
