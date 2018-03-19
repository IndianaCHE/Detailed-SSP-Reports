suppressPackageStartupMessages(library("drake"))
suppressPackageStartupMessages(library("lubridate"))
stopifnot(requireNamespace("git2r", quietly = TRUE))

senior_cohort <- function(
  .date,
  period_start = period_start(.date)
  ){
  cohort <- dplyr::case_when(
    lubri.date::month(.date) < rollover_month ~ lubri.date::year(.date),
    lubri.date::month(.date) > rollover_month ~ lubri.date::year(.date) + 1,
    lubri.date::mday(.date) < rollover_mday ~ lubri.date::year(.date),
    lubri.date::mday(.date) >= rollover_mday ~ lubri.date::year(.date) + 1
    )
  return(cohort)
}

period_start_fn <- function(
  .date,
  rollover_month = 07,
  rollover_mday = 01
  ){

}

setup_parameters_plan <- drake_plan(
  strings_in_dots = "literals",
  current_senior_cohort = 2018,
  period_start = lubridate::ymd("20170701")
  )

na_spec <- c("na", "NA", "", "NULL", "null")

n_jobs <- parallel::detectCores() - 1

parameters_always_plan <- drake_plan(strings_in_dots = "literals",
  git_commit_hash_short = git2r::repository() %>%
    git2r::head(x = .) %>%
    git2r::branch_target(branch = .) %>%
    substr(start =  0, stop = 6) %>%
    toupper(.),
  today_date = lubridate::today(),
  current_senior_cohort = 2018L
  )

dates_derived_plan <- drake_plan(strings_in_dots = "literals",
  find_rollover_date = function(.date, rollover_day = "July 1st"){
    candidate_day <- mdy(paste0(rollover_day, ", ", year(.date)))
    rollover_date <- if_else(
      candidate_day > .date,
      #if candidate is later than today, go back one year
      mdy(paste0(rollover_day, ", ", (year(.date) - 1))),
      #otherwise, use the candidate
      candidate_day
      )
    return(rollover_date)
  },
  rollover_date = find_rollover_date(
    .date = today_date,
    rollover_day = "July 1"
    ),
  last_year = today_date - dyears(1),
  two_weeks_ago = today_date - dweeks(2),
  rollover_last_year = find_rollover_date(
    .date = last_year,
    rollover_day = "July 1"
    ),
  next_rollover = rollover_date + dyears(1),
  days_to_next_rollover = next_rollover - today_date,
  seq_this_year = tibble(
    date = seq(from = rollover_date, to = next_rollover, by = 1)
    ) %>%
  mutate(day_count = rownames(.)),
seq_last_year = tibble(
  date = seq(from = rollover_last_year, to = rollover_date, by = 1)
  ) %>%
mutate(day_count = rownames(.)),
current_class_standings = tibble(
  grade_number = seq(from = 12L, to = 7L, by = -1L),
  grade_name = c("Senior", "Junior" ,"Sophomore", "Fresh", "8th Grade", "7th grade"),
  grade_cohort = seq(from = current_senior_cohort, to = current_senior_cohort + 5, by = 1L)
  ),
last_year_class_standings = current_class_standings %>%
  mutate(grade_cohort = grade_cohort - 1L)
)

parameters_file_plan <- bind_rows(
  parameters_always_plan,
  dates_derived_plan
  )

if (!quickrun){
parameters_file_plan %>%
  mutate(trigger = "always") %>%
  make(plan = ., jobs = 1, verbose = 0)
}
