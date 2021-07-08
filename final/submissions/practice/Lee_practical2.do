//Part 2 
use "C:\Users\chaew\Desktop\Classes\ECO9000-03\Final\lottery_newstata.dta"
	reg d z female
	predict dhat
	reg lnw female dhat
	eststo ts

//*Problem 2
//1)
by year lotcateg, sort : eteffects (lnw female) (d z), atet level(90) nolog

//2)
by year lotcateg, sort : eteffects (lnw female) (d z) [pweight = lnw], atet level(90) nolog

//3)
//I don't know why but bootstrap is not working with treatment effect in my STATA. Saying "the by prefix may not be used with vce(bootstrap) option"
//"by year lotcateg, sort : eteffects (lnw female, probit) (d z), atet vce(bootstrap, cluster(d) reps(1000) seed(1) dots(1)) level(90) nolog" is what I tried.


set seed 1
global bootstrap 1000

reg lnw female dhat

matrix ab_B = J(1,2,.)
matrix colnames ab_B = a_B b_B

quietly {
 forvalues b = 1(1)$bootstrap{
	preserve
	bsample 
	reg lnw female dhat
	matrix beta = e(b)
	matrix a_`b' = beta[1,2]
	matrix b_`b' = beta[1,1]
	matrix ab_`b' = [a_`b',b_`b']
	matrix ab_B = [ab_B \ ab_`b']
	restore
}
}

matrix ab_B = ab_B
matrix ab_B = ab_B[2...,1...]
svmat ab_B, names(col)

correlate a_B b_B, cov
sum a_B
sum b_B
