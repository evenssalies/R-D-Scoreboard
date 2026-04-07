/* Impute les bons secteurs dans le Scoreboard

	Evens Salies, v2.0
	02/2025, 03/2025
	
	Notes: 

		A88	<-> ICBNAME3
		NACEREV2	Nettoyage
		
	Correspondance ICB -> NAF-A88 [ou c'est NAF-A21 ? car j'ai peu de labels]
	Note : j'ai 44 noms dans ma liste d'ICB "empirique". Des noms (Alternative
		   energy, par ex.) sont dans ma liste mais pas dans les 44 théoriques.
		   Au contraire, d'autres noms (Beverages, par ex.) ne sont pas dans ma
		   liste, mais dans la liste théorique

	Note : 	ce code inclut des productions de tableaux qui prennent du temps,
			que je n'ai pas besoin de refaire à chaque exécution du programme
			mère */

/*
/*******************
* A88 <-> ICBNAME3 *
********************/
keep			ICBNAME3
duplicates drop
sort			ICBNAME3
drop if			ICBNAME3==""
generate		A88="Services admin. et de support" if		_n==1
replace			A88="Eau & Elec." if 						_n==2|_n==13|_n==23|_n==57
replace			A88="Commerce détail, de gros et répar." if	_n==3|_n==5|_n==20|_n==21|_n==27|_n==33|_n==44|_n==45|_n==55
replace			A88="Finance et Assurance" if				_n==4|_n==17|_n==18|_n==34|_n==39|_n==40|_n==43
replace			A88="Santé" if								_n==6|_n==26|_n==46|_n==47
replace			A88="Manufacturier Haute-tech" if			_n==7|_n==8|_n==12|_n>=14&_n<=16|_n==28|_n==29|_n==49|_n==53|_n==54
replace			A88="Edition, Video et Logiciels" if 		_n==9|_n==35|_n==50|_n==51
replace			A88="Services IT" if 						_n==10|_n==19|_n==32|_n==37
replace			A88="Construction" if 						_n==11
replace			A88="Ind. Extract." if 						_n==22|_n==30|_n==36|_n==41|_n==42
replace			A88="Manufacturier Basse-tech" if 			_n==24
replace			A88="Autres serv. techniques et scient." if _n==25
replace			A88="Autre Transport et entreposage" if 	_n==31
replace			A88="Serv. jurid., compta. et manag." if 	_n==52
replace			A88="Transport aérien+Hotel et Restau." if 	_n==56
replace			A88="Immobilier" if 						_n==48
merge 1:m		ICBNAME3 using "filetemp.dta"
keep if			_merge==3
drop			_merge
order			ICBNAME3 A88, after(YEAR)
sort			RAISON YEAR
save			"scoreboard_panel.dta", replace
*/

/***********
* NACEREV2 *
***********/

/* 	Dans le Scoreboard, les codes NACE Rév. 2 sont théoriquement au niveau
		4 digits. Si on a 1, 2 ou 3 digits, c'est une erreur. Corriger. */
cls
*tabulate		NACEREV2

/*		Secteurs NA
			Note :	les imputer quand c'est possible avec une secteur de
					production, la difficulté étant qu'on a des holdings ! */
count if		NACEREV2==""
*list 			RAISON if NACEREV2=="", compress noobs table

/*			AI PERFORM HOLDINGS
				On donne le code de DAZN LIMITED: 6311 (Traitement de données, hébergement et activités connexes)
			ALDRIN
				ALDRIN TOPCO LIMITED, and 70100 in SIC, so: 7010
			FRONTIER SILICON HOLDINGS
				D'après Copilot, it specializes in semiconductor, audio technologies and consumer electronics: 2630 (Manufacture of consumer electronics)
			HOLMBERGS FIRST
				D'après Copilot, it manufacturing of safety equipment or motor: 2932 (Manufacture of other parts and accessories for motor vehicles)
			PREMIER LOTTERIES UK
				D'après Copilot, dans le "Gambling", mais son activité est adminstrative: 7490
			PRIVISTA CAPITAL
				D'après Copilot, c'est une holding company, de type: 6430 (Trusts, funds, and similar financial entities)
			SYMPHONY BIDCO
				Copilot me dit que l'actionnaire princip. est dans aviation industry (aircraft cabin systems), mais holding, so: 74909
			TIBIA INTRESSENTER
				Copilot says it operates in the sector of asset management (real estate, ...), so like PRIVISTA: 6430
			VERTIGIS HOLDINGS
				C'est une holding d'une entreprise dans l'informatique, https://www.vertigis.com/so: 5829
			YIDU
				Difficile, nom trop court, YIDU TECH INC. dans "Scoreboard_panel_2024.xlsx", could be 6209, so: 6209 */
