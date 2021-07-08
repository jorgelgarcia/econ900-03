set more off
clear all
set matsize 11000
set maxvar  32000
set seed 0
global bootstraps 1000

// set environment variables
global econ_git: env econ_git
global storage : env storage

// locations
global data = "$storage/econ900/econ900-03/final"
global code="$econ_git/econ_900-03_empirical/final"

cd  $data
use lottery_newstata.dta, clear

//I summarize two database,I found there is nothing difference between them so I choose to use the new one.

//1. use F-test to explore if the instrument is relevant
reg d z
test z
di invFtail(1,1474,0.05)
//we can reject that there is no relationship between z and d,so the instrument is relevant.

//2.Estimate and provide inference fot the causal effect of graduation(Di) on lnwage
//Causal effect should be Yi(1)-Yi(0)
etreg lnw d,treat(d=z) vce(robust)
margins r.d,vce(unconditional) contrast(nowald)
//we want to get causal effect of d on lnw, so we use OLS regression and get the coefficent is 0.17(I wondering why it is a little bit different from question3)

//3.instrument variable and two stage least square is the same
//two stage
reg d z
predict dhat,xb
reg lnw dhat
//instrument variable
ivregress 2sls lnw (d=z)
//it is clear to see the instrument variable is the same as two stage least squares.

//4.instrument variable estimator is equivalent to the quotient of reduced form to the first stage
//for quotient
reg d z
scalar beta1=_b[z]
reg lnw z
scalar beta2=_b[z]
scalar IV_quotient=beta2/beta1
scalar list IV_quotient
//for iv estimator
ivregress 2sls lnw (d=z)
//Both of them are 0.18711
