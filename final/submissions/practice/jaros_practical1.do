set more off
clear all
// set matsize 11000
// set maxvar  32000

//env variables
global projects: env projects
global storage : env storage

//locations
global data = "$storage/econ900-03/final"
global code = "$projects/SideCodes"

cd  "C:\Users\jaros\Box\econ900\econ900-03\final"
use lottery_newstata.dta, clear

//1. F-test to explore relevance

reg d z
reg d z, r

//We find that the the instrument, "z", getting admitted to med school through
//the lottery is certainly relevant to "d", going to med school.
//The F test,  Prob > F = 0.0000, indicates that we will reject the null
//hypothesis that the instrument "z" is not relevant to "d". 
//We reject this with confidence greater than 99.99%.


//2.  Causal effect of graduation on Post graduation log wage
reg lnw d
reg lnw d, cluster(z)

// The estimated difference from graduating med school on one's log wage is 
// .1274218.  The causal inferrence for this effect comes from the following:
//logwage=3.056557 + d *.1274218.  Therefore, the logwage without graduating med
//school is around 3.056557, whereas, with graduation from med school is is
// around 3.1839788.  I clustered the data in this way because the individuals
//either graduate from med school, d=1, or they do not, d=0.  This variable is 
//related to their receival of the treatment Z, so I clustered by z.  


//3. Verify IV and Two-stage least squares provide same estimate as causal effect.

//IV= (Cov(Lnw,Z)/V(Z))/(Cov(D,Z)/V(Z))
reg lnw z
reg d z

//(Cov(Lnw,Z)/V(Z))= .097358,  (Cov(D,Z)/V(Z)) = .5203044
//(Cov(Lnw,Z)/V(Z))/(Cov(D,Z)/V(Z)) = 0.187117387

//When z=1: 2.98691167 + .0.187117387 = 3.1839788

//Two-stage least squares
//First Stage= causal effect of z on d.
reg d z

//Second Stage= Reduced Form Relationship = causal effect of z on lnw
reg lnw d

//The first stage of causal effect, is whether they will go to med school, dependent 
//on the instrumental variable of whether they get in through the random lottery
// "z".  "d"=.410087 + z* .5203044.  

//Then we insert the d into the lnw d equation: lnw=a + B *(.410087 + z* .5203044).
//Thus, lnw= 3.056557 + .127422 *(.410087 + z* .5203044).
//When Z=0, this will equal 3.056557.  Which is the same as Causal inference.
//When Z=1, this will equal 3.056557 + 0.118552 = 3.175  which is close, with
//slight variation from rounding in excel.

//Therefore, the instrumental variable and two-stage least squares estimators
//provide the same estimate as the causal effect.



//4.Verify instrumental variable estimator is equal to the quotient of reduced form
//to the first stage (Wald estimator) 

//Wald estimator= (Expected value ((EV) of logwage if they receive lottery, z=1, 
//- EV Logwage if they don't, z=0))/ ((EV Attending medschool, d=1, if they received
//lottery, z=1. - EV Medschool, d=1, if they did not receive the lottery, z=0))

//need the following results:
reg d z
reg lnw z

//EVlogwage,z=1 is 3.1847. - EVlogwage,z=0 is 3.087347.
//EVd=1,z=1 is 1- EVd=1,z=0 is .4100877.
//Therefore, Wald Estimator is .097358/.5203044 = .187117387

//The instrumental variable estimator is 0.187117387, therefore, they are the same.
