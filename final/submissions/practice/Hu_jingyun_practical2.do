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
global code="$econ_git/econ_900-03_empirical/final2"

cd  $data
use lottery_newstata.dta, clear

//1. loop for LATE by year and category
//For my understanding, there are two instruments-year and category
//j=1,2 because we only have two instruments, 
//get two covariance pj=cov(yi,zji)/cov(di,zji)when j=1,2

//with loop
local vars"year lotcateg"
foreach v of varlist `vars'{
corr d `v',covariance
scalar dv_cov=r(cov_12)
corr lnw `v',covariance
scalar lnwv_cov=r(cov_12)
scalar LATE=lnwv_cov/dv_cov
scalar list LATE
}
//there are two LATES with different instruments, for LATE of year is -1.1449631
//for LATE of lotcateg is  .1861613

//2.using a weighted average with appropriate weights.
//for the book most harmless, P174
//first, get coefficient of Zi1,Zi2 with d_hat
reg d year lotcateg
scalar wd1=_b[year]
scalar wd2=_b[lotcateg]
scalar list wd1 wd2
//from the most harmless, we know the equation is w*LATE1+(1-w)*LATE2
//we assume LATE1 is LATE of year, and LATE2 is LATE of lotcateg
corr d year,covariance
scalar dyear_cov = r(cov_12)
corr d lotcateg,covariance
scalar dlot_cov = r(cov_12)
scalar w=wd1*dyear_cov/(wd1*dyear_cov+wd2*dlot_cov)
scalar list w
scalar LATE_year_category_wise=w* -1.1449631+(1-w)* .1861613
scalar list LATE_year_category_wise
//the aggregate year-category-wise LATE is  .07351671, the same as ivregress 2sls lnw (d=year lotcateg)

//3.provide a 90% confidence interval for weighted average of LATE with boostrap
//bootstrap with IV model
bootstrap,rep(100) seed(1):ivregress 2sls lnw (d=year lotcateg),level(90)
