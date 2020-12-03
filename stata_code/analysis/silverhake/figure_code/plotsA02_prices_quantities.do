
/*
Code plot silver hake  prices

*/


#delimit;
version 15.1;
pause off;

timer on 1;

local  in_data ${data_main}/dealer_prices_full_${vintage_string}.dta ;
local  marketcats ${data_raw}/dealer_nespp4_codes${vintage_string}.dta ;
local working_nespp3 509 ;

clear;
use `in_data' if inlist(nespp3, `working_nespp3'), clear;
merge m:1 nespp4 using `marketcats', keep(1 3);
assert _merge==3;
labmask nespp4, value(sp_mkt);
drop _merge;





gen price=value/landings;
keep if price<=10;
bysort nespp4: egen mp=mean(price);
preserve;
keep if nespp3==509;

graph box price, over(nespp4, label(angle(45)) sort(mp));
graph export ${silverhake_images}/box_prices_${vintage_string}.png, replace as(png);

restore;

