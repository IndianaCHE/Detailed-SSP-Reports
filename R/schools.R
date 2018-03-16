suppressPackageStartupMessages(library("tidyverse"))
suppressPackageStartupMessages(library("drake"))
suppressPackageStartupMessages(library("stringr"))

school_spec_plan <- drake_plan(strings_in_dots = "literals",
  school_spec = cols(
    SchoolID = col_integer(),
    School = col_character(),
    Address = col_character(),
    City = col_character(),
    State = col_character(),
    Zip = col_character(),
    `School Type` = col_integer(),
    Corporation = col_character(),
    `CHE Region` = col_character(),
    County = col_character()
    )
  )

schools_plan <- drake_plan(strings_in_dots = "literals",
  schools_table_raw = read_csv(
    file_in("schools.csv"),
    na = na_spec,
    col_types = school_spec),
  schools_table_clean = schools_table_raw %>%
    mutate_if(is_character, str_trim) %>%
    arrange(UQ(as.name("SchoolID"))) %>%
    filter_at("County", any_vars(. == "DeKalb"))
  )

schools_summary_plan <- drake_plan(strings_in_dots = "literals",
  summarize_schools = function(.data, column){
    stopifnot(is_character(column))
    .data %>%
      select(
        "value" = column,
        "SchoolID" = "SchoolID"
        ) %>%
    group_by_at("value") %>%
    summarize_at(.vars = "SchoolID", .funs = list) %>%
    mutate(level = column)
  },
  schools_list = schools_table_clean %>% summarize_schools("School"),
  corp_list = schools_table_clean %>% summarize_schools("Corporation"),
  region_list = schools_table_clean %>% summarize_schools("CHE Region"),
  county_list = schools_table_clean %>% summarize_schools("County"),
  state_list = schools_table_clean %>% summarize_schools("State"),
  combined_levels_list = bind_rows(
    schools_list, corp_list, region_list, county_list, state_list
    ) %>%
  mutate(clean_value = str_replace_all(
      string = value,
      pattern = ":|\\+|\\-|\\*|\\^|\\(|\\)|\\[|\\]|^_|\\\"",
      replacement = " "
      )) %>%
  mutate(refcode = paste0(
      level, "_",
      if_else(level %in% c("School", "Corporation"),
        abbreviate(clean_value),
        clean_value
        )
      )) %>%
  mutate(refcode = str_replace_all(
      string = refcode,
      pattern = " ",
      replacement = ""
      )) %>%
  filter_at(.vars = "value", .vars_predicate = any_vars(!is.na(.))) %>%
  select(-clean_value) %>%
  filter_at("level", any_vars(. == "State"))
  )

schools_file_plan <- bind_rows(
  school_spec_plan,
  schools_plan,
  schools_summary_plan
  )

if (!quickrun){
make(schools_file_plan, jobs = 1, verbose = 0)
}
