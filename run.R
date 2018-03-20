# This file is the main file to execute to create the detailed SSP Reports
library("tidyverse")
ibrary("drake")

# Enable running through setup stuff once per day.
quickrun <- cached(today_date) && readd(today_date) == lubridate::today()

master_plan <- NULL
source("R/parameters.R")
master_plan <- bind_rows(master_plan, parameters_file_plan)
source("R/schools.R")
master_plan <- bind_rows(master_plan, schools_file_plan)
source("R/raw_data.R")
master_plan <- bind_rows(master_plan, raw_data_file_plan)
source("R/regroup.R")
master_plan <- bind_rows(master_plan, regroup_file_plan)
source("R/analysis.R")
master_plan <- bind_rows(master_plan, analysis_file_plan)
source("R/geolocation.R")
master_plan <- bind_rows(master_plan, geolocation_file_plan)
source("R/middle_school_analysis.R")
master_plan <- bind_rows(master_plan, ms_analysis_file_plan)
source("R/high_school_analysis.R")
master_plan <- bind_rows(master_plan, hs_analysis_file_plan)

master_config <- drake_config(master_plan)
vis_drake_graph(master_config, targets_only = TRUE)
print(master_plan)

make(
  plan = master_plan,
  jobs = n_jobs
  )
