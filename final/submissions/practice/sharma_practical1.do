
	set more off
	clear all
	set seed 0
	global bootstrap 500
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
	
	
//Answer 1:
	//Checking the relevance condition of Instrument Variables//
	//Runing the first stage regression of endogenous variable(d) on instrument vaiables(z)//
	//Note that errors is adjust at category define as lotcateg//we can do this without using cluster to see the correlation between d and z.
	reg d  z, cluster(lotcateg)
	test z=0
	di invFtail(1,3,0.05)
	//we can see our F stat value is greater then critical value (31.74> 10.12)(also looking at p value);
	//we can reject the null that all z is zero. Hence Corr(x,z) not equal to 0.(Relevance Condition satisified)//
	
	
	//Without adjusting at lotcateg //
	//similar procedure//
	reg d  z
	test z=0
	di invFtail(1,1474,0.05)
	//we can see our F stat value is greater then critical value (also looking at p value);
	//we can reject the null that all z is zero. Hence Corr(x,z) not equal to 0.(Relevance Condition satisified)//

	
	
//Answer 2: Esitmating the casual effect of graduation on post-graduation log wage
		//First : Without clustering//
		ivregress 2sls lnw female (d=z)
	
		
		
		
	//we can obtain robust std error using cluster regression at categories defined by lotcateg.//	
	ivregress 2sls lnw female (d=z),cluster(lotcateg)
		di _b[d]
		gen b_IV=_b[d]
		
	
	//Comparing the standard error (robust standard error in case of cluster regression), (0.02544<0.05043)
	//we find that the robust standard standard error is less than the normal standard error from the regression without clustering.//
	//This justifies the use of cluster regression.//
	
//Answer 3:
   //Usng two stage regression here
   //First stage//
   reg d z female, cluster(lotcateg)
   predict iv,xb
   
   //Second Stage//
   reg lnw iv female,cluster(lotcateg)
   di _b[iv]
   gen b_IV2stage=_b[iv]
   
   //Comparing the two slope estimates, they are identical i.e. b_IV=b_IV2stage//
   
   
   
//Answer 4:
   //Estimating the Wald esitmator beta_wald//
   //getting the sum of lnw and d(endogenous) over z=1 and z=1
   total lnw, over(z)
   total d,over(z)
   
   //Calculating the average of lnw and d over z=1 and z=0 //
   tab z
   gen size_treatment= 1020
   gen size_ctrl=456
   gen sum_lnw_1= 3248.399
   gen sum_lnw_0= 1407.83
   gen sum_d_1= 949
   gen sum_d_0= 187
   gen beta_wald= ((sum_lnw_1/size_treatment)-(sum_lnw_0/size_ctrl))/((sum_d_1/size_treatment)-(sum_d_0/size_ctrl))
   di beta_wald
   
   //comparing beta_wald and beta_wald and b_IV , we find that they are identical //
   
   
   
   

