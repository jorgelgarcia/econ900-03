//Part 2 
use "C:\Users\chaew\Desktop\Classes\ECO9000-03\Final\lottery_newstata.dta"
//------------------------------------------------------------------------------
//*Problem 1

	//OLS regression
	reg lnw female d
	eststo ols

	//IV regression
	ivreg lnw female (d=z)
	eststo iv
	
	//Two-Stage Least Squares
	reg d z female
	predict dhat
	reg lnw female dhat
	eststo ts

	//Comparison
	estout
	
	//Verifying IV estimator is equivalent to the quotient of the reduced form to the first stage
	ivregress 2sls lnw female (d=z)
	estat firststage
	
//1) From the first stage F-statistics, we can see the instrument is relevant. F-statistics value is 712.249 which is far higher than F-critical value

//2) From the OLS regression, we can see that the graduation is positively related to the post-graduation log wage with graduation(when d=1), individuals have higher wage.

//3) When we compare the result from the IV regression and the Two-stage least squares to the OLS regression we can check that the variables have same effects on the post-graduation wage log.

//4) When we compare the results from the IV regression and the Two-stage least squares, estout shows that the coefficients are identical (.1876858). This means that the IV is not weak instrument.
//------------------------------------------------------------------------------
