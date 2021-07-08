///////////////////////////////////////////////////////////////////////
/*
		Final Exam - Part Two: Problem Two - ECON 900_03
		Micah Thomas
		December 5, 2020	
*/
///////////////////////////////////////////////////////////////////////
/////////////////////			SETUP			///////////////////////
///////////////////////////////////////////////////////////////////////
	set more off			// Prevent output breaks
	clear all				// Clear memory
	set seed 1				// Setting the seed
	global bootstrap 1000	// Setting bootstrap - Instructions: 1000
	set trace off
	//env variables
		global projects: env projects
		global storage : env storage
	//locations
		global data = "$storage/econ900/econ900-03/final"
	// Importing the dataset
		cd  $data
		use lottery_newstata.dta, clear		// Importing the "New" Dataset
///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////




///////////////////////////////////////////////////////////////////////
//////////////////////////  NUMBER 1   ////////////////////////////////
///////////////////////////////////////////////////////////////////////

	  // The LATE parameter is effectively the coefficient on the endogenous
	  // in the 2SLS or the coefficient on the fitted regression on the endogeneous
	  // variable when using the seperate OLS approach.
	  // Looping by year and category to estimate the IV LATE in each period
		gen weighted_LATE = 0	// Generating a holding for the weighted LATE
		forvalues y=1988(1)1989 {	// Looping through the years
			forvalues k=3(1)6 {		// Looping through the lottery categories
				ivregress 2sls lnw female (d = z) if year == `y' & lotcateg == `k'
				gen LATE_`y'_`k' = _b[d]	// Storing the LATE
				gen weight_`y'_`k' = e(N)/_N	// Estimating the weight of the LATE
				gen weighted_LATE_`y'_`k' = _b[d]*e(N)/_N	// Weighing the LATE 
			  // Generating the sum of the overall weighted late
				replace weighted_LATE = weighted_LATE+weighted_LATE_`y'_`k'	
				}
			}
	  // Displaying the LATE by year and category:
		mean LATE_*
		
		
		
		
///////////////////////////////////////////////////////////////////////
//////////////////////////  NUMBER 2   ////////////////////////////////
///////////////////////////////////////////////////////////////////////
	  // Displaying the appropriate weights as calculated above:
		mean weight_*
	  // Displaying the overall weighted LATE:
		display "The weighted Late is: " weighted_LATE
		
		
		
		
///////////////////////////////////////////////////////////////////////
//////////////////////////  NUMBER 3   ////////////////////////////////
///////////////////////////////////////////////////////////////////////
	  // Generating a holder matrix to carry the values outside the bootstrap
		matrix ab_B = J(1,2,.)
		matrix colnames ab_B = a_B b_B
		
	  // Beginning bootstrap simulations
		forvalues b = 1(1)$bootstrap { // Looping through bootstrap set in the setup
			display "....." `b'		// Displaying bootstrap round for verification
			quietly preserve	// Preserving the original sample
			quietly bsample 	// Pulling a random bootstrap sample
			quietly replace weighted_LATE = 0	// Resetting the weighted LATE holder
			quietly forvalues y=1988(1)1989 {	// Looping through the years
				forvalues k=3(1)6 {		// Looping through the lottery categories
				  // Beginning the estimation by year and category
					reg d female z		// Generating first stage estimates
					gen IV_`b'_`y'_`k' = _b[_cons]+_b[female]*female+_b[z]*z /// 
						if year == `y' & lotcateg == `k'
					reg lnw female IV_`b'_`y'_`k' if year == `y' & lotcateg == `k'
					replace weighted_LATE_`y'_`k' = _b[IV_`b'_`y'_`k']*e(N)/_N
					replace weighted_LATE = weighted_LATE+weighted_LATE_`y'_`k'
					}
				}
			global holder = float(weighted_LATE)	// Storing the bootstrapped LATE
			matrix a_`b' == 0	// Filling the holder column
			matrix b_`b' = [float( $holder )]	// Slotting the bootstrapped LATE
			matrix ab_`b' = [a_`b',b_`b']	// Appending submatrix
			matrix ab_B = [ab_B \ ab_`b']	// Appending outer matrix with submatrix
			restore		// Restoring the sample as saved by preserve
		}

	  // Imprinting the bootstrap distribution to the data
		matrix ab_B = ab_B[2...,1...]
		svmat  ab_B, names(col)

	  // Creating the 90% condidence interval for the bootstrapped weighted LATE
		summ b_B, d
		scalar bmin = r(p5)
		scalar bmax = r(p95)
		display "The 90% confidence interval is: [" bmin ", " bmax "]"
			// .The 90% confidence interval is: [.08542938, .3000567]
