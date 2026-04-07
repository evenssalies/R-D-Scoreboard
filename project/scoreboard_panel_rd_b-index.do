/* B-index 
	01/2025
	Evens Salies */

local			FOLDER="DATA\Production\support\"
local			FILEIN="`FOLDER'"+"OECD_RDTAX_DB2023_2.xlsx"

/* Importe à partir de la ligne 7 */
import excel using ///
				"`FILEIN'", sheet("2b_RDTAXSUB_Data") cellrange(A6) clear

/* Il y a des variables inutiles */
drop			G-Y

/* Renommer les variables, arrange les donneés */
rename			(A B C D E F)(alpha3 english YEAR SIZE PROFIT TEMP)
drop in			1
compress

/* Entités géographiques que l'on garde */
drop if			english=="EU"
drop if			english=="OECD"
destring		YEAR TEMP, replace

rename			TEMP TEMP_
reshape wide	TEMP_, i(alpha3 english YEAR SIZE) j(PROFIT) string
rename			(TEMP_Loss TEMP_Profit) ///
				(TEMP_L_ TEMP_P_)
reshape wide	TEMP_*, i(alpha3 english YEAR) j(SIZE) string
rename			(TEMP_L_Large TEMP_P_Large) ///
				(TEMP_L_GE TEMP_P_GE)
rename			(TEMP_L_SME TEMP_P_SME) ///
				(TEMP_L_PME TEMP_P_PME)

/* B-index */
replace			TEMP_L_GE=1-TEMP_L_GE
replace			TEMP_L_PME=1-TEMP_L_PME
replace			TEMP_P_GE=1-TEMP_P_GE
replace			TEMP_P_PME=1-TEMP_P_PME
rename			(TEMP_L_GE TEMP_L_PME TEMP_P_GE TEMP_P_PME) ///
				(BI_L_GE BI_L_PME BI_P_GE BI_P_PME)

keep if			YEAR>=2003&YEAR<=2023

merge m:1		alpha3 using "http://www.frequency.fr/countries.dta", ///
				keepusing(alpha2)
keep if 		_merge==3

/*		Corrige GB -> UK */
replace			alpha2="UK" if alpha2=="GB"

drop			_merge alpha3 english 
merge m:m		alpha2 YEAR using "scoreboard_panel.dta"
keep if			_merge==3
drop			_merge

order			BI_*, after(N_FIRMES)
order			YEAR, after(COUNTRY)

sort			COUNTRY YEAR NACEREV2_42