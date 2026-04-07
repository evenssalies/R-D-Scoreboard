/* Déflateur du PIB */
/* 	Dans la base du déflateur, les noms des pays sont codés en alpha3, alors
		que dans le Scoreboard Panel, à ce stade, j'ai codé en alpha2.
		Je vais donc chercher les codes alpha3 avec le fichier countries.dta.
		Faut que je sois sûr, auparavant, que les codes alpha2 du Panel sont
		bien écris */

use				"scoreboard_panel.dta", clear

/*
generate		TEMP=1
collapse		TEMP, by(alpha2)
merge 1:1		alpha2 using "http://www.frequency.fr/countries.dta"
sort			english alpha*	/* é est après z donc prend plutôt l'english */
cls
list 			english alpha*
/*		Remarque : j'ai les états-unis et les émirats arabes unis à la fin car
			les ces noms commencent avec un accent
			Reste deux problèmes : GB et CN */
use				"scoreboard_panel.dta", clear
replace			alpha2="CN_X_HK" if alpha2=="CN"
replace			alpha2="UK" if alpha2=="GB"
rename			COUNTRY english
merge m:1		alpha2 using "http://www.frequency.fr/countries.dta"
list 			alpha2 alpha3 english if _merge==2
/*		_merge==2 : 15 pays sur 71 ne sont pas dans le Scoreboard Panel */
keep if			_merge==3
drop			_merge english monnaie soustraitantcircii ze20

merge m:m		alpha3 YEAR ///
				using "http://www.frequency.fr/pib_deflator.dta", ///
				keepusing(PIB_DEF)
/*		_merge=1 : Taiwan de 2003 à 2022 (20 a.)*134 etr./an env. = 2067 obs.
					n'ont pas de valeur de PIB_DEF [chercher plus tard] +
		_merge=2 : 		2000 à 2002, 2023, 217 alpha3 (689 obs.) +
						2003 à 2022, les alpha3 qui ne sont pas dans le 
							Scoreboard Panel (3364 obs.) = 4053 obs. */
keep if			_merge==3
drop			_merge
/* 		Note : il n'y a que les YEAR de 2003 à 2022 dans le Scoreboard Panel */

order			REGION
order			PIB_DEF EMPL, after(CAPEX)
order			ue28 oecd alpha*, after(PIB_DEF)

compress

replace			RDINV=100*RDINV/PIB_DEF
replace			SALES=100*SALES/PIB_DEF
replace			PROFIT=100*PROFIT/PIB_DEF
replace			CAPEX=100*CAPEX/PIB_DEF
drop			PIB_DEF
save			"scoreboard_panel.dta", replace
*/

/**********************
* Deflateurs EU-KLEMS *
***********************/

/* national accounts
 Ne garde que :
 
 nace_r2_code, nace <-> NACEREV2 dans le scoreboard
 year
 II_PI
 GO_PI pour SALES
 geo_code <-> alpha2 dans le scoreboard) */
use 			"national_accounts.dta", clear
keep 			geo_code geo_name year nace_r2_code II_PI GO_PI

rename			nace_r2_code X

/*	Commencer par ce débarasser des agrégats non-NACE */
drop if			X == "L68A"|X == "MARKTxAG"|X == "MARKT"|X == "TOT"|X == "TOT_IND"

