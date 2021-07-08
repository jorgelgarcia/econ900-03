set more off
clear all
set seed 0

global projects: env projects
global storage: env storage

global data = "$storage/econ900/econ900-03/final"
global code = "$projects/econ900_03_empirical/econ900_03_empirical/final"
	
cd  $data
use lottery_newstata.dta, clear

//1 
//Using F test to explore if the instrument is relevant
ivregress 2sls lnw (d = z)
estat firststage

//The instrument is relevant, F=712.956, p-value = 0.0000
//We reject the null hypothesis that the instrument is weak
//According to Stock, Wright, and Yogo (2002), "the F statistic should exceed 10 for inference
//based on the 2SLS estimator to be reliable when there is one endogenous regressor."
//Source: https://www.stata.com/manuals/rivregresspostestimation.pdf

//2
//Estimating causal effect of graduation on post-graduation log wage
ivregress 2sls lnw (d = z), vce(cluster female)
//.1871175
//The causal effect of graduation on post-graduate log wage is .1876858 
//In other words, graduation increases log wage by .1876858 on average
//I have clustered by gender because typically there are differences in wages between gender due to gender-wage gaps


//3
//2SLS:
ivregress 2sls lnw (d = z)
// .1871175

//IV:
correlate lnw z, covariance
gen covyz=r(cov_12)
correlate d z, covariance
gen covdz=r(cov_12)
display (covyz/covdz)
//.18711748

//4
//IV:
correlate lnw z, covariance
gen cyz=r(cov_12)
correlate d z, covariance
gen cdz=r(cov_12)
display (cyz/cdz)
//.18711748

//First stage:
regress lnw z
gen a = _b[z]
regress d z
gen b = _b[z]
display a/b
//.18711746

//Interpretation:  Beta hat IV is equal to the cov(y,z)/cov(d,z) which is equal to
//the reduced form/first stage.   This gives us the
//average treatment effect but only for the compliers 