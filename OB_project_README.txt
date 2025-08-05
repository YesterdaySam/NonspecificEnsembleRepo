These functions and helpers will analyze the behavioral accuracy of mice performing DNMP T-maze spatial alternation

1. Ensure all data is accurate and organized in the following way on the first tab of the spreadsheet.
Excel .xlsx file named Data_Log_%%# where %% is the name code and number, i.e. OB12
Data in file organized under the following headers and data types:
recFolderName - string e.g. OB9 20210726
sessionID - string e.g. pre_training or Opto_20_Hz
context - string e.g. A
optoType - string e.g. None or square
optoFreq - number e.g. 0 or 20
smplSeq - string e.g. NaN or RLLRRRRL
testSeq - string e.g. LRRLLRRL. NOTE! Must match smpleSeq length
optoSeq - Text e.g. NaN or 00000110101 NOTE! Must be Text formatted to prevent losing initial 0 characters
wt - numbmer e.g. 27.7
tagSide - number. Must be 1 for left or 0 for right.

2. Place data files in a main analysis directory, e.g. F:\Research\Code\OB_project

3. Open OB_Analyze_Script.m in Matlab and change the following as needed
mainPath - point to .xlsx file directory
rerunSoloFlag - 0 or 1 to re-analyze and plot single mouse data
rerunCohortFlag - 0 or 1 to re-analyze and plot cohort data
mouseInclude - vector of 0 or 1 to determine which mmice to include in the cohort. Must be the same length as number of data files

NOTE at the moment, cohort analysis must be done on mice with the same tag side

4. Run script

Outputs:
First creates an output directory for each mouse or skips previously analyzed mice if rerunSoloFlag is 1
For each trial the script saves a new variable, session_mouse_trialDate containing a struct with computed accuracy scores for various metrics

Then it transforms the session data into a single table and saves it
Then it makes various nonmparametric comparisons and outputs graphical views of them, saving all outputs as .png and .fig