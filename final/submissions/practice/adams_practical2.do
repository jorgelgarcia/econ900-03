set more off
clear all
set matsize 11000
set maxvar  32000
set seed 0
global bootstraps 500

// set environment variables
global projects: env projects
global storage : env storage

// locations
global data = "$storage/econ900/econ900-03/final"

cd  $data
use lottery_newstata.dta, clear    

cd $data
use lottery_newstata.dta, clear

//PART 2

//a
gen eightyeight = 0
replace eightyeight = 1 if year==1988

global fourgroups d z
global yearcat eightyeight lotcateg

egen yearcatz = group($yearcat)
egen four = group($fourgroups)
sort four

gen com = 1
replace com = (z+d)
sort com
tab com

bysort yearcat: egen prd1 = mean(d)

gen ipw = (1 / prd1) if d==1
replace ipw = (1 / (1 / prd1)) if d==0

forvalues i = 1/8 {
reg lnw d [iw=ipw] if yearcatz==`i' & com !=1
scalar obs`i' = e(N)
matrix late`i' = e(b)
scalar lategroup`i' = late`i'[1,1]
display obs`i'
display lategroup`i'
}

//The LATE is the ATE for each (year*category) group's compliers. The forvalues loop created eight LATEs for the eight groups of (year*category), and filtered them out based on whether they were a complier or not.

//Part B

forvalues i = 1/8 {
	scalar weight`i' = (lategroup`i' * obs`i' /1476)
}

display weight1+weight2+weight3+weight4+weight5+weight6+weight7+weight8

//The total weighted-average : LATE parameter is 0.1526; treatment increased wages for compliers by 15.26 percent throughout all the groups, on average all else constant.

//Part C


matrix alef = J(10,1,.)

gen id = _n

forvalues _n = 1(1)$bootstraps{

preserve
bsample

forvalues i = 1/8 {
reg lnw d if yearcatz==`i' & com !=1
scalar obs`i' = e(N)
matrix late`i' = e(b)
scalar lategroup`i' = late`i'[1,1]
scalar weight`i' = (lategroup`i' * obs`i' /1476)
matrix estimate`_n' = weight1+weight2+weight3+weight4+weight5+weight6+weight7+weight8
}
restore

}

forvalues i = 1/10 {
	
	matrix alef`i' = estimate`i'[1,1]
	matrix alef = [alef`i']
	
	
}
mat list alef

//Note: I could only generate the matrix for first bootstrap result and couldn't aggregate the rest into a matrix, so I changed the amount of bootstraps.
 
















