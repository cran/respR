#' Convert between units of dissolved oxygen
#'
#' This is a conversion function that performs conversions between concentration
#' and pressure units of dissolved oxygen (DO).
#'
#' The function uses an internal database and a fuzzy string matching algorithm
#' to accept various unit formatting styles. For example, `"mg/l"`, `"mg/L"`,
#' `"mgL-1"`, `"mg l-1"`, `"mg.l-1"` are all parsed the same. See
#' `[unit_args()]` for details of accepted units.
#'
#' Oxygen concentration units should use SI units (`L` or `kg`) for the
#' denominator.
#'
#' Some DO units require temperature (`t`), salinity (`S`), and atmospheric
#' pressure (`P`) to be specified; if this is the case the function will stop
#' and prompt for them. For the atmospheric pressure input (P), a default value
#' of 1.013 bar (standard pressure at sea level) is applied if not otherwise
#' entered. For freshwater experiments, salinity should be set to zero (i.e. `S
#' = 0`).
#'
#' ## S3 Generic Functions
#'
#' Saved output objects (if `simplify = FALSE` is used) can be entered in the
#' generic S3 functions `print()` and `summary()`.
#'
#' - `print()`: prints input and converted values (up to first 20), plus input
#' and output units.
#'
#' - `summary()`: simple wrapper for `print()` function. See above.
#'
#' @return By default (`simplify = TRUE`) the output is a numeric vector of
#'   converted values. If `simplify = FALSE` output is a `list` object of class
#'   `convert_DO` containing five elements: `$call` the function call, `$input`
#'   values, `$output` converted values, `$input.unit` and `$output.unit`.
#'
#' ## More
#'
#' For additional help, documentation, vignettes, and more visit the `respR`
#' website at <https://januarharianto.github.io/respR/>
#'
#' @param x numeric. The dissolved oxygen (DO) value(s) to be converted.
#' @param from string. The DO unit to convert *from*. See [unit_args()] for
#'   details.
#' @param to string. The DO unit to convert *to*. See [unit_args()] for details.
#' @param S numeric. Salinity (ppt). Defaults to NULL. Required for conversion
#'   of some units. See [unit_args()] for details.
#' @param t numeric. Temperature(°C). Defaults to NULL. Required for conversion
#'   of some units. See [unit_args()] for details.
#' @param P numeric. Pressure (bar). Defaults to 1.013253. Required for
#'   conversion of some units. See [unit_args()] for details.
#' @param simplify logical. Defaults to `TRUE` in which case the converted
#'   values are returned as a numeric vector. if `FALSE` a list object of class
#'   `convert_DO` is returned.
#'
#' @importFrom marelac molvol molweight gas_satconc sw_dens vapor atmComp
#' @export
#'
#' @examples
#' # Convert a numeric value from & to units which do not require t, S and P
#' convert_DO(8.21, from = "mg/L", to = "umol/L")
#'
#' # Convert a numeric value from & to units which require t, S and P
#' convert_DO(100, from = "%Air", to = "mg L-1", S = 33, t = 18)
#' convert_DO(214, from = "hPa", to = "mL/kg", S = 33, t = 18)
#'
#' # Convert a vector of values
#' convert_DO(urchins.rd[[5]], from = "mg/L", to = "umol/L")
#' convert_DO(c(8.01, 8.03, 8.05), from = "mg per litre", to = "%Air",
#'   t = 15, S = 35)
#' convert_DO(sardine.rd[[2]], from = "%Air", to = "torr",
#'   t = 15, S = 35)

