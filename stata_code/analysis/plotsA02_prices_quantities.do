
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
pause off;

timer on 1;

global oracle_cxn " $mysole_conn lower";
local in_data ${data_raw}/raw_dealer_prices_${vintage_string}.dta ;

clear;
use `in_data', clear;
label define marketcats 5090 "Round" 5091 "King" 5092 "Small" 5093 "Dressed" 5094 "Juvenile" 5095 "Large" 5096 "Medium" 5097 "Unc" , replace ;
label define marketcats 1470 "Large" 1471 "Extra Large" 1472 "Medium" 1473 "Market" 1475 "Scrod" 1476 "Snapper" 1479 "Unc"  1477 "Unc Round", modify;
label define marketcats 0120 "Tails" 0121 "Large Tails" 0122 "Small Tails"  0123 "Livers" 0124 "Unc Round" 0126 "Peewee Tails" 0127 "Belly Flaps" 0128 "Head on Gutted" 0129 "Dressed" 0125 "Cheeks",modify;

label values nespp4 marketcats;

gen price=value/landings;
keep if price<=10;
gen nespp3=floor(nespp4/10);
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
