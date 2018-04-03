suppressPackageStartupMessages(library("drake"))
suppressPackageStartupMessages(library("tidyverse"))
suppressPackageStartupMessages(library("writexl"))

loadd(combined_levels_list)

hs_functions_plan <- drake_plan(strings_in_dots = "literals",
  summarize_ssps = function(.data, .date){
    .data %>%
      group_by_at(c("grade_number", "grade_name", "hs_grad_year")) %>%
      mutate(n = n()) %>%
      group_by_at("n", .add = TRUE) %>%
      summarize_at(
        .vars = vars(contains("ssp_")),
        .funs = funs(sum(as.numeric(. <= .date), na.rm = TRUE))
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
  mutate(refcode = "TK_refcode_TK") %>%
  left_join(combined_levels_list, by = "refcode") %>%
  select("level", "value", everything()) %>%
  select(-one_of("SchoolID", "refcode")),
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
  ) %>%
mutate(refcode = "TK_refcode_TK") %>%
left_join(combined_levels_list, by = "refcode") %>%
select("level", "value", everything()) %>%
select(-one_of("SchoolID", "refcode"))
)

high_school_combine <- tibble(
  target = c("this_year_all_ssps", "last_year_all_ssps"),
  command = c(
    paste0(
      "bind_rows(", paste0("ssps_this_year", "_",
        combined_levels_list[["refcode"]], collapse = ", "), ")"
      ),
    paste0(
      "bind_rows(", paste0("ssps_last_year", "_",
        combined_levels_list[["refcode"]], collapse = ", "), ")"
      )
    )
  )

combined_excel_plan <- drake_plan(strings_in_dots = "literals",
  write_xlsx(
    path = file_out("Reports/ssp_summary.xlsx"),
    x = list(
      "This Year" = this_year_all_ssps,
      "Last Year" = last_year_all_ssps
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
  hs_functions_plan,
  high_school_plan,
  high_school_combine,
  combined_excel_plan
  )
