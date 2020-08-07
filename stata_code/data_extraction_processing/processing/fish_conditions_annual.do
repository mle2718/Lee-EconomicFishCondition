/* code to construct/merge the annual fish condition data */




version 15.1
pause off

timer on 1

local in_data ${data_raw}/raw_dealer_prices_${vintage_string}.dta 
local  out_data ${data_raw}/annual_condition_index_${vintage_string}.dta 

/* read in data with a global/local  */


/* aggregate, by() */

/* keep a subset? */

/* attach nespp3 codes to merge to cfdbs */

/* save */

save  `out_data', replace 
