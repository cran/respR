% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/convert_rate.ft.R
\name{convert_rate.ft}
\alias{convert_rate.ft}
\title{Convert a unitless oxygen rate value from flowthrough respirometry to
absolute, mass-specific or area-specific rates}
\usage{
convert_rate.ft(
  x,
  oxy.unit = NULL,
  flowrate.unit = NULL,
  output.unit = NULL,
  mass = NULL,
  area = NULL,
  S = NULL,
  t = NULL,
  P = 1.013253,
  plot = FALSE,
  ...
)
}
\arguments{
\item{x}{numeric value or vector, or object of class \code{\link[=calc_rate.ft]{calc_rate.ft()}} or
\code{\link[=adjust_rate.ft]{adjust_rate.ft()}}. Contains the rate(s) to be converted.}

\item{oxy.unit}{string. The dissolved oxygen units of the original raw data
used to determine the rate in \code{x}.}

\item{flowrate.unit}{string. The units of the flowrate through the
respirometer. See Details.}

\item{output.unit}{string. The output unit to convert the input rate to.
Should be in the correct order: "Oxygen/Time" or "Oxygen/Time/Mass" or
"Oxygen/Time/Area".}

\item{mass}{numeric. Mass/weight in \strong{kg}. This is the mass of the specimen
if you wish to calculate mass-specific rates.}

\item{area}{numeric. Surface area in \strong{m^2}. This is the surface area of the
specimen if you wish to calculate surface area-specific rates.}

\item{S}{numeric. Salinity (ppt). Defaults to NULL. Used in conversion of
some oxygen units. Fresh water should be entered as \code{S = 0}.}

\item{t}{numeric. Temperature(°C). Defaults to NULL. Used in conversion of
some oxygen units.}

\item{P}{numeric. Pressure (bar). Used in conversion of some oxygen units.
Defaults to a standard value of 1.013253 bar.}

\item{plot}{logical. Default is \code{FALSE}. Controls if a plot is produced. See
Plot section.}

\item{...}{Allows additional plotting controls to be passed. See Plot
section.}
}
\value{
Output is a \code{list} object containing the \verb{$rate.input}, and converted
rate(s) in \verb{$rate.output} in the \verb{$output.unit}, as well as inputs and
summary elements. Note, \verb{$rate.abs} is the \emph{absolute} rate in the output
unit minus the mass- or area-specific component. The \verb{$summary} table
element contains all rate parameters and data locations (depending on what
class of object was entered), adjustments (if applied), units, and more.
}
\description{
\code{convert_rate.ft} converts a unitless rate derived from \code{\link[=calc_rate.ft]{calc_rate.ft()}} or
\code{\link[=adjust_rate.ft]{adjust_rate.ft()}} into an absolute rate (i.e. whole specimen or whole
chamber), mass-specific rate (i.e. normalised by specimen mass), or
area-specific rate (i.e. normalised by specimen surface area) in any common
unit. These should be rates calculated as an oxygen delta (inflow minus
outflow oxygen) multiplied by the flowrate.
}
\details{
By default, \code{convert_rate.ft} converts the \verb{$rate} element from
\code{calc_rate.ft} objects, or the \verb{$rate.adjusted} element from \code{adjust_rate.ft}
objects if these are entered as the \code{x} input. Alternatively, a numeric value
or vector of rates can be input as \code{x}.
\subsection{Units}{

The \code{oxy.unit} of the original raw data used to calculated the rate is
required. Concentration units should use only SI units (\code{L} or \code{kg}) for the
denominator, e.g. \code{"mg/L"}, \code{"mmol/kg"}. Percentage saturation of air or
oxygen is accepted, as are oxygen pressure units. See \code{\link[=unit_args]{unit_args()}} for
details.

An \code{output.unit} is also required. If left \code{NULL}, The default of \code{"mgO2/h"}
is used, or \code{"mgO2/h/kg"} or \code{"mgO2/h/m2"} if a \code{mass} or \code{area} respectively
has been entered. The \code{output.unit} must be in the sequence \emph{Oxygen-Time}
(e.g. \code{"mg/h"}) for absolute rates, \emph{Oxygen-Time-Mass} (e.g. \code{"mg/h/kg"}) for
mass-specific rates, and \emph{Oxygen-Time-Area} (e.g. \code{"mg/h/cm2"}) for surface
area-specific rates.

Note, some oxygen input or output units require temperature (\code{t}) and
salinity (\code{S}) to perform conversions. For freshwater experiments, salinity
should be entered as zero (i.e. \code{S = 0}).

Strictly speaking the atmospheric pressure (\code{P}) should also be supplied. If
not, the default value of 1.013253 bar (standard pressure at sea level) is
used. In most locations which have a normal range (outside extreme weather
events) of around 20 millibars, any variability in pressure will have a
relatively minor effect on dissolved oxygen, and even less on calculated
rates. However, we would encourage users to enter the actual value if they
know it, or use historical weather data to find out what it was on the day.
See \code{\link[=unit_args]{unit_args()}} for details.

The \code{flowrate.unit} is required and should be the units of the \code{flowrate}
used in \code{calc_rate.ft} to calculate the rate, and should be in the form of
volume (L, ml, or ul) per unit time (s,m,h,d), for example in \code{"L/s"}. Note,
the volume component does \emph{NOT} represent the volume of the respirometer, and
the time component does \emph{NOT} represent the units or recording interval of
the original raw data.

The function uses a fuzzy string matching algorithm to accept various unit
formatting styles. For example, \code{"mg/l"}, \code{"mg/L"}, \code{"mgL-1"}, \code{"mg l-1"},
\code{"mg.l-1"} are all parsed the same. See \code{\link[=unit_args]{unit_args()}} for details of
accepted units and their formatting. See also \code{\link[=convert_val]{convert_val()}} for simple
conversion between non-oxygen units.
}

\subsection{Plot}{

Plotting provides three ways of visualising converted rates (or a selection
of them using \code{pos}), chosen using \code{type}. This is mostly useful only if you
have extracted multiple rates (see \code{calc_rate.ft()}). The default is \code{plot = FALSE} to prevent plots being produced for every single conversion.
\code{convert_rate.ft} objects can only be plotted if and \code{inspect.ft} object was
used as the input in \code{calc_rate.ft}. In other words, converted rates from
numeric inputs cannot be plotted.

\code{type = "full"} (the default) plots a grid of up to 20 plots with each rate
(i.e. region of averaged delta values) highlighted on a plot of delta oxygen
values, with the converted rate value in the title. Values on the axes - time
(bottom), row (top), and oxygen delta (left) - are in the units of the
original raw data. Rates are plotted in order of how they appear in the
summary table up to the first 20 rows, unless different rows have been
specified via \code{pos}.

\code{type = "rate"} plots the entire data timeseries, that is the outflow and
inflow oxygen (if used) on the upper plot, with delta oxygen on the middle
plot or as the upper plot if delta oxygen values have been entered in
\code{inspect.ft}. The lower plot is the output rate values in the chosen output
units. Each rate is plotted against the middle of the region used to
determine it (i.e. region of averaged delta values). \code{pos} can be used to
select a range of rates (i.e. summary table rows) to show in the lower plot
(default is all).

\code{type = "overlap"} visualises where regression results in the summary table
occur in relation to the original dataset to help understand how they are
distributed or may overlap. The top plot is the entire data timeseries, that
is the outflow and inflow oxygen (if used) on the upper plot, with delta
oxygen on the middle plot or as the upper plot if delta oxygen values have
been entered in \code{inspect.ft}. The bottom plot is the region of the data each
rate has been calculated over (i.e. region of averaged delta values). The
y-axis represents the position (i.e. row) of each in the summary table
descending from top to bottom. If no reordering or selection has been
performed, this will usually be equivalent to the \verb{$rank} column, but note as
reordering or selection is performed rank and summary table position will not
necessarily be equivalent. One result (summary table row) can be highlighted,
the default being \code{highlight = 1}. \code{pos} can be used to select a range of
summary rows to plot in the lower overlap plot.

Other options:

\code{legend = FALSE} will suppress plot labels, \code{pos} selects summary rates to
plot, \code{quiet} suppresses console messages.
}

\subsection{S3 Generic Functions}{

Saved output objects can be used in the generic S3 functions \code{print()},
\code{summary()}, and \code{mean()}.
\itemize{
\item \code{print()}: prints a single result, by default the first converted rate.
Others can be printed by passing the \code{pos} input. e.g. \code{print(x, pos = 2)}
\item \code{summary()}: prints the output \verb{$summary} table of converted rates and
metadata. Specific rows can be specified with the \code{pos} input. e.g.
\code{summary(x, pos = 1:5)}. This can be exported as a separate data frame by
passing \code{export = TRUE}, and includes all rate parameters, data locations,
adjustments if applied, units, and more. Note, the summary table contains
linear regression coefficients alongside other metadata. These should not be
confused with those in other functions such as \code{calc_rate} where slopes
represent rates and coefficients such as a high r-squared are important.
Here, slope represents the stability of the data region, in that the closer
the slope is to zero, the less the delta oxygen values in that region vary,
which is an indication of a region of stable rates. They are included to
enable possible future functionality where stable regions may be
automatically identified, and should generally be ignored. However, advanced
users can use regular R syntax to explore and subset the results using these
if they wish.
\item \code{mean()}: calculates the mean of all converted rates, or those specified by
the \code{pos} input. e.g. \code{mean(x, pos = 1:5)} The mean can be exported as a
separate value by passing \code{export = TRUE}.
}
}

\subsection{More}{

For additional help, documentation, vignettes, and more visit the \code{respR}
website at \url{https://januarharianto.github.io/respR/}
}
}
\examples{
# Convert a single numeric rate to an absolute rate
convert_rate.ft(-0.09, oxy.unit = 'mg/l', flowrate.unit = 'L/s',
                output.unit = 'mg/min')

# Convert a single numeric rate to a mass-specific rate
convert_rate.ft(-0.09, oxy.unit = 'mg/l', flowrate.unit = 'L/s',
                output.unit = 'mg/min/kg', mass = 0.5)

# Convert a single numeric rate to an area-specific rate
convert_rate.ft(-0.09, oxy.unit = 'mg/l', flowrate.unit = 'L/s',
                output.unit = 'mg/min/cm2', area = 0.0002)

# Full object-oriented workflow
# Inspect, calculate rate, adjust rate, and convert
# to a final mass-specific rate
inspect.ft(flowthrough_mult.rd,
           time = 1,
           out.oxy = 2,
           in.oxy = 6) \%>\%
  calc_rate.ft(flowrate = 0.1,
               from = 30,
               to = 60,
               by = "time") \%>\%
  adjust_rate.ft(by = -0.032) \%>\%
  convert_rate.ft(oxy.unit = '\%Air',
                  flowrate.unit = 'L/min',
                  output.unit = 'mg/h/g',
                  mass = 0.05,
                  S =35, t = 15, P = 1.013)
}
