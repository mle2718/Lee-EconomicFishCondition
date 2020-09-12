
/*This is not the proper query.*/


#delimit;
version 15.1;
pause off;

timer on 1;

local out_data ${data_raw}/raw_obsial_${vintage_string}.dta ;


clear;


/* observer silver hake is 5090 in observer no market category

monk 0120 to 0129
haddock 1470 to 1479

But there's not enough data.
*/

	odbc load,  exec("select * from asmial where nespp4 >= 0120 and nespp4<=0129;") $mynova_conn;

	clear;
