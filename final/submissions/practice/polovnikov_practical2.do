set more off
clear all

global projects: env projects
global storage : env storage

set seed 1
global bootstraps 1000
set matsize 11000

*ssc install ivreg2
*ssc install xtivreg2

global data = "$storage/econ900/econ900-03/final"
global code = "$projects/econ900-03_empirical/classcodes"

cd  $data
use lottery_oldstata.dta, clear

egen lott_year = group(lotcateg year)
egen cat_num = max(lott_year)
global categories = cat_num

////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////Question 1////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

forvalues c = 1(1)$categories {
	egen mean_y_z1_`c' = mean(lnw) if z == 1 & lott_year == `c'
	egen mean_y_1_`c' = max(mean_y_z1_`c')
	drop mean_y_z1_`c'
	
	egen mean_y_z0_`c' = mean(lnw) if z == 0 & lott_year == `c'
	egen mean_y_0_`c' = max(mean_y_z0_`c')
	drop mean_y_z0_`c'
	
	egen mean_d_z1_`c' = mean(d) if z == 1 & lott_year == `c'
	egen mean_d_1_`c' = max(mean_d_z1_`c')
	drop mean_d_z1_`c'
	
	egen mean_d_z0_`c' = mean(d) if z == 0 & lott_year == `c'
	egen mean_d_0_`c' = max(mean_d_z0_`c')
	drop mean_d_z0_`c'
	
	gen late_z_`c' = (mean_y_1_`c' - mean_y_0_`c') / (mean_d_1_`c' - mean_d_0_`c')
	drop mean_y_1_`c' mean_y_0_`c' mean_d_1_`c' mean_d_0_`c'
}


////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////Question 2////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

gen id = _n
egen N = count(id) if z == 1 & d == 1
egen N_compl= count(id) if d == 1 & z == 1, by(lott_year)
drop id
gen weight = N_compl / N

collapse late_z_* weight N N_compl, by(lott_year)

gen late_z = .
forvalues c = 1(1)$categories {
	replace late_z = late_z_`c' if lott_year == `c'
}
egen late = sum(late_z * weight)
*calculated LATE = 0.21388729\



////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////Question 3////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

set more off
clear all

global projects: env projects
global storage : env storage

set seed 1
global bootstraps 1000
set matsize 11000

global data = "$storage/econ900/econ900-03/final"
global code = "$projects/econ900-03_empirical/classcodes"

cd  $data
use lottery_oldstata.dta, clear

egen lott_year = group(lotcateg year)
egen cat_num = max(lott_year)
global categories = cat_num


matrix LATE = J(1,1,.)
matrix colnames LATE = late
/// my apologies for the running time, did not have time to think of a better way////
forvalues b = 1(1)$bootstraps {
	preserve
	bsample, cluster(lott_year) 
	
		forvalues c = 1(1)$categories {
			egen mean_y_z1_`c' = mean(lnw) if z == 1 & lott_year == `c'
			egen mean_y_1_`c' = max(mean_y_z1_`c')
			drop mean_y_z1_`c'
	
			egen mean_y_z0_`c' = mean(lnw) if z == 0 & lott_year == `c'
			egen mean_y_0_`c' = max(mean_y_z0_`c')
			drop mean_y_z0_`c'
	
			egen mean_d_z1_`c' = mean(d) if z == 1 & lott_year == `c'
			egen mean_d_1_`c' = max(mean_d_z1_`c')
			drop mean_d_z1_`c'
	
			egen mean_d_z0_`c' = mean(d) if z == 0 & lott_year == `c'
			egen mean_d_0_`c' = max(mean_d_z0_`c')
			drop mean_d_z0_`c'
	
			gen late_z_`c' = (mean_y_1_`c' - mean_y_0_`c') / (mean_d_1_`c' - mean_d_0_`c')
			drop mean_y_1_`c' mean_y_0_`c' mean_d_1_`c' mean_d_0_`c'
		}
		
		gen id = _n
		egen N = count(id) if z == 1 & d == 1
		egen N_compl= count(id) if d == 1 & z == 1, by(lott_year)
		drop id
		gen weight = N_compl / N

		collapse late_z_* weight N N_compl, by(lott_year)

		gen late_z = .
		forvalues c = 1(1)$categories {
			replace late_z = late_z_`c' if lott_year == `c'
		}
		egen late = sum(late_z * weight)
		local late = late
		matrix late_`b' = `late'
		matrix LATE = [LATE \ late_`b']
		restore
}

matrix LATE = LATE[2...,....]
svmat  LATE, names(col)

egen late_empirical_exp = mean(late)

//distribution with the result from Q2 (red line)
#delimit
twoway (histogram late, barw(.001) lcolor(gs0) fcolor(none) xline(0.21388729, lcolor(red) lwidth(thick)))
       (kdensity  late, lcolor(gs0)) ,
		  legend(label(1 "histogram")  label(2 "density") order(1 2) row(1))
		  ylabel(, grid glcolor(gs14) angle(h) labsize(medlarge)) 
		  xlabel(, grid glcolor(gs14) angle(h)) 
		  ytitle("Density")
		  xtitle("Support", size(medlarge))
		  graphregion(color(white)) plotregion(fcolor(white));
#delimit cr
