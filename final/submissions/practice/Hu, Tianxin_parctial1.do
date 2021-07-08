//settings
set more off
clear all
global projects: env projects
global storage : env storage
global data = "$storage/econ900/econ900-03/final"
cd $data
use lottery_newstata.dta

//1.
//if bata(z) is not 0, then z has the marginal effect on D, which means z is relevent.
reg d z
//t= 26.70 reject 

//2.

//3.
ivregress 2sls lnw (d=z)