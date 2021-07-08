//locations
global data = "$storage/econ900/econ900-03/final"
global code = "$projects/econ900-03_empirical/econ900-03_empirical"

cd $data
use lottery_newstata.dta, clear

*1. Use an F-test test to explore if the instrument is relevant. 
ivregress 2sls lnw year female lotcateg (d =z)

estat firststage


*2. Estimate and provide inference for the causal effect of graduation on post-graduation. log wage justifying your clustering.
//we see cluster as lotcateg variable (3,4,5,6)

/*Calculate P[Z|A=a]*/
tab z d, row

/*Calculate P[Y|Z=z]*/
ttest lnw, by(z)

/*Final IV estimate, OPTION 1: Hand calculations*/
/*Numerator: num = E[Y|Z=1] - E[Y|Z=0] = 3.184705-3.087347  = 0.097358*/
/*Denominator: denom = P[A=1|Z=1] - P[A=1|Z=0] =  0.9304  -  0.4101  = 0.5203 */ 
/*IV estimator: E[Ya=1] - E[Ya=0] = (E[Y|Z=1]-E[Y|Z=0])/(P[A=1|Z=1]-P[A=1|Z=0]) = 0.097358/0.5203 =0.18711896982*/
display "Numerator, E[Y|Z=1] - E[Y|Z=0] =",3.184705-3.087347
display "Denominator: denom = P[A=1|Z=1] - P[A=1|Z=0] =",0.9304-0.4101
display "IV estimator =",0.097358/0.5203

/*OPTION 2 2: automated calculation of instrument*/
/*Calculate P[A=1|Z=z], for each value of the instrument, 
and store in a matrix*/
quietly summarize d if (z==0)
matrix input pa = (`r(mean)')
quietly summarize d if (z==1)
matrix pa = (pa ,`r(mean)')
matrix list pa

/*Calculate P[Y|Z=z], for each value of the instrument, 
and store in a second matrix*/
quietly summarize lnw if (z==0)
matrix input ey = (`r(mean)')
quietly summarize lnw if (z==1)
matrix ey = (ey ,`r(mean)')
matrix list ey

/*Using Stata's built-in matrix manipulation feature (Mata), 
calculate numerator, denominator and IV estimator*/
*Numerator: num = E[Y|Z=1] - E[Y|Z=0]*mata
*Denominator: denom = P[A=1|Z=1] - P[A=1|Z=0]*
*IV estimator: iv_est = IV estimate of E[Ya=1] - E[Ya=0] *
mata 
pa = st_matrix("pa")
ey = st_matrix("ey")
num = ey[1,2] - ey[1,1] 
denom = pa[1,2] - pa[1,1]
iv_est = num / denom 
num
denom
st_numscalar("iv_est", iv_est)
end
di scalar(iv_est)

*3.Verify that the instrumental-variable and two-stage least squares estimators provide the same estimate of the causal effect in 2
ivregress 2sls lnw female year lotcateg (d = z)
ivregress 2sls lnw (d = z)


*4. Verify that the instrumental-variable estimator is equivalent to the quotient of the reduced form to the first stage (this quotient is referred to as the Wald estimator). Interpret. 
/* Compare means (and differences) */
ttest lnw, by(z)
ttest d, by(z)

/* Compute Wald estimate */
sureg (d z) (lnw z) if !missing(z)
nlcom [lnw]_b[z] / [d]_b[z]

/* OLS estimate */
regress lnw d if !missing(z)

///In question 1) IV estimator= 0.097358/0.5203 =0.18711896982*/
///In question 5)_nl_1 |   0.1871175
