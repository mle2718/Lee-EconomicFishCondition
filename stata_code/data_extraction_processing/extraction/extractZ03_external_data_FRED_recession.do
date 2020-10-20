/* extract recession indicators from St. Louis Fed


	*/
version 15.1
clear

local importlist  USRECM
import fred `importlist',  daterange(1991-01-01 .) clear
notes: extracted on $vintage_string;
drop datestr
gen monthly=mofd(daten)
drop daten
save "$recession", replace

