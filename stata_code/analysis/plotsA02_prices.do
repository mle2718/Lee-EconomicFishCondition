
/*
Code to extract 
Monk and silver hake prices
silver hake:
King 5091
Large 5095
Medium 5096
Small 5092
Juvenile 5094

"Round" 5090
Dressed 5093
	Convert dressed to round by multiplying landings  1.66
	
Unclassifed 5097 (not in the time series) 

*/


#delimit;
version 15.1;
pause on;

timer on 1;

global oracle_cxn " $mysole_conn lower";
local in_data ${data_intermediate}/dealer_prices_real${vintage_string}.dta ;

local marketcats ${data_raw}/dealer_nespp4_codes${vintage_string}.dta ;

clear;
use `in_data', clear;
drop if _merge==1;
cap drop _merge;
merge m:1 nespp4 using `marketcats', keep(1 3);
assert _merge==3;
labmask nespp4, value(sp_mkt);
drop _merge;

gen priceR_GDPDEF=valueR_GDPDEF/landings;

label var priceR "Real Price per pound";
keep if price<=10;
bysort nespp4: egen mp=mean(price);
preserve;
keep if nespp3==509;

graph box price, over(nespp4, label(angle(45)) sort(mp)) nooutsides;
graph export ${my_images}/silver_hake_prices.png, replace as(png);

graph box price if nespp4==5091, over(year, label(angle(45)))  nooutsides title("King Silver Hake")  yscale(range(0 3)) ylabel(0(.5)3);
graph export ${my_images}/king_silver.png, replace as(png);


graph box price if nespp4==5092, over(year, label(angle(45)))  nooutsides title("Small Silver Hake")  yscale(range(0 3)) ylabel(0(.5)3);
graph export ${my_images}/small_silver.png, replace as(png);


graph box price if nespp4==5094, over(year, label(angle(45)))  nooutsides title("Juvenile Silver Hake")  yscale(range(0 3)) ylabel(0(.5)3);
graph export ${my_images}/juvenile_silver.png, replace as(png);
restore;



preserve;
keep if nespp3==12;
graph box price, over(nespp4, label(angle(45)) sort(mp)) nooutsides;
graph export ${my_images}/monkfish_prices.png, replace as(png);

restore;



preserve;
keep if inlist(nespp3,147,148);
graph box price, over(nespp4, label(angle(45)) sort(mp)) nooutsides;
graph export ${my_images}/haddock_prices.png, replace as(png);

restore;
