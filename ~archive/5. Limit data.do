set excelxlsxlargefile on

gl root "D:\\Data\\NHANES\\NHANES\\"
gl input "$root/cdc"
gl output "$root/output"
gl temp "$root/temp"

adopath ++ "D:\\Applications\\Stata ADO"
clear 

use "$temp/flagged variables.dta", clear
keep if !mi(flag)
capture rename feature_class featureclass 
keep flag featureclass variablename

duplicates drop
*brdup variablename

levels variablename, local(variables)
drop if strpos(lower(variablename), "comment")
drop if strpos(lower(variablename), "comt")
drop if strpos(lower(variablename), "cmt")
sort featureclass flag
*gl variables `variables'

clear
gen year = .
forval year = 1999(2)2013 {
	append using "$temp/`year'.dta"
	replace year = `year' if mi(year)
}

save "$temp/all years.dta", replace


use "$temp/all years.dta", replace
*keep riagendr diq175c

keep year seqn lbdv4clc lbdvbflc lbdvbmlc lbdvbzlc lbdvcflc lbdvcmlc lbdvctlc lbdvdblc lbdveblc lbdvtclc lbdvtolc bmiwaist riagendr lbdv1dlc lbdv2alc lbdv3blc lbdvcblc lbdvmclc lbdvtelc lbd2dflc lbdvnblc lbdv06lc lbdvdxlc urdflow1 urdflow2 urdflow3 diq175c bmdsadcm lbdv07lc lbdv08lc lbdvc6lc lbdveelc lbdvealc lbdveclc lbdvmplc lbdvhtlc lbdvvblc
/*foreach var of varlist * {
	local drop = 1
	local lab: variable label `var'	
	if `"`var'"' == "seqn" continue
	if `"`var'"' == "year" continue
		
	foreach varkeep of local variables {
	
	   *disp `"`lab' ||| `varkeep'"'
	   
		if `"`varkeep'"' == `"`lab'"' {
			local drop = 0 
			break
		}
	}
	
	if `drop' {
		drop `var'
		*disp in red `"Dropping `var'"'
		continue
	}
	disp in blue `"Keeping `var'"'
	
}
*/

gen mignder = mi(riagendr )
gen miage = mi(diq175c)
tab year miage 
tab year mignder 
save "$output/Final variables.dta", replace

foreach var of varlist * {
	codebook `var' if year >= 2007
}

* ideas: make everything strings
* standardize variable names...
* Go back to using coded varible names...
