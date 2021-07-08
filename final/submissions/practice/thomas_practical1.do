///////////////////////////////////////////////////////////////////////
/*
		Final Exam - Part Two: Problem One - ECON 900_03
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
	// env variables
		global projects: env projects
		global storage : env storage
	// locations
		global data = "$storage/econ900/econ900-03/final"
	// Importing the dataset
		cd  $data
		use lottery_newstata.dta, clear		// Importing the "New" Dataset
///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////




///////////////////////////////////////////////////////////////////////
//////////////////////////  NUMBER 1   ////////////////////////////////
///////////////////////////////////////////////////////////////////////
	  // Perform OLS regression of endogeneous variable on the instrument
		reg d female z		// Running first stage regression
		predict e, residuals	// Predicting the residuals from first stage
		reg lnw d female e		// Regress model using residuals
		test e		// Calculate F-test for instrument relevance: H0: Endeogeneity

		
		
///////////////////////////////////////////////////////////////////////
//////////////////////////  NUMBER 2   ////////////////////////////////
///////////////////////////////////////////////////////////////////////
	  // Performing the IV estimation
		reg d female z		// Generating first stage estimates
		gen IV_d = _b[_cons]+_b[female]*female+_b[z]*z	// Generating IV estimator
		reg lnw female IV_d, vce(cluster year)	// Running IV estimation
	  // This result suggests that there is an 18.77% increase in wages
	  // for those who graduate school as compared to those who do not graduate.
	  // Clustering in this case was based upon year only as the category was
	  // stated to be arbitrarily determined meaning the expected variance across
	  // the categories should be the same within a given year if the lottery is
	  // conducted in the same way across each category.
		
		
		
		
///////////////////////////////////////////////////////////////////////
//////////////////////////  NUMBER 3   ////////////////////////////////
///////////////////////////////////////////////////////////////////////
	  // Verifying that the 2SLS produces the same solution as the manual process
		ivregress 2sls lnw female (d = z), vce(cluster year)
		estat firststage

		
		
		
///////////////////////////////////////////////////////////////////////
//////////////////////////  NUMBER 4   ////////////////////////////////
///////////////////////////////////////////////////////////////////////
	  // Calcualting the Wald Estimator based on the appropriate covariances
		quietly corr d z, cov	// Estimating the denominator 
		quietly gen cov_dz = r(cov_12)	// Storing the value
		quietly corr lnw z, cov		// Estimating the numerator
		quietly gen cov_lnwz = r(cov_12)	// Storing the value
		quietly gen wald_estimator = cov_lnwz/cov_dz  //Calculating the Wald Estimator
		display "The Wald Estimator is: " wald_estimator	
		
		