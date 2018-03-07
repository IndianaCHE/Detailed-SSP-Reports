@echo off
setlocal enabledelayedexpansion
SET "location=\\state.in.us\file1\CHE\Research&Analysis\Users\Alex\Projects\Detailed-SSP-Reports"
SET schools_query_file=!location!\schools.sql
SET ssp_query_file=!location!\county_detailed_SSPs.sql
SET rawdatafile=!location!\raw_record_data.csv
SET schools_data_file=!location!\schools.csv
SET ssp_data_file=!location!\record_data.csv

ECHO We're working with !location!

ECHO Running !ssp_query_file!, and storing results as !rawdatafile!
sqlcmd -S CHESQLP01FW,3467 -i "!ssp_query_file!" -o "!rawdatafile!" -s"," -W

ECHO cleaning !rawdatafile! into !ssp_data_file!
findstr /v /c:"---" "!rawdatafile!" > "!ssp_data_file!" 

ECHO removing uncleaned data in !rawdatafile!
del !rawdatafile!

ECHO Running !ssp_query_file!, and storing results as !rawdatafile!
sqlcmd -S CHESQLP01FW,3467 -i "!schools_query_file!" -o "!rawdatafile!" -s"," -W

ECHO cleaning !rawdatafile! into !ssp_data_file!
findstr /v /c:"---" "!rawdatafile!" > "!schools_data_file!" 

ECHO removing uncleaned data in !rawdatafile!
del !rawdatafile!

endlocal
