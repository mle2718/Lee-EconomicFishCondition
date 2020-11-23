/* For this to run properly, you must set up stata's import fred command
In particular, you need to 
1. go to the St. Louis Federal reserve, register for an account, and get an API key for their data

https://research.stlouisfed.org/useraccount/login/secure/

once you have an account, click on "my account" (top right) and request an API key.

2.  in stata do
set fredkey <your_key_here>, perm
*/




/* extract 3 quarterly deflators from FRED 
I have extracted 2 specific to fishing
PCU3117103117102: PPI industry data for Seafood product preparation and packaging-Fresh and frozen seafood processing, not seasonally adjusted
PCU31171031171021: PPI industry data for Seafood product preparation and packaging-Prepared fresh fish/seafood, inc. surimi/surimi-based products, not seasonally adjusted
GDPDEF  Gross Domestic Product: Implicit Price Deflator 


DDFUELNYH: Diesel fuel in NY harbor is probably too volatile
Industry classification. A Producer Price Index for an industry is a measure of changes in prices received for the industry's output sold outside the industry (that is, its net output).
Commodity classification. The commodity classification structure of the PPI organizes products and services by similarity or material composition, regardless of the industry classification of the producing establishment. 
	This system is unique to the PPI and does not match any other standard coding structure. 
	In all, PPI publishes more than 3,700 commodity price indexes for goods and about 800 for services (seasonally adjusted and not seasonally adjusted), organized by product, service, and end use.

*/

/*extract 3 quarterly income metrics from FRED 
A939RX0Q048SBEA: Quarterly Real gross domestic product per capita. 10,000USD. FRED: A939RX0Q048SBEA.  Chained 2012 Dollars, Seasonally Adjusted Annual Rate.  BEA Account Code: A939RX
A792RC0Q052SBEA: Quarterly Nominal Personal income per capita. 10,000USD. FRED: A792RC0Q052SBEA.  Dollars, Seasonally Adjusted Annual Rate. BEA Account Code: A792RC. 
A229RX0Q048SBEA: Quarterly Real Disposable Personal Income Per Capita (FRED: A229RX0Q048SBEA). 10,000USD. Chained 2012 Dollars, Seasonally Adjusted Annual Rate.. BEA Account Code: A229RX

*/

version 15.1
clear

local importlist  GDPDEF  PCU3117103117102 PCU31171031171021 

local basey=2019

import fred `importlist',  daterange(1991-01-01 .) aggregate(annual,avg) clear
gen year=yofd(daten)
drop daten datestr

notes: deflators extracted on $vintage_string;

foreach var of varlist  `importlist'{

gen base`var'=`var' if year==`basey'
sort base`var'
replace base`var'=base`var'[1] if base`var'==.

	gen f`var'_`basey'=`var'/base`var'
	notes f`var'_`basey': divide a nominal price or value by this factor to get real `basey' prices or values
	notes f`var'_`basey': multiply a real `basey' price or value by this factor to get nominal prices or values
	notes `var': raw index value
	drop base`var'

}
sort year 
order year f*`basey'

tsset year

notes fGDPDEF_2019: GDP Implicit Price Deflator
notes fPCU3117103117102_2019: PPI industry data for Seafood product preparation and packaging-Fresh and frozen seafood processing, not seasonally adjusted
notes fPCU31171031171021_2019: PPI industry data for Seafood product preparation and packaging-Prepared fresh fish/seafood, inc. surimi/surimi-based products, not seasonally adjusted	


save "$deflatorsY", replace
tsline f*


/* which is your base period : 2016Q2 and 2018Q1
*/


local b1 "2019Q1"
local baseq=quarterly("`b1'","Yq")


