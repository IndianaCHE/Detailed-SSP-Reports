library("magrittr")
library("drake")
library("readr")


raw_data_plan <- drake_plan(
  strings_in_dots = "literals",
  raw_record_data = read_csv(
    file_in("record_data.csv"),
    na = na_spec,
    col_types =  cols(
      StudentID = col_integer(),
      hs_grad_year = col_integer(),
      high_school_id = col_integer(),
      middle_school_id = col_integer(),
      Approved = col_logical(),
      IsExpelled = col_logical(),
      PledgeViolation = col_logical(),
      IsSubmitted = col_logical(),
      SubmittedDateTime = col_datetime(format = ""),
      scholartrack_account = col_logical(),
      ssp_01 = col_datetime(format = ""),
      ssp_02 = col_datetime(format = ""),
      ssp_03 = col_datetime(format = ""),
      ssp_04 = col_datetime(format = ""),
      ssp_05 = col_datetime(format = ""),
      ssp_06 = col_datetime(format = ""),
      ssp_07 = col_datetime(format = ""),
      ssp_08 = col_datetime(format = ""),
      ssp_09 = col_datetime(format = ""),
      ssp_10 = col_datetime(format = ""),
      ssp_11 = col_datetime(format = ""),
      ssp_12 = col_datetime(format = ""),
      isir_version = col_integer()
      )
    ),
  )

master_plan <- bind_rows(
  master_plan,
  raw_data_plan
  )
