/*	Quelques noms à corriger en harmonie avec ma base Scoreboard EU */
{
use 			"scoreboard_panel.dta", clear
replace			RAISON="ALK-ABELLO" if RAISON=="ALK ABELLO"

/*		Les "NOW", "NOW PART" ne font plus partie du Scoreboard Panel */

/*		Il y a quelques noms avec une parenthèse ; ex. BLACKBOARD (UK) */

/* 		Le cas KORSNAS n'en n'est plus un, mais il y a une entreprise 
			BILLERUDKORSNAS */

/*			Jette un oeil pour voir s'il reste des cas ambigus */
*keep			RAISON
*duplicates drop	RAISON, force
replace			RAISON="HAMBURGER HAFEN UND LOGISTIK" if ///
				RAISON=="HAMBURGER HAFEN UND LOGSTIK"
replace			RAISON="MUHLBAUER" if RAISON=="MUEHLBAUER"
split			RAISON, generate(TEMP_) parse("RED ELECTRICA")
replace			RAISON="RED ELECTRICA DE ESPANA" if TEMP_1==""
drop			TEMP_1
replace			RAISON="STRATEC BIOMEDICAL SYSTEMS" if ///
				RAISON=="STRATEC"
replace			RAISON="WAAGNER-BIRO" if RAISON=="WAAGNER BIRO"
replace			RAISON="EL.EN" if RAISON=="EL EN"

/*			Des doublons ?
				(Entreprises, Année) en double ? 1 cas
				On pourrait prendre la moy. des obs., mais soit les secteurs
				des doublons sont différents, soit le pays
				L'entreprise WAAGNER-BIRO, de 2012 à 2017 en double.
					Le secteur, le pays diffèrent les années doublons */
duplicates tag	RAISON YEAR, generate(RAISONPURE)
gsort			-RAISONPURE RAISON YEAR
table			RAISONPURE
drop if			RAISON=="WAAGNER-BIRO"&COUNTRY=="Luxembourg"&RAISONPURE==1
drop			RAISONPURE
sort			RAISON YEAR
save			"scoreboard_panel.dta", replace

/*	Cree une variable qui prend la valeur 1 si le nom a la ligne n est inclut
		dans le nom a la ligne n+1. Il y a plusieurs cas. */
keep			RAISON
duplicates drop	RAISON, force
sort			RAISON
generate		RAISONAVANT=RAISON[_n-1] if _n>1
generate		MATCH=regexm(RAISON,RAISONAVANT) if _n>1
generate		MATCHNPLUS1=MATCH[_n+1]
order			MATCH*
gsort			-MATCH RAISON
count if		MATCH==1
/*		Il y a 237 couples d'entreprises dont le nom de l'une rentre dans
			dans l'autre. À y regarder de plus près, certains couple diffèrent
			d'un nombre de caractères pouvant aller jusqu'à 10. Il y a donc
			peu de chances qu'il sagisse de la même entreprise. Par ailleurs,
			certains couples dont les nombres de caractères des noms sont
			proches (3 dans 7), ont des noms qui ne semblent rien avoir ; par
			ex. : ALIAXIS et ALI. [et BICYCLE THERAPEUTICS et BIC. ?]
		 Pour l'instant, je ne fait aucun remplacement comme suit:

replace			MATCH=MATCHNPLUS1 if MATCHNPLUS1==1
keep if			MATCH==1
count if		MATCHNPLUS1==1
rename			MATCHNPLUS1 KEEP
keep			RAISON KEEP
save			"filetemp.dta", replace	// Fichier des entreprises à virer
sort			RAISON YEAR		
replace			RAISON=upper(RAISON)
replace			RAISON=rtrim(RAISON)
merge m:1		RAISON using "filetemp.dta"
drop			_merge 

 		Si une entreprise appartenant aux cas dicsutés précédelment a son année
			d'obs. max plus petite que 2021, on la vire. On traite séparemment
			celles qui ont leur nom court ou long
egen			YEARMAX0=max(YEAR) if KEEP==0, by(RAISON)
egen			YEARMAX1=max(YEAR) if KEEP==1, by(RAISON)
drop if			KEEP==0&YEARMAX0<2021
drop if			KEEP==1&YEARMAX1<2021
drop			KEEP YEARMAX* 

/* Valeurs aberrantes 
gsort			-RDINV

	CHONGOING CHANGAN ? */
