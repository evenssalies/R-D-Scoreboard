/*	Construction du stock de capital physique

		Routine pour nombre d'années variables
		par entreprise presque terminée

	 	On ne peut pas calculer un taux de variation en partant de 0.
		Imputation pour les i : si CAPEX(1) nul, mettre CAPEX(2) ;
		la technique est de mettre la valeur la plus petite après 0. */
		
egen 			YEARMIN=min(YEAR), by(RAISON)
egen 			YEARMAX=max(YEAR), by(RAISON)
egen			YEARN=count(YEAR), by(RAISON)
egen			MISSN=count(YEAR) if missing(CAPEX), by(RAISON)

sort			MISSN YEARN RAISON YEAR
generate		CAPZERO=0

/*				Si #obs=x et #missing=x, flag à 1 (pas de CAPEX pour l'entre. */
replace			CAPZERO=(MISSN==YEARN)
replace			MISSN=0 if MISSN==.

/*				Si #obs=1 et #missing=0, ne fait rien */
 
/*				Si #obs=2, taguer 1 si CAPEX[1]=0 et CAPEX[2]>0 */
generate		CAPZERO1=(MISSN==0&YEARN==2&YEAR==YEARMIN&CAPEX==0)
generate		CAPZERO2=2 if MISSN==0&YEARN==2&YEAR==YEARMAX&CAPEX!=0
replace			CAPZERO2=0 if CAPZERO2==.
generate		CAPZERO3=CAPZERO1+CAPZERO2 if MISSN==0&YEARN==2
egen			CAPZERO4=sum(CAPZERO3) if MISSN==0&YEARN==2, by(RAISON) 
replace			CAPZERO=1 if CAPZERO4==3&MISSN==0&YEARN==2
drop			CAPZERO1-CAPZERO4

/*				Si #obs=3 */
egen			CAPRANK=rank(CAPEX) if MISSN==0&YEARN>=3, unique by(RAISON)
replace			CAPZERO=1 if MISSN==0&YEARN==3&YEAR==YEARMIN&CAPEX==0
sort			RAISON CAPRANK
capture drop	CAPTROIS
generate		CAPTROIS=0
by 				RAISON, sort: ///
 replace		CAPTROIS=CAPEX[2] if MISSN==0&YEARN==3&CAPZERO==1
sort			MISSN YEARN RAISON YEAR
replace			CAPEX=CAPTROIS if MISSN==0&YEARN==3&CAPTROIS>0

/*				Si #obs=4 */
capture drop	CAPTROIS
generate		CAPTROIS=0
replace			CAPZERO=1 if MISSN==0&YEARN==4&YEAR==YEARMIN&CAPEX==0
sort			RAISON CAPRANK
by 				RAISON, sort: ///
 replace		CAPTROIS=CAPEX[2] if MISSN==0&YEARN==4&CAPZERO==1
sort			MISSN YEARN RAISON YEAR
replace			CAPEX=CAPTROIS if MISSN==0&YEARN==4&CAPTROIS>0

/*				Si #obs=5 */
capture drop	CAPTROIS
generate		CAPTROIS=0
replace			CAPZERO=1 if MISSN==0&YEARN==5&YEAR==YEARMIN&CAPEX==0
sort			RAISON CAPRANK
by 				RAISON, sort: ///
 replace		CAPTROIS=CAPEX[2] if MISSN==0&YEARN==5&CAPZERO==1
sort			MISSN YEARN RAISON YEAR
replace			CAPEX=CAPTROIS if MISSN==0&YEARN==5&CAPTROIS>0

/*				Si #obs>5, alors check le CAP de YEARMAX ; si nul, donner
				 l'avant dernière valeur */
egen			CAPSUM=sum(CAPEX), by(RAISON)
replace			CAPZERO=1 if MISSN==0&YEARN>5&YEAR==YEARMAX&CAPEX==0&CAPSUM>0
forvalues		I=6(1)17 {
 capture drop	CAPTROIS
 generate		CAPTROIS=0
 sort			RAISON CAPRANK
 by 			RAISON, sort: ///
 replace		CAPTROIS=CAPEX[_N-1] if MISSN==0&YEARN==`I'&CAPZERO==1
 replace		CAPEX=CAPTROIS if MISSN==0&YEARN==`I'&CAPTROIS>0
}
drop			CAPZERO CAPRANK CAPSUM CAPTROIS
sort			RAISON YEAR
save			"filetemp.dta", replace

keep if			YEAR==YEARMIN|YEAR==YEARMAX
by 				RAISON, sort: generate YCAPMIN=CAPEX[1]
by				RAISON, sort: generate YCAPMAX=CAPEX[2]
keep if			YEAR==YEARMIN
replace			YCAPMAX=YCAPMIN if YEARN==1
by				RAISON, sort: generate ///
					YCAPRATE=(YCAPMAX/YCAPMIN)^(1/(YEARMAX-YEARMIN))-1 if YEARN>1
replace			YCAPRATE=0 if YCAPRATE==.&CAPEX!=.
keep			RAISON YCAPRATE
merge 1:m		RAISON using "filetemp.dta"
keep if 		_merge==3
drop			_merge
drop			MISSN
order			YCAPRATE, last
sort			RAISON YEAR
generate		KSTOCK=CAPEX
local			DELTA=0.08
by 				RAISON, sort: ///
				replace	KSTOCK=KSTOCK/(`DELTA'+YCAPRATE) if YEAR==YEARMIN
sort			RAISON YEAR
replace			YEARMIN=YEARMIN+1
by				RAISON, sort: ///
				replace KSTOCK=KSTOCK+(1-`DELTA')*KSTOCK[_n-1] if YEAR>=YEARMIN
sort			RAISON YEAR
drop			YCAPRATE
replace			YEARMIN=YEARMIN-1