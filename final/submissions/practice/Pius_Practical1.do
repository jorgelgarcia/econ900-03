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
global code = "$projects/econ900-03_empirical/classcodes"

cd  $data
use lottery_newstata.dta, clear


//use "C:\Users\admin\Google Drive (jpiusne@g.clemson.edu)\Clemson PhD\SEM 4 Fall 2020\Econ 003\Final Exam\lottery_newstata.dta"

//1. F statistic to check there is significant correlation between IV and Endogenous variable
reg d z
//Since we have only one IV we can check the t stat and take the square of it to get the F-stat
//t =  26.70; F = 712.89

di invFtail(1,1475,.05) //3.847771
//Since F calc > F- Critical , we reject the null (H0:Bz =0). Therefore the IV is relevant.
//Moreover as a rule of thumb the F stat should be greater than 10 inorder to have a strong effect. In this case both have been satisfied.

//2.
ivreg2 lnw i.lotcateg i.female (d = z),robust cluster (year)
mat beta= e(b)
gen IV = beta[1,1] // .1893309 
/*Inference: For those who got admitted to school has 18.93 % more wages than those who didnt go school. We clustered based on year because every year there
could be some random policy that could push a child to join a school.*/




//3.
reg d z // First stage
predict x_beta, xb 
reg lnw x_beta i.lotcateg i.female, robust cluster (year) // Second stage 
mat beta1= e(b)
gen twosls = beta1[1,1]
di IV
di twosls
//ivregress 2sls lnw i.lotcateg i.female (d = z),vce(cluster year)

//4.
reg d z // First stage
mat b3= e(b)
gen fs = b3[1,1]
reg lnw z //Reduced form
mat b4= e(b)
gen rf = b4[1,1]
gen IV_cal = rf/fs //Wald Estimator
di IV_cal

 