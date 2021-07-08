set more off
clear all
set matsize 11000
set maxvar  32000
set seed 0
global bootstraps  5
global simulations 500

// set environment variables
global projects: env projects
global storage : env econstorage

// set general locations
// scripts
global scripts       = "$projects/econ_816/problemsets/problemset1"
global data          = "$storage/econ816_psets/problemset1/"

// open data
cd $data
use lalonde.dta, clear

// a
// check average balance across controls in basic variables
// you could also have checked distributions 
global basecontrols black hisp age nodegree educ married re74 re75
foreach var of varlist $basecontrols {
	reg `var' treated
}

// b
// note that we do not require standard errors, so this is easy
// compute
foreach num of numlist 0 1 {
	summ  re78 if treated == `num'
	local re78_`num' = r(mean)
}
// display
di `re78_1' - `re78_0'

// d
// declare samples and obtain means
global sample1 treated == 1 
global sample2 sample  == 2

foreach num of numlist 1 2 {
	summ re78 if ${sample`num'}
	local re78_`num' = r(mean)
}
// display
di `re78_1' - `re78_2'
// this gives a negative effect beause CPS does not delimit to disadvantaged 
// individuals, as those who participate in NSW.  

// e 
// OLS may help to deal with the differences between treated and CPS
gen     ind_cpstreat = 1 if treated == 0
replace ind_cpstreat = 0 if sample  == 2

reg re78 ind_cpstreat $basecontrols
// it improves but it still garbage 

// f 
// use the same controls or covariates as in a) 
// this will confirm that the differences in observed characteristics are huge 
foreach var of varlist $basecontrols {
	reg `var' ind_cpstreat
}
// importantly note the differences in income! 

// g 
// propensity score nearest neighbor 
psmatch2 ind_cpstreat $basecontrols, outcome(re78) neighbor(10) ate
di r(ate)
// which still pretty bad! 

// propensity score
psmatch2 ind_cpstreat $basecontrols, outcome(re78) ate
di r(ate)
// oops! not that good either (although it improves)

// local linear regression 
psmatch2 ind_cpstreat $basecontrols, outcome(re78) llr ate 
di r(ate)






