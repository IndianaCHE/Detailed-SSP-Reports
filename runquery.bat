@echo off
setlocal enabledelayedexpansion
SET "location=S:\Research&Analysis\Users\Alex\Requests\2017-11-20-GHarrell_DATA-123_Marion_county_Completions"
SET queryfile=!location!\county_detailed_SSPs.sql
SET rawdatafile=!location!\record_data.csv
SET datafile=!location!\record_data.csv

ECHO We're working with !location!

ECHO Running !queryfile!, and storing results as !datafile!
sqlcmd -S CHESQLP01FW,3467 -i "!queryfile!" -o "!rawdatafile!" -s"," -W

ECHO cleaning!datafile!
findstr /v /c:"---" "!rawdatafile!" > "!datafile!" 

endlocal
