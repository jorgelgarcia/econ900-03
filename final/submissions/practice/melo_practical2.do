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

// Di = Going to school or not
// Zi lottery 
// lnw = outcome of interest

* Vitor Melo 
* Problem 2

* Method 1: 
egen c=group(year lotcateg)
bootstrap, reps($bootstraps) seed(1) cluster(c) idcluster(ID) : ivregress 2sls lnw (d = z), level(90)

/* 1) This method is the most efficient way to complete this question. The Bootstrap command runs a loop of 1000 bootstrap samples (with replacement) by the clusters year and category. It also gives me the ID of the clusters through the idcluster command. 

2) The LATE parameter using bootstrap is 0.1871175 (which is the same from empirical problem 1). This estimate is statistically significant at all reasonable statistical levels. This command automaticallly aggregates the year-category-wise LATE with appropriate weights. The constant is 3.010613. 

3) The command above offers the 90% confidence intterval of the paremeters (through the level(90) option). The 90% ci for the LATE is [.0976058, .2766292]. The seed in the command is 1 and I used 1000 bootstrap resamples. I clustered at the year and lotcateg levels because it is likelly that the errors correlate among clusters. It is much more reasonable to assume that errors are homoskedastic within those clusters since the lottery takes place by year and category. */ 

*------------------------------------------------------------------------------------------------------

* Method 2

* This method involves a step by step of running the loop, aggregating the paraameters and calculating the 90% CI. The results in method one should give those results ion a mcun simpler way, but we can also run a step-by-step approaach. 

*Stata IC cannot support matrices with more than 800 rows so It would be better to refer to the results in method 1. This approach iss based on 799 rows, which is the most I can use.

* 1)
matrix ab_B = J(1,2,.)
matrix colnames ab_B = a_B b_B

forvalues b = 1(1)$bootstraps {
	preserve
	bsample 
	ivregress 2sls lnw (d = z), vce(cluster year lotcateg)
	matrix beta = e(b)
	matrix a_`b' = beta[1,2]
	matrix b_`b' = beta[1,1]
	matrix ab_`b' = [a_`b',b_`b']
	matrix ab_B = [ab_B \ ab_`b']
	restore
}

* this command runs a loop of 1000 bootstrap samples (with replacement) by the clusters year and category.

* 2) 
matrix ab_B = ab_B[2...,1...]
svmat  ab_B, names(col)
summ b_B, d

* The LATE parameter using step by step bootstrap are very similar to the ones using the bootstrap command, but are comprimised by the issue with limited matrices rows.

* 3)
scalar bmin = r(p5)
scalar bmax = r(p95)

scalar list bmin
scalar list bmax

* The 90% CI is also very similar to the results from method 1 with the bootstrap command. 







