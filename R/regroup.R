suppressPackageStartupMessages(library("drake"))
suppressPackageStartupMessages(library("tidyverse"))

loadd(combined_levels_list)

split_schools_plan_template <- drake_plan(strings_in_dots = "literals",
  level_info = combined_levels_list %>%
    filter_at(
      .vars = "refcode",
      .vars_predicate = any_vars(. == "TK_refcode_TK")
      ),
  school_codes = level_info_TK_refcode_TK %>%
    select("SchoolID") %>%
    unnest(),
  level = level_info_TK_refcode_TK %>% pull(level),
  value = level_info_TK_refcode_TK %>% pull(value),
  hs_data = clean_record_data %>%
    inner_join(
      UQ(as.name(paste0("school_codes_", "TK_refcode_TK"))),
      by = c("high_school_id" = "SchoolID")
      ),
  ms_data = clean_record_data %>%
    inner_join(
      UQ(as.name(paste0("school_codes_", "TK_refcode_TK"))),
      by = c("middle_school_id" = "SchoolID")
      )
  )

# See https://github.com/ropensci/drake/issues/235#issuecomment-363124440
split_schools_plan <- evaluate_plan(
  plan = split_schools_plan_template,
  rules = list(
    "TK_refcode_TK" = combined_levels_list[["refcode"]]
    ),
  expand = TRUE
  )

regroup_file_plan <- bind_rows(
  split_schools_plan
  )
