/*				Classes de taille d'effectif */
generate		TAILLE=4 if EMPL>=5000
replace			TAILLE=3 if EMPL<5000					
replace			TAILLE=2 if EMPL<250
replace			TAILLE=1 if EMPL<10
replace			TAILLE=. if EMPL==.
order			TAILLE, after(EMPL)