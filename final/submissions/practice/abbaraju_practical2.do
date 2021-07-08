clear all
set more off
set seed 0

// set environment variables
global projects: env projects
global storage : env storage

// locations
global data = "$storage/econ900/econ900-03/other"
global code = "$projects/econ900-03_empirical/classcodes"

cd  $data
use lottery_newstata.dta, clear

// I had to give the path directly because my env variable for box folder was not working
//use "/Users/pranith/Desktop/finalexam/lottery_newstata.dta"

// LATE Instrument & Treatement are binary variables
// LATE = Avg potential outcome for compliers when they DO receive treatment - Avg potential outcome for compliers when they DO NOT receive treatment

// We know that Avg Outcome in Control group = (Avg Potential outcome for compliers when they DON'T receive treatement x Proportion of compliers) + (Avg Potential outcome for NEVER TAKERS when they DON'T receive treatement x Proportion of Never Takers)


// Compliers receiving Treatment
//gen compliers_T = mean(lnw) if d==1 & z==1
scalar compliers_Trt = 3.197833


//Avg of entire Control group
//scalar all_C = mean(lnw) if d==0
scalar all_control = 3.056557 

// Now we take the percentage of compliers in the treatement group and multiply it with the above value to get the avg outcome of compliers when they dont get treatement. Assuming this is a random assignment into treatement and control. Similarly we can find the proportion of never takers and multiply it here to get average outcome of individuals who are never takers.

//Never Takers or Compliers in Control cannot be segregated at this time. We will however, calculate it below.

// Percentage of compliers and never takers in treatement 
scalar comp_percent = (949/1136)
scalar nt_percent = (187/1136)

// Compliers in Control
scalar  compliers_C = all_control * comp_percent

// Never takers in Control
scalar  nt_C = all_control * nt_percent

scalar LATE = compliers_Trt - compliers_C 

display LATE

// I apologize for my shabby attempt and I know this is no where close to what was asked but I was hoping I could get atleast some partial credit. Thank you!