convert_DO <- function(x, from = NULL, to = NULL, S = NULL, t = NULL,
                       P = NULL, simplify = TRUE) {

  ## Save function call for output
  call <- match.call()

  # Verify the units:
  fru <- verify_units(from, 'o2')
  tou <- verify_units(to, 'o2')

  # Units requiring t, S and/or P (all same for now)
  tsp_req <- c("mL/L.o2", "cm3/L.o2", "mL/kg.o2",
               "%Air.o2", "%Oxy.o2",
               "Torr.o2p", "hPa.o2p", "kPa.o2p",
               "inHg.o2p", "mmHg.o2p",
               "mg/kg.o2", "ug/kg.o2",
               "mol/kg.o2", "mmol/kg.o2", "umol/kg.o2",
               "mL/kg.o2")

  # Check t, S and P needed for units

  ## t and S - could combine these to one check
  if(is.null(S) && (fru %in% tsp_req || tou %in% tsp_req))
    stop("convert_DO: Input or output units require Salinity input (i.e. S = ??)")

  if(is.null(t) && (fru %in% tsp_req || tou %in% tsp_req))
    stop("convert_DO: Input or output units require Temperature input (i.e. t = ??)")

  ## Set default P if not provided
  if(is.null(P) && (fru %in% tsp_req || tou %in% tsp_req))
    message("convert_DO: Input or output units require Atmospheric Pressure input (i.e. P = ??). \n Default value of P = 1.013253 bar has been used.")
  if(is.null(P)) P <- 1.013253

  if(!dplyr::between(P, 0.9, 1.08))
    warning("convert_DO: The Atmospheric Pressure input 'P' is outside the normal realistic range. \nIt should not be outside the typical range of 0.9 to 1.1 except for special applications. \nPlease make sure it is entered in 'bar' units. Conversion performed regardless.")

  # Constants/formula data using data taken from 'marelac' (gsw removed atm).
  # Conversion factors between pressure units are obtained from the udunits2
  # C library: https://www.unidata.ucar.edu/software/udunits/

  if(!is.null(t)) omVl <- unname(marelac::molvol(t, P, species = "O2"))  # moles O2 in 1L vol
  omWt <- unname(marelac::molweight('O2'))  # molecular weight of O2 in g/mol
  if(!is.null(t) && !is.null(S)) oGas <- unname(marelac::gas_satconc(S, t, P, species = "O2")) # gas sat conc.
  if(!is.null(t) && !is.null(S)) swDn <- marelac::sw_dens(S = S, t = t, P = P) # seawater density in kg/m^3
  #swDn <- gsw::gsw_rho_t_exact(S, t, (P * 10))  # seawater density in kg/m^3
  if(!is.null(t) && !is.null(S)) vpor <- marelac::vapor(S = S, t = t)  # sat. pressure of water vapour (au)
  oAtm <- unname(marelac::atmComp('O2'))  # atmospheric composition of O2 (%)

  # Import from other functions
  # This made no sense! These are not DO units but DO/time rates
  # However this would be useful functionality to have - conversion of rates between units
  # if (class(x) %in% c("calc_rate","auto_rate")) z <- x$rate
  # if (class(x) %in% "adjust_rate") z <- x$adjusted.rate

  # Validate x input:
  if (!is.numeric(x)) stop("convert_DO: input 'x' must be a numeric value or vector.")
  if (is.numeric(x)) z <- x

  # Perform conversions
  # First we convert all values to a standard unit, mg/L:
  if (fru == verify_units('mg/L',   'o2')) {c <-  z}
  if (fru == verify_units('ug/L',   'o2')) {c <-  z / 1e3}
  if (fru == verify_units('mol/L',  'o2')) {c <-  z * omWt * 1e3}
  if (fru == verify_units('mmol/L', 'o2')) {c <-  z * omWt}
  if (fru == verify_units('umol/L', 'o2')) {c <-  z * omWt / 1e3}
  if (fru == verify_units('mL/L',   'o2')) {c <-  z * omWt / omVl}
  if (fru == verify_units('cm3/L',  'o2')) {c <-  z * omWt / omVl}
  if (fru == verify_units('mg/kg',  'o2')) {c <-  z * swDn / 1e3}
  if (fru == verify_units('ug/kg',  'o2')) {c <-  z * swDn / 1e6}
  if (fru == verify_units('mol/kg', 'o2')) {c <-  z * swDn * omWt}
  if (fru == verify_units('mmol/kg','o2')) {c <-  z * swDn * omWt / 1e3}
  if (fru == verify_units('umol/kg','o2')) {c <-  z * swDn * omWt / 1e6}
  #if (fru == verify_units('%',      'o2')) {c <-  z * oGas * omWt / 1e3 / 100}
  if (fru == verify_units('%Air',   'o2')) {c <-  z * oGas * omWt / 1e3 / 100}
  if (fru == verify_units('%Oxy',    'o2')) {c <-  z * oGas * omWt / oAtm / 1e3 / 100}
  if (fru == verify_units('mL/kg',  'o2')) {c <-  z * omWt / omVl * swDn / 1e3}
  if (fru == verify_units('Torr',   'o2')) {c <-  z / (P - vpor) / oAtm * oGas * omWt / 1e3 / 760.000066005}
  if (fru == verify_units('hPa',    'o2')) {c <-  z / (P - vpor) / oAtm * oGas * omWt / 1e3 / 1013.235}
  if (fru == verify_units('kPa',    'o2')) {c <-  z / (P - vpor) / oAtm * oGas * omWt / 1e3 / 101.3235}
  if (fru == verify_units('mmHg',   'o2')) {c <-  z / (P - vpor) / oAtm * oGas * omWt / 1e3 / 759.999951996}
  if (fru == verify_units('inHg',   'o2')) {c <-  z / (P - vpor) / oAtm * oGas * omWt / 1e3 / 29.9212583001}

  # Then we convert mg/L to the final desired unit:
  if(tou == verify_units('mg/L',   'o2')) {out <- c}
  if(tou == verify_units('ug/L',   'o2')) {out <- c * 1e3}
  if(tou == verify_units('mol/L',  'o2')) {out <- c / omWt / 1e3}
  if(tou == verify_units('mmol/L', 'o2')) {out <- c / omWt}
  if(tou == verify_units('umol/L', 'o2')) {out <- c / omWt * 1e3}
  if(tou == verify_units('mL/L',   'o2')) {out <- c / omWt * omVl}
  if(tou == verify_units('cm3/L',  'o2')) {out <- c / omWt * omVl}
  if(tou == verify_units('mg/kg',  'o2')) {out <- c / swDn * 1e3}
  if(tou == verify_units('ug/kg',  'o2')) {out <- c / swDn * 1e6}
  if(tou == verify_units('mol/kg', 'o2')) {out <- c / omWt / swDn}
  if(tou == verify_units('mmol/kg','o2')) {out <- c / omWt / swDn * 1e3}
  if(tou == verify_units('umol/kg','o2')) {out <- c / omWt / swDn * 1e6}
  #if(tou == verify_units('%',      'o2')) {out <- c / omWt / oGas * 1e3 * 100}
  if(tou == verify_units('%Air',   'o2')) {out <- c / omWt / oGas * 1e3 * 100}
  if(tou == verify_units('%Oxy',    'o2')) {out <- c / omWt / oGas * oAtm * 1e3 * 100}
  if(tou == verify_units('mL/kg',  'o2')) {out <- c / swDn * omVl / omWt * 1e3}
  if(tou == verify_units('Torr',   'o2')) {out <- c / omWt / oGas * oAtm * (P - vpor) * 1e3 * 760.000066005}
  if(tou == verify_units('hPa',    'o2')) {out <- c / omWt / oGas * oAtm * (P - vpor) * 1e3 * 1013.253}
  if(tou == verify_units('kPa',    'o2')) {out <- c / omWt / oGas * oAtm * (P - vpor) * 1e3 * 101.3253}
  if(tou == verify_units('mmHg',   'o2')) {out <- c / omWt / oGas * oAtm * (P - vpor) * 1e3 * 759.999951996}
  if(tou == verify_units('inHg',   'o2')) {out <- c / omWt / oGas * oAtm * (P - vpor) * 1e3 * 29.9212583001}

  # Generate output
  out <- list(call = call,
              input = z,
              output = out,
              input.unit = from,
              output.unit = to)

  class(out) <- "convert_DO"

  if(simplify) return(out$output) else
    return(out)
}

