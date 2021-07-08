//Huiyu Yang
//Part 2. Practice
//Problem 1. IV in Practice
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
set seed 0  

//1.
reg d z
scalar ttest = _b[z]/_se[z]
scalar Ftest = (ttest)^2
scalar list
scalar list Ftest
//Since Ftest which corresponds to the hypothesis that the coefficients on z is zero
//in the first-stage regression is greater than 10, the instrument is relevant.


//2.
predict d_hat, xb
reg lnw d_hat, vce(bootstrap, reps(1000) seed(0) cluster (female))
scalar causaleffect = _b[d_hat]
scalar list causaleffect
//The causal effect of graduation on post-graduation log wage is 0.18711747.
scalar se = _se[d_hat]
scalar list se
//I clustered by female in this regression, and my justification is that female 
//usually get lower wage than male after they work. Therefore, there will be 
//heteroscedasticity between these two groups. Besides, I choose bootstrap to 
//calculate the standard error.
scalar t = causaleffect/se
scalar list t
//Since the t value is greater than 1.96, the estimated causal effect is 
//significant at 95% level.


//3.
bootstrap, reps(1000) seed(0) cluster(female): ivreg2 lnw ( d = z )
scalar ives = _b[d]
ivregress 2sls lnw ( d = z ), vce(bootstrap, reps(1000) cluster (female))
scalar tslses = _b[d]
scalar list causaleffect ives tslses //all =  0.18711747
//From the results we can find that they are all the same, so the instrumental-variable
//and two-stage least squares estimators provide the same estimate of the causal 
//effect in 2.


//4.
*first stage
reg d z
scalar fs = _b[z]
*reduced form
reg lnw z,vce(bootstrap, reps(1000) seed(0) cluster (female))
scalar rf = _b[z]
scalar Wald = rf/fs
scalar list Wald ives  //all =  0.18711747
//From the results we can find that they are all the same.
//According to ECON900-02, we know that the OLS estimator of the instrumental 
//variable is COV(z,lnw)/COV(z,d), and the estimator of reduced form is 
//COV(z,lnw)/VAR(z), the estimator of first stage is COV(z,d)/VAR(z). So the quotient
//of these two estimator is equivalent to the instrumental variable.


