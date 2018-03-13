suppressPackageStartupMessages(library("drake"))
suppressPackageStartupMessages(library("tidyverse"))

loadd(unique_school_codes)
loadd(combined_levels_list)
foob <- readd(schools_table_clean) %>% filter(County == "DeKalb") %>%
  select("County", "Corporation", "School") %>%
  tidyr::gather() %>%
  filter(complete.cases(.)) %>%
  select("value")
foo <- combined_levels_list %>% inner_join(foob, by = "value") %>% distinct()
foo_schools <- foo$SchoolID %>% unlist()

split_schools_plan_template <- drake_plan(strings_in_dots = "literals",
  high_school_code_data = {
    combined_levels_list #this is here to introduce a logical dependency
    raw_record_data %>%
      filter_at(
        .vars = "high_school_id",
        .vars_predicate = function(x) x == TK_school_code_TK)
  }
  )

split_schools_plan <- evaluate_plan(
  plan = split_schools_plan_template,
  rules = list("TK_school_code_TK" = foo_schools)
  )

recombine_schools_plan <- foo %>%
  transmute(
    target = paste(level, value, sep = "_"),
    command = UQ(as.name("SchoolID")) %>%
      unlist() %>%
      paste0("high_school_code_data", "_", ., collapse = ", ") %>%
      paste0("bind_rows(", ., ")")
    )

regroup_file_plan <- bind_rows(
  split_schools_plan,
  recombine_schools_plan,
  )
