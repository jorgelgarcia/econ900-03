set more off
clear all
set matsize 11000
set maxvar  32000
set seed 0

// set environment variables
global projects: env projects
global storage : env storage

// locations
global data = "$storage/econ900/econ900-03/final"
global code = "$projects/econ900-03_empirical/classcodes"

cd  $data
use lottery_newstata.dta, clear

//use "C:\Users\admin\Google Drive (jpiusne@g.clemson.edu)\Clemson PhD\SEM 4 Fall 2020\Econ 003\Final Exam\lottery_newstata.dta"

//1.
global X lotcateg year

// create categories of observed characteristics
egen g = group($X)
sort g
drop if g ==.
summ g
forvalues i = 0/`r(max)'{
	bysort g : egen  lnw1 = mean(lnw) if z==1
	bysort g : egen  lnw0 = mean(lnw) if z==0
	bysort g : egen  zd1 = mean(d) if z==1
	bysort g : egen  zd0 = mean(d) if z==0
	}
keep d lnw1 lnw0 g zd1 zd0
gen  counter = 1
describe
gen N = r(N)
collapse (mean) lnw1 lnw0 zd1 zd0 N (sum) d counter, by(g)	
//2. generate weighted mean difference
gen 	RS = lnw1-lnw0
gen   	zd  = zd1 - zd0
gen		LATE = RS/zd
gen     weight   =  counter / N
gen     Wtd_LATE =  weight*LATE
summ    Wtd_LATE
matrix  LATE_wsum = r(sum)
mat list LATE_wsum // .21283848

//3.
/******************Boot Strap***************/
set more off
clear all
set matsize 11000
set maxvar  32000
set seed 1
global bootstraps 1000

set obs 1476

// simulate bivariate regression with a = 1.3 and b = .5
// y = a + b*D + e
// regressor is dummy 
scalar a = 3.0026167
scalar b = .21283848

// simulate dummy variable
gen d = runiform()
gen D = cond(d < .6, 1, 0)

// simulate e 
gen U = runiform(1,2)
gen e = rnormal(0,1) if U< 1.2
replace e = rnormal(0,2) if U>= 1.2 & U < 1.3
replace e = rnormal(0,3) if U>= 1.3 & U < 1.4
replace e = rnormal(0,4) if U>= 1.4 & U < 1.5
replace e = rnormal(0,5) if U>= 1.5 & U < 1.6
replace e = rnormal(0,6) if U>= 1.6 & U < 1.7
replace e = rnormal(0,7) if U>= 1.7 & U < 1.8
replace e = rnormal(0,8) if U>= 1.8 & U <= 2
 
gen group = 1 if U< 1.2
replace group = 2 if U>= 1.2 & U < 1.3
replace group = 3 if U>= 1.3 & U < 1.4
replace group = 4 if U>= 1.4 & U < 1.5
replace group = 5 if U>= 1.5 & U < 1.6
replace group = 6 if U>= 1.6 & U < 1.7
replace group = 7 if U>= 1.7 & U < 1.8
replace group = 8 if U>= 1.8 & U <= 2


// simulate e with sigma2 = 1
//scalar sigma2 = 1
//gen e = rnormal(0,sigma2) 

// state y
gen y = a + b*D + e

// display estimates
reg    y D
matrix beta = e(b)
scalar a = beta[1,2]
scalar b = beta[1,1]

// explore model
#delimit
twoway (histogram y, barw(.1) lcolor(gs0) fcolor(none))
       (kdensity  y, lcolor(gs0)) ,
		  legend(label(1 "histogram")  label(2 "density") order(1 2) row(1))
		  ylabel(, grid glcolor(gs14) angle(h) labsize(medlarge)) 
		  xlabel(, grid glcolor(gs14) angle(h)) 
		  ytitle("Density")
		  xtitle("Support", size(medlarge))
		  graphregion(color(white)) plotregion(fcolor(white));
#delimit cr

matrix ab_B = J(1,2,.)
matrix colnames ab_B = a_B b_B

gen id = _n
// estimate in bootstrap samples
forvalues b = 1(1)$bootstraps {
	preserve
	bsample 
	reg y D, cluster(group) // Clustering for 8 groups because lottery is only exogenous within year X lottery category cells.
	matrix beta = e(b)
	matrix a_`b' = beta[1,2]
	matrix b_`b' = beta[1,1]
	
	matrix ab_`b' = [a_`b',b_`b']
	matrix ab_B = [ab_B \ ab_`b']
//	matrix list a_`b'
//	matrix list b_`b'
//	matrix list ab_`b'
//	matrix list ab_B
	restore
}

// bring on bootstrap distribution to data
matrix ab_B = ab_B[2...,1...]
svmat  ab_B, names(col)

// variance-covariance matrix
correlate a_B b_B, cov

// create non-parametric 90% confidence interval for b
summ b_B
scalar bmin = r(p5)
scalar bmax = r(p95)
scalar bmean = r(mean)
scalar SE = r(sd)
display bmin
display bmax
