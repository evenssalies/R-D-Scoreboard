/* RTP2025
	
	Evolution de la part de la R&D des pays appartenant au top 10 % des
	investisseurs en R&D.

 Evens Salies,
				v4 04/2025
	
*/

cls
set more off

global	GDRIVE="G:\.shortcut-targets-by-id\1HfSmUOZCFEUwi-aWTtOmVrEeyJrgRxlc\"
global	URL="$GDRIVE"+"RTP 2025\"
global	PATHIN="$URL"+"Indiv\Evens\"
cd		"$PATHIN"
global	PATHOUT="$PATHIN"+"Output\"

local	FILEIN="`PATHIN'"+"scoreboard_panel.dta"
use		"`FILEIN'", clear

/*
/*******************************************
* Part du Scoreboard dans la DIRDE en 2019 *
********************************************/
keep if 		YEAR==2019
drop			YEAR
rename			COUNTRY english
drop if			english==""
merge m:1		english using "http://www.evens-salies.com/countries.dta", ///
				keepusing(english ue27_2020 alpha2)
drop if			_merge!=3
drop			_merge
cls
table			english
tabulate		english if ue27_2020==1
di				r(r)
keep if			ue27_2020==1
drop			ue27_2020 RAISON
su				RDINV
local			NUM=r(mean)*r(N)
keep			alpha2
duplicates drop
save			"temp1.dta", replace

local			FILEIN="$URL"+"Indiv\Evens\"+"rd_e_gerdfund.dta"
use				"`FILEIN'", clear
keep			alpha2 YEAR RD_COU_BES_TOTAL
rename			RD_COU_BES_TOTAL Y
keep if 		YEAR==2019
drop			YEAR
save			"temp2.dta", replace

use				"temp2.dta", clear
drop			if alpha2=="US"|alpha2=="CN_X_HK"|alpha2=="JP"|alpha2=="KR"| ///
				alpha2=="RU"
su				Y
local			DEN=r(mean)*r(N)

di				100*`NUM'/`DEN'

use				"temp2.dta", clear
merge m:1		alpha2 using "http://www.evens-salies.com/countries.dta", ///
				keepusing(ue27_2020) keep(3)
replace			ue27_2020=0 if ue27_2020==. 
keep if			ue27_2020==1
drop			ue27_2020 _merge
su				Y
local			DEN=r(mean)*r(N)
di				100*`NUM'/`DEN'

use				"temp2.dta", clear
merge 1:1 		alpha2 using "temp1.dta", keep(3)
su				Y
local			DEN=r(mean)*r(N)
di				100*`NUM'/`DEN'
*/			

/******************************************
* Top 10% des entreprises US en 2003 2023 *
*******************************************/
/*
/*	On garde 2003 et 2023 */
keep if			YEAR==2003|YEAR==2023

/*	Garde US */ 
keep if			alpha2=="US"

/*	Sélectionne le top 10 % en 2003 et en 2023 
		Ajoute un contrainte de taille mondiale, pas nécessaire ? */
gsort			YEAR -RDINV
capture drop	TEMP1
egen			TEMP1=count(RAISON), by(YEAR)
generate		TEMP2=int(0.10*TEMP1)
by YEAR, sort: ///
				generate TEMP3=_n
generate		TEMP4=TEMP2-TEMP3
drop if			TEMP4<0
drop			TEMP*
table			YEAR						// 2003 (80), 2023 (70)

/*	Statistique au passage : part de la R&D des GAFAM dans le total US,
		idem pour la part de la R&D des TIC */
generate		TAG=1 if ///
				RAISON=="ALPHABET"|RAISON=="META"|RAISON=="APPLE"| ///
				RAISON=="MICROSOFT"
sum				RDINV if TAG==1&YEAR==2023
/* 		R&D d'AMAZON de 2017 en euro de 2023 */
local			AMAZON=359.71
local			TOTAL=r(sum)+`AMAZON'
display			`TOTAL'
drop			TAG
total			RDINV if YEAR==2023
display			127509.35/376207.4

