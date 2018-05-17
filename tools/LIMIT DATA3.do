set excelxlsxlargefile on

gl root "D:\\Data\\NHANES\\NHANES\\"
gl input "$root/cdc"
gl output "$root/output"
gl temp "$root/temp"

** Consolidate
use "$output/Final variables.dta", replace
*gen mid = mi(lbdhdd )
*gen mix = mi(lbxhdd )
*gen miindfmin2  = mi(indfmin2)
*gen miindfminc  = mi(indfminc)

*replace lbdhdd  = lbxhdd if mi(lbdhdd )
*replace indfminc  = indfmin2 if mi(indfminc)
*drop lbxhdd indfmin2

** Average blood pressures
*bpxdi1 bpxdi2 bpxdi3 bpxdi4
*bpxsy1  bpxsy2 bpxsy3 bpxsy4 

egen systolic_avg = rowmean(bpxsy*)
egen diastolic_avg = rowmean(bpxdi*)
egen ab_diam = rowmean(bmxsad*)

replace bpxsy1  = systolic_avg
replace bpxdi1  = diastolic_avg
replace bmxsad1 = ab_diam

drop bpxsy2 bpxsy3 bpxsy4 bpxdi2 bpxdi3 bpxdi4 bmxsad2 bmxsad3 bmxsad4
drop systolic_avg diastolic_avg ab_diam

foreach var of varlist * {
	local label: var l `var'
	disp "`label'"
	
	foreach symbol in " " "#" "/" "-" "*" "(" ")" ":" "." "," "?" {
		local label = subinstr("`label'", "`symbol'", "_", .)
		local label = subinstr("`label'", "__", "_", .)
	}
	if "`label'" != "" label variable `var' "_`label'"
}

local label_variable mcq160c
global label_variable mcq160c
local continuous_variables bpxsy1  bpxdi1  bmxsad1 lbxcrp	lbxbpb	lbxbcd	lbxthg	lbxihg	lbxtc	lbdtcsi	bpxpls	bmxwt	bmxht	bmxbmi	bmxwaist	ridageyr	ridagemn	indfminc	lbdhdd	lbxsf2	lbxbge	lbxbgm	lbxbse	lbxbmn	bmdavsad	diq175o	diq175j	lbxsf5	lbxsf3 pad590 pad600

drop if mi(`label_variable')
drop if !inlist(`label_variable', 1,2)

gen x = 0 /*`label_variable'*/

tempfile a b
save `a'

*collapse (mean) `continuous_variables', by(`label_variable')
collapse (mean) `continuous_variables', by(x)
rename * *_avg
rename x_avg x
save `b'

use `a', clear
merge m:1 x using `b', assert(3) nogen
drop x

foreach var of varlist  `continuous_variables' {
	*gen mi_`var' = mi(`var')
	*bysort 
	replace `var' = `var'_avg if mi(`var')
	order `var', last
}

drop *avg

foreach var of varlist * {
	local label: var l `var'
	if "`label'" != "" rename `var' `=substr("`label'", 1,31)'
}
drop __time_week_you_play_or_exercis
drop _Total_cholesterol_mg_dL_
drop _Waist_Circumference_Comment
drop _Ever_told_had_congestive_heart 
drop _Ever_told_you_had_angina_angin 
drop _Ever_told_you_had_heart_attack 
drop _Ever_told_you_had_COPD_
drop _Sagittal_Abdominal_Diameter_Co
drop seqn
order _Ever_told_you_had_coronary_hea, last

save "$output/Final variables2.dta", replace
capture rm "$output/variables.csv"
export delimited using "$output/variables.csv", replace

*export excel using "$output/Final variables.xlsx", sheetreplace firstrow(varlabels)


foreach var of varlist * {
	*corr $label_variable `var'
	disp in red "`var'"
	corr _Ever_told_you_had_coronary_hea `var'
}
