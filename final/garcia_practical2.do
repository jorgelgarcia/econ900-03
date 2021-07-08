set more off
clear all
set matsize 11000
set maxvar  32000
set seed 0
global bootstraps 500

// set environment variables
global projects: env projects
global storage : env storage

// locations
global data = "$storage/econ900/econ900-03/final"

cd  $data
use lottery_newstata.dta, clear

// 1. 
// group year and category 
egen clus = group(year lotcateg)

levelsof clus, local(lotteries)
foreach num of numlist `lotteries' {
	ivreg2 lnw (d = z) if clus == `num'
	matrix biv_`num' = e(b)
	matrix biv_`num' = biv_`num'[1,1]   // capture estimate
	matrix N_`num'   = e(N)			    // capture observations
}

// 2. 
// number of observations
summ clus
matrix N = r(N)

// the weights are the fraction of the total sample that each lottery is
matrix wiv = 0
foreach num of numlist `lotteries' {
	matrix wiv = wiv[1,1] + (N_`num'[1,1]/N[1,1])*biv_`num'[1,1]
}

// computing the iv estimate from problem 1 for comparison
ivreg2 lnw (d = z), cluster(clus)
matrix biv = e(b)
matrix biv = biv[1,1]

mat list biv
mat list wiv

// the difference in magnitude is sizable because the dependent variable is in logs! 

// 3. 
// open matrix to save boostrap estimates
matrix wivB = .
foreach b of numlist 1(1)$bootstraps {
	preserve
	bsample, cluster(clus)
	
	// repeat procedure in for each bootstrap sample
	// 1. iv for each lottery value
	levelsof clus, local(lotteries)
	foreach num of numlist `lotteries' {
		ivreg2 lnw (d = z) if clus == `num'
		matrix biv_`num' = e(b)
		matrix biv_`num' = biv_`num'[1,1]  
		matrix N_`num'   = e(N)			    
	}
	
	summ clus
	matrix N = r(N)

	// weight
	matrix wiv_`b' = 0
	foreach num of numlist `lotteries' {
		matrix wiv_`b' = wiv_`b'[1,1] + (N_`num'[1,1]/N[1,1])*biv_`num'[1,1]
	}
	
	matrix wivB = [wivB \  wiv_`b']
	restore
}
matrix wivB = wivB[2...,1]

// bring into data to plot 
svmat  wivB
rename wivB1 wivB

// locate bottom 5% and top 5%
summ wivB, d
local p5  = r(p5)
local p95 = r(p95)

// the area between the red bars is the cofidence interval
// thick great bar is zero
// thus, the estimate is > 0 with 90% confidence
#delimit
twoway (histogram wivB, barw(.01) lcolor(gs0) fcolor(none)
		  xline(0    , lpattern(dash) lcolor(gs10) lwidth(vvvthick))
		  xline(`p5' , lcolor(red) lwidth(thick))
		  xline(`p95', lcolor(red) lwidth(thick))) ,
		  legend(off)
		  ylabel(, grid glcolor(gs14) angle(h) labsize(medlarge)) 
		  xlabel(, grid glcolor(gs14) angle(h)) 
		  ytitle("Frequency")
		  xtitle("Support", size(medlarge))
		  graphregion(color(white)) plotregion(fcolor(white));
#delimit cr
