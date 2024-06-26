## library(testthat)
## testthat::test_file("tests/testthat/test-format_time.R")
## covr::file_coverage("R/format_time.R", "tests/testthat/test-format_time.R")

if (!identical(Sys.getenv("NOT_CRAN"), "true")) return()
skip_on_cran()

test_that("format_time works with default inputs", {

  x <- c("09-02-03 01:11:11", "09-02-03 02:11:11","09-02-03 02:25:11")
  expect_error(format_time(x), regexp = NA)
  # Works with and outputs vector
  expect_is(format_time(x), "numeric")
  # Output vector is same length as input
  expect_equal(length(format_time(x)), length(x))
})

test_that("format_time correctly calculates output", {
  x <- c("09-02-03 01:11:11", "09-02-03 02:11:11","09-02-03 02:25:11")
  expect_equal(format_time(x)[3], 4441)
})

test_that("format_time converts day-month-year hour-min", {
  x <- c("03-02-09 01:11", "03-02-09 02:11","03-02-09 02:25")
  expect_equal(format_time(x, format = "dmyHM")[3], 4441)
})

test_that("format_time converts when AM/PM is present", {
  x <- c("09-02-03 11:11:11 AM", "09-02-03 12:11:11 PM","09-02-03 01:25:11 PM")
  expect_equal(format_time(x, format = "dmyHMSp")[3], 8041)
})

test_that("format_time accepts dataframes", {
  x <- data.frame(
    x = c("09-02-03 01:11:11", "09-02-03 02:11:11","09-02-03 02:25:11"),
    y = c(23, 34, 45))
  expect_error(format_time(x), regexp = NA)
})

test_that("format_time adds new column to dataframe", {
  x <- data.frame(
    x = c("09-02-03 01:11:11", "09-02-03 02:11:11","09-02-03 02:25:11"),
    y = c(23, 34, 45))
  expect_equal(ncol(x)+1, ncol(format_time(x)))
  # Adds new column as LAST column
  expect_equal(as.numeric(format_time(x)[3,3]), 4441)
  ## outputs a dataframe", {
  expect_is(format_time(x), 'data.frame')
})


test_that("format_time accepts data table", {
  x <- data.table::data.table(
    x = c("09-02-03 01:11:11", "09-02-03 02:11:11","09-02-03 02:25:11"),
    y = c(23, 34, 45))
  expect_error(format_time(x), regexp = NA)
})

test_that("format_time outputs are same class as input", {
  x <- data.table::data.table(
    x = c("09-02-03 01:11:11", "09-02-03 02:11:11","09-02-03 02:25:11"),
    y = c(23, 34, 45))
  expect_is(format_time(x), 'data.table')
  x <- data.frame(
    x = c("09-02-03 01:11:11", "09-02-03 02:11:11","09-02-03 02:25:11"),
    y = c(23, 34, 45))
  expect_is(format_time(x), 'data.frame')
})

test_that("format_time uses correct column if not default", {
  x <- data.table::data.table(
    w = c("some", "random", "text"),
    x = c("09-02-03 01:11:11", "09-02-03 02:11:11","09-02-03 02:25:11"),
    y = c(23, 34, 45))
  expect_equal(as.numeric(format_time(x, time = 2)[3,4]), 4441)
})


test_that("format_time converts dataframe with separate date and time columns", {
  x <- data.frame(
    w = c("09-02-18", "09-02-18","10-02-18"),
    x = c("22:11:11", "23:11:11","00:25:11"),
    y = c(23, 34, 45),
    z = c(56, 67, 78))
  result <- format_time(x, time = 1:2, format = "dmyHMS")
  expect_equal(result[[5]], c(1,3601,8041))

  ## This failed with previous versions when date-times did not include column 1
  ## Don't know why. Probably data.table, but the code was needlessly complex anyway
  x <- data.frame(text = c("text","text","text",
                           "text","text","text"),
                  date = c("2020-4-6", "2020-4-6", "2020-4-6",
                           "2020-4-6", "2020-4-6", "2020-4-6"),
                  time = c("3:25:01 PM", "3:25:11 PM", "3:25:21 PM",
                           "3:25:31 PM", "3:25:41 PM", "3:25:51 PM"))
  result <- format_time(x, time = 2:3, format = "ymdHMSp")
  expect_equal(result[[4]],
               c(1,11,21,31,41,51))
  # non contiguous columns
  x <- data.frame(text = c("text","text","text",
                           "text","text","text"),
                  date = c("2020-4-6", "2020-4-6", "2020-4-6",
                           "2020-4-6", "2020-4-6", "2020-4-6"),
                  text2 = c("text2","text2","text2",
                            "text2","text2","text2"),
                  time = c("3:25:01 PM", "3:25:11 PM", "3:25:21 PM",
                           "3:25:31 PM", "3:25:41 PM", "3:25:51 PM"))
  result <- format_time(x, time = c(2,4), format = "ymdHMSp")
  expect_equal(result[[5]],
               c(1,11,21,31,41,51))
})

