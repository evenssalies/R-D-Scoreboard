/* RTP2025
	
	Taux d'entrée, sortie, turbulence des groupes de RD par pays.
	
		Remarques :
			
			- garde les pays présents à chaque période
			- sélection du top x % dans chaque pays ?
				Non si Scoreboard sélectionne le même nb. de groupes
				chaque année. Oui sinon (voir document d'accompagnement).
			
	Evens Salies,

	v1 04/2025	*/

cls
set more off

global	GDRIVE="G:\.shortcut-targets-by-id\1HfSmUOZCFEUwi-aWTtOmVrEeyJrgRxlc\"
global	URL="$GDRIVE"+"RTP 2025\"
global	PATHIN="$URL"+"Indiv\Evens\"
cd		"$PATHIN"
global	PATHOUT="$PATHIN"+"Output\"

local	FILEIN="`PATHIN'"+"scoreboard_panel.dta"
use		"`FILEIN'", clear

/*	Règle une ambiguïté */
drop if			RAISON=="CHINA RAILWAY"

/*	2003, 2023 */
keep if			YEAR==2003|YEAR==2023
keep			RAISON YEAR alpha2 REGION
sort			YEAR alpha2 RAISON
		
/*	Tague BRICS hors Chine : Brésil, Russie, Inde, Afrique du Sud */
replace			REGION="BRICS_X_CN" if ///
	alpha2=="BR"|alpha2=="RU"|alpha2=="ZA"|alpha2=="IN"

/* 	Ne garde que les pays présents en 2003 et 2023 (39 pays) */
save			"filetemp1.dta", replace
keep			alpha2 YEAR
duplicates drop
sort			alpha2 YEAR
fillin			alpha2 YEAR
egen			TEMP1=sum(_fillin), by(alpha2)
drop if			TEMP1==1
drop			TEMP1
merge m:m		alpha2 YEAR using "filetemp1.dta", nogenerate
drop if			_fillin==.
drop			_fillin
quietly:	tabulate		alpha2 if YEAR==2003
di				r(r)
quietly:	tabulate		alpha2 if YEAR==2023
di				r(r)
quietly:	tabulate		alpha2 if YEAR==2003&REGION=="EU"
di				r(r)
quietly:	tabulate		alpha2 if YEAR==2023&REGION=="EU"
di				r(r)

/*	Mettre les groupes de 2023 à droite de 2003 */
sort			YEAR alpha2 RAISON
encode			alpha2, generate(alpha2code)
save			"filetemp.dta", replace
drop			REGION
order			alpha2 YEAR
save			"filetemp1.dta", replace

quietly: tabulate alpha2code
global			alpha2n=r(r)

forvalues		I=1(1)$alpha2n {
	use				"filetemp1.dta", clear
	keep if			alpha2code==`I'
	generate		LINE=0
	by YEAR, sort: ///
	replace 		LINE=_n
	fillin			YEAR LINE
	drop			_fillin
	save			"filetemp2.dta", replace
	keep if 		YEAR==2003
	drop			YEAR
	rename			RAISON RAISON2003
	save			"filetemp3.dta", replace
	use				"filetemp2.dta", clear
	keep if 		YEAR==2023
	drop			YEAR
	rename			RAISON RAISON2023
	merge m:m		alpha2 LINE using "filetemp3.dta", nogenerate
	drop			LINE
	order			RAISON2023, after(RAISON2003)
	local			FILE="file"+"`I'.dta"
	drop if			alpha2==""
	save			"`FILE'", replace
}

use				"file1.dta", clear
forvalues		I=2(1)$alpha2n {
	local		FILE="file"+"`I'.dta"
	append using "`FILE'"
	erase		 "`FILE'"
}
save			"filetemp4.dta", replace
erase			"file1.dta"
erase			"filetemp1.dta"
erase			"filetemp2.dta"
erase			"filetemp3.dta"

/*	Dans chaque pays, fait un merge des groupes 
		_merge = 1 :	groupes en 2003 seulement
		_merge = 2 :	groupes en 2023 seulement
		_merge = 3 :	groupes en 2003 et 2023
		----------
		Somme :			#groupes différents */
cls

