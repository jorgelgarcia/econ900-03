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
// Accessing data
cd $data
use lottery_newstata.dta, clear

// Creating variables for every combination of year and category
global X year lotcateg
egen combo = group($X)
levelsof combo, local(combo)
sort combo
drop if combo ==.

// ------------------------- PROBLEM 5 PART 1 ----------------------------- //

// This problem was difficult for me, and my explanation may not be that good.
// What I think we're supposed to do is reg lnw on z, get the relevant
// coefficient, then put that over the equivalent coefficient from regressing
// d on z. This is basically the same as computing the Wald estimator, so I
// don't know if that's okay or not. There's also the complication that you
// want a conditional regression, but that's apparently easy enough to build.

// We'll need to save these values, so we'll want to build three 8x1 matrices
// to do our calculations with. I've quieted the loop so that it doesn't crowd
// out my output.

matrix ITTEstimates = J(8,1,0)
matrix ITTDEstimates = J(8,1,0)
matrix LATEstimates = J(8,1,0)

quietly {
	foreach l of local combo {
		regress lnw z if combo==`l'
		matrix list e(b)
		mat A = e(b)
		matrix ITTEstimates[`l',1] = A[1,1]
		regress d z if combo== `l'
		mat A = e(b)
		matrix ITTDEstimates[`l',1] = A[1,1]
		matrix LATEstimates[`l',1] = ITTEstimates[`l',1]/ITTDEstimates[`l',1]
	}
}

matrix list LATEstimates

// 1: 1988 Lotcateg 3
// 2: 1988 Lotcateg 4
// 3: 1988 Lotcateg 5
// 4: 1988 Lotcateg 6
// 5: 1989 Lotcateg 3
// 6: 1988 Lotcateg 4
// 7: 1988 Lotcateg 5
// 8: 1988 Lotcateg 6

// I'm not happy that one of the LATE estimates is negative while all the
// rest are positive, nor am I happy that the estimates are so different from
// each other, but I don't know if that's a flaw in my method or if it should
// read that way.

// ------------------------- PROBLEM 5 PART 2 ----------------------------- //

// I think (there's some more guesswork involved here) that the weights are
// supposed to be the percentage of observations that belong to each unique
// combination of year and lottery category (what I've labelled lotcateg). I
// haven't figured out how to save counts into matrices, so I'm going to plug
// the numbers in directly, but you can see from the for-loop that these are
// the same numbers as what Stata measured.

matrix Products = J(8,1,0)

count
foreach l of local combo {
	count if combo==`l'
}

quietly {
	matrix Products[1,1] = (84/1476)*LATEstimates[1,1]
	matrix Products[2,1] = (209/1476)*LATEstimates[2,1]
	matrix Products[3,1] = (190/1476)*LATEstimates[3,1]
	matrix Products[4,1] = (266/1476)*LATEstimates[4,1]
	matrix Products[5,1] = (79/1476)*LATEstimates[5,1]
	matrix Products[6,1] = (191/1476)*LATEstimates[6,1]
	matrix Products[7,1] = (210/1476)*LATEstimates[7,1]
	matrix Products[8,1] = (247/1476)*LATEstimates[8,1]
}
	
matrix list Products

matrix WeightedAverage = J(1,1,0)
foreach l of local combo {
	matrix WeightedAverage[1,1] = WeightedAverage[1,1] + Products[`l',1]	
}

matrix list WeightedAverage

// As you can see, if my methods from Problem 1 and Problem 2 are correct, the
// weighted average of the LATEs should be about 0.21283869, which is a
// postiive treatment effect.

// ------------------------- PROBLEM 5 PART 3 ----------------------------- //

scalar b = WeightedAverage[1,1]
matrix bootstrapMatrix_B = J(1,1,.)
matrix colnames bootstrapMatrix_B = mainCol_B

// 1000 bootstrap observations is awful to look at, so this whole section has
// been quieted. My code contains additional comments on what is inside
// the quieted section. This will take a LONG time to execute.

// My general approach here was to take your boostrap code from the class
// exercise and try to repurpose it for the weighted average of the LATE.
// Also, like in Problem 4, this all breaks down in Stata IC because of matrix
// size limits (it works for smaller bootstrap numbers). If you've got a better
// license than me it may not be a problem; if you don't, you'd have to change
// the bootstraps to something much smaller (I know it runs for 100 on Stata
// IC).

quietly{
	forvalues b = 1(1)$bootstraps {
		preserve
		bsample
	
		// This whole passage should, I hope, just redo all of the work of
		// calculating the weighted average of the LATE for each boostrap
		// sample. I would think this might break down because the boostraps
		// will screw with the proportions of the unique combos and possibly
		// even fail to include observations for some of them, but I don't know
		// how to fix that potential problem.
	
		matrix ITTEstimates = J(8,1,0)
		matrix ITTDEstimates = J(8,1,0)
		matrix LATEstimates = J(8,1,0)
		quietly {
			foreach l of local combo {
				regress lnw z if combo==`l'
				matrix list e(b)
				mat A = e(b)
				matrix ITTEstimates[`l',1] = A[1,1]
				regress d z if combo== `l'
				mat A = e(b)
				matrix ITTDEstimates[`l',1] = A[1,1]
				matrix LATEstimates[`l',1] = ITTEstimates[`l',1]/ITTDEstimates[`l',1]
			}
		}
		matrix list LATEstimates
		matrix Products = J(8,1,0)
		count
		foreach l of local combo {
			count if combo==`l'
		}
		quietly {
			matrix Products[1,1] = (84/1476)*LATEstimates[1,1]
			matrix Products[2,1] = (209/1476)*LATEstimates[2,1]
			matrix Products[3,1] = (190/1476)*LATEstimates[3,1]
			matrix Products[4,1] = (266/1476)*LATEstimates[4,1]
			matrix Products[5,1] = (79/1476)*LATEstimates[5,1]
			matrix Products[6,1] = (191/1476)*LATEstimates[6,1]
			matrix Products[7,1] = (210/1476)*LATEstimates[7,1]
			matrix Products[8,1] = (247/1476)*LATEstimates[8,1]
		}
		matrix list Products
		matrix WeightedAverage = J(1,1,0)
		foreach l of local combo {
			matrix WeightedAverage[1,1] = WeightedAverage[1,1] + Products[`l',1]	
		}
	
		matrix mainCol_`b' = WeightedAverage[1,1]
		matrix bootstrapMatrix_`b' = [mainCol_`b']
		matrix bootstrapMatrix_B = [bootstrapMatrix_B \ bootstrapMatrix_`b']
	
		restore
	}
}

matrix bootstrapMatrix_B = bootstrapMatrix_B[1...,1...]
svmat bootstrapMatrix_B, names(col)
summ mainCol, d
scalar mainColmin = r(p5)
scalar mainColmax = r(p95)
scalar list mainColmin
scalar list mainColmax

// To my understanding, this is the desire 90% confidence interval for the 
// weighted average of the LATEs for each combination of year and lottery
// category. I can't really say a lot about it (I mostly test with extremely
// low bootstrap numbers, to make sure my code works), but every time I've run
// it it has at least included my estimate of 0.21283869 in its interval, so
// that's a good sign.
