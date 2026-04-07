/*
	Calcul de productivité à la :

	Griliches,
	Levinsohn-Petrin,
	Doraszelski et Jaumandreu
	
*/

use				"scoreboard_panel_final.dta", clear
encode			RAISON, generate(RAISONCODE)
xtset			RAISONCODE ANNEE

generate		y=log(SALES)
generate		l=log(EMPL)
generate		r=log(RDINV)
generate		s=log(RSTOCK)
generate		k=log(KSTOCK)

generate		p=log(P)
generate		pM=log(PM)
generate		w=log(W)
 
/*  Sans effets individuels, sans biens intermédiaires */
regress 		y k l
test			_b[k]+_b[l]=1	/* Rendements d'échelle 1,002 */

/* Dans le panel */
xtreg			y k l, fe
test			_b[k]+_b[l]=1	/* 0,978 */

/* Sans effets individuels, avec biens intermédiaires (substitution) */
generate		wpM=w-pM
regress			y k l wpM
generate		nottouse=(y==.|k==.|l==.|wpM==.)


nl 				(y={b0} ///
					+{bk}*k ///
					+{bl}*l ///
					+{bm}*wpM) ///
				if nottouse==0, delta(1e-5)
				
nl 				(y={b0prime} ///
					+{bk}*k ///
					+({bl}+{bm})*l ///
					+{bm}*wpM) ///
				if nottouse==0, delta(1e-5)
				
/*	Retrouver b0 = boprime - bm*log(bm/bl) */
			

/* Griliches */
regress 		y k l
predict			resid, residuals	/* resid : productivité */
regress			d1.resid d1.s		/* alpha */

/* Griliches */
regress 		y k l
ivregress 2sls	y k (l = l1.p)
drop			resid
predict			resid, residuals	/* resid : productivité */
regress			d1.resid d1.s		/* alpha */

/* Bon et Guceri [PAS FAIT] */
ivregress 2sls	y k (l = l1.p)

/* Doraszelski et Jaumandreu à la Levinsohn-Petrin */
set more off
generate		rl1=l1.r
prodest			y, method(lp) free(l) state(k) proxy(wpM) endogenous(rl1)

/*		Par secteurs européens */