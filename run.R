# This file is the main file to execute to create the detailed SSP Reports
suppressPackageStartupMessages(library("tidyverse"))
suppressPackageStartupMessages(library("drake"))

master_plan <- NULL
source("R/parameters.R")
master_plan <- bind_rows(master_plan, parameters_file_plan)
source("R/schools.R")
master_plan <- bind_rows(master_plan, schools_file_plan)
source("R/data.R")
master_plan <- bind_rows(master_plan, data_file_plan)
source("R/regroup.R")
master_plan <- bind_rows(master_plan, regroup_file_plan)
source("R/analysis.R")
master_plan <- bind_rows(master_plan, analysis_file_plan)
source("R/geolocation.R")
master_plan <- bind_rows(master_plan, geolocation_file_plan)

master_config <- drake_config(master_plan)
vis_drake_graph(master_config)

make(
  plan = master_plan,
  jobs = n_jobs
  )
