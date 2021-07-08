set more off
clear all
set matsize 800
set seed 1
global bootstraps 1000

// set environment variables
//global projects: env projects
//global storage : env storage

// locations
//global data = "$storage/econ900/econ900-03/other"
//global code = "$projects/econ900-03_empirical/classcodes"

//cd  $data
cd "C:\Users\Vitor Melo\Box\econ900\econ900-03\final"
use lottery_newstata.dta, clear

// Di = Going to school or not
// Zi lottery 
// lnw = outcome of interest 

*Vitor Melo
*problem 1:

*traditional iv regress command with clustered SE
ivregress 2sls lnw (d = z), first vce(cluster year lotcateg)
* step-by-step IV with clustered SE
egen c=group(year lotcateg)
reg  d z, cluster (c)
predict dhat, xb
regress lnw dhat, cluster (c)

*1)
* The instrument is relevant. The F-test in the first stage regression is 175.33 and the p-value is 0.0000. Thus, we can reject the null hypothesis that the instrument is not relevant. 

*2) 
* Based on the two stage LS estimates, going to school has a positive and statistically significant impact on wages. The P-value is 0.000 which means that the impact is significant at all reasonable levels. The magnitude of the impact is .1871175. However, this coeficient only represnts the LATE, and not the ATE. Thus, the the magnitude of the impact should be interpreted with caution. I clustered SE based on year anbd lotcateg since the lotery was distributed based on those tewo variable ans errorts might be different for people in different years and/or categories. 

* 3) 
ivregress 2sls lnw (d = z), first vce(cluster year lotcateg)

egen c=group(year lotcateg)
reg  d z, cluster (c)
predict dhat, xb
regress lnw dhat, cluster (c)

* the instrumentAL variable dhat provides the same estimate as the two-stage LS. Both show a first stage coefficient of .5203044 and a second stage coefficient of .1871175. The results can be seen above. 

*4)

reg lnw z,cluster (c)
matrix beta_lnw = e(b)
scalar a_hat = beta_lnw[1,2]
scalar b_hat = beta_lnw[1,1]
scalar yiz1 = a_hat + b_hat
scalar yiz0 = a_hat

reg d z, cluster (c)
matrix beta_z = e(b)
scalar a_hatz = beta_z[1,2]
scalar b_hatz = beta_z[1,1]
scalar diz1 = a_hatz + b_hatz
scalar diz0 = a_hatz

scalar wald_e =(yiz1 - yiz0)/(diz1 - diz0)
scalar list wald_e

* The instrumental variable estimator is in fact equal to the wald estimator. Both are equal to .187117. The results of the wald estimator above is the same as the IV estimate ( as we showed in class). 







































