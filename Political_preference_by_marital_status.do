//Assignment do file

set more off
//Defining the directory:
global dir1 "/Users/nicolobarbagallo/Desktop/Longitudina Family studies/Assignment/merge"

***Creating a long file data using waves 1-3 of Understanding Society***

//A loop comand to select variables from each file and create temporary files:  
foreach wave in a b c d e f g {
use pidp `wave'_sex `wave'_mastat_dv `wave'_vote3 `wave'_dvage /// 
using "$dir1/`wave'_indresp", clear
renpfix `wave'_
gen wave=index("abcdefg","`wave'")
save "$dir1/junk`wave'", replace
}

//A loop to append all files together
//(note that the last file "junkc" is still open, so the letter c is excluded from the loop):
foreach wave in a b c d e f {
append using "$dir1/junk`wave'"
}
 
//Explore the data:
//sum

//Recode negative values as missing:
foreach var of varlist mastat_dv vote3 sex {
recode `var' -10/-1=.
}
recode mastat_dv 0=.
recode dvage -9/-1=.
recode dvage 16=.
recode dvage 17=.

//Variable creation
sort pidp
by pidp: generate t = _n 
bysort pidp: ge mar1 = mastat_dv == 2

///recoding political vote3
bysort pidp: ge PA = vote3 == 1 // conservative
replace PA=2 if vote3 == 2 // labour
replace PA=3 if vote3 == 3 // lib-dem
replace PA=4 if vote3 == 95 // none
recode PA 0=.
///recoding sex
replace sex=0 if Sex==1
replace sex=1 if Sex==2

///renaing and labeling
rename dvage Age
rename sex Sex
rename wave Wave
rename PA Party
lab var mar1 "Marriage status"
rename mar1 Married_status
label define party 1 "Conservative" 2 "Labour" 3 "Lib-Dem" 4 "None"
label values Party party
label define year 1 "2009-2010" 2 "2010-2011" 3 "2011-2012" 4 "2012-2013" 5 "2013-2014" 6 "2014-2015" 7 "2015-2016"
label values Wave year
label define FM 0 "Male" 1 "Female"
label values Sex FM
label define MAR 0 "Other" 1 "Married"
label values Married_status MAR

//Define panel variables and explore the data:
xtset pidp Wave
xtdes
xtsum

/// running the Multinomial logistic regression computing prediciting margins and plotting them

mlogit Party i.Married_status i.Sex Wave Age, base(1) rrr
margins 1.Married_status, at(Wave=(1 2 3 4 5 6 7)) vsquish
marginsplot, noci

///descriptive statistics 

///dependent variable

tab Party if 1.Married_status
xttrans Party if 1.Married_status

/// Dependent vars

tab Sex
xttab Married_status 
sum Age

///respodents patterns over seven waves
xtdes


