set more off
clear all
set matsize 11000
set maxvar  32000
set seed 0
global bootstraps 1000

//First set the environmental variables. Projects and Storage in capital letters.
global storage: env Storage

//Global locations using the environmental variables
global data = "$storage\econ900-03\econ900-03\other"

cd $data

use lottery_oldstata.dta, clear

//If everyone is a complier then LATE and ATE are equivalent. 
//That's what we will use to solve this problem

drop if d != z 

//Part 1. Write a loop that estimates the LATE parameter by year and category

global X year lotcateg

// We create categories of observed characteristics. This procedure is very similar
//to the Conditional Independence Assumption covered in Selection on Observables

egen Z = group($X)
sort Z
drop if Z ==.


// We drop observations failing the common support assumptions
bysort Z : egen pr_d = mean(d) 
drop if         pr_d == 1 | pr_d == 0


// We generate ipw
gen     ipw = 1 / pr_d        if d == 1
replace ipw = 1 / ( 1 - pr_d) if d == 0

// Notice that the parameter to be estimated is now ATE since we are dealing
//with only compliers. In this problem LATE = ATE 
 
reg lnw d [iw = ipw]
matrix late_reg = e(b)
matrix late_reg = late_reg[1,1]
keep if e(sample) == 1


//Part 3 (before Part 2)

//We do the bootstrap method first. Notice three things:
//a. We do not use clusterting around year and lotcateg because we already arranged the 
//data conditional on year and lotcateg
//b. We use the bootstrap specifically to obtain non-parametric estimation of standard 
//errors of the estimator of LATE
//c. Weights used in the regression are ipw. 



matrix ab_B = J(1,2,.)
matrix colnames ab_B = a_B b_B

gen id = _n
// estimate in bootstrap samples
forvalues b = 1(1)$bootstraps {
	preserve
	bsample 
	reg lnw d [iw = ipw]
	matrix beta = e(b)
	matrix a_`b' = beta[1,2]
	matrix b_`b' = beta[1,1]
	
	matrix ab_`b' = [a_`b',b_`b']
	matrix ab_B = [ab_B \ ab_`b']
	restore
}

//Create columns of the constand and the estimator of LATE
matrix ab_B = ab_B[2...,1...]
svmat  ab_B, names(col)

//Summarizing the estimator of LATE. Notice that this is distributed normally
//by Central Limit Theorem

summ b_B, d
scalar sd = r(sd)

//Error bound for the mean in order to calculate condidence interval in Part 3

scalar t_value = invt(999, 0.95)
scalar ebm = (t_value)*((sd)/sqrt(1000))


// Then we restructure data to implement weighted average method
// by choice. Notice that choice = lottery in the current data set. So 
//we are estimating LATE using the same procedure as we would with ATE

forvalues i = 0/1 {
	bysort Z : egen  lnw_l`i' = mean(lnw) if d == `i'
	bysort Z : egen mlnw_l`i' = max(lnw_l`i')
	drop lnw_l`i'
}

// Then we calculate the mean difference 
gen mlnw = mlnw_l1 - mlnw_l0
// And we restructure the data again
keep Z mlnw

//Part 2. Aggregate the year-category-wise LATE parameter estimates using a weighted average
//with the appropriate weights. Again recall LATE = ATE in this problem. 


gen  counter = 1
describe
gen N = r(N)
collapse (mean) mlnw N (sum) counter, by(Z)

// Finally we calculate weighted mean difference
gen     weight   =  counter / N
gen     wmlnw =  weight*mlnw
summ    wmlnw 
matrix  late_wsum = r(sum)

// Notice that the two estimates are equivalent 

mat list late_reg 
mat list late_wsum 


//Part 3. We will use the error bound of the mean (ebm) from bootstrap and use
//the late_wsum estimates to create the non-parametric confidence interval 

// Finally we create non-parametric 90% confidence interval for late_wsum

scalar uplimit = late_wsum[1,1] + ebm

scalar lowlimit = late_wsum[1,1]  - ebm

display uplimit, lowlimit 

//The 90% confidence interval is (0.162, 0.155). 


