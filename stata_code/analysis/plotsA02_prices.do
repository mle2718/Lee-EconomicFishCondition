
/*
Code to plot prices
*/


#delimit;
version 15.1;
pause on;

timer on 1;

local  in_data ${data_main}/dealer_prices_real_lags${vintage_string}.dta ;
local  marketcats ${data_raw}/dealer_nespp4_codes${vintage_string}.dta ;


local relabelstr `"relabel(1 "J" 2 "F" 3 "M"  4 "A"  5 "M"  6 "J"  7 "J" 8 "A" 9 "S" 10 "O" 11 "N" 12 "D" 13 "J" 14 "F" 15 "M"  16 "A"  17 "M"  18 "J"  19 "J" 20 "A" 21 "S" 22 "O" 23 "N" 24 "D")"' ;

clear;
use `in_data', clear;
merge m:1 nespp4 using `marketcats', keep(1 3);
assert _merge==3;
labmask nespp4, value(sp_mkt);
drop _merge;


gen priceR_GDPDEF=valueR_GDPDEF/landings;

label var priceR "Real Price per pound";
keep if price<=10;
bysort nespp4: egen mp=mean(price);

gen monthly=ym(year, month);
tab monthly;
preserve;
keep if nespp3==509;

graph box price, over(nespp4, label(angle(45)) sort(mp)) nooutsides;
graph export ${my_images}/silver_hake_prices.png, replace as(png);

local yearly_opts over(year, label(angle(45)))  nooutsides yscale(range(0 3)) ylabel(0(.5)3) ymtick(##2) ;


graph box price if nespp4==5091, title("King Silver Hake") `yearly_opts';
graph export ${my_images}/king_silver.png, replace as(png);


graph box price if nespp4==5092, title("Small Silver Hake")   `yearly_opts'; 
graph export ${my_images}/small_silver.png, replace as(png);


graph box price if nespp4==5094, title("Juvenile Silver Hake")  `yearly_opts';
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

local yearly_opts over(year, label(angle(45)))  nooutsides yscale(range(0 6)) ylabel(0(2)6) ymtick(##4);
graph box price if nespp4==1470, title("Large Haddock")  `yearly_opts';
graph export ${my_images}/large_haddock.png, replace as(png);


graph box price if nespp4==1475, title("Scrod Haddock")  `yearly_opts';
graph export ${my_images}/scrod_haddock.png, replace as(png);


graph box price if nespp4==1476,  title("Snapper Haddock")   `yearly_opts'; 
graph export ${my_images}/snapper_haddock.png, replace as(png);


restore;


#delimit ;
local relabelstr `"relabel(1 "J" 2 "F" 3 "M"  4 "A"  5 "M"  6 "J"  7 "J" 8 "A" 9 "S" 10 "O" 11 "N" 12 "D" 13 "J" 14 "F" 15 "M"  16 "A"  17 "M"  18 "J"  19 "J" 20 "A" 21 "S" 22 "O" 23 "N" 24 "D")"' ;

preserve;
keep if inlist(nespp3,120);
keep if year>=2009;

graph box price, over(nespp4, label(angle(45)) sort(mp)) nooutsides;




graph box price if nespp4==1200 & year>=2011 & year<=2012, over(monthly, `relabelstr') title("Unclass Winter, 2011-2012")  nooutside cwhisker lines(lcolor(none));
graph export ${my_images}/winter_unclass_2011_2012.png, replace as(png);

graph box price if nespp4==1200 & year>=2009 & year<=2010, over(monthly, `relabelstr') title("Unclass Winter, 2009-2010")  nooutside cwhisker lines(lcolor(none));
graph export ${my_images}/winter_unclass_2009_2010.png, replace as(png);


graph box price if nespp4==1202 & year>=2011 & year<=2012, over(monthly, `relabelstr') title("Large Winter, 2011-2012")  nooutside cwhisker lines(lcolor(none));
graph export ${my_images}/winter_large_2011_2012.png, replace as(png);

graph box price if nespp4==1202 & year>=2009 & year<=2010, over(monthly, `relabelstr') title("Large Winter, 2009-2010")  nooutside cwhisker lines(lcolor(none));
graph export ${my_images}/winter_large_2009_2010.png, replace as(png);




graph box price if nespp4==1203 & year>=2011 & year<=2012, over(monthly, `relabelstr') title("Small Winter, 2011-2012")  nooutside cwhisker lines(lcolor(none));
graph export ${my_images}/winter_small_2011_2012.png, replace as(png);

graph box price if nespp4==1203 & year>=2009 & year<=2010, over(monthly, `relabelstr') title("Small Winter, 2009-2010")  nooutside cwhisker lines(lcolor(none));
graph export ${my_images}/winter_small_2009_2010.png, replace as(png);

restore;




preserve;
keep if inlist(nespp3,124);
keep if year>=2009;

graph box price, over(nespp4, label(angle(45)) sort(mp)) nooutsides;




graph box price if nespp4==1241 & year>=2018 & year<=2019, over(monthly, `relabelstr') title("Large Plaice, 2018-2019")  nooutside cwhisker lines(lcolor(none));
graph export ${my_images}/plaice_large_2018_2019.png, replace as(png);

graph box price if nespp4==1241 & year>=2009 & year<=2010, over(monthly, `relabelstr') title("Large Plaice, 2009-2010")  nooutside cwhisker lines(lcolor(none));
graph export ${my_images}/placie_large2009_2010.png, replace as(png);


graph box price if nespp4==1242 & year>=2018 & year<=2019, over(monthly, `relabelstr') title("Small Plaice, 2018-2019")  nooutside cwhisker lines(lcolor(none));
graph export ${my_images}/plaice_small_2011_2012.png, replace as(png);

graph box price if nespp4==1242 & year>=2009 & year<=2010, over(monthly, `relabelstr') title("Small Plaice, 2009-2010")  nooutside cwhisker lines(lcolor(none));
graph export ${my_images}/plaice_small_2009_2010.png, replace as(png);
restore;


/*

graph box price if nespp4==1203 & year>=2011 & year<=2012, over(monthly, label(angle(45))) title("Unclass Winter, 2011-2012")  nooutside cwhisker lines(lcolor(none));
graph export ${my_images}/plaice_small_2011_2012.png, replace as(png);

graph box price if nespp4==1203 & year>=2013 & year<=2014, over(monthly, label(angle(45))) title("Unclass Winter, 2009-2010")  nooutside cwhisker lines(lcolor(none));
graph export ${my_images}/plaice_unclass_2009_2010.png, replace as(png);

*/
