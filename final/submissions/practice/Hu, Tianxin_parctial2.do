//settings
set more off
clear all
global projects: env projects
global storage : env storage
global data = "$storage/econ900/econ900-03/final"
cd $data
use lottery_newstata.dta

//1.

matrix ab_B = J(1,2,.)
matrix colnames ab_B = a_B b_B

#delimit
gen cate = cond(year==1988 & lotcateg == 3,1, 
           cond(year==1988 & lotcateg == 4,2,
		   cond(year==1988 & lotcateg == 5,3,
		   cond(year==1988 & lotcateg == 6,4,
		   cond(year==1989 & lotcateg == 3,5,
		   cond(year==1989 & lotcateg == 4,6,
		   cond(year==1989 & lotcateg == 5,7,
		   cond(year==1989 & lotcateg == 6,8,0
		   ))))))));
#delimit cr

forvalues cate = 1(1)8 {
		ivregress 2sls lnw (d=z) if cate == `cate'
		matrix beta = e(b)
	    matrix a_`b' = beta[1,2]
	    matrix b_`b' = beta[1,1]
		matrix ab_`b' = [a_ `b',b_ `b']
		matrix ab_B = [ab_B \ ab_`b']
}
matrix ab_B = ab_B[2...,1...]
matlist ab_B

//2.

//3.
