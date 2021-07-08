set more off
clear all
set seed 0

global projects: env projects
global storage: env storage

global data = "$storage/econ900/econ900-03/final"
global code = "$projects/econ900_03_empirical/econ900_03_empirical/final"
	
cd  $data
use lottery_newstata.dta, clear


//A: Writing the loop:
global A z year lotcateg
egen B = group($A)
sort B
tab B,m 

forvalues i=1(1)16 {
	ivregress 2sls lnw (d=`i'.B)
	display _b[d]
}


//B: Computing the weighted average LATE estimate:
forvalues i=1(1)16 {
	ivregress 2sls lnw (d=`i'.B)
	count if B==`i'
	return list
	//Multiplying LATE by the weight:
	display = _b[d]*(r(N)/e(N))
}

//Not sure how to store the output from display command
//So will have to add manually

display .06960441+-.00799443+.00163638+.0120037+.00823144+.01064523+.03751485+.01581314+-.0123212+.07476385+.03590437+.03872413+.02418259+-.02143647+.02216548+-.0167959

//Weighted Average of LATE is .29264157

//C 
//Unsure:
set seed 1
global bootstrap 1000
ivregress 2sls lnw (d=i.B)
scalar t_1 = (_b[d]-.29264157)/_se[d]
scalar list t_1
display invttail(998,0.1)
