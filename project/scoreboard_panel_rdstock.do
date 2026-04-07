/*		Stock de capital de RD */ 
use				"filetemp.dta", clear
keep if			YEAR==YEARMIN|YEAR==YEARMAX
by 				RAISON, sort: generate YCAPMIN=RDINV[1]
by				RAISON, sort: generate YCAPMAX=RDINV[2]
keep if			YEAR==YEARMIN
replace			YCAPMAX=YCAPMIN if YEARN==1
by				RAISON, sort: generate ///
					YCAPRATE=(YCAPMAX/YCAPMIN)^(1/(YEARMAX-YEARMIN))-1 if YEARN>1
replace			YCAPRATE=0 if YCAPRATE==.&RDINV!=.
keep			RAISON YCAPRATE
merge 1:m		RAISON using "filetemp.dta"
keep if 		_merge==3
drop			_merge
order			YCAPRATE, after(RDINV)
sort			RAISON YEAR
generate		RSTOCK=RDINV
order			RSTOCK, after(YCAPRATE)
local			DELTA=0.08
by 				RAISON, sort: ///
				replace	RSTOCK=RSTOCK/(`DELTA'+YCAPRATE) if YEAR==YEARMIN
replace			YEARMIN=YEARMIN+1
by				RAISON, sort: ///
				replace RSTOCK=RSTOCK+(1-`DELTA')*RSTOCK[_n-1] if YEAR>=YEARMIN
sort			RAISON YEAR
drop			YCAPRATE YEARMIN YEARMAX YEARN 
order			YEAR, after(RAISON)