
/*
Code plot silver hake and monkfish prices

*/


#delimit;
version 15.1;
pause off;

timer on 1;

local  in_data ${data_main}/dealer_prices_real_lags${vintage_string}.dta ;
local  marketcats ${data_raw}/dealer_nespp4_codes${vintage_string}.dta 

clear;
use `in_data', clear;
merge m:1 nespp4 using `marketcats', keep(1 3)
assert _merge==3
labmask nespp4, value(sp_mkt)
drop _merge





gen price=value/landings;
keep if price<=10;
bysort nespp4: egen mp=mean(price);
preserve;
keep if nespp3==509;

graph box price, over(nespp4, label(angle(45)) sort(mp));
graph export ${my_images}/silver_hake_prices.png, replace as(png);

restore;



preserve;
keep if nespp3==12;
graph box price, over(nespp4, label(angle(45)) sort(mp));
graph export ${my_images}/monkfish_prices.png, replace as(png);

restore;



preserve;
keep if nespp3==147;
graph box price, over(nespp4, label(angle(45)) sort(mp));
graph export ${my_images}/haddock_prices.png, replace as(png);

restore;
