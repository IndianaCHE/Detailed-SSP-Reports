suppressPackageStartupMessages(library("drake"))
suppressPackageStartupMessages(library("tidyverse"))

loadd(combined_levels_list)

middle_school_plan_template <- drake_plan(strings_in_dots = "literals",
  applications_this_year = TK_middle_school_data_TK %>%
    filter(FALSE)
  )

middle_school_analysis_file_plan <- bind_rows(
  )
