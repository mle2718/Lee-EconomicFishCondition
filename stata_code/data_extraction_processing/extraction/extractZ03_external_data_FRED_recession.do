/* extract recession indicators from St. Louis Fed


	*/
version 15.1
clear

local importlist  USRECM USREC USRECP
import fred `importlist',  daterange(1991-01-01 .) clear
notes: extracted on $vintage_string;
drop datestr
gen monthly=mofd(daten)
drop daten
notes USRECM: Recession, Peak to trough
notes USREC: Recession, period after peak to trough
notes USRECP: Recession, Peak to period before trough
save "$recession", replace

