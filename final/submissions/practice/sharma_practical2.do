
	set more off
	clear all
	set seed 0
	//env variables
		global projects: env projects
		global storage : env storage
	//locations
		global data = "$storage/econ900/econ900-03/final/"
		global code = "$projects/econ900-03_empirical/"
	
	cd  $data
	use lottery_newstata.dta, clear
	
//Decriptive analysis of the gicen data//
	sum 
	tab female
	tab d
	tab z
	tab lotcateg
	

//Answer 1: Estimation of iv regression provides a LATE so, we will be using the same model as 1.//
 
// construct and list X variables (year and category as defined in the question)
	global X year lotcateg
	// create categories of observed characteristics-mutually exhaustive categories 
	egen ZZ= group($X)
	sort ZZ
	drop if ZZ ==.
	hist ZZ
	tab ZZ,m
	
	// check common support: 0 < p(d = 1 | ZZ = z) < 1 
preserve
collapse (mean) d, by(ZZ)

#delimit
twoway (scatter d ZZ, mcolor(gs0)),
		  legend(off)
		  ylabel(, grid glcolor(gs14) angle(h) labsize(medlarge)) 
		  xlabel(, grid glcolor(gs14) angle(h)) 
		  ytitle("Prob(l = 1)")
		  xtitle("Support of Z", size(medlarge))
		  graphregion(color(white)) plotregion(fcolor(white));
#delimit cr
restore

// drop observations failing the common support assumptions
bysort ZZ : egen pr_d = mean(d) 
drop if         pr_d == 1 | pr_d == 0

// generate ipw
gen     ipw = 1 / pr_d        if d == 1
replace ipw = 1 / ( 1 - pr_d) if d== 0

// LATE using regression 
reg lnw d [iw = ipw]
matrix ate_reg = e(b)
matrix ate_reg = ate_reg[1,1]
keep if e(sample) == 1

// displaying year-category-wise LATE parameter
mat list ate_reg

/////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////

//Answer 2: Estimating LATE using weighted average
// restructure data to category level to implement weighted average method
// average by choice
forvalues i = 0/1 {
	bysort ZZ : egen  lnw_l`i' = mean(lnw) if d == `i'
	bysort ZZ : egen mlnw_l`i' = max(lnw_l`i')
	drop lnw_l`i'
}

// mean difference and weighted mean difference
gen  mlnw  =      mlnw_l1 - mlnw_l0
// restructure
keep ZZ mlnw
gen  counter = 1
describe
gen N = r(N)
collapse (mean) mlnw N (sum) counter, by(ZZ)

// generate weighted mean difference
gen     weight   =  counter / N
gen     wmlnw =  weight*mlnw
summ    wmlnw
matrix  ate_wsum = r(sum)

// display estimators 
mat list ate_wsum


//////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////

//Answer 3:
//I have used the regression method assigning appropriate weights for the weighted average of the LATE as it is observed the result from regression method and weighted average provides the identical estimates.
//Also, the bootstrap regression is clusted at ZZ (year-category-wise) becasue we have created the mutually exhaustive category based on X defined by year and category (lotcateg).
//ZZ= "some value" implying the assigned valued group has same characteristics based on pre-defined Xs (year and lotcateg)

//***Note that: while setting bootstrap sample to 1000 i have got the following error message so i have sample to 500 to run the command in my stata //
    //You have attempted to create a matrix with too many rows or columns or attempted to fit a model with too many variables.

    //You are using Stata/IC which supports matrices with up to 800 rows or columns.  See limits for how many more rows and columns Stata/SE and Stata/MP can support.//

set more off
	clear all
	//setting our seed to 1 //
	set seed 1
	//setting 1000 bootstrap resamples
	//global bootstrap 1000 (I was supposed to se this but I am not able to set this becasue of the resaon mentioned above *** ;so i have set up maximum mat size provided in my STATA package which is 800, so it is set to 799//
	global bootstrap 799
	//env variables
		global projects: env projects
		global storage : env storage
	//locations
		global data = "$storage/econ900/econ900-03/final/"
		global code = "$projects/econ900-03_empirical/"
	
	cd  $data
	use lottery_newstata.dta, clear
	
//Decriptive analysis of the gicen data//
	sum 
	tab female
	tab d
	tab z
	tab lotcateg
	

// construct and list X variables (year and category as defined in the question)
	global X year lotcateg
	// create categories of observed characteristics-mutually exhaustive categories 
	egen ZZ= group($X)
	sort ZZ
	drop if ZZ ==.
	hist ZZ
	tab ZZ,m
	
	// check common support: 0 < p(d = 1 | ZZ = z) < 1 
preserve
collapse (mean) d, by(ZZ)

#delimit
twoway (scatter d ZZ, mcolor(gs0)),
		  legend(off)
		  ylabel(, grid glcolor(gs14) angle(h) labsize(medlarge)) 
		  xlabel(, grid glcolor(gs14) angle(h)) 
		  ytitle("Prob(l = 1)")
		  xtitle("Support of Z", size(medlarge))
		  graphregion(color(white)) plotregion(fcolor(white));
#delimit cr
restore

// drop observations failing the common support assumptions
bysort ZZ : egen pr_d = mean(d) 
drop if         pr_d == 1 | pr_d == 0

// generate ipw
gen     ipw = 1 / pr_d        if d == 1
replace ipw = 1 / ( 1 - pr_d) if d== 0


matrix ab_B =J(1,1,.)
matrix colnames ab_B =  b_B

//gen id = _n
// estimate in bootstrap samples
matrix ab_B=J(1,2,.)
matrix colnames ab_B = a_B b_B

gen id = _n
// estimate in bootstrap samples
forvalues b = 1(1)$bootstrap{
	preserve
	bsample 
	reg lnw d ,cluster(ZZ)
	matrix beta = e(b)
	matrix a_`b' = beta[1,2]
	matrix b_`b' = beta[1,1]
	matrix ab_`b' = [a_`b',b_`b']
	matrix ab_B = [ab_B \ ab_`b']
	restore
}

// bring on bootstrap distribution to data
matrix ab_B = ab_B[2...,1...]
svmat  ab_B, names(col)

// variance-covariance matrix
correlate a_B b_B, cov

// creating non-parametric 90% confidence interval for b which is weighted late estimates 
summ b_B, d
scalar bmin = r(p5)
scalar bmax = r(p95)

//////



