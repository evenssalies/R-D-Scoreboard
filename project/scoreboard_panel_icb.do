/*		Dans le Scoreboard 2024, les entreprises sont classées dans
		 l'ancienne nomenclature ICBNAME3-Secteur et dans la NACE-Classes.
		 (la nomenclature de ancienne (2012) a 41 secteurs).
		
		La nouvelle nomenclature ICBNAME3-Secteur, qui a 45 secteurs, ne figure
		 pas dans le Scoreboard.
		
		Ex. :
			"Health Care Equipment & Services"	ancienne ICBNAME3
			"Health Care Providers"				nouvelle ICBNAME3
		
		Mon souhait à termes est de n'utiliser que la NACE */

/*	ICBNAMEx 
		C (icb3_short) : 	 11 secteurs (y. c. "Others")
		D (icb3_name) :  	 40 secteurs (ICBNAME pour moi avant)			
		E (icb4_name) : 	108 secteurs
		
			46 missing dans C, D, E soit 0,04 %, c n'est rien
		
		F (nace_rev2) : 	412 secteurs
		G (nace_rev2_new) : 407 secteurs
			Note : la différence entre F et G et que G est une version un
						peu nettoyée de F (par ex. 0111 et 111 c'est pareil) */
/*
foreach 		X in C D E {
	quietly: 	tabulate	`X'
	di			r(r)
	count if	missing(`X')
	di			100*r(N)/_N
}
*/

order			C D F G, after(YEAR)
rename			D ICBNAME3
rename			E ICBNAME4
rename			G NACEREV2
drop			C F // ICBNAME4

/*	Vérifie chaque ICBNAME3 :
		- Dans la nouvelle nomenclature, les noms n'ont pas de "&".
			Reécrire les noms de l'ancienne de manière à ce qu'elle soit le plus
			proche possible de la nouvelle.
		- Il y a 21 Automobiles & Parts avec des espaces inutiles à g. */
duplicates tag	ICBNAME3, generate(TEMP)
replace		ICBNAME3="Automobiles & Parts" if TEMP==20

/*	Ancienne nomenclature ICBNAME3-Secteur, 40 secteurs dans les données
		1 secteur manque : 	Real Estate Investment Trusts
		2 sous-secteurs : 	Electronic Equipment
							Travel & Tourism 		*/
*tabulate	ICBNAME3
replace		ICBNAME3="Aerospace and Defence" if 					ICBNAME3=="Aerospace & Defence"
replace		ICBNAME3="Alternative Energy" if 						ICBNAME3=="Alternative Energy"
replace		ICBNAME3="Automobiles and Parts" if						ICBNAME3=="Automobiles & Parts"
replace		ICBNAME3="Banks" if 									ICBNAME3=="Banks"
replace		ICBNAME3="Beverages" if 								ICBNAME3=="Beverages"

replace		ICBNAME3="Chemicals" if 								ICBNAME3=="Chemicals"
replace		ICBNAME3="Construction and Materials" if				ICBNAME3=="Construction & Materials"
replace		ICBNAME3="Electricity" if 								ICBNAME3=="Electricity"
replace		ICBNAME3="Electronic and Electrical Equipment" if		ICBNAME3=="Electronic & Electrical Equipment"
replace		ICBNAME3="Electronic Equipment" if 						ICBNAME3=="Electronic Equipment"	// sous-secteur

replace		ICBNAME3="Financial Services" if 						ICBNAME3=="Financial Services"
replace		ICBNAME3="Fixed Line Telecommunications" if				ICBNAME3=="Fixed Line Telecommunications"
replace		ICBNAME3="Food and Drug Retailers" if 					ICBNAME3=="Food & Drug Retailers"
replace		ICBNAME3="Food Producers" if 							ICBNAME3=="Food Producers"
replace		ICBNAME3="Forestry and Paper" if						ICBNAME3=="Forestry & Paper"

replace		ICBNAME3="Gas, Water and Multi-utilities" if 			ICBNAME3=="Gas, Water & Multiutilities"
replace		ICBNAME3="General Industrials" if 						ICBNAME3=="General Industrials"
replace		ICBNAME3="General Retailers" if 						ICBNAME3=="General Retailers"
replace		ICBNAME3="Health Care Equipment and Services" if 		ICBNAME3=="Health Care Equipment & Services"
replace		ICBNAME3="Household Goods and Home Construction" if 	ICBNAME3=="Household Goods & Home Construction"

replace		ICBNAME3="Industrial Engineering" if 					ICBNAME3=="Industrial Engineering"
replace		ICBNAME3="Industrial Metals and Mining" if 				ICBNAME3=="Industrial Metals & Mining"
replace		ICBNAME3="Industrial Transportation" if					ICBNAME3=="Industrial Transportation"
replace		ICBNAME3="Leisure Goods" if 							ICBNAME3=="Leisure Goods"
replace		ICBNAME3="Life Insurance" if 							ICBNAME3=="Life Insurance"

replace		ICBNAME3="Media" if 									ICBNAME3=="Media"
replace		ICBNAME3="Mining" if 									ICBNAME3=="Mining"
replace		ICBNAME3="Mobile Telecommunications" if 				ICBNAME3=="Mobile Telecommunications"
replace		ICBNAME3="Non-life Insurance" if 						ICBNAME3=="Nonlife Insurance"
replace		ICBNAME3="Oil and Gas Producers" if 					ICBNAME3=="Oil & Gas Producers"

replace		ICBNAME3="Oil Equipment, Services and Distribution" if	ICBNAME3=="Oil Equipment, Services & Distribution"
replace		ICBNAME3="Personal Goods" if 							ICBNAME3=="Personal Goods"
replace		ICBNAME3="Pharmaceuticals and Biotechnology" if			ICBNAME3=="Pharmaceuticals & Biotechnology"
replace		ICBNAME3="Real Estate Investment and Services" if 		ICBNAME3=="Real Estate Investment & Services"
replace		ICBNAME3="Software and Computer Services" if 			ICBNAME3=="Software & Computer Services"

replace		ICBNAME3="Support Services" if							ICBNAME3=="Support Services"
replace		ICBNAME3="Technology Hardware and Equipment" if 		ICBNAME3=="Technology Hardware & Equipment"
replace		ICBNAME3="Tobacco" if 									ICBNAME3=="Tobacco"
replace		ICBNAME3="Travel and Leisure" if 						ICBNAME3=="Travel & Leisure"
replace		ICBNAME3="Travel and Tourism" if						ICBNAME3=="Travel & Tourism"		// sous-secteur