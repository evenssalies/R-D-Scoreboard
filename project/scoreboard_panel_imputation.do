/*	Imputations sales (peaufiner plus tard avec une régression, etc).
		La motivation est la construciton des stocks dans la suite.
		Remplacer var==. par la moy. artithmétique de var.
			S'il n'y a qu'une année et quelle est nulle, il n'y a rien à faire
			à part une imputation plus sophistiquée plus tard.
 		Laisser les 0 de CAPEX, pas pour les autres variables 
sort			RAISON YEAR
foreach 		Y of varlist CAPEX SALES EMPL {
 egen			`Y'MEAN=mean(`Y'), by(RAISON)
 by RAISON, sort: replace `Y'=`Y'MEAN if `Y'==.
 drop			`Y'MEAN
}
foreach Y of varlist SALES EMPL {
 egen			`Y'MEAN=mean(`Y'), by(RAISON)
 by RAISON, sort: replace `Y'=`Y'MEAN if `Y'==0
 drop			`Y'MEAN
} */
*/
