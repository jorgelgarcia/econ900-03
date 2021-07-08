set more off
clear all
set matsize 11000
set maxvar  32000
set seed 1
global bootstraps 1000

// set environment variables
global projects: env projects
global storage : env storage

// locations
global data = "$storage/econ900/econ900-03/final"
global code = "$projects/econ900-03_empirical/classcodes"

cd  $data
use lottery_newstata.dta, clear


****************** parts 1 and 2 (first way) *******************************
// 1.
forvalues y = 1988(1)1989 { 
	forvalues c = 3(1)6 {

		sum lnw if year==`y' & lotcateg==`c' & z==1
		scalar w_z1_`y'_`c' = r(mean)

		sum lnw if year==`y' & lotcateg==`c' & z==0
		scalar w_z0_`y'_`c' = r(mean)

		sum d if year==`y' & lotcateg==`c' & z==1
		scalar d_z1_`y'_`c' = r(mean)

		sum d if year==`y' & lotcateg==`c' & z==0
		scalar d_z0_`y'_`c' = r(mean)

		scalar late_`y'_`c' = (w_z1_`y'_`c' - w_z0_`y'_`c') / (d_z1_`y'_`c' - d_z0_`y'_`c')
		scalar list late_`y'_`c'

		sum lnw if year==`y' & lotcateg==`c'
		scalar n_`y'_`c' = r(N)
	}
}


// 2.
scalar s = 0
scalar n = 0
forvalues y = 1988(1)1989 { 
	forvalues c = 3(1)6 {
		scalar s = late_`y'_`c' * n_`y'_`c' + s
		scalar n = n_`y'_`c' + n
	}
}

scalar late = s / n
scalar list late
// Because I did not include female into the model, I think the estimate of weighted LTE is not completely accurate. So, I decided to do these 2 parts in another way that I can include female into the model as well.


****************** parts 1 and 2 (second way) *******************************
// 1.
forvalues y = 1988(1)1989 { 
	forvalues c = 3(1)6 {

		ivreg2 lnw female (d=z) if year==`y' & lotcateg==`c'
		matrix b = e(b)
		scalar late_`y'_`c' = b[1,1]
		scalar n_`y'_`c' = e(N)
		scalar list late_`y'_`c'
	}
}


// 2. 
scalar s = 0
scalar n = 0
forvalues y = 1988(1)1989 { 
	forvalues c = 3(1)6 {
		scalar s = late_`y'_`c' * n_`y'_`c' + s
		scalar n = n_`y'_`c' + n
	}
}

scalar late = s / n
scalar list late



************************* Part 3 ******************************************
// 3.
matrix d_B = J(1,1,.)
matrix colnames d_B = d_B

forvalues b = 1(1)$bootstraps {
	preserve
	bsample, cluster(year lotcateg)
	quietly ivreg2 lnw female i.year#i.lotcateg (d=z)
	matrix beta = e(b)
	matrix d_`b' = beta[1,1]
	
	matrix d_B = [d_B \ d_`b']
	restore
}
// Because the lottery is only exogenous within year*lottery category cells, I clustered bootsrap using year and lotcateg.

// bring on bootstrap distribution to data
matrix d_B = d_B[2...,1]
svmat  d_B, names(col)

// create non-parametric 90% confidence interval for d
summ d_B, d
scalar bmin = r(p5)
scalar bmax = r(p95)
scalar list bmin bmax


