set more off
clear all
set matsize 11000
set maxvar  32000
set seed 0
global bootstraps 1000

//First set the environmental variables. Projects and Storage in capital letters.
global storage: env storage

//locations
global data = "$storage/econ900/econ900-03/final"
global code = "$projects/econ900-03_empirical/econ900-03_empirical"

cd $data
use lottery_newstata.dta, clear

//Part 1. F-test test to explore if the instrument is relevant
//We will do an OLS regression and a regression with instrumental variables 

reg lnw d 

matrix A_ols = r(table)

matrix c_ols = A_ols[1, 1...]

matrix list c_ols

matrix se_ols = A_ols[2, 1...]

matrix list se_ols

gen r_ols = e(rss)

display r_ols


ivregress 2sls lnw (d = z)

matrix A_2sls = r(table)

matrix c_2sls = A_2sls[1, 1...]

matrix list c_2sls

matrix se_2sls = A_2sls[2, 1...]

matrix list se_2sls

gen r_2sls = e(rss)

display r_2sls

gen F_test = ((r_2sls - r_ols)/1)/ ((r_ols)/(1476-1))

display F_test

display Ftail(1, 1475, 4.3069)

//The F-value is 4.3069 and the corresponding p-value is 0.03813. Therefore we can
//see that the use of instrumental variable ensures that the model fits as well
// as the unrestriced OLS and conclude that the instrument variable is relevant. 

//Part 2. 
//We can only use ivregress and not ivreg2 because of the version of STATA that I am 
//using. Hence we can only cluster around one variable. 

ivregress 2sls lnw (d = z), cluster(year)

matrix A_2sls_c = r(table)

matrix c_2sls_c = A_2sls_c[1, 1...]

matrix list c_2sls_c

scalar coeff_2sls = c_2sls_c[1, 1]

matrix se_2sls_c = A_2sls_c[2, 1...]

matrix list se_2sls_c

scalar serror = se_2sls_c[1, 1]

gen r_2sls_c = e(rss)

display r_2sls_c

display coeff_2sls

gen t_stat = (coeff_2sls - 0)/(serror)

display t_stat

display ttail(1475, 5.8349) 

//The estimate is given by 0.1871175 and the t-stat is 5.8349 with a p-value of 
//3.320*10^(-9). Hence it is statistically sigificant and we reject null. 

//Clustering by year enables us to account for any heteroskedasticity in the model 
//due to the year in which the lottery was implemnted. 



//Part 3

regress d z

predict dhat, xb

regress lnw dhat 

matrix A_2stage = r(table)

matrix c_2stage = A_2stage[1, 1...]

matrix list c_2stage

scalar coeff_2stage = c_2stage[1,1]

display coeff_2stage

//In Part 2 we calculated c to be 0.1871175. We see that it is equal to d. 


//Part 4

regress lnw z

matrix A_reduced= r(table)

matrix c_reduced = A_reduced[1, 1...]

matrix list c_reduced

scalar reduced = c_reduced[1,1]

regress d z

matrix A_1stage = r(table)

matrix c_1stage = A_1stage[1, 1...]

matrix list c_1stage

scalar firststage = c_1stage[1,1]

scalar coeff_quotient = reduced/firststage

display coeff_quotient 

//The coeff is also equal to 0.1871175. Hence it is equal to both c and d is Parts
//2 and 3. 