/*	Recoder 01 à 88 */
replace 		X = "01-03" if	X == "A"
/* 04 n'existe pas dans NACE */
replace 		X = "05-09" if	X == "B"
drop if			X == "C"
replace 		X = "10-12" if	X == "C10-C12"
replace 		X = "13-15" if	X == "C13-C15"
replace 		X = "16-18" if	X == "C16-C18"
replace 		X = "19" if 	X == "C19"
replace 		X = "20" if		X == "C20"
drop if			X == "C20-C21"
replace 		X = "21" if 	X == "C21"
replace 		X = "22-23" if 	X == "C22-C23"
replace 		X = "24-25" if 	X == "C24-C25"
replace 		X = "26" if		X == "C26"
drop if			X == "C26-C27"
replace 		X = "27" if		X == "C27"
replace 		X = "28" if		X == "C28"
replace 		X = "29-30" if	X == "C29-C30"
replace 		X = "31-33" if 	X == "C31-C33"
/* 34 */
drop if			X == "D-E"
replace 		X = "35" if		X == "D"
replace 		X = "36-39" if	X == "E"
/* 40 */
replace 		X = "41-43" if	X == "F"
/* 44 */
drop if			X == "G"
replace 		X = "45" if		X == "G45"
replace 		X = "46" if		X == "G46"
replace 		X = "47" if		X == "G47"
/* 48 */
drop if			X == "H"
replace 		X = "49" if		X == "H49"
replace 		X = "50" if		X == "H50"
replace 		X = "51" if		X == "H51"
replace 		X = "52" if		X == "H52"
replace 		X = "53" if		X == "H53"
/* 54 */
replace 		X = "55-56" if 	X == "I"
/* 57 */
drop if			X == "J"
replace 		X = "58-60" if 	X == "J58-J60"
replace 		X = "61" if 	X == "J61"
replace 		X = "62-63" if 	X == "J62-J63"
replace 		X = "64-66" if 	X == "K"
/* 67 */
replace 		X = "68" if 	X == "L"
replace 		X = "69-75" if 	X == "M"
/* 76 */	
drop if			X == "M-N"
replace 		X = "77-82" if 	X == "N"
/* 83 */
replace 		X = "84" if 	X == "O"
replace 		X = "85" if 	X == "P"
drop if			X == "O-Q"|X == "Q"
replace 		X = "86" if		X == "Q86"
replace 		X = "87-88" if	X == "Q87-Q88"
/* 89 */
replace 		X = "90-93" if 	X == "R"
drop if			X == "R-S"
replace 		X = "94-96" if 	X == "S"
replace 		X = "97-98" if 	X == "T"
replace 		X = "99" if 	X == "U"

keep if			year>=2003&year<=2023
rename			(geo_code geo_name year X)(alpha2 COUNTRY YEAR NACEREV2_42)				
merge m:m		COUNTRY YEAR NACEREV2_42 using "scoreboard_panel.dta"
keep if			_merge==3
drop			_merge
save			"scoreboard_panel1.dta", replace

/*	Traitement du fichier capital_accounts
 garder Ip_GFCF */
use 			"capital_accounts.dta", clear
keep 			geo_code geo_name year nace_r2_code Ip_GFCF

rename			nace_r2_code X

/*	Commencer par ce débarasser des agrégats non-NACE */
drop if			X == "L68A"|X == "MARKTxAG"|X == "MARKT"|X == "TOT"|X == "TOT_IND"

/*	Recoder 01 à 88 */
replace 		X = "01-03" if	X == "A"
/* 04 n'existe pas dans NACE */
replace 		X = "05-09" if	X == "B"
drop if			X == "C"
replace 		X = "10-12" if	X == "C10-C12"
replace 		X = "13-15" if	X == "C13-C15"
replace 		X = "16-18" if	X == "C16-C18"
replace 		X = "19" if 	X == "C19"
replace 		X = "20" if		X == "C20"
drop if			X == "C20-C21"
replace 		X = "21" if 	X == "C21"
replace 		X = "22-23" if 	X == "C22-C23"
replace 		X = "24-25" if 	X == "C24-C25"
replace 		X = "26" if		X == "C26"
drop if			X == "C26-C27"
replace 		X = "27" if		X == "C27"
replace 		X = "28" if		X == "C28"
replace 		X = "29-30" if	X == "C29-C30"
replace 		X = "31-33" if 	X == "C31-C33"
/* 34 */
drop if			X == "D-E"
replace 		X = "35" if		X == "D"
replace 		X = "36-39" if	X == "E"
/* 40 */
replace 		X = "41-43" if	X == "F"
/* 44 */
drop if			X == "G"
replace 		X = "45" if		X == "G45"
replace 		X = "46" if		X == "G46"
replace 		X = "47" if		X == "G47"
/* 48 */
drop if			X == "H"
replace 		X = "49" if		X == "H49"
replace 		X = "50" if		X == "H50"
replace 		X = "51" if		X == "H51"
replace 		X = "52" if		X == "H52"
replace 		X = "53" if		X == "H53"
/* 54 */
replace 		X = "55-56" if 	X == "I"
/* 57 */
drop if			X == "J"
replace 		X = "58-60" if 	X == "J58-J60"
replace 		X = "61" if 	X == "J61"
replace 		X = "62-63" if 	X == "J62-J63"
replace 		X = "64-66" if 	X == "K"
/* 67 */
replace 		X = "68" if 	X == "L"
replace 		X = "69-75" if 	X == "M"
/* 76 */	
drop if			X == "M-N"
replace 		X = "77-82" if 	X == "N"
/* 83 */
replace 		X = "84" if 	X == "O"
replace 		X = "85" if 	X == "P"
drop if			X == "O-Q"|X == "Q"
replace 		X = "86" if		X == "Q86"
replace 		X = "87-88" if	X == "Q87-Q88"
/* 89 */
replace 		X = "90-93" if 	X == "R"
drop if			X == "R-S"
replace 		X = "94-96" if 	X == "S"
replace 		X = "97-98" if 	X == "T"
replace 		X = "99" if 	X == "U"

