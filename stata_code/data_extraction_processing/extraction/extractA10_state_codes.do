
/*Code to extract itis and cfspp species codes.*/
#delimit;
version 15.1;
pause off;
clear;




odbc load,  exec("select distinct statecd ,stateabb from port;") $mysole_conn;
renvarlab, lower;

destring, replace;

labmask statecd, value(stateabb);

drop if statecd==.;
save $state_codes, replace;



/********************************************************************************************************/
/********************************************************************************************************/
/* At the end of this step, a dataset with the statecd and stateabb. I've used labmask to label the statecd with the stateabb
*/
/********************************************************************************************************/
/********************************************************************************************************/


