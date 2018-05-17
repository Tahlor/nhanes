set excelxlsxlargefile on

gl root "D:\\Data\\NHANES\\NHANES\\"
gl input "$root/cdc"
gl output "$root/output"
gl temp "$root/temp"

adopath ++ "D:\\Applications\\Stata ADO"
clear 
local reimport 0

use "$temp/flagged variables.dta", clear
keep if !mi(flag)
capture rename feature_class featureclass 
keep flag featureclass variablename proper_label

bysort flag featureclass variablename (proper_label): keep if _n==1
*duplicates drop
*brdup variablename

levels variablename, local(variables)
drop if strpos(lower(variablename), "comment")
drop if strpos(lower(variablename), "comt")
drop if strpos(lower(variablename), "cmt")
drop if proper_label == "Calcium (Mg)"

sort featureclass flag
*gl variables `variables'

if `reimport' {
	clear
	gen year = .
	forval year = 1999(2)2013 {
		append using "$temp/`year'.dta"
		replace year = `year' if mi(year)
	}
	save "$temp/all years.dta", replace
}

use "$temp/all years.dta", replace

*keep year seqn lbdv4clc lbdvbflc lbdvbmlc lbdvbzlc lbdvcflc lbdvcmlc lbdvctlc lbdvdblc lbdveblc lbdvtclc lbdvtolc bmiwaist riagendr lbdv1dlc lbdv2alc lbdv3blc lbdvcblc lbdvmclc lbdvtelc lbd2dflc lbdvnblc lbdv06lc lbdvdxlc urdflow1 urdflow2 urdflow3 diq175c bmdsadcm lbdv07lc lbdv08lc lbdvc6lc lbdveelc lbdvealc lbdveclc lbdvmplc lbdvhtlc lbdvvblc
keep year seqn	ridagemn	riagendr	ridageyr	indfmin2	indfminc	seqn	bpxsy2	bmxwt	bpxpuls	bpxdi1	bpxsy4	bpxsy3	bmxht	bpxpty	bpxpls	bpxdi3	bpxdi2	bmxbmi	bpxdi4	bpxsy1	bmxwaist	bmdsadcm	bmxsad4	bmxsad3	bmxsad2	bmdavsad	bmiwaist	bmxsad1	seqn	enq020	enq010	lbxcrp	lbxtc	lbdhdd	lbdtcsi	lbxhdd	urxuio	seqn	urdflow3	urxvol2	urdflow1	urxvol1	urxucr	urdflow2	urxvol3	urxuhg	lbxihg	lbxbmn	lbxsf3	lbxbgm	lbxsf2	lbxthg	lbxbcd	lbxbge	lbxbpb	lbxbse	lbxsf5	seqn	mcq160b	mcq160c	mcq160d	mcq010	mcq203	mcq160e	mcq070	mcq160o	mcq160g	mcq160k	mcq082	mcq160f	mcq160l	mcq220	mcq160m	paq560	diq175o	diq175j	mcq370c	mcq370d	mcq365c	mcq365d	mcq370b	mcq300a	mcq365a	mcq370a	mcq086	mcq365b	mcq080	pad600	pad590	
* huq050	huq010	pfq020	huq051	hsd010	dlq050	paq710	paq715
* Check missings
gen mignder = mi(riagendr )
gen miage = mi(ridageyr)
tab year miage 
tab year mignder 
drop miage mignder
drop ur*

** Consolidate
use "$output/Final variables.dta", replace
*gen mid = mi(lbdhdd )
*gen mix = mi(lbxhdd )
*gen miindfmin2  = mi(indfmin2)
*gen miindfminc  = mi(indfminc)
replace lbdhdd  = lbxhdd if mi(lbdhdd )
replace indfminc  = indfmin2 if mi(indfminc)
drop lbxhdd indfmin2

save "$output/Final variables.dta", replace
export excel using "$output/Final variables.xlsx", sheetreplace firstrow(varlabels)

Stop

foreach var of varlist * {
	codebook `var' if year >= 2007
}

* ideas: make everything strings
* standardize variable names...
* Go back to using coded varible names...