#' Print convert_DO objects
#' @param x convert_DO object
#' @param ... Pass additional inputs
#' @return Print to console. No returned value.
#' @export
print.convert_DO <- function(x, ...) {

  cat("\n# print.convert_DO # --------------------\n")
  if(length(x$input) >= 20) cat("Showing only the first 20 conversions:\n")

  cat("\nInput values:\n")
  if(length(x$input) >= 20) {
    print(head(x$input, 20))
  } else print(x$input)

  cat("Output values:\n")
  if(length(x$output) >= 20) {
    print(head(x$output, 20))
  } else print(x$output)
  cat("\nInput unit: ", x$input.unit)
  cat("\nOutput unit:", x$output.unit)
  cat("\n")
  cat("-----------------------------------------\n")
}

#' Summarise convert_DO objects
#' @param object convert_DO object
#' @param ... Pass additional inputs
#' @return Print to console. No returned value.
#' @export
summary.convert_DO <- function(object, ...) {
  print(object)
}

#' Plot convert_DO objects
#' @param x convert_DO object
#' @param ... Pass additional plotting parameters
#' @return A plot. No returned value.
#' @export
plot.convert_DO <- function(x, ...) {
  message("convert_DO: plot() is not available for 'convert_DO' objects.")
  return(invisible(x))
}