replace			NACEREV2="6311" if RAISON=="AI PERFORM HOLDINGS"
replace			NACEREV2="7010" if RAISON=="ALDRIN"
replace			NACEREV2="2630" if RAISON=="FRONTIER SILICON HOLDINGS"
replace			NACEREV2="2932" if RAISON=="HOLMBERGS FIRST"
replace			NACEREV2="7490" if RAISON=="PREMIER LOTTERIES UK"
replace			NACEREV2="6430" if RAISON=="PRIVISTA CAPITAL"
replace			NACEREV2="7490" if RAISON=="SYMPHONY BIDCO"
replace			NACEREV2="6430" if RAISON=="TIBIA INTRESSENTER"
replace			NACEREV2="5829" if RAISON=="VERTIGIS HOLDINGS"
replace			NACEREV2="6209" if RAISON=="YIDU"

/*		Secteurs "0" */
count if		NACEREV2=="0"
*list 			RAISON if NACEREV2=="0", compress noobs table

/*			PLADIS FOODS */	
replace			NACEREV2="7010" if RAISON=="PLADIS FOODS"

/*		Check */
count if		NACEREV2==""|NACEREV2=="0"

/*		Secteurs à 3 digit
			Note :	il manque probablement un 0 devant (par ex., on a 116 dans
					la base, mais c'est 0116. Je me sers d'ICBNAME3 et du nom
					des entreprises. Et enfin, d'autres années où l'entreprise
					est dans la base dans un ou plusieurs autres secteurs */
gen				LENGTH=length(NACEREV2)
order			LENGTH
sort			LENGTH NACEREV2 RAISON YEAR
*tabulate		LENGTH										// 426 à 3 digit
*table			(NACEREV2 ICBNAME3) if LENGTH==3, nototals	// 16 secteur
*table			(NACEREV2 RAISON) if LENGTH==3, nototals	// 16 secteur

/*			Impute chaque secteur NACE xyz de la base
				xyz, 	ICBNAME abcd... (#obs),							Nom NACE 0xyz) 
				116,	Food Producers (14),							Growing of fibre crops
				161,	General Industrials (11),						Support activities for crop production
				162, 	Food Producers (2),								Support activities for animal production
				210, 	Forestry and Paper (21),						Silviculture and other forestry activities
				321, 	Food Producers (11),							Marine aquaculture
				510, 	Mining (22),									Mining of hard coal
				520, 	Mining (14),									Mining of lignite
				610, 	Oil and Gas Producers (98),						Extraction of crude petroleum
						Pharmaceuticals and Biotechnology (10),			Extraction of crude petroleum
				620, 	Oil and Gas Producers (11),						Extraction of natural gas
				721,	Electricity (2),								Mining of uranium and thorium ores
				729,	Industrial Metals and Mining (22),				Mining of other non-ferrous metal ores
						Technology Hardware and Equipment (1),			Mining of other non-ferrous metal ores
				811, 	Mining (9),										Quarrying of ornamental and building stone, limestone, gypsum, chalk and slate
				812, 	Mining (15),									Operation of gravel and sand pits; mining of clays and kaolin
				891, 	Chemicals (10),									Mining of chemical and fertiliser minerals
				893, 	Chemicals (9),									Extraction of salt
				910, 	Oil and Gas Producers (10),						Support activities for petroleum and natural gas extraction
						Industrial Engineering (16),					Support activities for petroleum and natural gas extraction
						Oil Equipment, Services and Distribution (106),	Support activities for petroleum and natural gas extraction
						Software and Computer Services (12),			Support activities for petroleum and natural gas extraction
				
				xyz,	RAISON(s) si recherche nécessaire,				NACE prédit		
				116,	SAKATA SEED,									0116
				161,	SIME DARBY,										0161
				162,													0162
				210,													0210
				321,													0321
				510,													0510
				520,													0520
				610,													0610
				620,													0620
				721,	AREVA, ORANO									0721
				729,	HUNAN NONFER ..., KROMEK GROUP, MOLYCORP,		0729	
				811,													0811
				812,													0812
				891,													0891
				893,	DAISO COMPANY LIMITED							0893
				910,													0910 */
replace			NACEREV2="0"+NACEREV2 if LENGTH==3
sort			RAISON YEAR NACEREV2
drop			LENGTH

/*	Est-ce que les entreprises changent de secteur dans le temps ? */
sort			RAISON NACEREV2
by				RAISON: ///
	generate	TEMP=(_n==1)
order			TEMP
by				RAISON: ///
	replace		TEMP=sum(TEMP)	
*tabulate		TEMP
drop			TEMP
sort			RAISON YEAR

