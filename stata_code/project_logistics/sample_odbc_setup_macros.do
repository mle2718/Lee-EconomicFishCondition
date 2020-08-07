/* 
Min-Yang's preferred approach to connecting to NEFSC's Oracle from Stata is:

odbc load,  exec("select something from table 
	where blah blah blah;")
	conn("$mysole_conn") lower;

where $mysole_conn contains a connection string for sole

This sample file shows how to build one.
Because there are semicolons inside the connection string, you should not use semicolons as delimiters in this file*/

version 15.1
#delimit cr
global myuid "mlee"
global mypwd "PWDHERE"
global mygarfo_pwd "your_garfo_pwd"



/* if you have a properly set up odbcinst.ini , then this will work (on nix). */
global mysole_conn "Driver={OracleODBC-11g};Dbq=path.to.sole.server.gov:PORT/sole;Uid=mlee;Pwd=$mypwd;"
global mynova_conn "Driver={OracleODBC-11g};Dbq=path.to.nova.server.gov:PORT/nova;Uid=mlee;Pwd=$mypwd;"
global mygarfo_conn "Driver={OracleODBC-11g};Dbq=NNN.NNN.NN.NNN/perhaps.more.letters.here.nfms.gov;Uid=mlee;Pwd=$mygarfo_pwd;"

/* It might be cleaner to do this: but I can't test it.
global mysole_conn "conn("Driver={OracleODBC-11g};Dbq=path.to.sole.server.gov:PORT/sole;Uid=mlee;Pwd=$mypwd;") lower" ;
global mynova_conn "conn("Driver={OracleODBC-11g};Dbq=path.to.nova.server.gov:PORT/sole;Uid=mlee;Pwd=$mypwd;") lower" ;

 */




/* if you have a properly set up odbc.  Then this will work (on Windows). */
global mysole_conn "dsn(sole) user($myuid) password($mypwd) lower"
global mynova_conn "dsn(nova) user($myuid) password($mypwd) lower"
global mygarfo_conn "dsn(musky) user($myuid) password($mygarfo_pwd) lower"

