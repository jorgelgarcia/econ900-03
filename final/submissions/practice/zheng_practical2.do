cls  //clear screen
clear all
set more off  //show all results
//set matsize 11000
//set maxvar 32000
set seed 1  //reset random number

global bootstraps 1000  //bootstrap distributions with 1000 re-samplings

//set environment variables
global projects: env projects
global storage : env storage

//locations
global data = "$storage/econ900/econ900-03/final"
//global code = "$projects/econ900-03_empirical/classcodes"

//open data
//cd  $data
use lottery_newstata.dta, clear
//use lottery_oldstata.dta, clear
//use "C:\Users\征尘扬\Desktop\计量考试\lottery_newstata.dta", clear
//use "C:\Users\征尘扬\Desktop\计量考试\lottery_oldstata.dta", clear




//
global X lotcateg d z female year

// create categories of observed characteristics
egen Z = group($X)
sort Z
drop if Z ==.

// drop observations failing the common support assumptions
bysort Z : egen pr_lotcateg = mean(lotcateg) 
drop if         pr_lotcateg == 1 | pr_lotcateg == 0

// generate ipw
gen     ipw = 1 / pr_lotcateg        if lotcateg == 1
replace ipw = 1 / ( 1 - pr_lotcateg) if lotcateg == 0

// ATE using regression 
reg lnw lotcateg [iw = ipw]
matrix ate_reg = e(b)
matrix ate_reg = ate_reg[1,1]
keep if e(sample) == 1

// restructure data to category level to implement weighted average method
// average by choice
forvalues i = 0/1 {
	bysort Z : egen  lnw_l`i' = mean(lnw) if lotcateg == `i'
	bysort Z : egen mlnw_l`i' = max(lnw_l`i')
	drop lnw_l`i'
}

// mean difference and weighted mean difference
gen  mlnw  =      mlnw_l1 - mlnw_l0
// restructure
keep Z mlnw
gen  counter = 1
describe
gen N = r(N)
collapse (mean) mlnw N (sum) counter, by(Z)

// generate weighted mean difference
gen     weight   =  counter / N
gen     wmlnw =  weight*mlnw
summ    wmlnw 
matrix  ate_wsum = r(sum)

// display estimators for comparison 
mat list ate_reg 
mat list ate_wsum 




//
set seed 1  //reset random number

global bootstraps 1000  //bootstrap distributions with 1000 re-samplings

reg lnw lotcateg
matrix beta = e(b)
scalar a = beta[1,2]
scalar b = beta[1,1]

matrix err2a = e(V)

gen id = _n
//estimate in bootstrap samples
forvalues b = 1(1)$bootstraps {
	preserve
	bsample 
	reg y D
	matrix beta = e(b)
	matrix a_`b' = beta[1,2]
	matrix b_`b' = beta[1,1]
	
	matrix ab_`b' = [a_`b',b_`b']
	matrix ab_B = [ab_B \ ab_`b']
	restore
}


//a non-parametric p-value
//create non-parametric 90% confidence interval for a
summ a_B, d
scalar amin = r(p5)
scalar amax = r(p95)

//create null distribution and impose null hypothesis
summ a_B
//demean (center at zero) 
replace a_B = a_B - r(mean)
//impose null (shift to 1)
replace a_B = a_B + 1

//calculate non-parametric p-value
local  a = a
gen  pind = abs(a_B) > `a' if a_B !=.
summ pind
scalar pvalue = r(mean)
scalar list pvalue
di invttail(998,0.01)  




reg lnw lotcateg
matrix beta = e(b)
scalar a = beta[1,2]
scalar b = beta[1,1]

gen id = _n
bootstrap, reps(1000) cluster(year): reg y lotcateg

matrix err = e(V)
scalar se = sqrt(err[2,2])  //standard error
scalar t = (a - 1) / se
scalar list t
di invttail(998,0.01)
