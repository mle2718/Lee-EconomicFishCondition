
/*
Code to plot prices
*/


#delimit;
version 15.1;
pause on;

timer on 1;

local  in_data ${data_main}/dealer_prices_final_spp_509_${vintage_string}.dta ;
local daily ${data_raw}/raw_entire_fishery_${vintage_string}.dta ;

local  marketcats ${data_raw}/dealer_nespp4_codes${vintage_string}.dta ;


local relabelstr `"relabel(1 "J" 2 "F" 3 "M"  4 "A"  5 "M"  6 "J"  7 "J" 8 "A" 9 "S" 10 "O" 11 "N" 12 "D" 13 "J" 14 "F" 15 "M"  16 "A"  17 "M"  18 "J"  19 "J" 20 "A" 21 "S" 22 "O" 23 "N" 24 "D")"' ;

clear;
use `in_data', clear;
merge m:1 nespp4 using `marketcats', keep(1 3);
assert _merge==3;
labmask nespp4, value(sp_mkt);
drop _merge;


merge m:1 month day year using `daily', keep(1 3);



gen price=value/landings;
drop if date==.;

gen priceR_GDPDEF=valueR_GDPDEF/landings;

label var priceR "Real Price per pound";
keep if price<=10;
bysort nespp4: egen mp=mean(price);



cap drop monthly;
gen monthly=mofd(date);
collapse (sum) landings value valueR_GDPDEF aggregateL aggregateV, by(monthly);

replace aggregateL=aggregateL/1000;
replace aggregateV=aggregateV/1000;


label var landings "Whiting Landings (000s)";
label var value "Whiting Value (000s)";
label var valueR_GDPDEF "Whiting Value (Real 000s)";

label var aggregateL "Landings M lbs";
label var aggregateV "Value M nominal";

tsset monthly ;
format monthly %tm;
twoway (tsline landings) (tsline aggregateL, yaxis(2)), tlabel(#12, format(%tmCCYY) angle(45)) tmtick(##2, grid) ylabel(,nogrid)  title("Monthly Landings") legend (order(1 "whiting" 2 "finfish"));


graph export ${my_images}/silver_hake_and_allQ_monthly.png, replace as(png);



twoway (tsline value) (tsline aggregateV, yaxis(2)), tlabel(#12, format(%tmCCYY) angle(45)) tmtick(##2, grid) ylabel(,nogrid)  title("Monthly Landings") legend (order(1 "whiting" 2 "finfish"));