/*	Divisions NACEREV2
		Note :	en préparation de la fusion avec EU-KLEMS, code les Sections 
				par exemple 0103 (pas A) pour les divisions 01-03. */
*tabulate		NACEREV2
*di				r(r)		// 393 classes
generate 		NACEREV2_88 = substr(NACEREV2, 1, 2)
*tabulate		NACEREV2_88
*di				r(r)		// 80 divisions
order			NACEREV2_88, after(NACEREV2)

/*	Sections NACEREV2
	Notes. 	1. En préparation de la fusion avec EU-KLEMS, code les Sections 
			par exemple 29-30 pour les divisions C29-C30, et 01-03 pour A.
			2. Je sors l'édition de logiciels 5821|5829 du groupe 58-60.
			3. Cela ajoute 1 secteur "58219" aux 42 de EU-KLEMS, mais je garde
			le suffixe "42". */
do				"euklems_nacerev2.do"
			
generate		NACEREV2_42=""
clonevar		X1=NACEREV2_88
destring		X1, replace
rename			NACEREV2_42 X2
order			X1 X2, after(NACEREV2_88)

replace 		X2 = "01-03" if X1 >= 1 & X1 <= 3
replace 		X2 = "05-09" if X1 >= 5 & X1 <= 9
replace 		X2 = "10-12" if X1 >= 10 & X1 <= 12
replace 		X2 = "13-15" if X1 >= 13 & X1 <= 15
replace 		X2 = "16-18" if X1 >= 16 & X1 <= 18
replace 		X2 = "22-23" if X1 >= 22 & X1 <= 23
replace 		X2 = "24-25" if X1 >= 24 & X1 <= 25
replace 		X2 = "29-30" if X1 >= 29 & X1 <= 30
replace 		X2 = "31-33" if X1 >= 31 & X1 <= 33
replace 		X2 = "36-39" if X1 >= 36 & X1 <= 39
replace 		X2 = "41-43" if X1 >= 41 & X1 <= 43
replace 		X2 = "55-56" if X1 >= 55 & X1 <= 56
replace 		X2 = "58-60" if X1 >= 58 & X1 <= 60
replace 		X2 = "62-63" if X1 >= 62 & X1 <= 63
replace 		X2 = "64-66" if X1 >= 64 & X1 <= 66
replace 		X2 = "69-75" if X1 >= 69 & X1 <= 75
replace 		X2 = "77-82" if X1 >= 77 & X1 <= 82
replace 		X2 = "87-88" if X1 >= 87 & X1 <= 88
replace 		X2 = "90-93" if X1 >= 90 & X1 <= 93
replace 		X2 = "94-96" if X1 >= 94 & X1 <= 96
replace 		X2 = "97-98" if X1 >= 97 & X1 <= 98

replace			X2 = NACEREV2_88 if X2 == ""

/*	Edition de logiciels 
		Le groupe 58-60 n'inclut plus l'édition de logiciels.
		Et créer une dummy pour le 5821 (édition de jeux vidéo) */
replace			X2 = "58219" if NACEREV2=="5821"|NACEREV2=="5829"
rename			X2 NACEREV2_42

/*	Traitement particulier de certains secteurs, sur la base des noms des
		entreprises. Des entreprises comme Atari, qui ne font plus de jeux,
		ne sont plus dans le 5821. 
		
		1) Noms d'entreprises du JV qui sont ou ont été dans le JV
			ATARI, 				2003-2023,	6200
			ELECTRONIC ARTS,	2003-2023,	5829
			SQUARE ENIX,		2004-2012,	6201,	2013-2019,	5821	
			UBISOFT,			2003-2023,	6201 */
generate		JV=(NACEREV2=="5821")
replace			JV=1 if RAISON=="ATARI"| ///
						RAISON=="ELECTRONIC ARTS"| ///
						RAISON=="SQUARE ENIX"| ///
						RAISON=="UBISOFT"
drop			ICBNAME3 NACEREV2 NACEREV2_88 X1

/*	Importe les noms de secteurs
	Notes.	1. _merge==1 : il y a le secteur 58219 que l'on vient de créér, qui
			n'est donc pas par définition dans EU-KLEMS.
			2. _merge==2 : il y a les secteurs de EU-KLEMS dans lesquels
			aucune entreprise du Scoreboard n'est (87-88, 97-98). */
merge m:1		NACEREV2_42 using "euklems_nacerev2.dta", ///
				keepusing(NACEREV2_42_NAME_FR)
drop if		_merge==2
drop		_merge

replace		NACEREV2_42_NAME_FR="Éd. logiciels" if NACEREV2_42=="58219"
				
order			NACEREV2_42_NAME_FR, after(NACEREV2_42)