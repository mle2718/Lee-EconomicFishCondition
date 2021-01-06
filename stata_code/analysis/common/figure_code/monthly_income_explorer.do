
vintage_lookup_and_reset

global common_images ${my_images}/common
local  in_data ${data_external}/incomeQ_${vintage_string}.dta 

use `in_data', clear


gen year=yofd(dofq(dateq))
keep if year<=2019
gen qtr=quarter(dofq(dateq))

/*res
expand 3
sort dateq

bysort dateq: gen month=3*(qtr-1)+_n
*/

keep year dateq rGDPcapita qtr

bysort year: egen ybar=mean(rGDPcapita)
bysort qtr: egen mbar=mean(rGDPcapita)


tsset dateq
gen dev=rGDP-ybar
gen devm=rGDP-mbar
egen gm=mean(rGDPcapita)
gen dm2=rGDPcapita-ybar-mbar+gm


tsline dm2, tmtick(##5, grid)  title("rGDP per cap demeaned by yearly and quarterly averages") 
graph export ${common_images}/rGDPC_dmYQ.png, replace as(png)


tsline dev, tmtick(##5, grid) title("rGDP per cap minus yearly averages") 
graph export ${common_images}/rGDPC_dmY.png, replace as(png)

tsline dm, tmtick(##5, grid) title("rGDP per cap minus monthly averages") 
graph export ${common_images}/rGDPC_dmQ.png, replace as(png)
