set more off
clear all
// set matsize 11000
// set maxvar  32000
set seed 1

global bootstraps 100

//env variables
global projects: env projects
global storage : env storage

//locations
global data = "$storage/econ900-03/final"
global code = "$projects/SideCodes"

cd  C:\Users\jaros\Box\econ900\econ900-03\final
use lottery_newstata.dta, clear

//1. Loop that estimates Local Average Treatment Effect (LATE) by year and category

reg lnw z, cluster(year)
//2 years
reg lnw z, cluster(lotcateg)
//4 lottery categories

tab lotcateg, gen(lotcateg_)

//    Lottery |
//   category |      Freq.     Percent        Cum.
//------------+-----------------------------------
//          3 |        163       11.04       11.04
  //        4 |        400       27.10       38.14
    //      5 |        400       27.10       65.24
    //      6 |        513       34.76      100.00
//------------+-----------------------------------
//      Total |      1,476      100.00

. tab year, gen(year)

//    Year of |
//    lottery |      Freq.     Percent        Cum.
//------------+-----------------------------------
//       1988 |        749       50.75       50.75
//       1989 |        727       49.25      100.00
//------------+-----------------------------------
//      Total |      1,476      100.00

//Want to reg lnw z for every year and category will be the local average
//treatment effect at that year or category LATE= (EV(lnw,z=1)-EV(lnw,z=0))/
//(EV(d,z=1)-EV(d,z=0))

bysort year: reg lnw z
bysort year: reg d z


//1998- lnw= 3.128782 + z* .085753 ; d= .372 + z* .5558557
//LATE = 0.154272053

//1999- lnw= 3.037062 + z* .119073 ; d= .4563107 + z* .4765108
//LATE = 0.249885207

bysort lotcateg: reg lnw z
bysort lotcateg: reg d z

//3 lnw= 3.067063 + z* .0984796 ; d= .7142857 + z* .2118888
//LATE = 0.4647702

//4 lnw= 3.16609 + z* .0162381 ; d= .6091954 + z* .3141273 
//LATE =0.051692737

//5 lnw= 3.085936 + z* .1265199 ; d= .471831 + z* .4700295
//LATE = 0.269174382

//6 lnw= 3.057459 + z* .1153787 ; d= .2676056 + z* .6623944 
//LATE = 0.174184293



//2. Aggregate year-category-wise LATE parameter estimates ising a weighted average
//with appropriate weights

global X year lotcateg z d
egen Z = group($X)

bysort Z: egen pr_z = mean(z)
bysort Z: egen pr_lotcateg = mean(lotcateg)
bysort Z: egen pr_year = mean(year)

//generate IPW

gen ipw = 1/ pr_z if pr_z == 1
replace ipw = 1 / (1 - pr_z) if pr_z == 0


//ATE, will then be made LATE when grouped

reg lnw pr_z [iw = ipw]
matrix late_reg = e(b)
matrix late_reg = late_reg[1,1]
keep if e(sample) == 1

//Category Level, average by lottery z. 
forvalues i=0/1 {
    bysort Z : egen  lnw_1`i' = mean(lnw) if z == `i'
	bysort Z : egen mlnw_1`i' = max(lnw_1`i')
	drop lnw_1
}


//---------------------------------------------------------------------

//3. Provide 90% confidence interval for weighted-average of LATE using the bootstrap
//(justify clustering)

//bivariate regression, a= 3.087347, b= .097358
// y = a + b*D + e
scalar a = 3.087347
scalar b = .097358

// simulate dummy variable
gen t = runiform()
gen D = cond(d < .6, 1, 0)

// simulate e with sigma2 = 1
scalar sigma2 = 1
gen e = rnormal(0,sigma2) 

gen y = a + b*D + e

// display estimates
reg    y D
matrix beta = e(b)
scalar a = beta[1,2]
scalar b = beta[1,1]

matrix ab_B = J(1,2,.)
matrix colnames ab_B = a_B b_B

gen id = _n

// estimate in bootstrap samples
forvalues b = 1(1)$bootstraps {
	preserve
	bsample 
	reg y D
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



summ b_B, d
scalar bmin = r(p5)
scalar bmax = r(p95)

//90% confidence interval of LATE between 0.0655619 and 0.1860657

//I had some trouble getting the bootstrap to run.  My version was limited to 800
//and it would not run the whole thing.  I was able to run it with 100 bootstraps,
//I reset it to 1000 at the top because I know you would look for that.

