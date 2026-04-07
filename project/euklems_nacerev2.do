/*	Transforme les codes et étiquettes de EU_KLMENS en format NACE

		Evens Salies,	v1   /2023
						v2   /2024
						v3 03/2025 */

save			"filetemp", replace

use				"C:\Users\82128\Documents\DATA\Branch\national_accounts.dta", clear 
keep			nace_r2_code nace_r2_name
duplicates 		drop

/*	Garde les divisions seules ou agrégées, sans Sections */
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

rename			X NACEREV2_42
rename			nace_r2_name NACEREV2_42_NAME_EN

/*	Ajoute les noms en français (jusqu'à 60 caractères) */
generate		NACEREV2_42_NAME_FR = ""
replace			NACEREV2_42_NAME_FR = "Agriculture, sylviculture et pêche" if NACEREV2_42 == "01-03"
replace			NACEREV2_42_NAME_FR = "Industries extractives" if NACEREV2_42 == "05-09"
replace			NACEREV2_42_NAME_FR = "Industries alimentaires; Boissons; Produits à base de tabac" if NACEREV2_42 == "10-12"
replace			NACEREV2_42_NAME_FR = "Textiles; Articles d'habillement." if NACEREV2_42 == "13-15"
replace			NACEREV2_42_NAME_FR = "Travail du bois; Papier; Imprimerie, reproduction d'enreg." if NACEREV2_42 == "16-18"
replace			NACEREV2_42_NAME_FR = "Cokéfaction et raffinage" if NACEREV2_42 == "19"
replace			NACEREV2_42_NAME_FR = "Industrie chimique" if NACEREV2_42 == "20"
replace			NACEREV2_42_NAME_FR = "Industrie pharmaceutique" if NACEREV2_42 == "21"
replace			NACEREV2_42_NAME_FR = "Produits en caoutchouc/plastique; Minéraux non métalliques" if NACEREV2_42 == "22-23"
replace			NACEREV2_42_NAME_FR = "Métallurgie; Produits métalliques, sauf mach. et équi." if NACEREV2_42 == "24-25"

replace			NACEREV2_42_NAME_FR = "Produits informatiques, électroniques et optiques." if NACEREV2_42 == "26"
replace			NACEREV2_42_NAME_FR = "Équipements électriques" if NACEREV2_42 == "27"
replace			NACEREV2_42_NAME_FR = "Machines et équipements n.c.a." if NACEREV2_42 == "28"
replace			NACEREV2_42_NAME_FR = "Automobiles et remorques; Autres matériels de transport" if NACEREV2_42 == "29-30"
replace			NACEREV2_42_NAME_FR = "Fabric. de meubl; Autres. ind. man.; Rép. ins. mach./équi." if NACEREV2_42 == "31-33"
replace			NACEREV2_42_NAME_FR = "Prod. et distri. d'élec., de gaz, de vapeur et d'air condit." if NACEREV2_42 == "35"
replace			NACEREV2_42_NAME_FR = "Prod. et distri. d'eau; assainiss., gest. déchets et dépoll." if NACEREV2_42 == "36-39"
replace			NACEREV2_42_NAME_FR = "Construction; Génie civil; Travaux de construct. spécialisés" if NACEREV2_42 == "41-43"
replace			NACEREV2_42_NAME_FR = "Commerce et réparation d'automobiles et de motocycles" if NACEREV2_42 == "45"
replace			NACEREV2_42_NAME_FR = "Commerce de gros, sauf automobiles et des motocycles" if NACEREV2_42 == "46"

replace			NACEREV2_42_NAME_FR = "Commerce de détail, sauf automobiles et des motocycles" if NACEREV2_42 == "47"
replace			NACEREV2_42_NAME_FR = "Transports terrestres et transport par conduites" if NACEREV2_42 == "49"
replace			NACEREV2_42_NAME_FR = "Transports par eau" if NACEREV2_42 == "50"
replace			NACEREV2_42_NAME_FR = "Transports aériens" if NACEREV2_42 == "51"
replace			NACEREV2_42_NAME_FR = "Entreposage et services auxiliaires des transports" if NACEREV2_42 == "52"
replace			NACEREV2_42_NAME_FR = "Activ. de poste et de courrier" if NACEREV2_42 == "53"
replace			NACEREV2_42_NAME_FR = "Hébergement et restauration" if NACEREV2_42 == "55-56"
replace			NACEREV2_42_NAME_FR = "Éd./prod. films, vidéo, tv.; Prod. music.; Éd. logiciels" if NACEREV2_42 == "58-60"
replace			NACEREV2_42_NAME_FR = "Télécommunications" if NACEREV2_42 == "61"
replace			NACEREV2_42_NAME_FR = "Programmation, conseil et autres activ. info.; Serv. d'info." if NACEREV2_42 == "62-63"

replace			NACEREV2_42_NAME_FR = "Activ. financières et d'assurance" if NACEREV2_42 == "64-66"
replace			NACEREV2_42_NAME_FR = "Activ. immobilières" if NACEREV2_42 == "68"
replace			NACEREV2_42_NAME_FR = "Activ. spécialisées, scientifiques et techniques" if NACEREV2_42 == "69-75"
replace			NACEREV2_42_NAME_FR = "Activ. de services administratifs et de soutien" if NACEREV2_42 == "77-82"
replace			NACEREV2_42_NAME_FR = "Administration publique" if NACEREV2_42 == "84"
replace			NACEREV2_42_NAME_FR = "Enseignement" if NACEREV2_42 == "85"
replace			NACEREV2_42_NAME_FR = "Activ. pour la santé humaine" if NACEREV2_42 == "86"
replace			NACEREV2_42_NAME_FR = "Hébergement médico-social et social, Action sociale sans hébergement" if NACEREV2_42 == "87-88"
replace			NACEREV2_42_NAME_FR = "Arts, spectacles et activ. récréatives" if NACEREV2_42 == "90-93"
replace			NACEREV2_42_NAME_FR = "Autres activ. de services" if NACEREV2_42 == "94-96"

replace			NACEREV2_42_NAME_FR = "Activ. ménag. employeurs; ménag. producteurs de B&S pour soi" if NACEREV2_42 == "97-98"
replace			NACEREV2_42_NAME_FR = "Activ. extra territoriales" if NACEREV2_42 == "99"

label variable	NACEREV2_42 "Code Nace Rév. 2 (42)"
label variable	NACEREV2_42_NAME_FR "Nom Nace Rév. 2 (42)"
drop			NACEREV2_42_NAME_EN
compress
save			"euklems_nacerev2.dta", replace

/*	Passage de 42 à 36 secteurs pour diagrammes en étoile */

use				"filetemp.dta", clear