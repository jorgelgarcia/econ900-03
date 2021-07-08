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

// 1.
reg d z female i.year#i.lotcateg
test z
// F-test result is very big indicating that z is highly correlated with d.
// Therefore, the instrument is relevant.
 

// 2.
ivreg2 lnw female i.year#i.lotcateg (d=z), robust
//The coefficient on graduation is 0.199 which means that graduation leads to 19.9% increase in wages.
// I used robust method, which is Huber-White sandwich estimator of variance to estimate standard error, to allow for heteroskedasticity. 
//Also because z is exogenous within the interaction of year and category, we might use cluster method as well to consider intracluster correlation and relax the assumption of independence within the clusters. It means that the observations are only independent across the clusters.


// 3.
reg d z female i.year#i.lotcateg
predict d_pred, xb
reg lnw d_pred i.year#i.lotcateg, robust
// The coefficient for 2SLS is the same.


// 4. 
// first way (lazy way!):
correlate lnw z, cov
matrix cov_yz = r(cov_12)
mat list cov_yz

correlate d z, cov
matrix cov_dz = r(cov_12)
mat list cov_dz

matrix b_iv = cov_yz[1,1] / cov_dz[1,1]
mat list b_iv
ivreg2 lnw (d=z)

// second way (more accurate way!):
reg d z female i.year#i.lotcateg
matrix b = e(b)
matrix b_zd = b[1,1]
correlate d z, cov
matrix var_z = r(Var_2)
matrix cov_dz = b_zd * var_z

reg lnw z female i.year#i.lotcateg
matrix b = e(b)
matrix b_zw = b[1,1]
matrix cov_wz = b_zw * var_z

matrix b_iv = cov_wz[1,1] / cov_dz[1,1]
mat list b_iv

ivreg2 lnw female i.year#i.lotcateg (d=z)
// The results are the same which shows that the b_iv is eual to the cov(z,lnw)/cov(z,D). This indicates that b_iv is ATE for compliers not a general ATE because we cannot see the behavior on always takers and never takers. 
