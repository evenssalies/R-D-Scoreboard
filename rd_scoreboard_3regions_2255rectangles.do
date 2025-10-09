/*
 Evens Salies, 2025.
 
 Data: EU R&D Investment Scoreboard (year 2023).
 
 Stata package treemap: Naqvi, A. (2024). Stata package "treemap" version 1.6.
 Release date 09 October 2024. https://github.com/asjadnaqvi/stata-treemap. */

cls
clear all
set maxvar 		120000

use				"datasets/rd_scoreboard_3regions_2255rectangles.dta", clear

/*	A = company name (Alphabet, Volkswagen, ...)
	J = region  (China, EU, US)
	T = R&D investment in billions of euros */

treemap 		T, ///
				by(J A) ///	
				labcond(5) ///			/* Values less than 5 not shown */
				format(%3.1f) ///		/* 1 decimal (3 digits overall) */
				labsize(2.5 3 2) ///	/* Text sizes (see treemap options) */
				fi(0 100 0) ///			/* Fill intensity */
				linewidth(0) ///
				addtitles titlegap(2) labgap(2) ///
				palette(#9E003a #555555 #7df9ff)  ///
				titleprop labprop colorprop fade(75)