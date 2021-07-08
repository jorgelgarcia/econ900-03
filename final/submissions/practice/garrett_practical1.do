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

 
 //1.  
 //Standard Regression
 reg d z
test z
 //Robust
 reg d z, vce(robust)
 test z
 //Clustering
egen independentvariables = group(lotcateg year)
 reg d z, cluster(independentvariables) 
test z
 //Throughout standard, robust and clustered regression, the F score is greater than 10 and therefore Z is a relevant instrument 
 //2.
 reg lnw d, cluster(independentvariables)
 ivreg lnw (d=z), cluster(independentvariables)
 //whether we use d in a standard regressions, or z in an instrumental variable regression, we get similar results when clustering lotcateg and year.  With ivreg we have a causal effect of 18.7% increase in logwage when graduating (with a robust std. err. of .044), compared with the 12.7% (with a robust std. err. of .017) under a standard regression using the dummy. Due to the very low standard errors, the clustering is justified
 //3.
 ivregress 2sls lnw (d=z), cluster(independentvariables)
 reg d z
 predict prediction, xb
 reg lnw prediction
 // There were two methods for perfoming a two-stage least squares regression when I researched the topic, and both methods yielded similar estimators.  Furthermore, this value corresponds with the value of the estimator produced in number 2
 //4.
 reg lnw z, cluster(independentvariables)
 matrix reduced = e(b)
 matrix reduced = reduced[1,1]
 reg d z
 matrix stage1 = e(b)
 matrix stage1 = stage1[1,1]
 matrix wald = reduced/stage1[1,1]
 mat list wald
 // I had a lot of difficulty determining what the reduced form would be.  My research showed that a reduced form regression was one in which the endogenous variables were on the left and exogenous on the right.  However, when I would have it set up as "reg lnw d, cluster(independentvariables)", I would not get the value that corresponds with the IV Estimator.  If i used both d and z, the value was close, but not exact.  It was not until, through process of elimination, I used the reduced form you see above and was able to get a wald statistic that matches the estimators from numbers 2 and 3.
