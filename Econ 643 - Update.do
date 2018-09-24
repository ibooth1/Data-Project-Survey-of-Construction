clear all
capture log close
cd "C:\Users\Isaac\Documents\GitHub\soc-analysis"
log using "Econ643 - Update", replace

******************************************************************
************************** ECON 643 ******************************
************************* Data Project ***************************
**************************Isaac Booth*****************************
******************************************************************

***********************Project Explainer**************************

/* Initially a group project assigned for Empirical Analysis I,
this assignment has been overhauled to incorporate a more nuanced
understanding of stata and the nature of econometric techniques.
The accompanying paper has also been updated to reflect my
understanding of econometrics from an impact analysis perspective.
*/
******************************************************************

**********************Importing the Data**************************
/*
Data was obtained from census's Survey of Construction webpage

See the readme for a link to the data source.
*/
******************************************************************

clear
import excel "soc17.xls", sheet("soc17") firstrow

******************************************************************
*************************Data Cleaning****************************
******************************************************************

******************************************************************
/*
As nice as the Census's data is, when I imported it into excel it
was all strings. I ran a foreach loop to destring the variables
that describe housing characteristics. Some variables were already
not strings, but it was faster to put them in the loop than it
would have been to check their data types. Also the dummy
variables were all coded as 1 or 2, but dummy variables in STATA
must be coded as 0 or 1.
*/
******************************************************************


*foreach loop to destring variables
foreach x in "FINC" "ACS" "AGER" "ASSOC" "BASE" "CAT" "CLOS" "CON" "DET" "DIV" "FNBS" "FOYER" "FRAME" "GAR" "HEAT" "HEAT2" "LNDR" "METRO" "MFGS" "SEWER" "STOR" "WAL1" "WAL2" "WALS" "WATER" "AREA" "BEDR" "FFNSQ" "FPLS" "FULB" "HAFB" "LOTV" "FSQFS" {
	destring `x', replace
}


*changing dummy variables to 0 and 1
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


*******************Coding the "treatment" Dummy*******************
/*
This particular dummy variable is the "treatment" variable which
refers to the fact that anyone who received FHA financing received
the "treatment" of being cash poor by the amount of cash they
would have needed to afford a conventional loan instead 
*/
******************************************************************

gen FIN = 0
replace FIN = 1 if FINC == 2

***************************Final Cleaning*************************
/*
The final cleaning is to drop any sales for which a sale price was
unrecorded. This is so we don't skew the results too low by
including new homes that simply have not yet been sold
*/
******************************************************************

drop if FSLPR == 0

*Make and assign labels so that our graphs appear more legible
label define labb 0 CONVENTIONAL 1 FHA
label values FIN labb

********************Preliminary Data Visualization****************
/*Create a histogram of the distriubtions of home sales for those
who used conventional loans and those who used FHA loans in order
to see what biases the data may contain.
*/

histogram FSLPR, bin(20) percent by(FIN)
graph save Graph "FHA & Conventional Loan Distributions.gph",replace

****************Change Sale Price to Log Specification************
/*
A log specification allows us to view any change in the dependent
variable as a percent change resulting from a change in the
independent variable. This is more useful than comparing flat
dollar values across a spectrum of homebuyers due to the
differences between homebuyers at the far left and far right of
both distriubtions
*/
******************************************************************

gen logFSLPR = log(FSLPR)

******************************************************************
************************Data Analysis*****************************
******************************************************************


**************Run Simplest Specification of the Analysis**********
/*
Running a regression of log sale price on type of financing to
obtain an estimate of the predicted effect of the financing type
on final sale price
*/
******************************************************************

reg logFSLPR FIN [iw=WEIGHT]
est sto fin1

***********Run Specification of the Analysis With Controls********
/*
By including controls, we can more accruately estimate the impact
of financing type on final sale price. The values are stored and
postestimation is run to check for multicollinearity
*/
******************************************************************

reg logFSLPR FIN acs ager assoc i.BASE i.CAT con det i.DIV fnbs foyer i.FRAME i.GAR i.HEAT i.HEAT2 i.LNDR metro i.MFGS i.SEWER i.STOR i.WAL1 i.WAL2 wals i.WATER AREA i.BEDR FFNSQ FPLS FULB HAFB LOTV FSQFS [iw=WEIGHT]

*postestimation to check for multicollinearity
vif
*storing the regression outputs
est sto fin2

***********Variables removed due to high VIF:*********************
/*
BEDR(number of bedroom)
LNDR(location of laundry room)
GAR(type of parking)
MFGS(construction method)
*/
******************************************************************

*********Final Specification of the Analysis With Controls********
/*
By removing variables with collinearity we can obtain a more
accurate estimate of the coefficients on the controls and achieve
a model with lower standard errors/more accuracy
*/
******************************************************************

*Final attempt
reg logFSLPR FIN acs ager assoc i.BASE i.CAT con det i.DIV fnbs foyer i.FRAME i.HEAT i.HEAT2 metro i.SEWER i.STOR i.WAL1 i.WAL2 wals i.WATER AREA FFNSQ FPLS FULB HAFB LOTV FSQFS [iw=WEIGHT]
vif
est sto fin3

***************************Results********************************

esttab fin1 fin2 fin3, r2







log close
