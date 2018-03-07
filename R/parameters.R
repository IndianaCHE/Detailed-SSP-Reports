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
