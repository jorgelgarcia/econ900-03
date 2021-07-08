set more off
clear all

// Introducing environmental variables
global projects: env projects
global storage : env storage

// Defining locations
global data = "$storage/econ900/econ900-03/final"
global code = "$projects/econ900-03_empirical/classcodes"

// Accessing data
cd $data
use lottery_newstata.dta, clear

// Model
// My understanding is that lnw (log of wages) is being predicted by D which is
// being predicted by Z. There is a dummy variable for female vs male, but you
// don't mention it in the instructions, so I'm assuming it's not relevant to
// our analysis.

// ------------------------- PROBLEM 4 PART 1 ---------------------------- //

// 1.  Use an F-test test to explore if the instrument is relevant.  (5 points)

ivregress 2sls lnw (d = z), vce(robust)
estat firststage

// The highest significance level for the F-test is extremely small - rounding
// to below 0.0000 - so we may confidently assume that the instrumental
// variable Z is relevant. It is the first stage we are interested in because
// the first stage is the "relevant" condition.

// ------------------------- PROBLEM 4 PART 2 ---------------------------- //

// This problem is confusing to me, as my understanding is that IV is a type of
// 2SLS. I'm not really sure what I'm supposed to do other than ivregress -
// which is the same as 2SLS - other than to do the beta-hat IV, which is
// (Z'X)^(-1)*(Z'Y).

// Now, the next problem is that I can't actually compute that on my license of
// Stata, which limits me to matrices of 800 variables or less. However, that
// should be okay; I made my own amended data set that's smaller than that
// (I dropped all the females; you can see it as "JacobCampbellTestData" in 
// Box), and I tested this code on that data file, and it worked correctly. So, 
// this code should work, but it MIGHT not, as I can't verify it on my end. 
// Since I'm 99% sure the code will execute correctly, I will base my inference 
// off of ivregress 2sls.

// We're going to need to generate a variable where everything is 1 to use
// as our "constant" vector in Z and X, and the mkmats will take those
// variables and turn them into matrices so we can do the matrix calculations.

// If it won't run on yours - I assume you have a better version of Stata than
// me - just comment this whole passage out.

gen const = 1
mkmat const z, matrix(zmatrix)
mkmat const d, matrix(dmatrix)
mkmat lnw, matrix(ymatrix)
matrix ztransd = zmatrix'*dmatrix
matrix ztransy = zmatrix'*ymatrix
matrix estimator = inv(ztransd)*ztransy
matrix list estimator 

// Whatever number popped out on the bottom is the causal effect of the dummy
// (graduation) on log-wages. I don't really know what clustering means in this
// context.

// ------------------------- PROBLEM 4 PART 3 ---------------------------- //

ivregress 2sls lnw (d = z)

// If my work in Part 2 was done correctly, this should have yielded the same
// the same value for the coefficient of d as my "manual" calculation of the IV
// estimator did above.

// ------------------------- PROBLEM 4 PART 4 ---------------------------- //

// The way I went about this was that I computed the conditional expectations
// of lnw and d for z = 1 and z = 0, I took the appropriate differences, and
// then I took the quotient to get our Wald estimator.

egen meanlnw1 = mean(lnw / (z == 1))
egen meanlnw2 = mean(lnw / (z == 0))
egen meand1 = mean(d / (z == 1))
egen meand2 = mean(d / (z == 0))
gen difftop = meanlnw1 - meanlnw2
gen diffbot = meand1 - meand2
gen Wald = difftop/diffbot 
mean(Wald)

// Notice how we get a mean of 0.1871174, just like the 2SLS coefficient, which
// itself is said to be the same as the IV estimator. This is slightly off, and
// I'm not really sure why; if I compute this all in Excel it comes out the
// exact same. I'm inclined to chalk it up to some rounding issue. But either
// way, you can see how Wald is approximate, if not equivalent, to the other
// estimators discussed. Really, I believe it has to do with rounding, as I
// know for sure this works in Excel.
