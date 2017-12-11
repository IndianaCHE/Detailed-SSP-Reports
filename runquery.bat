cd /d S:/Research&Analysis/Users/Alex/2017-11-20-GHarrell_DATA-123_Marion_county_Completions/

sqlcmd -S CHESQLP01FW,3467 -i "S:\Research&Analysis\Users\Alex\Requests\2017-11-20-GHarrell_DATA-123_Marion_county_Completions\county_detailed_SSPs.sql" -o "S:\Research&Analysis\Users\Alex\Requests\2017-11-20-GHarrell_DATA-123_Marion_county_Completions\data.csv" -s"," -W
 
|findstr /v /c:"---" "S:\Research&Analysis\Users\Alex\Requests\2017-11-20-GHarrell_DATA-123_Marion_county_Completions\data.csv" "S:\Research&Analysis\Users\Alex\Requests\2017-11-20-GHarrell_DATA-123_Marion_county_Completions\data-nodash.csv" 
