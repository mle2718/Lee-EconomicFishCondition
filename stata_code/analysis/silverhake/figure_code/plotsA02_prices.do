
/*
Code to plot prices
*/


#delimit;
version 15.1;
pause on;

timer on 1;

local  in_data ${data_main}/dealer_prices_full_${vintage_string}.dta ;
local  marketcats ${data_raw}/dealer_nespp4_codes${vintage_string}.dta ;

local working_nespp3 509;
local relabelstr `"relabel(1 "J" 2 "F" 3 "M"  4 "A"  5 "M"  6 "J"  7 "J" 8 "A" 9 "S" 10 "O" 11 "N" 12 "D" 13 "J" 14 "F" 15 "M"  16 "A"  17 "M"  18 "J"  19 "J" 20 "A" 21 "S" 22 "O" 23 "N" 24 "D")"' ;

clear;
use `in_data' if inlist(nespp3, `working_nespp3'), clear;
merge m:1 nespp4 using `marketcats', keep(1 3);
assert _merge==3;
labmask nespp4, value(sp_mkt);
drop _merge;

gen price=value/landings;
keep if price<=10;

gen priceR_GDPDEF=valueR_GDPDEF/landings;

label var priceR "Real Price per pound";
keep if price<=10;
bysort nespp4: egen mp=mean(price);

preserve;
keep if nespp3==509;

graph box price, over(nespp4, label(angle(45)) sort(mp)) nooutsides;
graph export ${silverhake_images}/box_price_${vintage_string}.png, replace as(png);

local yearly_opts over(year, label(angle(45)))  nooutsides yscale(range(0 3)) ylabel(0(.5)3) ymtick(##2) ;


graph box price if nespp4==5091, title("King Silver Hake") `yearly_opts';
graph export ${silverhake_images}/king_5091_${vintage_string}.png, replace as(png);


graph box price if nespp4==5092, title("Small Silver Hake")   `yearly_opts'; 
graph export ${silverhake_images}/small_5092_${vintage_string}.png, replace as(png);


graph box price if nespp4==5094, title("Juvenile Silver Hake")  `yearly_opts';
graph export ${silverhake_images}/juvenile_5094_${vintage_string}.png, replace as(png);
restore;
