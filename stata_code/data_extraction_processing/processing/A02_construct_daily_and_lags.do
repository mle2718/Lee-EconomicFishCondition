/* code to construct daily totals by modified NESPP3 and NESPP4 data */




version 15.1
pause off
timer on 1


cap drop _merge
cap drop date
gen date=mdy(month,day,year)
/* construct Day-of-week indicators */
/* sunday =0; Saturday==6*/
gen dow=dow(date)
gen weekend=inlist(dow,0,6)

label define days_of_week 0 "Sunday" 1 "Monday" 2 "Tuesday" 3 "Wednesday" 4 "Thursday" 5 "Friday" 6 "Saturday" 
label values dow days_of_week

replace value=value/1000
replace landings=landings/1000
label var landings "000s of lbs"
label var value "000s of dollars"

/* construct daily landings */
/* you need to make the ihs transform because you need to handle zeros */
preserve
collapse (sum) landings, by(date)
drop if date==.
tsset date
/* fill zeros */
tsfill, full
replace landings=0 if landings==.
gen ihsq=asinh(landings)
gen lnq=ln(landings)

/*construct lags */
foreach lag of numlist 1 7 14 28{
	gen ihsq_lag`lag'=l`lag'.ihsq
	gen q_lag`lag'=l`lag'.landings
	gen lnq_lag`lag'=l`lag'.lnq
}


rename landings daily_landings
tempfile daily
save `daily'
restore
merge m:1 date using `daily', keep(1 3)
/* any merge=1 are due to day=0 or month=0 invalid dates */
assert day==0 | month==0 if _merge==1

drop _merge
/* construct daily by nespp4 landings */
preserve
collapse (sum) landings, by(date nespp4)
tsset nespp4 date
drop if date==.

tsfill, full

replace landings=0 if landings==.


gen ihs_ownq=asinh(landings)
gen ln_ownq=ln(landings)
rename landings own4landings



/*construct lags */
foreach lag of numlist 1 7 14 28{
	gen ihsownq_lag`lag'=l`lag'.ihs_ownq
	gen ownq_lag`lag'=l`lag'.own4landings
	gen lnownq_lag`lag'=l`lag'.ln_ownq
	gen own4landings_lag`lag'=l`lag'.own4landings
}


tempfile daily2
save `daily2'
restore
merge m:1 date nespp4 using `daily2', keep(1 3)
tab _merge


/* construct other landings and lags*/
gen other_landings=daily_landings-own4landings
gen ihs_other_landings= ihsq- ihs_ownq
gen ln_other_landings= lnq- ln_ownq

foreach lag of numlist 1 7 14 28{

	gen other_landings_lag`lag'=q_lag`lag'-own4landings_lag`lag'
	gen ihs_other_landings_lag`lag'= ihsq_lag`lag'- ihsownq_lag`lag'
	gen ln_other_landings`lag'= lnq_lag`lag'- lnownq_lag`lag'

}
compress
/* _merge=1 iff date==. */
assert date==. if _merge==1
assert _merge==1 if date==.
drop _merge