test_that("format_time converts data table with separate date and time columns", {
  x <- data.table::data.table(
    w = c("09-02-18", "09-02-18","10-02-18"),
    x = c("22:11:11", "23:11:11","00:25:11"),
    y = c(23, 34, 45),
    z = c(56, 67, 78))
  result <- format_time(x, time = c(1,2), format = "dmyHMS")
  expect_equal(as.numeric(result[3,5]), 8041)
})

test_that("format_time converts dataframe with 3 separate date and time columns", {
  x <- data.frame(
    w = c("09-02-18", "09-02-18","10-02-18"),
    x = c("22:11", "23:11","00:25"),
    y = c("11", "11", "11"),
    z = c(56, 67, 78))
  # select 2 columns, different data-time format
  result <- format_time(x, time = c(1,2), format = "dmyHM")
  expect_equal(result[3,5], 8041)
  # select 3 columns
  result <- format_time(x, time = c(1,2,3), format = "dmyHMS")
  expect_equal(result[3,5], 8041)
})

test_that("format_time works with extra punctuation character", {
  x <- data.frame(
    w = c("09-02-18", "09-02-18","10-02-18"),
    x = c("22:11", "23:11","00:25"),
    y = c(":11", ":11", ":11"),
    z = c(56, 67, 78))
  # select 3 columns
  result <- format_time(x, time = c(1,2,3), format = "dmyHMS")
  expect_equal(result[3,5], 8041)
})

test_that("format_time works with NO punctuation characters", {
  x <- data.frame(
    w = c("090218", "090218","100218"),
    x = c("2211", "2311","0025"),
    y = c("11", "11", "11"),
    z = c(56, 67, 78))
  # select 3 columns
  result <- format_time(x, time = c(1,2,3), format = "dmyHMS")
  expect_equal(result[3,5], 8041)
})

test_that("format_time works with date-times over a stupid number of columns", {
  x <- data.frame(
    pre = c("text","text","text"),
    a = c("09", "09","10"),
    b = c("02", "02","02"),
    c = c("2018", "2018","2018"),
    d = c("22", "23","00"),
    e = c("11", "11","25"),
    f = c("11", "11", "11"),
    g = c(56, 67, 78))
  # select 3 columns
  result <- format_time(x, time = c(2:7), format = "dmyHMS")
  expect_equal(result[[9]], c(1,3601,8041))
})


test_that("format_time works across midnight when no dates provided", {
  x <- c("23:59:11", "00:11:11")
  expect_equal(format_time(x, time = 1, format = "HMS")[2],
               721)
  expect_error(format_time(x, time = 1, format = "HMS"),
               regexp = NA)
  expect_message(format_time(x, time = 1, format = "HMS"),
                 regexp = "Times cross midnight, attempting to parse correctly...")

  ## doesn't confuse 11 am for 11 pm
  x <- c("11:59:11", "00:11:11")
  expect_equal(format_time(x, time = 1, format = "HMS")[2],
               43921)
  expect_error(format_time(x, time = 1, format = "HMS"),
               regexp = NA)

  expect_message(format_time(x, time = 1, format = "HMS"),
                 regexp = "Times cross midnight, attempting to parse correctly...")
  ## works with "p" suffix for AM/PM present
  x <- c("11:59:11 PM", "00:11:11 AM")
  expect_equal(format_time(x, time = 1, format = "HMSp")[2],
               721)
  expect_error(format_time(x, time = 1, format = "HMSp"),
               regexp = NA)
  expect_message(format_time(x, time = 1, format = "HMSp"),
                 regexp = "Times cross midnight, attempting to parse correctly...")
})

## This test in response to a failure to convert i still don't really understand.
## But 'unlist' on the data.table column of already posix date-times caused them
## to be converted to unix times so then the 'format' was wrong.
## Added purrr:reduce instead, which seems like it preserves the class
## It's something to do with it being a data.table or data.frame column.
## Does not happen with vectors.

test_that("format_time - works with times already formatted as POSIX", {

  datetimes <- c("2013-05-23 13:02:40", "2013-05-23 13:02:41", "2013-05-23 13:02:42",
                          "2013-05-23 13:02:43", "2013-05-23 13:02:44", "2013-05-23 13:02:45",
                          "2013-05-23 13:02:46", "2013-05-23 13:02:47", "2013-05-23 13:02:48",
                          "2013-05-23 13:02:49")
  datetimes<-as.POSIXct(datetimes)

  ## vector
  expect_error(format_time(datetimes, 1, "ymdHMS"),
               NA)
  expect_equal(format_time(datetimes, 1, "ymdHMS"),
               1:10)
  ## df
  df <- data.frame(times = datetimes,
                   oxy = urchins.rd[[2]][1:10])
  expect_error(format_time(df, 1, "ymdHMS"),
               NA)
  expect_equal(format_time(df, 1, "ymdHMS")[[3]],
               1:10)
  ## dt
  dt <- data.table(times = datetimes,
                   oxy = urchins.rd[[2]][1:10])
  expect_error(format_time(dt, 1, "ymdHMS"),
               NA)
  expect_equal(format_time(dt, 1, "ymdHMS")[[3]],
               1:10)

})