generate		TAG=1 if ///
				NACEREV2_42=="61"|NACEREV2_42=="62-63"|NACEREV2_42=="26"| ///
				NACEREV2_42=="58219"
sum				RDINV if TAG==1&YEAR==2023				
local			TOTAL=r(sum)
display			`TOTAL'
drop			TAG
total			RDINV if YEAR==2023
display			239053.4/376207.4

generate		TAG=1 if ///
				NACEREV2_42=="61"|NACEREV2_42=="62-63"|NACEREV2_42=="26"| ///
				NACEREV2_42=="58219"
sum				RDINV if TAG==1&YEAR==2003				
local			TOTAL=r(sum)
display			`TOTAL'
drop			TAG
total			RDINV if YEAR==2003
display			37260.5/83730.4
*/

/*****************************************************************
* Top 10 des entreprises en 2003 et 2023 dans 5 régions du monde *
******************************************************************/
/*
/*	On garde 2003 et 2023 */
keep if			YEAR==2003|YEAR==2023

/*	Attention au nom de la Chine */
replace			alpha2="CN_X_HK" if alpha2=="CN"
replace			COUNTRY="ChinaexceptHongKong" if COUNTRY=="China" 

/*	Tague l'UE */ 
rename			COUNTRY english
drop if			english==""
merge m:1		english using "http://www.frequency.fr/countries.dta", ///
				keepusing(english ue27_2020 alpha2)
drop if			_merge!=3
drop			_merge

/*	Tague BRICS hors Chine : Brésil, Russie, Inde, Afrique du Sud */
generate		BRICS=(english=="Brazil"| ///
				english=="Russia"| ///
				english=="South Africa"| ///
				english=="India")

/*	Attention au nom de la Chine */
replace			alpha2="CN" if alpha2=="CN_X_HK"
replace			english="China" if english=="ChinaexceptHongKong" 

/*		Vérifie que english est en bijection avec alpha2 */
save			"tempfile.dta", replace
keep			alpha2 english
duplicates drop
cls
tabulate		english
di				r(r)
tabulate		alpha2
di				r(r)
sort			alpha2 english

/*	Tague les régions/pays qui ne sont pas US, EU, CN, JP, BRICS */
use				"tempfile.dta", clear
generate		KEEP=(alpha2=="US"|alpha2=="JP"|alpha2=="CN"|alpha2=="IN")
replace			KEEP=1 if ue27_2020==1|BRICS==1

/*		Vire-les */
keep if			KEEP==1

