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

reg lnw d 
reg lnw z 
reg d z

corr ln d z, covariance
//             |      lnw        d        z
//-------------+---------------------------
//        lnw |  .219392
//          d |  .022606   .17741
//          z |    .0208  .111159  .213642

//LATE =  .0208 / .111159 

//By year & category
//I'm sorry for not making loop
//I estimate 6 LATEs (year * lotcateg)

//keep if year == 1988 & lotcateg ==3
//reg lnw d 
//reg lnw z 
//reg d z

//corr ln d z, covariance
//             |      lnw        d        z
//-------------+---------------------------
//         lnw |  .253916
//           d | -.002378  .067126
//           z | -.013141  .016351  .096816

// LATE =  -.013141  / .016351


//By year & category
//keep if year == 1988 & lotcateg ==4
//reg lnw d 
//reg lnw z 
//reg d z

//corr ln d z, covariance

//            |      lnw        d        z
//-------------+---------------------------
//         lnw |  .218375
//           d |  .025696  .149476
//           z |  .007417  .062063  .182876

//LATE is   .007417 /.062063 


//By year & category
//keep if year == 1988 & lotcateg ==5
//reg lnw d 
//reg lnw z 
//reg d z

//corr ln d z, covariance

//             |      lnw        d        z
//-------------+---------------------------
//         lnw |  .184072
//           d |  .031456  .206767
//           z |  .022993  .144389  .240184

//LATE is   .022993 /.144389 



//By year & category
//keep if year == 1988 & lotcateg ==6
//reg lnw d 
//reg lnw z 
//reg d z

//corr ln d z, covariance
//
//             |      lnw        d        z
//-------------+---------------------------
//         lnw |  .240659
//           d |  .035934  .229366
//          z |  .034013  .162293  .246844

//LATE is   .034013 /.162293 



//By year & category
//keep if year == 1989 & lotcateg ==3
//reg lnw d 
//reg lnw z 
//reg d z

//corr ln d z, covariance


//             |      lnw        d        z
//-------------+---------------------------
//         lnw |   .24023
//           d |  .032573   .10224
//           z |  .028684  .018338  .060045

//LATE is   .028684/.018338 


//By year & category
//keep if year == 1989 & lotcateg == 4
//reg lnw d 
//reg lnw z 
//reg d z

//corr ln d z, covariance

//             |      lnw        d        z
//-------------+---------------------------
//         lnw |  .189994
//           d |   .01393  .094241
//           z |  .000511  .042767  .157013

//LATE is  .000511/.042767 


//By year & category
//keep if year == 1989 & lotcateg ==5
//reg lnw d 
//reg lnw z 
//reg d z

//corr ln d z, covariance

//             |      lnw        d        z
//-------------+---------------------------
//         lnw |   .21116
//           d |  .012435  .139553
//           z |  .036813  .070973  .218296

//LATE is .036813/.070973


//By year & category
//keep if year == 1989 & lotcateg == 6
//reg lnw d 
//reg lnw z 
//reg d z

//corr ln d z, covariance

//             |      lnw        d        z
//-------------+---------------------------
//        lnw |  .229075
//           d |  .017003  .224022
//           z |  .023282  .160182  .239459

//LATE is 0.023282/0.160182


*2. Aggregate the year-category-wise LATE parameter estimates using a weighted average with the appropriate weights.
//2SLS estimate is a certain weighted average of complier LATEs
reg d z year lotcateg

predict dhat
reg lnw dhat

ivregress 2sls lnw  year lotcateg (d = z)

*3.
ivregress 2sls lnw female year lotcateg (d = z), vce(cluster lotcateg)
bootstrap, reps(1000) seed(1): ivregress 2sls lnw female year lotcateg (d = z), vce(cluster lotcateg)

