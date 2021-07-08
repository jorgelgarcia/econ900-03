//Huiyu Yang
//Part 2. Practice
//Problem 2. More IV in Practice and the Bootstrap
set more off
clear all
set matsize 11000
set maxvar  32000

// set environment variables
global projects: env projects
global storage : env storage

// locations
global data = "$storage/econ900/econ900-03/final"
cd  $data
use lottery_newstata.dta, clear

//1.
global X year lotcateg
egen m = group($X) 
matrix MLATE = J(1,1,.)
matrix colnames MLATE = LATE
forvalues b = 1(1)8 {
    ivregress 2sls lnw ( d = z ) if m == `b',vce(cluster female) 
    matrix LATE_`b' = _b[d]
	matrix MLATE = [MLATE \ LATE_`b'] 
}
matrix MLATE = MLATE[2...,1...]
svmat  MLATE, names(col)
list LATE if LATE !=.
/*
      +-----------+
      |      LATE |
      |-----------|
   1. | -.8036624 |
   2. |   .119505 |
   3. |  .1592434 |
   4. |   .209577 |
   5. |  1.564191 |
      |-----------|
   6. |  .0119386 |
   7. |  .5186929 |
   8. |  .1453456 |
      +-----------+
*/


//2.
gen complier = 1 if d==1 & z==1
replace complier = 1 if d==0 & z==0
replace complier = 0 if complier == .
summ complier
scalar N_complier = r(sum)
bysort m : egen nj_complier = sum(complier)
matrix TWEIGHT = J(1,1,.)
matrix colnames TWEIGHT = weight
forvalues b = 1(1)8 {
    summ nj_complier if m==`b'
    scalar n_complier_`b'=r(mean)
    matrix TWEIGHT_`b' = n_complier_`b'/N_complier
	matrix TWEIGHT = [TWEIGHT \ TWEIGHT_`b'] 
}
matrix TWEIGHT = TWEIGHT[2...,1...]
matrix AGG = [MLATE,TWEIGHT]
drop LATE
svmat AGG, names(col)
list LATE weight if LATE != . & weight != .
gen wLATE = LATE*weight
summ wLATE
scalar agg_LATE = r(sum)
scalar list agg_LATE 
//agg_LATE = 0.21069866


//3.
set seed 1 
global bootstraps 1000
matrix WLATE_B = J(1,1,.)
matrix colnames WLATE_B = wLATE_B
drop LATE weight
gen weight = nj_complier/N_complier
qui{
forvalues b = 1(1)8 {
    ivregress 2sls lnw ( d = z ) if m == `b',vce(cluster female) 
    gen LATE_`b' = _b[d] if m == `b'
	replace LATE_1 = LATE_`b' if LATE_`b' !=.
}
rename LATE_1 LATE
drop LATE_*
}

forvalues a = 1(1)$bootstraps {
	preserve 
	collapse (mean) LATE weight , by(m)
	bsample, cluster (m)   
    gen mulLATE_`a' = LATE*weight
    summ mulLATE_`a'
    matrix wLATE_`a' = r(sum)
    matrix WLATE_B = [WLATE_B \ wLATE_`a']
    restore
}

matrix WLATE_B = WLATE_B[2...,1...]
svmat  WLATE_B, names(col)
summ wLATE_B, d
scalar bmin = r(p5)
scalar bmax = r(p95)
scalar list bmin bmax

/*

      bmin =  .02468393
      bmax =  .38903131
	  
The 90% confidence interval is (0.02468393,0.38903131)
I clustered by m which is the year×lottery category cells, and my justification
is that since the lottery Z is only exogenous within these cells, if I cluster 
on other variable, the property of exogenous may disappear, and cause some problems
to the estimation of LATE and aggregate LATE. Therefore, I choose to cluster on
the year×lottery category cells or m variable I defined.
*/

