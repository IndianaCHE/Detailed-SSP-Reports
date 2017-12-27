library("git2r")
library("drake")
library("knitr")
library("tidyverse")
library("ggridges")
library("DT")
library("lubridate")
library("extrafont")
library("ggCHE")
library("rlang")
library("stringr")

setup_parameters_plan <- drake::drake_plan(
  current_senior_cohort = 2018,
  period_start = if_else(
    month(today()) < 9,
    ymd(paste(year(today()) - 1, "0701")),
    ymd(paste(year(today()), "0701"))
    ),
  strings_in_dots = "literals"
  )

ssp_descriptions_plan <- drake::drake_plan(strings_in_dots = "literals",
  dim_ssp = tibble::tribble(
    ~ssp_code, ~ssp, ~grade, ~long_name, ~short_name,
    "ssp_01", 01, 09, "Create a Graduation Plan", "Grad Plan",
    "ssp_02", 02, 09, "Participate in an Extracurricular or Service Activity", "Extracurricular", #nolint
    "ssp_03", 03, 09, "Watch \"Paying for College 101\"", "Paying 101",
    "ssp_04", 04, 10, "Take a Career Interests Assessment", "Career Interests",
    "ssp_05", 05, 10, "Get Workplace Experience", "Workplace",
    "ssp_06", 06, 10, "Estimate the Costs of College", "Estimate Costs",
    "ssp_07", 07, 11, "Visit a College Campus", "Campus Visit",
    "ssp_08", 08, 11, "Take a College Entrance Exam (ACT/SAT)", "Entrance Exam",
    "ssp_09", 09, 11, "Search for Scholarships", "Scholarships",
    "ssp_10", 10, 12, "Submit Your College Application", "Application",
    "ssp_11", 11, 12, "Watch \"College Success 101\"", "Success 101",
    "ssp_12", 12, 12, "File Your FAFSA", "FAFSA",
    "all_9th", NA, 09, "All 9th Grade Activities Complete", "All 9th Grade",
    "all_10th", NA, 10, "All 10th Grade Activities Complete", "All 10th Grade",
    "all_11th", NA, 11, "All 11th Grade Activities Complete", "All 11th Grade",
    "all_12th", NA, 12, "All 12th Grade Activities Complete", "All 12th Grade"
    )
  )

dt_plan <- drake::drake_plan(strings_in_dots = "literals",
  DT.options = list(
    dom = "Bfrtip",
    buttons = c("copy", "csv", "excel", "pdf", "print"),
    scrollX = TRUE,
    colReorder = TRUE,
    fixedColumns = list(leftColumns = 1)
    ),
  dt_extensions = c(
    "Buttons",
    "FixedColumns",
    "ColReorder"
    )
  )

data_import_pre_plan <- drake::drake_plan(strings_in_dots = "literals",
  raw_data_na_spec = c("", "NA", "NULL"),
  raw_data_col_spec = cols(
    hs_grad_year = col_integer(),
    School = col_factor(levels = NULL),
    Address = col_character(),
    City = col_character(),
    State = col_factor(levels = NULL),
    Zip = col_integer(),
    `School Type` = col_factor(levels = NULL),
    Corporation = col_factor(levels = NULL),
    `CHE Region` = col_factor(levels = NULL),
    County = col_factor(levels = NULL),
    ssp_01 = col_date(format = "%Y-%m-%d %H:%M:%OS"),
    ssp_02 = col_date(format = "%Y-%m-%d %H:%M:%OS"),
    ssp_03 = col_date(format = "%Y-%m-%d %H:%M:%OS"),
    ssp_04 = col_date(format = "%Y-%m-%d %H:%M:%OS"),
    ssp_05 = col_date(format = "%Y-%m-%d %H:%M:%OS"),
    ssp_06 = col_date(format = "%Y-%m-%d %H:%M:%OS"),
    ssp_07 = col_date(format = "%Y-%m-%d %H:%M:%OS"),
    ssp_08 = col_date(format = "%Y-%m-%d %H:%M:%OS"),
    ssp_09 = col_date(format = "%Y-%m-%d %H:%M:%OS"),
    ssp_10 = col_date(format = "%Y-%m-%d %H:%M:%OS"),
    ssp_11 = col_date(format = "%Y-%m-%d %H:%M:%OS"),
    ssp_12 = col_date(format = "%Y-%m-%d %H:%M:%OS"),
    isir_version = col_integer()
    )
  )

data_file_plan <- drake::drake_plan(strings_in_dots = "filenames",
  raw_record_data = record_data <- read_csv(
    file = "record_data.csv", #note the single quote inside the double
    na = raw_data_na_spec,
    col_type = raw_data_col_spec
    ),
  file_pull_time = file.mtime("record_data.csv")
  )

data_cleaning_plan <- drake::drake_plan(strings_in_dots = "literals",
record_data = raw_record_data %>%
  mutate(
    all_9th = pmax(
      UQ(as.name("ssp_01")),
      UQ(as.name("ssp_02")),
      UQ(as.name("ssp_03"))
      ),
    all_10th = pmax(
      UQ(as.name("ssp_04")),
      UQ(as.name("ssp_05")),
      UQ(as.name("ssp_06"))
      ),
    all_11th = pmax(
      UQ(as.name("ssp_07")),
      UQ(as.name("ssp_08")),
      UQ(as.name("ssp_09"))
      ),
    all_12th = pmax(
      UQ(as.name("ssp_10")),
      UQ(as.name("ssp_11")),
      UQ(as.name("ssp_12"))
      )
    )
  )

labeller_plan <- drake::drake_plan(strings_in_dots = "literals",
  label_cohorts = function(year){
    paste("Cohort:", year)
  },
  global_labeller = labeller(
    hs_grad_year = label_cohorts
    )
  )

region_list <- c(
  "Northwest",
  "Northeast",
  "Southwest",
  "Southeast",
  "North Central",
  "East",
  "West",
  "Central"
  )

report_deps <- drake::knitr_deps("report.Rmd")

# file_template_plan <- drake::drake_plan(strings_in_dots = "filenames",
file_template_plan <- data.frame(
  target = "report_template",
  command = as.list(c("report.Rmd", report_deps))
    ) %>%
  group_by(target) %>%
  summarise(command = paste(command, collapse = ", "))

render_plan_template <- drake::drake_plan(strings_in_dots = "literals",
  file_targets = FALSE,
  `detailed_reports/SSPs` = rmarkdown::render(
    input = report_template,
    # input = "'report.Rmd'",
    output_file = str_replace_all(
      string = "detailed_reports/SSPs_..LEVEL.._..LEVELVALUE...html",
      pattern = " ", replacement = "-"
      ),
    output_format = "html_document",
    params = list(level = "..LEVEL..", level_value = "..LEVELVALUE.."),
    quiet = TRUE
    )
  )

report_region_plan <- evaluate_plan(
  render_plan_template,
  rules = list(
    ..LEVEL.. = "CHE Region",
    ..LEVELVALUE.. = region_list
    )
  ) %>%
  mutate(target = paste0("./", target, ".html")) %>%
  mutate(target = str_replace_all(target, pattern = " ", replacement = "-")) %>%
  mutate(target = drake::as_drake_filename(target))

master_plan <- bind_rows(
  setup_parameters_plan,
  ssp_descriptions_plan,
  dt_plan,
  data_import_pre_plan,
  data_file_plan,
  data_cleaning_plan,
  labeller_plan,
  file_template_plan,
  report_region_plan
   )

vis_drake_graph(drake_config(master_plan))
