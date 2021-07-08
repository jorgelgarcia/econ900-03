cls  //clear screen
clear all
set more off  //show all results
//set matsize 11000
//set maxvar 32000
set seed 0  //reset random number

//set environment variables
global projects: env projects
global storage : env storage

//locations
global data = "$storage/econ900/econ900-03/final"
//global code = "$projects/econ900-03_empirical/classcodes"

//open data
cd  $data
use lottery_newstata.dta, clear
//use lottery_oldstata.dta, clear
//use "C:\Users\征尘扬\Desktop\计量考试\lottery_newstata.dta", clear
//use "C:\Users\征尘扬\Desktop\计量考试\lottery_oldstata.dta", clear

//1.
reg lnw d z
//F(2, 1473)=10.85
di invFtail(2,1473,0.05)

reg lnw d z
matrix beta = e(b)
matrix list beta
scalar rss1 = e(rss)
scalar list rss1

reg lnw d z lotcateg, nocons
scalar rss2 = e(rss)
scalar list rss2
scalar f = ((rss1-rss2)/2)/(rss2/1473)
scalar list f 

di invFtail(2,1473,0.05)

//2.  3.  4.
reg lnw z, r
scalar nominator = _b[z]
reg d z, r
scalar denominator = _b[z]
scalar betaiv1 = nominator/denominator
scalar list betaiv1

ivregress 2sls lnw (d = z)
//ivreg2 lnw (d = z)

reg d z, r
predict iv, xb
reg lnw iv, r
scalar betaiv2 = _b[iv]
scalar list betaiv2
ivregress 2sls lnw (d = z)
ivregress 2sls lnw (d = z), first

//try
reg lnw d

reg d z

ivregress 2sls lnw (d = z)
ivregress 2sls lnw (d = z), first

egen zbar = mean(z)
egen xbar = mean(d)
egen ybar = mean(lnw)

gen denominator = (z-zbar)*(d-xbar)
gen numerator   = (z-zbar)*(lnw-ybar)

egen sum_den = sum(denominator)
egen sum_num = sum(numerator)

gen iv2 = sum_nu/sum_de

list iv2 in 1/1
