# library(testthat)
# rm(list=ls())
# testthat::test_file("tests/testthat/test-convert_DO.R")
# covr::file_coverage("R/convert_DO.R", "tests/testthat/test-convert_DO.R")
# x <- covr::package_coverage()
# covr::report(x)

capture.output({  ## stops printing outputs on assigning

  test_that("convert_DO - stops if `x` not numeric", {
    expect_error(convert_DO("text", from = "%Air", to = "mg/l",
                            S = 35, t =10),
                 "convert_DO: input 'x' must be a numeric value or vector.")
  })

  test_that("convert_DO output conversions, using %Air, have expected results", {
    expect_equal(round(convert_DO(10, "%Air", "mg/l", S = 35, t = 25, P = 1.013253), 3), 0.675)
    expect_equal(round(convert_DO(10, "%Air", "ug/l", S = 35, t = 25, P = 1.013253), 3), 675.11)
    expect_equal(round(convert_DO(10, "%Air", "mol/l", S = 35, t = 25, P = 1.013253), 9), 0.000021098)
    expect_equal(round(convert_DO(10, "%Air", "mmol/l", S = 35, t = 25, P = 1.013253), 3), 0.021)
    expect_equal(round(convert_DO(10, "%Air", "umol/l", S = 35, t = 25, P = 1.013253), 3), 21.098)
    expect_equal(round(convert_DO(10, "%Air", "ml/l", S = 35, t = 25, P = 1.013253), 3), 0.516)
    expect_equal(round(convert_DO(10, "%Air", "mg/kg", S = 35, t = 25, P = 1.013253), 3), 0.66)
    expect_equal(round(convert_DO(10, "%Air", "ug/kg", S = 35, t = 25, P = 1.013253), 3), 659.79)
    expect_equal(round(convert_DO(10, "%Air", "mol/kg", S = 35, t = 25, P = 1.013253), 9), 0.000020619)
    expect_equal(round(convert_DO(10, "%Air", "mmol/kg", S = 35, t = 25, P = 1.013253), 3), 0.021)
    expect_equal(round(convert_DO(10, "%Air", "umol/kg", S = 35, t = 25, P = 1.013253), 3), 20.619)
    expect_equal(round(convert_DO(10, "%Air", "ml/kg", S = 35, t = 25, P = 1.013253), 3), 0.504)
    expect_equal(round(convert_DO(10, "%Air", "%Air", S = 35, t = 25, P = 1.013253), 3), 10)
    expect_equal(round(convert_DO(10, "%Air", "%Oxy", S = 35, t = 25, P = 1.013253), 3), 2.095)
    expect_equal(round(convert_DO(10, "%Air", "hPa", S = 35, t = 25, P = 1.013253), 3), 20.854)
    expect_equal(round(convert_DO(10, "%Air", "kPa", S = 35, t = 25, P = 1.013253), 3), 2.085)
    expect_equal(round(convert_DO(10, "%Air", "mmHg", S = 35, t = 25, P = 1.013253), 3), 15.642)
    expect_equal(round(convert_DO(10, "%Air", "inHg", S = 35, t = 25, P = 1.013253), 3), 0.616)
    expect_equal(round(convert_DO(10, "%Air", "Torr", S = 35, t = 25, P = 1.013253), 3), 15.642)
  })
  ## check that `from` inputs do not produce error

  ## regexp: regular expression to test against. If omitted, just asserts that
  ## code produces some output, messsage, warning or error. Alternatively, you can
  ## specify NA to indicate that there should be no output, messages, warnings or
  ## errors.
  test_that("convert_DO converts different units without error", {
    expect_error(convert_DO(10, "mg/l", "mg/l", S = 35, t = 25, P = 1.013253), regexp = NA)
    expect_error(convert_DO(10, "ug/l", "mg/l", S = 35, t = 25, P = 1.013253), regexp = NA)
    expect_error(convert_DO(10, "mmol/l", "mg/l", S = 35, t = 25, P = 1.013253), regexp = NA)
    expect_error(convert_DO(10, "umol/l", "mg/l", S = 35, t = 25, P = 1.013253), regexp = NA)
    expect_error(convert_DO(10, "ml/l", "mg/l", S = 35, t = 25, P = 1.013253), regexp = NA)
    expect_error(convert_DO(10, "mg/kg", "mg/l", S = 35, t = 25, P = 1.013253), regexp = NA)
    expect_error(convert_DO(10, "ug/kg", "mg/l", S = 35, t = 25, P = 1.013253), regexp = NA)
    expect_error(convert_DO(10, "mmol/kg", "mg/l", S = 35, t = 25, P = 1.013253), regexp = NA)
    expect_error(convert_DO(10, "umol/kg", "mg/l", S = 35, t = 25, P = 1.013253), regexp = NA)
    expect_error(convert_DO(10, "ml/kg", "mg/l", S = 35, t = 25, P = 1.013253), regexp = NA)
    expect_error(convert_DO(10, "%Air", "mg/l", S = 35, t = 25, P = 1.013253), regexp = NA)
    expect_error(convert_DO(10, "%Oxy", "mg/l", S = 35, t = 25, P = 1.013253), regexp = NA)
    expect_error(convert_DO(10, "Torr", "mg/l", S = 35, t = 25, P = 1.013253), regexp = NA)
    expect_error(convert_DO(10, "hPa", "mg/l", S = 35, t = 25, P = 1.013253), regexp = NA)
    expect_error(convert_DO(10, "kPa", "mg/l", S = 35, t = 25, P = 1.013253), regexp = NA)
    expect_error(convert_DO(10, "mmHg", "mg/l", S = 35, t = 25, P = 1.013253), regexp = NA)
    expect_error(convert_DO(10, "inHg", "mg/l", S = 35, t = 25, P = 1.013253), regexp = NA)
  })

  test_that("convert_DO produces the correct numeric output", {
    expect_is(convert_DO(10, "mg/l", "mg/l", S = 35, t = 25, P = 1.013253), "numeric")
    expect_is(convert_DO(10, "ug/l", "mg/l", S = 35, t = 25, P = 1.013253), "numeric")
    expect_is(convert_DO(10, "mol/l", "mg/l", S = 35, t = 25, P = 1.013253), "numeric")
    expect_is(convert_DO(10, "mmol/l", "mg/l", S = 35, t = 25, P = 1.013253), "numeric")
    expect_is(convert_DO(10, "umol/l", "mg/l", S = 35, t = 25, P = 1.013253), "numeric")
    expect_is(convert_DO(10, "ml/l", "mg/l", S = 35, t = 25, P = 1.013253), "numeric")
    expect_is(convert_DO(10, "mg/kg", "mg/l", S = 35, t = 25, P = 1.013253), "numeric")
    expect_is(convert_DO(10, "ug/kg", "mg/l", S = 35, t = 25, P = 1.013253), "numeric")
    expect_is(convert_DO(10, "mol/kg", "mg/l", S = 35, t = 25, P = 1.013253), "numeric")
    expect_is(convert_DO(10, "mmol/kg", "mg/l", S = 35, t = 25, P = 1.013253), "numeric")
    expect_is(convert_DO(10, "umol/kg", "mg/l", S = 35, t = 25, P = 1.013253), "numeric")
    expect_is(convert_DO(10, "ml/kg", "mg/l", S = 35, t = 25, P = 1.013253), "numeric")
    expect_is(convert_DO(10, "%Air", "mg/l", S = 35, t = 25, P = 1.013253), "numeric")
    expect_is(convert_DO(10, "%Oxy", "mg/l", S = 35, t = 25, P = 1.013253), "numeric")
    expect_is(convert_DO(10, "Torr", "mg/l", S = 35, t = 25, P = 1.013253), "numeric")
    expect_is(convert_DO(10, "hPa", "mg/l", S = 35, t = 25, P = 1.013253), "numeric")
    expect_is(convert_DO(10, "kPa", "mg/l", S = 35, t = 25, P = 1.013253), "numeric")
    expect_is(convert_DO(10, "mmHg", "mg/l", S = 35, t = 25, P = 1.013253), "numeric")
    expect_is(convert_DO(10, "inHg", "mg/l", S = 35, t = 25, P = 1.013253), "numeric")
  })

  test_that("convert_DO conversion works with changing salinity value", {
    expect_equal(round(convert_DO(7.5, "%Air", "mg/l", S = 35, t = 25, P = 1.013253), 3), 0.506)
    expect_equal(round(convert_DO(7.5, "%Air", "mg/l", S = 25, t = 25, P = 1.013253), 3), 0.536)
    expect_equal(round(convert_DO(7.5, "%Air", "mg/l", S = 15, t = 25, P = 1.013253), 3), 0.567)
    expect_equal(round(convert_DO(7.5, "%Air", "mg/l", S = 5, t = 25, P = 1.013253), 3), 0.601)
    expect_equal(round(convert_DO(7.5, "%Air", "mg/l", S = 0, t = 25, P = 1.013253), 3), 0.618)
  })

  test_that("convert_DO conversion works with changing pressure value", {
    expect_equal(round(convert_DO(7.5, "%Air", "mg/l", P = 0.9, S = 35, t = 25), 3),
                 0.45)
  })

  test_that("convert_DO conversion works with changing temperature", {
    expect_equal(round(convert_DO(100, "%Air", "mg/l", t = 25, P = 1.013253, S = 35), 3), 6.751)
    expect_equal(round(convert_DO(100, "%Air", "mg/l", t = 20, S = 35), 3), 7.377)
  })

  test_that("convert_DO verify_units internal functions works", {
    expect_is(verify_units("mg/l", "o2"), "character")
    expect_is(verify_units("ml", "vol"), "character")
    expect_is(verify_units("mg", "mass"), "character")
    expect_is(verify_units("mg", "o1"), "character")
  })

  test_that("convert_DO S3 generics work", {

    ob <- convert_DO(10, "inHg", "mg/l", S = 35, t = 25, P = 1.013253, simplify = FALSE)
    ob_many <- convert_DO(10:30, "inHg", "mg/l", S = 35, t = 25, P = 1.013253, simplify = FALSE)

    expect_error(print(ob),
                 NA)
    expect_error(print(ob_many),
                 NA)
    expect_output(print(ob),
                  "Input values:")
    expect_output(print(ob_many),
                  "Showing only the first 20 conversions:")

    expect_error(summary(ob),
                 NA)
    expect_error(summary(ob_many),
                 NA)
    expect_output(summary(ob),
                  "Input values:")
    expect_output(summary(ob_many),
                  "Showing only the first 20 conversions:")



  })

  test_that("convert_DO stops if % operator (old one) is used", {
    expect_error(convert_DO(10, "%", "mg/l", S = 35, t = 25, P = 1.013253),
                 regexp = "verify_units: unit \"%\" has been deprecated. Please use \"%Air\" or \"%Oxy\" instead. See unit_args().")
  })

  test_that("convert_DO - stops if unit not recognised", {
    expect_error(convert_DO(10, "text", "mg/l", S = 35, t = 25, P = 1.013253),
                 regexp = "verify_units: unit 'text' not recognised. Check it is valid for the input or output type.")
  })

  ## checks against respirometry::conv_o2 results

  test_that("convert_DO: %Air and %Oxy return same results as respirometry::conv_o2", {

    ## variables
    PercAir_in <- c(seq(100,50,-10))
    PercO2_in <- c(seq(20,10,-2))
    t_in <- seq(0,20,5)
    S_in <- c(0,10,20,30)
    P_in <- c(0.5, 1.013253, 1.5)

    ## all combinations
    grid <- expand.grid(PercO2_in = PercO2_in,
                        t_in = t_in,
                        S_in = S_in,
                        P_in = P_in)
    grid[[5]] <- seq(1:nrow(grid))

    # %Oxy
    # respR results
    res_respR <- apply(grid, 1, function(x) {
      suppressWarnings(convert_DO(x = x[1], from = "%Oxy", to = "mg/L", t = x[2], S = x[3], P = x[4]))
    })

    # respirometry results
    res_respirometry <- apply(grid, 1, function(x) {
      respirometry::conv_o2( o2 = x[1], from = "percent_o2", to = "mg_per_l",
                             temp = x[2], sal = x[3], atm_pres = x[4]*1000) ## nb diff pressure units
    })
    # check results same
    expect_true(all.equal(res_respR, res_respirometry))

    # %Air
    ## all combinations
    grid <- expand.grid(PercAir_in = PercAir_in,
                        t_in = t_in,
                        S_in = S_in,
                        P_in = P_in)
    grid[[5]] <- seq(1:nrow(grid))
    # respR results
    res_respR <- apply(grid, 1, function(x) {
      suppressWarnings(convert_DO(x = x[1], from = "%Air", to = "mg/L", t = x[2], S = x[3], P = x[4]))
    })

    # respirometry results
    res_respirometry <- apply(grid, 1, function(x) {
      respirometry::conv_o2( o2 = x[1], from = "percent_a.s.", to = "mg_per_l",
                             temp = x[2], sal = x[3], atm_pres = x[4]*1000) ## nb diff pressure units
    })
    # check results same
    expect_true(all.equal(res_respR, res_respirometry))

  })


  test_that("convert_DO: warning if P is outside realistic range", {
    expect_warning(convert_DO(x = 100, from = "%Air", to = "mg/L",
                              t = 12, S = 30, P = 1.5),
                   regexp = "convert_DO: The Atmospheric Pressure input 'P' is outside the normal realistic range.")
    expect_warning(convert_DO(x = 100, from = "%Air", to = "mg/L",
                              t = 12, S = 30, P = 1000),
                   regexp = "convert_DO: The Atmospheric Pressure input 'P' is outside the normal realistic range.")
    expect_warning(convert_DO(x = 100, from = "%Air", to = "mg/L",
                              t = 12, S = 30, P = 0.01),
                   regexp = "convert_DO: The Atmospheric Pressure input 'P' is outside the normal realistic range.")
    expect_warning(convert_DO(x = 100, from = "%Air", to = "mg/L",
                              t = 12, S = 30, P = 1),
                   regexp = NA)
  })


})
