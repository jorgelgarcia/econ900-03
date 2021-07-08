clear all
set more off
set seed 0

// set environment variables
global projects: env projects
global storage : env storage

// locations
global data = "$storage/econ900/econ900-03/final"
global code = "$projects/econ900-03_empirical/classcodes"

cd  $data
use lottery_newstata.dta, clear

// I had to give the path directly because my env variable for box folder was not working
//use "/Users/pranith/Desktop/finalexam/lottery_newstata.dta"

// First, let's see if the instrument z has a direct causal effect on outcome
reg lnw d z
// We can see that the coefficient of z is insignificant at 0.05 level. This is good because we don't want our instrument to directly impact the outcome but instead it has the go through the choice.

// Regressing choice on instrument will give us our first-stage regression
reg d z
// We can see that the instrument DOES have a causal effect on the choice variable.

// We can also look at the same as follows:
ivregress 2sls lnw (d=z)
estat firststage
// Here we can see that the F value is the same as earlier in first-stage regression 712.96 and p < 0.01. We can reject the hypothesis that the instrument is weak.
estat endogenous
// However, when we check for endogenity, we fail to reject the null hypothesis that our choice variable is exogeneous based on the p-values of Durbin and Wu-Hausmen tests at 0.05 significance level. This is a problem because we require that the choice var is endogenous for us to use instrument variable.

// Now, let's look at the causual effect of graduation on post-grad log wage
reg lnw d
// The coefficient of d indicates that on average, individuals who go to school earn 12.74% higher wages than those who don't.

// verifying the causal effect
ivreg lnw (d=z) // For some reason, my stata is not allowing me to use ivreg for 2sls and ivregress here. Sorry for the inconsistency.
ivregress 2sls lnw (d=z) 
// The coefficient of d is same in both cases which indicates that on average, individuals who go to school earn 18.71% higher wages than those who don't.
// We can take a longer route and do the same 2-Stage Least Squares. First, we need to regress our instrument on choice variables
reg d z // first-stage
predict double dhat 
reg lnw dhat // second-stage
// We can see that the coefficient of d in this regression is the same as in both earler cases. However, it is important to note that the Std. Errors are slightly different. 

// Lastly, let's verify that the IV estimator is equivalent to the quotient of the reduced form to the first stage
reg lnw z
scalar beta1=_b[z]
reg d z
scalar beta2=_b[z]
gen q = beta1/beta2
display q
// Yes, we get the quotient of the reduced form to the first stage, which is the same as the IV estimator 0.1871.
