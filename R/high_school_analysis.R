suppressPackageStartupMessages(library("drake"))
suppressPackageStartupMessages(library("tidyverse"))

loadd(combined_levels_list)

hs_functions_plan <- drake_plan(strings_in_dots = "literals",

  summarize_ssps = function(.data, .date){
    .data %>%
      group_by_at(c("grade_number", "grade_name", "hs_grad_year")) %>%
      summarize(
        n = n(),
        ssp_01 = sum(as.numeric(ssp_01 <= .date), na.rm = TRUE),
        ssp_02 = sum(as.numeric(ssp_02 <= .date), na.rm = TRUE),
        ssp_03 = sum(as.numeric(ssp_03 <= .date), na.rm = TRUE),
        ssp_04 = sum(as.numeric(ssp_04 <= .date), na.rm = TRUE),
        ssp_05 = sum(as.numeric(ssp_05 <= .date), na.rm = TRUE),
        ssp_06 = sum(as.numeric(ssp_06 <= .date), na.rm = TRUE),
        ssp_07 = sum(as.numeric(ssp_07 <= .date), na.rm = TRUE),
        ssp_08 = sum(as.numeric(ssp_08 <= .date), na.rm = TRUE),
        ssp_09 = sum(as.numeric(ssp_09 <= .date), na.rm = TRUE),
        ssp_10 = sum(as.numeric(ssp_10 <= .date), na.rm = TRUE),
        ssp_11 = sum(as.numeric(ssp_11 <= .date), na.rm = TRUE),
        ssp_12 = sum(as.numeric(ssp_12 <= .date), na.rm = TRUE),
        )
  }

  )

high_school_plan_template <- drake_plan(strings_in_dots = "literals",
  ssps_this_year = hs_data_TK_refcode_TK %>%
    inner_join(
      current_class_standings,
      by = c("hs_grad_year" = "grade_cohort")
      ) %>%
  filter_at(
    .vars = "grade_number",
    .vars_predicate = any_vars(. >= 9L)
    ) %>%
  summarize_ssps(.data = ., .date = today_date) %>%
  mutate_at(
    .vars = vars(contains("ssp_")),
    .funs = funs(
      . / n
      )
    ) %>%
  mutate(
    level = level_TK_refcode_TK,
    value = value_TK_refcode_TK
    ), 
  ssps_last_year = hs_data_TK_refcode_TK %>%
    inner_join(
      last_year_class_standings,
      by = c("hs_grad_year" = "grade_cohort")
      ) %>%
  filter_at(
    .vars = "grade_number",
    .vars_predicate = any_vars(. >= 9L)
    ) %>%
  summarize_ssps(.data = ., .date = last_year) %>%
  mutate_at(
    .vars = vars(contains("ssp_")),
    .funs = funs(
      . / n
      )
    )
  )

high_school_plan <- evaluate_plan(
  plan = high_school_plan_template,
  rules = list(
    "TK_refcode_TK" = combined_levels_list[["refcode"]]
    )
  )

hs_analysis_file_plan <- bind_rows(
  high_school_plan
  )
