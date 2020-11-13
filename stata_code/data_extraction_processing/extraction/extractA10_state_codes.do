
/*Code to extract itis and cfspp species codes.*/
#delimit;
version 15.1;
pause off;
clear;




odbc load,  exec("select distinct statecd ,stateabb from port;") $mysole_conn;
renvarlab, lower;

destring, replace;

labmask statecd, value(stateabb);


save $state_codes, replace;