/*	Tableau (tous les pays sauf l'UE) */
matrix define	MATRIX=J($alpha2n,5,0)
forvalues		I=1(1)$alpha2n {
	use				"filetemp4.dta", clear
	keep if			alpha2code==`I'
	keep			RAISON*
	save			"filetemp2.dta", replace
	keep			RAISON2023
	rename			RAISON2023 RAISON
	drop if			RAISON==""
	save			"filetemp3.dta", replace
	use				"filetemp2.dta", clear
	keep			RAISON2003
	rename			RAISON2003 RAISON
	drop if			RAISON==""
	merge 1:1		RAISON using "filetemp3.dta"
	sort			_merge RAISON
	forvalues		J=1(1)3 {
		count if		_merge==`J'
		matrix 			MATRIX[`I',`J']=r(N)
	}
	matrix			MATRIX[`I',4]=MATRIX[`I',1]+MATRIX[`I',2]+MATRIX[`I',3]
	matrix			MATRIX[`I',5]=`I'
}

erase			"filetemp2.dta"
erase			"filetemp3.dta"
matrix list		MATRIX

/*	Statistiques de turbulence */
/*		Matrice des entrées, sorties -> variables */
clear
set obs			$alpha2n
svmat			MATRIX, names(RAISON)
rename			RAISON4 N
rename			RAISON5 alpha2code
order			alpha2code

/*		Taux */
capture drop	TAUXENTREE TAUXSORTIE TURBULANCE
generate		TAUXENTREE=RAISON2/N
generate		TAUXSORTIE=RAISON1/N
generate		TURBULENCE=TAUXENTREE+TAUXSORTIE

/*	Ramène les régions */
merge 1:m		alpha2code using "filetemp.dta"
keep if			_n<=39
keep			TAUXENTREE TAUXSORTIE TURBULENCE N alpha2 REGION
order			alpha2 REGION
order			N, after(TURBULENCE)
replace			REGION="BR" if REGION=="BRICS_X_CN"
replace			REGION="CN" if REGION=="China"
replace			REGION="RO" if REGION=="ROW"
replace			REGION="JP" if REGION=="Japan"

/*	Noms des pays */
merge 1:1		alpha2 using "http://www.frequency.fr/countries.dta", ///
				keepusing(francais)
replace			francais="Chine" if alpha2=="CN"
replace			francais="Grande-Bretagne" if alpha2=="GB"
drop if			_merge==2
drop			_merge
drop			alpha2
order			francais

/*	Drop les pays qui n'ont ni entrée, ni sortie */
gsort			-TURBULENCE -TAUXENTREE -TAUXSORTIE francais REGION
save			"demographie.dta", replace

/*	Vire les RO et les pays à turbulence nulle ou unitaire */
drop if			REGION=="RO"
drop if			TURBULENCE==0|TURBULENCE==1
save			"demographie.dta", replace

/*	Union européenne */
matrix define	MATRIX=J(1,5,0)
use				"filetemp4.dta", clear
merge m:1		alpha2 using "http://www.frequency.fr/countries.dta", ///
				keepusing(francais ue27_2020)
keep if			ue27_2020==1
drop if			_merge==2
drop			_merge ue27_2020
compress
keep			RAISON*
save			"filetemp2.dta", replace
keep			RAISON2023
rename			RAISON2023 RAISON
drop if			RAISON==""
save			"filetemp3.dta", replace
use				"filetemp2.dta", clear
keep			RAISON2003
rename			RAISON2003 RAISON
drop if			RAISON==""
merge 1:1		RAISON using "filetemp3.dta"
sort			_merge RAISON
forvalues		J=1(1)3 {
	count if		_merge==`J'
	matrix 			MATRIX[1,`J']=r(N)
}
matrix			MATRIX[1,4]=MATRIX[1,1]+MATRIX[1,2]+MATRIX[1,3]

/*	Avec l'UE, ça fait 40 pays */
matrix			MATRIX[1,5]=24	

erase			"filetemp2.dta"
erase			"filetemp3.dta"
matrix list		MATRIX

/*	Statistiques de turbulence */
/*		Matrice des entrées, sorties -> variables */
clear
set obs			1
svmat			MATRIX, names(RAISON)
rename			RAISON4 N
rename			RAISON5 alpha2code
order			alpha2code

/*		Taux */
capture drop	TAUXENTREE TAUXSORTIE TURBULANCE
generate		TAUXENTREE=RAISON2/N
generate		TAUXSORTIE=RAISON1/N
generate		TURBULENCE=TAUXENTREE+TAUXSORTIE

/*	Ramène les régions */
merge 1:m		alpha2code using "filetemp.dta" 	
keep if			_n==1
keep			TAUXENTREE TAUXSORTIE TURBULENCE alpha2 REGION N
order			alpha2 REGION
order			N, after(TURBULENCE)
replace			REGION="EU" if REGION=="ROW"
replace			alpha2="UE (18 pays)" if alpha2=="LI"
rename			alpha2 francais
append using	"demographie.dta"

/*	Sauve */
gsort			-TURBULENCE -TAUXENTREE -TAUXSORTIE francais
save			"demographie.dta", replace