keep if			year>=2003&year<=2023
rename			(geo_code geo_name year X)(alpha2 COUNTRY YEAR NACEREV2_42)				
merge m:m		COUNTRY YEAR NACEREV2_42 using "scoreboard_panel1.dta"
keep if			_merge==3
drop			_merge
save 			"scoreboard_panel1.dta", replace
 
/*	Traitement du fichier intangibles_analytical.dta
 garder	Ip_RD */
use 			"intangibles_analytical.dta", clear
keep 			geo_code geo_name year nace_r2_code Ip_RD

rename			nace_r2_code X

/*	Commencer par ce débarasser des agrégats non-NACE */
drop if			X == "L68A"|X == "MARKTxAG"|X == "MARKT"|X == "TOT"|X == "TOT_IND"

/*	Recoder 01 à 88 */
replace 		X = "01-03" if	X == "A"
/* 04 n'existe pas dans NACE */
replace 		X = "05-09" if	X == "B"
drop if			X == "C"
replace 		X = "10-12" if	X == "C10-C12"
replace 		X = "13-15" if	X == "C13-C15"
replace 		X = "16-18" if	X == "C16-C18"
replace 		X = "19" if 	X == "C19"
replace 		X = "20" if		X == "C20"
drop if			X == "C20-C21"
replace 		X = "21" if 	X == "C21"
replace 		X = "22-23" if 	X == "C22-C23"
replace 		X = "24-25" if 	X == "C24-C25"
replace 		X = "26" if		X == "C26"
drop if			X == "C26-C27"
replace 		X = "27" if		X == "C27"
replace 		X = "28" if		X == "C28"
replace 		X = "29-30" if	X == "C29-C30"
replace 		X = "31-33" if 	X == "C31-C33"
/* 34 */
drop if			X == "D-E"
replace 		X = "35" if		X == "D"
replace 		X = "36-39" if	X == "E"
/* 40 */
replace 		X = "41-43" if	X == "F"
/* 44 */
drop if			X == "G"
replace 		X = "45" if		X == "G45"
replace 		X = "46" if		X == "G46"
replace 		X = "47" if		X == "G47"
/* 48 */
drop if			X == "H"
replace 		X = "49" if		X == "H49"
replace 		X = "50" if		X == "H50"
replace 		X = "51" if		X == "H51"
replace 		X = "52" if		X == "H52"
replace 		X = "53" if		X == "H53"
/* 54 */
replace 		X = "55-56" if 	X == "I"
/* 57 */
drop if			X == "J"
replace 		X = "58-60" if 	X == "J58-J60"
replace 		X = "61" if 	X == "J61"
replace 		X = "62-63" if 	X == "J62-J63"
replace 		X = "64-66" if 	X == "K"
/* 67 */
replace 		X = "68" if 	X == "L"
replace 		X = "69-75" if 	X == "M"
/* 76 */	
drop if			X == "M-N"
replace 		X = "77-82" if 	X == "N"
/* 83 */
replace 		X = "84" if 	X == "O"
replace 		X = "85" if 	X == "P"
drop if			X == "O-Q"|X == "Q"
replace 		X = "86" if		X == "Q86"
replace 		X = "87-88" if	X == "Q87-Q88"
/* 89 */
replace 		X = "90-93" if 	X == "R"
drop if			X == "R-S"
replace 		X = "94-96" if 	X == "S"
replace 		X = "97-98" if 	X == "T"
replace 		X = "99" if 	X == "U"

keep if			year>=2003&year<=2023
rename			(geo_code geo_name year X)(alpha2 COUNTRY YEAR NACEREV2_42)				
merge m:m		COUNTRY YEAR NACEREV2_42 using "scoreboard_panel1.dta"
keep if			_merge==3
drop			_merge
save 			"scoreboard_panel1.dta", replace
 
/* Crééer les prix unitaires 

	Note : le salaire plus tard L_PI=COMP/EMPE 
			label variable	L_PI "Salaire unitaire"
			renmae L_PI W */

rename			(GO_PI II_PI Ip_GFCF Ip_RD)(P PM PK PRD)

/* Déflater */
replace			CAPEX=100*CAPEX/PK
replace			RDINV=100*RDINV/PRD
replace			SALES=100*SALES/P

drop			PK PRD P PM

save 			"scoreboard_panel.dta", replace
erase			"scoreboard_panel1.dta"