/* 	Compter nb. pays/(régions, an) */
cls
foreach			X in 2003 2023 {
	tabulate	english if YEAR==`X'
	di			r(r)						// 26 24 en tout
	tabulate	english if ue27_2020==1&YEAR==`X'
	di			r(r)						// 19 19 UE
	tabulate	english if BRICS==1&YEAR==`X'
	di			r(r)						//  4  2 BRICS
}

/*	Sélectionne le top 20 % en 2003 et en 2023 
		Ajoute un contrainte de taille mondiale, pas nécessaire ? */
gsort			YEAR -RDINV
capture drop	TEMP1
egen			TEMP1=count(RAISON), by(YEAR)
generate		TEMP2=int(0.10*TEMP1)
by YEAR, sort: ///
				generate TEMP3=_n
generate		TEMP4=TEMP2-TEMP3
drop if			TEMP4<0
drop			TEMP*
table			YEAR						// 2003 (453), 2023 (493)

/*	Commence par lister (list) les entreprises */
/*		Créer les régions */
capture drop	REGION
generate		REGION="UE" if ue27_2020==1
replace			REGION="BRICS" if BRICS==1
replace			REGION="US" if alpha2=="US"
replace			REGION="JP" if alpha2=="JP"
replace			REGION="CN" if alpha2=="CN"

/*		Crée les rangs 1 à 10 dans chaque région */
gsort			YEAR REGION -RDINV
egen			TEMP1=count(RAISON), by(YEAR REGION)
by YEAR REGION, sort: ///
				generate TEMP2=_n
generate		TEMP3=TEMP2-10
drop if			TEMP3>0
keep			RAISON YEAR REGION TEMP2
order			RAISON, last

fillin			YEAR REGION TEMP2
order			REGION YEAR RAISON TEMP2
sort			REGION YEAR TEMP2

/*		Crée la table (OPTIMISER + TARD) */
drop			_fillin
reshape	wide	RAISON, i(REGION TEMP2) j(YEAR)
save			"tempfile.dta", replace

/*			Tableau au format région1|années | ... | régionR années */
use				"tempfile.dta", clear
keep if			REGION=="BRICS"
rename			(RAISON2003 RAISON2023)(BRICS03 BRICS23)
drop			REGION
save			"tempfile_1.dta", replace
use				"tempfile.dta", clear
keep if			REGION=="CN"
rename			(RAISON2003 RAISON2023)(CN03 CN23)
drop			REGION
save			"tempfile_2.dta", replace
use				"tempfile.dta", clear
keep if			REGION=="JP"
rename			(RAISON2003 RAISON2023)(JP03 JP23)
drop			REGION
save			"tempfile_3.dta", replace
use				"tempfile.dta", clear
keep if			REGION=="UE"
rename			(RAISON2003 RAISON2023)(UE03 UE23)
drop			REGION
save			"tempfile_4.dta", replace
use				"tempfile.dta", clear
keep if			REGION=="US"
rename			(RAISON2003 RAISON2023)(US03 US23)
drop			REGION
save			"tempfile_5.dta", replace
use				"tempfile_1", clear
merge 1:1		TEMP2 using "tempfile_2", nogenerate
merge 1:1		TEMP2 using "tempfile_3", nogenerate
merge 1:1		TEMP2 using "tempfile_4", nogenerate
merge 1:1		TEMP2 using "tempfile_5", nogenerate
drop			TEMP2
cls
list			, compress noobs table string(10)
*/

/*****************************************************************************
* Entreprises du top20, avec leur secteur en 2003 et 2023, dans cinq régions *
*	 BRICS (hors CHN), CHN, JP UE-27, USA									 *
******************************************************************************/

/*	2003, 2023 */
keep if			YEAR==2003|YEAR==2023
drop			COUNTRY

/*	Tague l'UE */
replace			alpha2="CN_X_HK" if alpha2=="CN"
*replace			alpha2="UK" if alpha2=="GB"	// PLUS LA PEINE
merge m:1		alpha2 using "http://www.frequency.fr/countries.dta", ///
				keepusing(english ue27_2020 alpha2)
drop if			_merge!=3
drop			_merge

/*	Tague BRICS hors Chine : Brésil, Russie, Inde, Afrique du Sud */
generate		BRICS=(english=="Brazil"| ///
				english=="Russia"| ///
				english=="South Africa"| ///
				english=="India")

/*	Vire les pays dont on n'a pas besoin */
replace			alpha2="CN" if alpha2=="CN_X_HK"
replace			english="China" if english=="ChinaexceptHongKong" 

/*		Vérifie que english est en bijection avec alpha2
save			"filetemp.dta", replace
keep			alpha2 english
duplicates drop
cls
tabulate		english
di				r(r)
tabulate		alpha2
di				r(r)
sort			alpha2 english
use				"filetemp.dta", clear */

/*	Tague les régions/pays qui ne sont pas US, EU, CN, JP, BRICS */
generate		KEEP=(alpha2=="US"|alpha2=="JP"|alpha2=="CN")
replace			KEEP=1 if ue27_2020==1|BRICS==1
replace			ue27_2020=0 if ue27_2020==.

/*		Vire-les */
keep if			KEEP==1
drop			KEEP

/*	Sélectionne le top 20 % en 2003 et en 2023 
		Ajoute un contrainte de taille mondiale, pas nécessaire ? */
		
/*	Règle d'abord une ambiguïté */
drop if			RAISON=="CHINA RAILWAY"
		
/*	Suite */		
gsort			YEAR -RDINV
capture drop	TEMP1
egen			TEMP1=count(RAISON), by(YEAR)
generate		TEMP2=int(0.20*TEMP1)
by YEAR, sort: ///
				generate TEMP3=_n
generate		TEMP4=TEMP2-TEMP3
drop if			TEMP4<0
drop			TEMP*
table			YEAR						// 2003 (453), 2023 (493)

/* 	Compte combien de pays par (régions, an) */
cls
tabulate		english						
di				"*" _newline(1) r(r) " pays en tout" _newline(1) "*"
foreach			X in 2003 2023 {
	tabulate	english if YEAR==`X'
	di			"*" _newline(1) r(r) " pays en tout " `X' _newline(1) "*"
	tabulate	english if ue27_2020==1&YEAR==`X'
	di			"*" _newline(1) r(r) " pays de l'UE-27 en " `X' _newline(1) "*"
	tabulate	english if BRICS==1&YEAR==`X'
	di			"*" _newline(1) r(r) " BRICS (hors CN) en " `X' _newline(1) "*"
}

/*	Commence par lister (list) les entreprises */
/*		Créer les régions */
replace			REGION="UE" if ue27_2020==1
replace			REGION="BRICS" if BRICS==1
replace			REGION="US" if alpha2=="US"
replace			REGION="JP" if alpha2=="JP"
replace			REGION="CN" if alpha2=="CN"

/*		Crée les rangs 1 à 10 dans chaque région */
gsort			YEAR REGION -RDINV
egen			TEMP1=count(RAISON), by(YEAR REGION)
	by YEAR REGION, sort: ///
				generate TEMP2=_n

/* 			Nombre d'entreprises du top 20% par pays en 2023 */
tabulate		english if YEAR==2023

/*			Continuer */	
drop if			TEMP2>10

/*		Variables de travail */
keep			RAISON NACEREV2_42_NAME_FR YEAR REGION TEMP2

/*		Cylindrer les données */
fillin			YEAR REGION TEMP2
drop			_fillin
order			REGION YEAR NACEREV2_42_NAME_FR TEMP2 RAISON
sort			YEAR REGION TEMP2

/*		Coller 2023 à droite de 2003 */
save			"filetemp1.dta", replace
keep if 		YEAR==2003
drop			YEAR
rename			(NACEREV2_42_NAME_FR RAISON)(SECTOR2003 RAISON2003)
save			"filetemp2.dta", replace
use				"filetemp1.dta", 
keep if 		YEAR==2023
drop			YEAR
rename			(NACEREV2_42_NAME_FR RAISON)(SECTOR2023 RAISON2023)
merge m:m		REGION TEMP2 using "filetemp2.dta", nogenerate
drop			TEMP2
order			REGION SECTOR2003 RAISON2003
drop if			SECTOR2023==""

/*		Un peu plus de nettoyages */
/*			Vide cellules */
replace			REGION="" if _n>=2&_n<=4
replace			REGION="" if _n>=6&_n<=14
replace			REGION="" if _n>=16&_n<=24
replace			REGION="" if _n>=26&_n<=34
replace			REGION="" if _n>=36&_n<=44

/*			Raccourcir noms des secteurs */
replace			SECTOR2003="Prod. info., électro. et optiques" if ///
	SECTOR2003=="Produits informatiques, électroniques et optiques."
replace			SECTOR2023="Prod. info., électro. et optiques" if ///
	SECTOR2023=="Produits informatiques, électroniques et optiques."

replace			SECTOR2003="Auto., autres matériels de transp." if ///
	SECTOR2003=="Automobiles et remorques; Autres matériels de transport"
replace			SECTOR2023="Auto., autres matériels de transp." if ///
	SECTOR2023=="Automobiles et remorques; Autres matériels de transport"

replace			SECTOR2003="Progr., conseil info.; Serv. d'info." if ///
	SECTOR2003=="Programmation, conseil et autres activ. info.; Serv. d'info."				
replace			SECTOR2023="Progr., conseil info.; Serv. d'info." if ///
	SECTOR2023=="Programmation, conseil et autres activ. info.; Serv. d'info."				
	
replace			SECTOR2003="Constr.; Génie civil" if ///
	SECTOR2003=="Construction; Génie civil; Travaux de construct. spécialisés"
replace			SECTOR2023="Constr.; Génie civil" if ///
	SECTOR2023=="Construction; Génie civil; Travaux de construct. spécialisés"

replace			SECTOR2003="Film., Vidé., TV., Music., Logi." if ///
	SECTOR2003=="Éd./prod. films, vidéo, tv.; Prod. music.; Éd. logiciels"
replace			SECTOR2023="Film., Vidé., TV., Music., Logi." if ///
	SECTOR2023=="Éd./prod. films, vidéo, tv.; Prod. music.; Éd. logiciels"

replace			SECTOR2003="Comm. détail, sauf auto. et motocy." if ///
	SECTOR2003=="Commerce de détail, sauf automobiles et des motocycles"
replace			SECTOR2023="Comm. détail, sauf auto. et motocy." if ///
	SECTOR2023=="Commerce de détail, sauf automobiles et des motocycles"

/*			Reccourcie noms de groupes */
replace			RAISON2003="SINOPEC" if ///
	RAISON2003=="CHINA PETROLEUM & CHEMICAL"
replace			RAISON2023="SUN PHARMACEUTICAL" if ///
	RAISON2023=="SUN PHARMACEUTICAL INDUSTRIES"
replace			RAISON2023="HUAWEI" if ///
	RAISON2023=="HUAWEI INVESTMENT & HOLDING"
replace			RAISON2023="CHINA STATE CONSTRUCTION" if ///
	RAISON2023=="CHINA STATE CONSTRUCTION ENGINEERING"
replace			RAISON2023="CCCC" if ///
	RAISON2023=="CHINA COMMUNICATIONS CONSTRUCTION"
replace			RAISON2023="CHINA RAILWAY" if ///
	RAISON2023=="CHINA RAILWAY CONSTRUCTION"
	
compress
erase			"filetemp.dta"
erase			"filetemp1.dta"
erase			"filetemp2.dta"
cd				"$PATHOUT"
save			"filetemp.dta", replace
*/

/*
/***************************************************************************
*  Chaque année, ne garder que les 10 % des plus grosses en termes de R&D  *
****************************************************************************/

*drop if			RDINV==.

/*	Trier chaque année la R&D par ordre décroissant */
gsort			YEAR -RDINV

/*	#Entreprises françaises et total par année */
capture drop	TEMP1
egen			TEMP1=count(RAISON) if COUNTRY=="France", by(YEAR)
table			YEAR, statistic(mean TEMP1)
capture drop	TEMP1
egen			TEMP1=count(RAISON), by(YEAR)
table			YEAR, statistic(mean TEMP1)

/*	Chaque année, retenir le top 10 % et compter #Entreprises 
		CN, DE, ES, FR, IT, US */
egen			TOTAL=sum(RDINV), by(YEAR)
generate		TEMP2=int(0.1*TEMP1)
by YEAR, sort: ///
				generate TEMP3=_n
generate		TEMP4=TEMP2-TEMP3
drop if			TEMP4<0
drop			TEMP*

/*	Dépense annuelle de R&D du top 10 % pour chaque pays */
egen			NUM=sum(RDINV), by(YEAR COUNTRY)

/*	Dépense annuelle de R&D du 10 % */
egen			DEN=sum(RDINV), by(YEAR)

/*	Part annuelle de la R&D de chaque pays dans le top 10 % 
		Cette variable servira à classer les pays dans l'ordre décroissant 
		de leur contribution au top 10 % */
generate		RAT=100*NUM/DEN

/*	Part de la R&D du top 10 % dans le totoal, annuel */
generate		TOTALRAT=100*DEN/TOTAL
label variable	TOTALRAT "R&D du top 10 % dans R&D totale"

drop			RDINV NUM DEN
gsort			YEAR -RAT COUNTRY
egen			TEMP1=count(RAT) if COUNTRY=="China", by(YEAR)
egen			TEMP2=count(RAT) if COUNTRY=="Germany", by(YEAR)
egen			TEMP3=count(RAT) if COUNTRY=="Spain", by(YEAR)
egen			TEMP4=count(RAT) if COUNTRY=="France", by(YEAR)
egen			TEMP5=count(RAT) if COUNTRY=="Italy", by(YEAR)
egen			TEMP6=count(RAT) if COUNTRY=="United States", by(YEAR)
table			YEAR, statistic(mean TEMP*)
drop			TEMP* RAISON NACEREV2_42*
duplicates		drop

*	Ne garde que les pays qui sont là sur toute la période (21 ans)
egen			TEMP=count(YEAR), by(COUNTRY)
keep if			TEMP==21
drop			TEMP
encode			COUNTRY, generate(COUNTRYCODE)
order			COUNTRY*, last

xtset			COUNTRYCODE YEAR
label variable	COUNTRYCODE "Pays"
label variable	YEAR " "
label variable	RAT "Part (%)"

/*	UE et Autres
		Remarque : Lhuillery et al. (2021, tableau 2, p. 21) mettent dans 
		"Autres" les pays dont la part des entreprises dans le top est
		inférierure à 1 %. J'utilise un autre critère de sélection. */
rename			COUNTRY english
replace			english="ChinaexceptHongKong" if english=="China"
merge m:1		english using "http://www.frequency.fr/countries.dta", ///
				keepusing(ue27_2020 francais alpha2)
drop if			_merge!=3
drop			_merge english
replace			francais="Chine" if alpha2=="CN"
replace			ue27_2020=0 if ue27_2020==.
rename			francais COUNTRY
tabulate		COUNTRY if ue27_2020==1
di				r(r)
tabulate		COUNTRY if ue27_2020==0
di				r(r)
gsort			YEAR -RAT
sort			COUNTRYCODE YEAR

local			TEMP1=21
local			OBSNEW=_N
local			TEMP2=`OBSNEW'
local			OBSOLD=`OBSNEW'
local			OBSNEW=`OBSOLD'+`TEMP1'
set obs			`OBSNEW'
replace			COUNTRY="Autres" if _n>`OBSOLD'
egen			RATSUM=sum(RAT) if ue27_2020==0& ///
				COUNTRYCODE!=3&COUNTRYCODE!=19, by(YEAR)
local			TEMP3=`TEMP2'
	forvalues	I=1(1)`TEMP1' {
		local	TEMP4=RATSUM[`I']
		local	++TEMP3
		replace	RATSUM=`TEMP4' if COUNTRY=="Autres"&_n==`TEMP3'
		replace	YEAR=2003+`I'-1 if COUNTRY=="Autres"&_n==`TEMP3'
	}
replace			RAT=RATSUM if COUNTRY=="Autres"
drop			RATSUM
drop			if ue27_2020==0&COUNTRYCODE!=3&COUNTRYCODE!=19

local			TEMP1=21
local			OBSNEW=_N
local			TEMP2=`OBSNEW'
local			OBSOLD=`OBSNEW'
local			OBSNEW=`OBSOLD'+`TEMP1'
set obs			`OBSNEW'
replace			COUNTRY="UE" if _n>`OBSOLD'
egen			RATSUM=sum(RAT) if ue27_2020==1, by(YEAR)
local			TEMP3=`TEMP2'
	forvalues	I=1(1)`TEMP1' {
		local	TEMP4=RATSUM[`I']
		local	++TEMP3
		replace	RATSUM=`TEMP4' if COUNTRY=="UE"&_n==`TEMP3'
		replace	YEAR=2003+`I'-1 if COUNTRY=="UE"&_n==`TEMP3'
	}
replace			RAT=RATSUM if COUNTRY=="UE"
drop			RATSUM
drop			if ue27_2020==1
drop 			ue27_2020 COUNTRYCODE

encode			COUNTRY, generate(COUNTRYCODE)
drop			COUNTRY
sort			YEAR COUNTRYCODE
egen			TEMP=sum(RAT), by(YEAR)

xtset			COUNTRYCODE YEAR
xtline			RAT, overlay ///
					legend(rows(1) position(6) size(small)) ///
					xlabel(2003(2)2023)	///
					ylabel(0(20)100) ytitle("") ///
					plot1(lcolor(eltblue%40)) ///
					plot2(lcolor(black)) ///
					plot3(lcolor(eltblue)) ///
					plot4(lcolor(cranberry)) ///
					addplot(tsline TOTALRAT, lcolor(grey%60) lpattern(dash))
s
cd				"`PATHOUT'"
graph export 	"rd_scoreboard_1224.png", width(800) height(600) replace
graph export 	"rd_scoreboard_1224.pdf", replace
graph export 	"rd_scoreboard_1224.svg", replace
*/

/*
/*****************************************************
*  Distributions des dépenses de R&D en 2003 et 2023 *
******************************************************/

drop			RAISON NACEREV2_42* REGION COUNTRY
drop if			RDINV==.

/*	Garde les années 2003 et 2023 */
keep if			YEAR==2003|YEAR==2023

/*	Trier chaque année la R&D par ordre décroissant */
sort			YEAR RDINV

/*	R&D/an */
egen			TOTAL=sum(RDINV), by(YEAR)

/*	#Entreprises/an */
capture drop	TEMP1
egen			TEMP1=count(alpha2), by(YEAR)
by YEAR, sort: 	generate TEMP2=_n
generate		TEMP3=100*TEMP2/TEMP1

/*		100 centiles par année */
by YEAR, sort: 	generate TEMP4=autocode(TEMP3,100,0,100)

/*		Pour chaque centile, reporte la valeur max du centile */
egen			TEMP5=max(RDINV), by(YEAR TEMP4)

/*		Ne garde que les 100 centiles */
keep			YEAR TEMP4 TEMP5
duplicates		drop

/*		Taux de variation de la R&D par déciles */
save			"rd_scoreboard_1224_filetemp.dta", replace
by YEAR, sort: 	generate TEMP6=floor((_n-1)/10)
egen			TEMP7=sum(TEMP5), by(YEAR TEMP6)
drop			TEMP4 TEMP5
duplicates drop
reshape wide	TEMP7, i(TEMP6) j(YEAR)
replace			TEMP6=TEMP6+1
rename			(TEMP6 TEMP72003 TEMP72023)(X Y1 Y2)
generate		ROC=100*((Y2/Y1)^(1/20)-1)
scatter			ROC X, xlabel(1(1)10)

/*		R&D en ln */
use				"rd_scoreboard_1224_filetemp", clear
generate		TEMP6=ln(1+TEMP5)

label variable	TEMP4 "Déciles"
label variable	YEAR " "
label variable	TEMP6 "R&D"

local			I=0
local			J=exp(`I')
forvalues		K=1(1)11 {
	di			`K' ": " `I' ", " `J' "."
	local		I=`I'+0.1*ln(40000)
	local		J=exp(`I')
	di
}

twoway			(scatter TEMP6 TEMP4 if YEAR==2003, ///
				color(red) ///
				xlabel(0(10)100) ///
				ylabel(	 0.0000     "1,0" 1.0596    "2,8" 2.1193     "8,3" 3.1789 "24,0" ///
						 4.2386    "69,3" 5.2983  "200,0" 6.3579   "577,0" ///
						 7.4176  "1665,1" 8.4773 "4804,5" 9.5369 "13862,9" ///
						10.5966 "40000,0") ///
				connect(1) msymbol(none)) ///
				(scatter TEMP6 TEMP4 if YEAR==2023, ///
				color(green) ///
				connect(1) msymbol(none))
				
twoway			(hist TEMP6 if YEAR==2003, bin(20) percent ///
				color(red%80) ///
				xlabel(0(1)10)) ///
				(hist TEMP6 if YEAR==2023, bin(20) percent ///
				color(green%80))
	
count if		TEMP5>=100&TEMP5<=1000&YEAR==2003
count if		TEMP5>=100&TEMP5<=1000&YEAR==2023
by YEAR, sort: su TEMP5, d	
*/