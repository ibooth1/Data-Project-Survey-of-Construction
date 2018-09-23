clear all
capture log close
cd "C:\Users\Isaac\Google Drive\FNMA"
log using "Econ643 - Update", replace

******************************************************************
************************** ECON 643 ******************************
************************* Data Project ***************************
**************************Isaac Booth*****************************
******************************************************************

**********************Importing the Data**************************

clear
import excel "soc17.xls", sheet("soc17") firstrow

*************************Data Cleaning****************************


*turning strings into numeric for analysis
foreach x in "FINC" "ACS" "AGER" "ASSOC" "BASE" "CAT" "CLOS" "CON" "DET" "DIV" "FNBS" "FOYER" "FRAME" "GAR" "HEAT" "HEAT2" "LNDR" "METRO" "MFGS" "SEWER" "STOR" "WAL1" "WAL2" "WALS" "WATER" "AREA" "BEDR" "FFNSQ" "FPLS" "FULB" "HAFB" "LOTV" "FSQFS" {
	destring `x', replace
}

*cleaning dummy variables
gen acs = .
replace acs = 1 if ACS==1
replace acs = 0 if ACS==2

gen ager = .
replace ager = 1 if AGER==1
replace ager = 0 if AGER==2

gen assoc = .
replace assoc = 1 if ASSOC==1
replace assoc = 0 if ASSOC==2

gen con = .
replace con = 1 if CON==1
replace con = 0 if CON==2

gen det = .
replace det = 1 if DET==1
replace det = 0 if DET==2

gen fnbs = .
replace fnbs = 1 if FNBS==1
replace fnbs = 0 if FNBS==2

gen foyer = .
replace foyer = 1 if FOYER==1
replace foyer = 0 if FOYER==2

gen metro = .
replace metro = 1 if METRO==1
replace metro = 0 if METRO==2

gen wals = .
replace wals = 1 if WALS==1
replace wals = 0 if WALS==2


 
*create "treatment" dummy variable
gen FIN = 0
replace FIN = 1 if FINC == 2
drop if FSLPR == 0

*make and assign labels
label define labb 0 CONVENTIONAL 1 FHA
label values FIN labb

*create histogram of distributions for initial analysis
histogram FSLPR, bin(20) percent by(FIN)
graph save Graph "FHA & Conventional Loan Distributions.gph",replace

*specify sale price as log
gen logFSLPR = log(FSLPR)

************************Data Analysis*****************************

*run simplest specification of the analysis
reg logFSLPR FIN [iw=WEIGHT]
est sto fin1

*add potential controls
reg logFSLPR FIN acs ager assoc i.BASE i.CAT con det i.DIV fnbs foyer i.FRAME i.GAR i.HEAT i.HEAT2 i.LNDR metro i.MFGS i.SEWER i.STOR i.WAL1 i.WAL2 wals i.WATER AREA i.BEDR FFNSQ FPLS FULB HAFB LOTV FSQFS [iw=WEIGHT]
*postestimation to check for multicollinearity
vif
est sto fin2

/*
Variables removed due to high VIF:
BEDR(number of bedroom)
LNDR(location of laundry room)
GAR(type of parking)
MFGS(construction method)
*/

*second attempt
reg logFSLPR FIN acs ager assoc i.BASE i.CAT con det i.DIV fnbs foyer i.FRAME i.HEAT i.HEAT2 metro i.SEWER i.STOR i.WAL1 i.WAL2 wals i.WATER AREA FFNSQ FPLS FULB HAFB LOTV FSQFS [iw=WEIGHT]
vif
est sto fin3

*attempt at matching algorithm
*psmatch2 FIN acs ager assoc i.BASE i.CAT con det i.DIV fnbs foyer i.FRAME i.HEAT i.HEAT2 metro i.SEWER i.STOR i.WAL1 i.WAL2 wals i.WATER AREA FFNSQ FPLS FULB HAFB LOTV FSQFS, out(logFSLPR) neighbor(5) ties ate

***************************Results********************************



esttab fin1 fin2 fin3, r2







log close
