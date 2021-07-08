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

 
 //1.
 
egen independentvariables = group(lotcateg year)
levelsof independentvariables, local(lottery)
display r(levels)
foreach round of numlist `lottery' {
	ivreg lnw (d=z) if independentvariables == `round' 
	//2.
	matrix ROUNDTOTAL = e(N)
	//Number of observations per round 
	matlist ROUNDTOTAL
	matrix IVs = e(b)
	//The coefficient of d
	matlist IVs
	
// I spent literally hours trying to figure out how to save regression outputs as new variables (in this case, "d", so that I could perform more simple calculations later, but I was unable to do so).  Since time was of the essence, I used the way we frequently performed similar operations in class, and used matrices.
	
    summ independentvariables
	//Total observations

    matrix WEIGHTLATE = ((ROUNDTOTAL[1,1]/1476)*IVs[1,1])
	matlist WEIGHTLATE[1,1]
	// The Weighted Local Average Treatment Effect for each round can be observed beneath each regression
    
}

  //3.
//For some reason, If I used 1000 bootstraps, it would tell me I'm trying to create a matrix that's too large?  I've never run into this problem before.  So I incrementally reduced the amount of bootstraps until the code successfully ran.  

local boots 1000
set emptycells drop
forvalues i = 1/20{
	cap timer clear `i'
}

//I found that running this regression each time I wanted to test my code was taking a very long time (maybe it is my computer, but it took at least 3min. to run it) so this was an attempt to speed it up.  However, I am not sure if it had any effect

levelsof independentvariables, local(lottery)
display r(levels)
matrix WEIGHTLATE3 = .
foreach b of numlist 1(1)$bootstraps {
	 quietly preserve
	 quietly bsample, cluster(independentvariables)
	 
//I made the individual components of this loop quiet so that I could "turn on and off" certain areas to troubleshoot

	levelsof independentvariables, local(lottery)
	quietly foreach round of numlist `lottery' {
	 ivreg lnw (d=z) if independentvariables == `round'
		matrix IV3_`round' = e(b)
		matrix IV3_`round' = IV3_`round'[1,1]
		matrix TOTAL3_`round' = e(N)
		
	//This is the same thing we did in numbers one and two, except now our estimates have been boostrapped.  

	}
	summ independentvariables
	matrix TOTALOBS = r(N) 
	matrix WEIGHTLATE3_`b' = 0
	foreach round of numlist `lottery' {
		matrix WEIGHTLATE3_`b' = WEIGHTLATE3_`b'[1,1] + (TOTAL3_`round'[1,1]/TOTALOBS[1,1])*IV3_`round'[1,1] //Unlike problem 2, we cannot just plug in 1476 for the total observations, because the amount of observations will change throughout the boostrap resampling.
		
	}
	
	//Calculating the weighted average LATE based off of the bootstrap
	
	matrix WEIGHTLATE3 = [WEIGHTLATE3 \ WEIGHTLATE3_`b']
restore

}

matrix WEIGHTLATE3 = WEIGHTLATE3[2...,1]
svmat WEIGHTLATE3



rename WEIGHTLATE31 WEIGHTLATE3
ci means WEIGHTLATE3 [fweight = d], level(90) //method 1
ci means WEIGHTLATE3, level(90) //method 2
tabulate WEIGHTLATE3 //method 3
sum WEIGHTLATE3, d //method 4




// I chose to list these various ways of calculating the 90% Confidence Interval because they all provided different results.  The first two, using the "ci means" method, provided relatively small intervals.  However, the second "ci means PROBIV, level(90)", shared the same mean(.2155702) with the fourth method, which I believe to be the correct method. I believe the confidence interval provided by the fourth method (.0383054 - .3871913) is accurate because it more closely represents the values presented by the tabulation of the frequencies (method 3)




  
 