#' Average convert_DO object values
#' @param x convert_DO object
#' @param pos integer(s). Which result(s) to average.
#' @param export logical. Export averaged values as single value.
#' @param ... Pass additional inputs
#' @return Print to console. No returned value.
#' @export
mean.convert_DO <- function(x, pos = NULL, export = FALSE, ...){

  cat("\n# mean.convert_DO # ---------------------\n")
  if(!is.null(pos) && any(pos > length(x$output)))
    stop("mean.convert_DO: Invalid 'pos' rank: only ", length(x$output), " rates found.")
  if(is.null(pos)) {
    pos <- 1:length(x$output)
    cat("Averaging all converted oxygen values.")
    cat("\n")
  } else{
    cat("Averaging converted oxygen values from entered 'pos' ranks:")
    cat("\n")
  }
  if(length(x$output[pos]) == 1)
    message("Only 1 converted oxygen value found. Returning mean rate anyway...")
  cat("\n")

  n <- length(x$output[pos])
  out <- mean(x$output[pos])
  cat("Mean of", n, "converted oxygen values:\n")
  print(out)
  print(x$output.unit)
  cat("-----------------------------------------\n")

  if(export)
    return(invisible(out)) else
      return(invisible(x))
}



#' Check unit string against a known database
#'
#' @keywords internal
verify_units <- function(unit, is) {
  # Not sure if worth ID'ing some of these using regex (too many variations)
  # EDIT: ok it's worth it, but I've come too far.... will fix in future version
  # Doing it the stupid way:
  # time units

  # time --------------------------------------------------------------------
  if (is == 'time') {
    all.units <- list(
      day.time = c('days', 'day', 'dy', 'dys', 'd',
                   'Days', 'Day', 'Dy', 'Dys', 'D'),
      hour.time = c('hours', 'hour', 'hr', 'hrs', 'h',
                    'Hours', 'Hour', 'Hr', 'Hrs', 'H'),
      min.time  = c('minutes', 'minute', 'min', 'mins', 'm',
                    'Minutes', 'Minute', 'Min', 'Mins', 'M'),
      sec.time  = c('seconds', 'second', 'sec', 'secs', 's',
                    'Seconds', 'Second', 'Sec', 'Secs', 'S'))
  }

  # o2 ----------------------------------------------------------------------
  # 2-dimensional o2 units, and pressure
  if (is == 'o2') {

    if(unit %in% c("%", "perc", "percent","percentage"))
      stop("verify_units: unit \"%\" has been deprecated. Please use \"%Air\" or \"%Oxy\" instead. See unit_args().")

    all.units <- list(
      '%Air.o2' = c('%Air.o2',
                    '%air','%Air','%A','%a',
                    "percair","percentair","percentageair"),

      '%Oxy.o2' = c('%Oxy.o2',
                    '%oxy','%Oxy','%OX','%OXY','%o2','%Oxy','%o','%O',
                    "percoxygen","percentoxygen","percentageoxygen",
                    "percoxy","percentoxy","percentageoxy",
                    "perco2","percento2","percentageo2",
                    "percoO2","percentO2","percentageO2"),

      'ug/L.o2' = c('ug/L.o2',
                    'ug/L','ug/l','ug / L','ug / l','ugL-1',
                    'ugl-1','ug L-1','ug l -1','ug per liter','ug per litre',
                    'ugO2/L','ugO2/l','ugO2 / L','ugO2 / l','ugO2L-1',
                    'ugO2l-1','ugO2 L-1','ugO2 l -1','ugO2 per liter','ugO2 per litre'),

      'mol/L.o2' = c('mol/L.o2',
                     'mol/L','mol/l','mol / L','mol / l',
                     'molL-1,','moll-1','mol L-1,','mol l-1',
                     'mol per liter','mol per litre',
                     'molO2/L','molO2/l','molO2 / L','molO2 / l',
                     'molO2L-1,','molO2l-1','molO2 L-1,','molO2 l-1',
                     'molO2 per liter','molO2 per litre'),

      'mmol/L.o2' = c('mmol/L.o2',
                      'mmol/L','mmol/l','mmol / L','mmol / l',
                      'mmolL-1,','mmoll-1','mmol L-1,','mmol l-1',
                      'mmol per liter','mmol per litre',
                      'mmolO2/L','mmolO2/l','mmolO2 / L','mmolO2 / l',
                      'mmolO2L-1,','mmolO2l-1','mmolO2 L-1,','mmolO2 l-1',
                      'mmolO2 per liter','mmolO2 per litre'),

      'umol/L.o2' = c('umol/L.o2',
                      'umol/L','umol/l','umolL-1','umoll-1',
                      'umol / L','umol / l','umol L-1','umol l-1',
                      'umol per litre','umol per liter',
                      'umolO2/L','umolO2/l','umolO2L-1','umolO2l-1',
                      'umolO2 / L','umolO2 / l','umolO2 L-1','umolO2 l-1',
                      'umolO2 per litre','umolO2 per liter'),

      'mL/L.o2' = c('mL/L.o2',
                    'ml/L','mL/L','mL/l','ml/l','mll-1','mLl-1',
                    'mLL-1','mlL-1','ml / L','mL / L','mL / l','ml / l',
                    'ml l-1','mL l-1','mL L-1','ml L-1','ml per l','mL per L',
                    'ml per L',
                    'mlO2/L','mLO2/L','mLO2/l','mlO2/l','mlO2l-1','mLO2l-1',
                    'mLO2L-1','mlO2L-1','mlO2 / L','mLO2 / L','mLO2 / l','mlO2 / l',
                    'mlO2 l-1','mLO2 l-1','mLO2 L-1','mlO2 L-1','mlO2 per l','mLO2 per L',
                    'mlO2 per L'),

      # this is identical to ml/L - only used in v old papers
      'cm3/L.o2' = c('cm3/L.o2',
                    'cm3/L','cm3/L','cm3/l','cm3/l','cm3l-1','cm3l-1',
                    'cm3L-1','cm3L-1','cm3 / L','cm3 / L','cm3 / l','cm3 / l',
                    'cm3 l-1','cm3 l-1','cm3 L-1','cm3 L-1','cm3 per l','cm3 per L',
                    'cm3 per L',
                    'cm3O2/L','cm3O2/L','cm3O2/l','cm3O2/l','cm3O2l-1','cm3O2l-1',
                    'cm3O2L-1','cm3O2L-1','cm3O2 / L','cm3O2 / L','cm3O2 / l','cm3O2 / l',
                    'cm3O2 l-1','cm3O2 l-1','cm3O2 L-1','cm3O2 L-1','cm3O2 per l','cm3O2 per L',
                    'cm3O2 per L'),

      'mg/L.o2' = c('mg/L.o2',
                    'mg/L','mg/l','mg / l','mg / L','mgL-1','mgl-1',
                    'mg L-1','mg l-1','mg per litre','mg per liter',
                    'mgO2/L','mgO2/l','mgO2 / l','mgO2 / L','mgO2L-1','mgO2l-1',
                    'mgO2 L-1','mgO2 l-1','mgO2 per litre','mgO2 per liter'),

      'mg/kg.o2' = c('mg/kg.o2',
                     'mg/kg','mg / kg','mgkg-1','mg kg-1',
                     'mg per kg',
                     'mgO2/kg','mgO2 / kg','mgO2kg-1','mgO2 kg-1',
                     'mgO2 per kg'),

      'ug/kg.o2' = c('ug/kg.o2',
                     'ug/kg','ugkg-1','ug / kg','ug kg-1',
                     'ug per kg',
                     'ugO2/kg','ugO2kg-1','ugO2 / kg','ugO2 kg-1',
                     'ugO2 per kg'),

      'mL/kg.o2' = c('mL/kg.o2',
                     'ml/kg','mL/kg','mlkg-1','mLkg-1','ml / kg',
                     'mL / kg','ml kg-1','mL kg-1','ml per kg',
                     'mlO2/kg','mLO2/kg','mlO2kg-1','mLO2kg-1','mlO2 / kg',
                     'mLO2 / kg','mlO2 kg-1','mLO2 kg-1','mlO2 per kg'),

      'mol/kg.o2' = c('mol/kg.o2',
                      'mol/kg','mol/Kg','molkg-1','molKg-1',
                      'mol / kg','mol / Kg','mol kg-1','mol Kg-1',
                      'mol per kg','mol per Kg',
                      'molO2/kg','molO2/Kg','molO2kg-1','molO2Kg-1',
                      'molO2 / kg','molO2 / Kg','molO2 kg-1','molO2 Kg-1',
                      'molO2 per kg','molO2 per Kg'),

      'mmol/kg.o2' = c('mmol/kg.o2',
                       'mmol/kg','mmol/Kg','mmolkg-1','mmolKg-1',
                       'mmol / kg','mmol / Kg','mmol kg-1','mmol Kg-1',
                       'mmol per kg','mmol per Kg',
                       'mmolO2/kg','mmolO2/Kg','mmolO2kg-1','mmolO2Kg-1',
                       'mmolO2 / kg','mmolO2 / Kg','mmolO2 kg-1','mmolO2 Kg-1',
                       'mmolO2 per kg','mmolO2 per Kg'),

      'umol/kg.o2' = c('umol/kg.o2',
                       'umol/kg','umol/Kg','umolkg-1,','umolKg-1',
                       'umol / kg','umol / Kg','umol kg-1,','umol Kg-1',
                       'umol per kg','umol per Kg',
                       'umolO2/kg','umolO2/Kg','umolO2kg-1,','umolO2Kg-1',
                       'umolO2 / kg','umolO2 / Kg','umolO2 kg-1,','umolO2 Kg-1',
                       'umolO2 per kg','umolO2 per Kg'),

      'Torr.o2p' = c('Torr.o2p',
                     'torr','TORR','Torr','Tor','tor',
                     'torrO2','TORRO2','TorrO2','TorO2','torO2'),

      'hPa.o2p' = c('hPa.o2p',
                    'hPa','hpa','Hpa','HPA','HPa','hectopascal',
                    'hpascal',
                    'hPaO2','hpaO2','HpaO2','HPAO2','HPaO2','hectopascalO2',
                    'hpascalO2'),

      'kPa.o2p' = c('kPa.o2p',
                    'kPa','kpa','Kpa','KPA','KPa','kilopascal',
                    'kpascal',
                    'kPaO2','kpaO2','KpaO2','KPAO2','KPaO2','kilopascalO2',
                    'kpascalO2'),

      'mmHg.o2p' = c('mmHg.o2p',
                     'mmHg','mm Hg','mmhg','mm hg','MMHG','MM HG',
                     'millimeter of mercury','mm mercury',
                     'mmHgO2','mm HgO2','mmhgO2','mm hgO2','MMHGO2','MM HGO2',
                     'millimeter of mercuryO2','mm mercuryO2'),

      'inHg.o2p' = c('inHg.o2p',
                     'inHg','in Hg','inhg','in hg','INHG','IN HG',
                     'inch of mercury','inch mercury',
                     'inHgO2','in HgO2','inhgO2','in hgO2','INHGO2','IN HGO2',
                     'inch of mercuryO2','inch mercuryO2'))
  }

  # vol ---------------------------------------------------------------------
  if (is == 'vol') {
    all.units <- list(
      uL.vol = c('ul.vol','ul','uL','microlitre','microliter',
                 'micro litre','micro liter'),
      mL.vol = c('mL.vol','ml','mL','millilitre','milli litre','milliliter',
                 'milli liter'),
      L.vol  = c('L.vol','l','L','liter','litre','Litre','Liter'))
  }

  # mass --------------------------------------------------------------------
  if (is == 'mass') {
    all.units <- list(
      ug.mass  = c('ug.mass','ug','UG','ugram','microgram'),
      mg.mass  = c('mg.mass','mg','MG','mgram','milligram'),
      g.mass   = c('g.mass','g','G','gram'),
      kg.mass  = c('kg.mass','kg','KG','kilogram','kgram'))
  }

  # area --------------------------------------------------------------------
  if (is == 'area') {
    all.units <- list(
      mm2.area  = c('mm2.area','mmsq','mm2','MM2','sqmm'),
      cm2.area  = c('cm2.area','cmsq','cm2','CM2','sqcm'),
      m2.area   = c('m2.area','msq','m2','M2','sqm'),
      km2.area  = c('km2.area','kmsq','km2','KM2','sqkm'))
  }

  # o1 ----------------------------------------------------------------------
  if (is == 'o1') {
    all.units <-  list(
      'ug.o2'   = c('ug.o2','ugo2','ugO2','ug','microgram'),
      'mg.o2'   = c('mg.o2','mgo2','mgO2','mg','milligram'),
      'mol.o2' = c('mol.o2','molo2','molO2','mol','mole'),
      'mmol.o2' = c('mmol.o2','mmolo2','mmolO2','mmol','millimol'),
      'umol.o2' = c('umol.o2','umolo2','umolO2','umol','micromol'),
      'ml.o2'   = c('ml.o2','mlo2','mlO2','ml','mLo2','mLO2','mL','millil'))
  }

  # flow --------------------------------------------------------------------
  if (is == 'flow') {
    ul_var <- c("ul", "uL", "UL", "Ul",
                "microlitre", "microlitres",
                "micro litre", "micro litres",
                "microliter", "microliters",
                "micro liter", "micro liters")
    ml_var <- c("ml", "mL", "ML", "Ml",
                "millilitre", "millilitres",
                "milli litre", "milli litres",
                "milliliter", "milliliters",
                "milli liter", "milli liters")
    l_var <- c("l", "L",
               "litre", "litres",
               "Litre", "Litres",
               "Liter", "Liters")
    vol_var <- list(ul_var,
                    ml_var,
                    l_var)
    vol_var.true <- list(rep("ul", length(ul_var)),
                         rep("ml", length(ml_var)),
                         rep("l", length(l_var)))

    sec_var  = c('seconds', 'second', 'sec', 'secs', 's', "S")
    min_var  = c('minutes', 'minute', 'min', 'mins', 'm', "M")
    hour_var = c('hours', 'hour', 'hr', 'hrs', 'h', "H")
    day_var = c('days', 'day', 'dy', 'dys', 'd', "D")

    time_var <- list(sec_var,
                     min_var,
                     hour_var,
                     day_var)
    time_var.true <- list(rep("s", length(sec_var)),
                          rep("m", length(min_var)),
                          rep("h", length(hour_var)),
                          rep("d", length(day_var)))

    ## all combinations of vol and time
    flow_units <- expand.grid(unlist(vol_var), unlist(time_var))
    ## with / sep
    flow_units[[3]] <- mapply(function(p,q) paste0(p, "/", q),
                              p = flow_units[[1]],
                              q = flow_units[[2]])
    ## with . sep
    flow_units[[4]] <- mapply(function(p,q) paste0(p, ".", q),
                              p = flow_units[[1]],
                              q = flow_units[[2]])
    ## with space sep
    flow_units[[5]] <- mapply(function(p,q) paste0(p, " ", q),
                              p = flow_units[[1]],
                              q = flow_units[[2]])
    ## with space sep plus -1
    flow_units[[6]] <- mapply(function(p,q) paste0(p, " ", q, "-1"),
                              p = flow_units[[1]],
                              q = flow_units[[2]])
    ## with NO sep plus -1
    flow_units[[7]] <- mapply(function(p,q) paste0(p, q, "-1"),
                              p = flow_units[[1]],
                              q = flow_units[[2]])
    ## with . sep plus -1
    flow_units[[8]] <- mapply(function(p,q) paste0(p, ".", q, "-1"),
                              p = flow_units[[1]],
                              q = flow_units[[2]])
    ## add final parsed unit
    ## this is what matches will be identified as
    flow_units[,9:10] <- expand.grid(unlist(vol_var.true), unlist(time_var.true))
    flow_units[[11]] <- mapply(function(p,q) paste0(p, "/", q, ".flow"),
                               p = flow_units[[9]],
                               q = flow_units[[10]])
    all.units <- list(
      'ul/s.flow' = unlist(flow_units[which(flow_units[[11]] == "ul/s.flow"),3:8]),
      'ml/s.flow' = unlist(flow_units[which(flow_units[[11]] == "ml/s.flow"),3:8]),
      'l/s.flow' = unlist(flow_units[which(flow_units[[11]] == "l/s.flow"),3:8]),
      'ul/m.flow' = unlist(flow_units[which(flow_units[[11]] == "ul/m.flow"),3:8]),
      'ml/m.flow' = unlist(flow_units[which(flow_units[[11]] == "ml/m.flow"),3:8]),
      'l/m.flow' = unlist(flow_units[which(flow_units[[11]] == "l/m.flow"),3:8]),
      'ul/h.flow' = unlist(flow_units[which(flow_units[[11]] == "ul/h.flow"),3:8]),
      'ml/h.flow' = unlist(flow_units[which(flow_units[[11]] == "ml/h.flow"),3:8]),
      'l/h.flow' = unlist(flow_units[which(flow_units[[11]] == "l/h.flow"),3:8]),
      'ul/d.flow' = unlist(flow_units[which(flow_units[[11]] == "ul/d.flow"),3:8]),
      'ml/d.flow' = unlist(flow_units[which(flow_units[[11]] == "ml/d.flow"),3:8]),
      'l/d.flow' = unlist(flow_units[which(flow_units[[11]] == "l/d.flow"),3:8])
    )
  }

  # pressure ----------------------------------------------------------------
  if (is == 'pressure') {
    all.units <- list(
      kpa.p  = c('kPa','kpa', 'KPA'),
      hpa.p  = c('hPa','hpa', 'HPA'),
      pa.p  = c('Pa','pa', 'PA'),
      ubar.p  = c('ub', 'ubar', 'Ubar', 'UBAR', 'uBar', 'ubr', 'UBR'),
      mbar.p  = c('mb', 'mbar', 'Mbar', 'MBAR', 'mBar', 'mbr', 'MBR'),
      bar.p  = c('b', 'bar', 'bar', 'BAR', 'Bar', 'br', 'BR'),
      atm.p  = c('atm', 'Atm', 'ATM', 'Atmos', 'ATMOS'),
      torr.p  = c('torr','TORR','Torr','Tor','tor'),
      mmhg.p = c('mmHg','mm Hg','mmhg','mm hg','MMHG','MM HG'),
      inhg.p = c('inHg','in Hg','inhg','in hg','INHG','IN HG'))
  }

  # temperature -------------------------------------------------------------
  if (is == 'temperature') {
    all.units <- list(
      c.temp  = c('C','c', 'dgrc', 'DGRC', 'dgr c', 'DGR C',
                  'degrees c', 'DEGREES C',
                  'celsius', 'Celsius', 'CELSIUS',
                  'centigrade', 'Centigrade'),
      k.temp  = c('K','k', 'dgrk', 'DGRK', 'dgr k', 'DGR K',
                  'degrees k', 'DEGREES K',
                  'kelvin', 'Kelvin', 'KELVIN'),
      f.temp  = c('F','f', 'dgrf', 'DGRF', 'dgr f', 'DGR F',
                  'degrees f', 'DEGREES F',
                  'fahrenheit', 'Fahrenheit', 'FAHRENHEIT'))
  }


  # Look for match ----------------------------------------------------------
  string <- paste0('^', unit, '$')  # for exact matching
  chk <- lapply(all.units, function(x) grep(string, x))
  chk <- sapply(chk, function(x) length(x) > 0)
  result <- any(chk == T)  # did a match occur?
  if (result == FALSE)
    stop("verify_units: unit '", unit, "' not recognised. Check it is valid for the input or output type. \nOutput rate unit strings should be in correct order: O2/Time or O2/Time/Mass or O2/Time/Area.\nSee unit_args() for details.", call. = F)
  out <- names(chk)[which(chk)]  # print unit name
  return(out)
}