import fred `importlist' ,  daterange(1991-01-01 .) aggregate(quarterly,avg) clear
gen dateq=qofd(daten)
drop daten datestr
format dateq %tq
notes: deflators extracted on $vintage_string


foreach var of varlist  `importlist'{
	gen base`var'=`var' if dateq==`baseq'
	sort base`var'
	replace base`var'=base`var'[1] if base`var'==.

	gen f`var'_`b1'=`var'/base`var'
	notes f`var'_`b1': divide a nominal price or value by this factor to get real `basey' prices or values
	notes f`var'_`b1': multiply a real `basey' price or value by this factor to get nominal prices or values
	notes `var': raw index value
	drop base`var'
}
sort dateq 
order dateq f*`b1' 
tsset dateq

notes fGDPDEF_2019Q1: GDP Implicit Price Deflator 
notes fPCU3117103117102_2019Q1: PPI industry data for Seafood product preparation and packaging-Fresh and frozen seafood processing, not seasonally adjusted
notes fPCU31171031171021_2019Q1: PPI industry data for Seafood product preparation and packaging-Prepared fresh fish/seafood, inc. surimi/surimi-based products, not seasonally adjusted	
save "$deflatorsQ", replace


tsline f* 





/* which is your base period : 2016Q2 and 2018Q1
*/
local importlist A939RX0Q048SBEA A792RC0Q052SBEA A229RX0Q048SBEA

import fred `importlist' JHGDPBRINDX,  daterange(1994-01-01 .) aggregate(quarterly,avg) clear
gen dateq=qofd(daten)
drop daten datestr
format dateq %tq
notes: deflators extracted on $vintage_string

local b1 "2019Q1"
local baseq=quarterly("`b1'","Yq")



foreach var of varlist  `importlist'{
	replace `var'=`var'/10000
	gen base`var'=`var' if dateq==`baseq'
	sort base`var'
	replace base`var'=base`var'[1] if base`var'==.

	gen f`var'_`b1'=`var'/base`var'
	notes f`var'_`b1': divide a nominal price or value by this factor to get real `basey' prices or values
	notes f`var'_`b1': multiply a real `basey' price or value by this factor to get nominal prices or values
	notes `var': raw index value
	drop base`var'
}
sort dateq 
order dateq f*`b1' 
tsset dateq

notes A939RX0Q048SBEA: Quarterly Real gross domestic product per capita. 10,000USD. FRED: A939RX0Q048SBEA.  Chained 2012 Dollars, Seasonally Adjusted Annual Rate.  BEA Account Code: A939RX
notes A792RC0Q052SBEA: Quarterly Nominal Personal income per capita. 10,000USD. FRED: A792RC0Q052SBEA.  Dollars, Seasonally Adjusted Annual Rate. BEA Account Code: A792RC. 
notes A229RX0Q048SBEA: Quarterly Real Disposable Personal Income Per Capita (FRED: A229RX0Q048SBEA). 10,000USD. Chained 2012 Dollars, Seasonally Adjusted Annual Rate.. BEA Account Code: A229RX

rename A939RX0Q048SBEA rGDPcapita
rename A792RC0Q052SBEA personal_income_capita
rename A229RX0Q048SBEA realDPIcapita

notes fA939RX0Q048SBEA: Quarterly Real gross domestic product per capita. Base year `b1'=1. FRED: A939RX0Q048SBEA
notes fA792RC0Q052SBEA: Quarterly Nominal Personal income per capita.  Base year `b1'=1. FRED: fA792RC0Q052SBEA
notes fA229RX0Q048SBEA: Quarterly Real Disposable Personal Income Per Capita (A229RX0Q048SBEA).  Base year `b1'=1. FRED: fA229RX0Q048SBEA

rename fA939RX0Q048SBEA frGDPcapita
rename fA792RC0Q052SBEA fpersonal_income_capita
rename fA229RX0Q048SBEA frealDPIcapita

notes JHGDPBRINDX:  GDP-Based Recession Indicator Index econbrowser.com/recession-index.

tsset dateq






save "$incomeQ", replace
tsline rGDPcapita personal_income_capita realDPIcapita




/********************************************************************************************************/
/********************************************************************************************************/
/* At the end of this step, you have 3 datasets
1. Yearly deflators (we're not using this)
2. Quarterly deflators 
3. Quarterly income 
*/
/********************************************************************************************************/
/********************************************************************************************************/

