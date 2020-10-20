/* extract quarterly data from FRED 
series_id                     	industry_code	product_code	seasonal	base_date	series_title	footnote_codes	begin_year	begin_period	end_year	end_period	
PCU3117103117102              	311710	3117102	U	198212	PPI industry data for Seafood product preparation and packaging-Fresh and frozen seafood processing, not seasonally adjusted		1982	M12	2020	M06
PCU31171031171021             	311710	31171021	U	198212	PPI industry data for Seafood product preparation and packaging-Prepared fresh fish/seafood, inc. surimi/surimi-based products, not seasonally adjusted		1965	M01	2020	M06
		
GDPDEF  Gross Domestic Product: Implicit Price Deflator 

PCU31171031171021, DDFUELNYH are probably too volatile


GDPDEF


Industry classification. A Producer Price Index for an industry is a measure of changes in prices received for the industry's output sold outside the industry (that is, its net output).
Commodity classification. The commodity classification structure of the PPI organizes products and services by similarity or material composition, regardless of the industry classification of the producing establishment. 
	This system is unique to the PPI and does not match any other standard coding structure. 
	In all, PPI publishes more than 3,700 commodity price indexes for goods and about 800 for services (seasonally adjusted and not seasonally adjusted), organized by product, service, and end use.



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
	replace `var'=`var'/1000
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

notes A939RX0Q048SBEA: Quarterly Real gross domestic product per capita.  FRED: A939RX0Q048SBEA.  Chained 2012 Dollars, Seasonally Adjusted Annual Rate.  BEA Account Code: A939RX
notes A792RC0Q052SBEA: Quarterly Nominal Personal income per capita.  FRED: A792RC0Q052SBEA.  Dollars, Seasonally Adjusted Annual Rate. BEA Account Code: A792RC. 
notes A229RX0Q048SBEA: Quarterly Real Disposable Personal Income Per Capita (FRED: A229RX0Q048SBEA). Chained 2012 Dollars, Seasonally Adjusted Annual Rate.. BEA Account Code: A229RX

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
