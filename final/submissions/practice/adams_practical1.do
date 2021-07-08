set more off
clear all
set seed 0
global bootstraps 1000

//env variables
global projects: env projects
global storage : env storage

//locations
global data = "$storage/econ900/econ900-03/final"
global code = "$projects/econ900-03_empirical/econ900-03_empirical"

cd $data
use lottery_newstata.dta, clear

//PART 1

//Part A: F-Test to determine relevance of instrument

reg d z


//The F-Score (1,1474) of the regression of the choice variable on the instrumental variable is 712.96; this is also the T-score of Z, squared. Since the p-value of the F-score is less than 0.05, we reject the null and say that the instrumental variable is RELEVANT.

ivregress 2sls female (d=z)
estat firststage

ivregress 2sls year (d=z)
estat firststage

ivregress 2sls lotcateg (d=z)
estat firststage

ivregress 2sls lnw (d=z)
estat firststage

//An alternate method to finding the F-score is running a first-stage IV regression, using the instrument equaling the choice variable as the independent variable and using the other variables as the dependent variables. The F-scores are the same and can reject the hypothesis that the instrumental variable is weak; thus it is RELEVANT.



//Part B: Causal Effect

reg d z female year lotcateg, cluster(lotcateg)
matrix firststage1 = e(b)
mat list  firststage1
predict d2sls
reg lnw d2sls female year lotcateg, cluster (lotcateg)
matrix causal = e(b)
mat list causal 

matrix causaleffect = causal[1,1]
mat list causaleffect

//The standard errors were clustered by lottery category because it provided the highest robust standard errors for which we could still reject the null of z's significance for.

//Part C: IV Estimators

ivregress 2sls lnw female year lotcateg (d=z)
matrix ivestimates = e(b)
mat list ivestimates
matrix ivestimate = ivestimates[1,1]


matrix firststagez = firststage1[1,1]
mat list causaleffect
mat list ivestimate


//The causal effect and IV estimate of the effect of graduation are the same (0.196681). Thus, graduation increases average post-graduation wages by 19.66 percent, on average all else constant.


//Part D: Wald Estimate

reg lnw female year lotcateg z, vce(robust)
mat reducedform = e(b)
mat list reducedform
mat reducedestimate = reducedform[1,4]
mat list reducedestimate

mat wald = (reducedestimate[1,1]/firststagez[1,1])

mat list wald
mat list causaleffect
mat list ivestimate

//The Wald Estimate equals the IV Estimate (0.1966) and is the quotient of the reduced form z-estimate and the first-stage z-estimate.

















