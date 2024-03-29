% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/adjust_rate.ft.R
\name{adjust_rate.ft}
\alias{adjust_rate.ft}
\title{Adjust rates in flowthrough respirometry to account for background
respiration or oxygen flux.}
\usage{
adjust_rate.ft(x, by)
}
\arguments{
\item{x}{numeric. A single numeric value, numeric vector, or object of class
\code{calc_rate.ft}. This is the experimental rate value(s) to be adjusted.}

\item{by}{numeric. A numeric value, numeric vector, or object of class
\code{calc_rate.ft}. This contains the background rate used to perform the
adjustment to \code{x}. If the vector or \code{calc_rate.ft} object contains multiple
rates, they will be averaged to produce a single adjustment value.}
}
\value{
\strong{Output}: If the \code{x} input is a \code{calc_rate.ft} object, the output
will be identical in structure, but of class \code{adjust_rate.ft} and
containing the additional elements \verb{$adjustment} and \verb{$rate.adjusted}, with
these also added to \verb{$summary} metadata.

If \code{x} is a numeric value or vector, the output is a \code{list} object of class
\code{adjust_rate.ft} containing four elements: a \verb{$summary} table, \verb{$rate},
\verb{$adjustment}, and \verb{$rate.adjusted}.

For all outputs, the \verb{$rate.adjusted} element will be the one converted
when the object is passed to \code{convert_rate.ft}.
}
\description{
The \code{adjust_rate.ft} function adjusts an oxygen uptake or production rate
(for example, as determined in \code{\link[=calc_rate.ft]{calc_rate.ft()}}) for background oxygen use
by microbial organisms, or other removal or input of oxygen during
\emph{flowthrough} respirometry experiments. The function accepts numeric values,
as well as \code{calc_rate.ft} objects. Numeric \code{x} and \code{by} inputs should be
rates calculated as the \strong{oxygen delta * flowrate}. Units will be specified
in \code{\link[=convert_rate.ft]{convert_rate.ft()}} when rates are converted to specific output units.
}
\details{
\code{adjust_rate.ft} allows the rate, or multiple rates, in \code{x} to be adjusted by
the background rate in \code{by}. There are several ways of determining the
background rate, or performing background corrections depending on the setup
of the experiment.

For experiments in which an empty "blank" experiment has been run, and the
background rate generally does not change over the course of the experiment
(that is, the oxygen delta between inflow and outflow concentrations remains
consistent), it is recommended the rate be determined and saved via the
\code{\link[=inspect.ft]{inspect.ft()}} and \code{\link[=calc_rate.ft]{calc_rate.ft()}} functions and then entered as the
\code{by} input as either a value or the saved \code{calc_rate.ft} object. In this
case, the \verb{$rate} element of the \code{calc_rate.ft} object is used to adjust all
rates in \code{x}. If there are multiple background rates in \verb{$rate}, the mean
value is used. In this way, a single blank experiment can be applied to
several specimen experiments. Alternatively, the rate from several blank
experiments can be averaged to provide a single adjustment value, and this
entered via \code{by} as a numeric value.

For experiments in which an empty "blank" experiment has been run alongside
actual experiments in parallel, and background rate may increase or decrease
over time (or there may be other variations for example in the inflow oxygen
concentrations), it is recommended you \emph{NOT} use this function. Instead, the
paired blank oxygen concentration data should be used in \code{\link{inspect.ft}} as
the \code{in.oxy} input. In this way, the calculated specimen delta oxygen values
take account of whatever background or other variation in oxygen is occurring
in the blank chamber with respect to time. See examples in the vignettes on
the website.

For adjustments, all rates in \code{x}, whether entered as values or as a
\code{calc_rate.ft} object, are adjusted by subtracting the mean of all background
rates in \code{by}.

\strong{Note:} take special care with the \emph{sign} of the rate used for adjustments.
In \code{respR} oxygen uptake rates are negative, as they represent a negative
slope of oxygen against time. Background rates will normally also be a
negative value (though not always). See Examples.
\subsection{S3 Generic Functions}{

Saved output objects can be used in the generic S3 functions \code{print()},
\code{summary()}, and \code{mean()}.
\itemize{
\item \code{print()}: prints a single result, by default the first adjusted rate.
Others can be printed by passing the \code{pos} input. e.g. \code{print(x, pos = 2)}.
See \code{help("print.adjust_rate.ft")}.
\item \code{summary()}: prints summary table of all results and metadata, or those
specified by the \code{pos} input. e.g. \code{summary(x, pos = 1:5)}. The summary can
be exported as a separate dataframe by passing \code{export = TRUE}. See
\code{help("summary.adjust_rate.ft")}.
\item \code{mean()}: calculates the mean of all adjusted rates, or those specified by
the \code{pos} input. e.g. \code{mean(x, pos = 1:5)} The mean can be exported as a
separate value by passing \code{export = TRUE}. See \code{help("mean.adjust_rate.ft")}.
}
}

\subsection{More}{

For additional help, documentation, vignettes, and more visit the \code{respR}
website at \url{https://januarharianto.github.io/respR/}
}
}
\examples{
# Note that oxygen uptake rates are negative in respR
# since they represent a decrease in dissolved oxygen
# and negative slope. Typically both specimen rate and
# background rate values are negative.

# ----------------------------------------------------
# Simple background respiration correction to a single
# rate.

# Note, 'x' and 'by' should both be rates calculated as
# the delta oxygen value, the difference between inflow
# and outflow oxygen, multiplied by the flowrate.

# This is (-0.98) - (-0.04) = -0.94
adjust_rate.ft(x = -0.98, by = -0.04)

# ----------------------------------------------------
# Mean background adjustment to a single rate.
adjust_rate.ft(x = -0.98, by = c(-0.04, -0.05, -0.06))

# ----------------------------------------------------
# Mean background adjustment to multiple rates.
out <- adjust_rate.ft(x = c(-0.98, -0.87, -0.91),
                      by = c(-0.04, -0.05, -0.06))
summary(out)

# ----------------------------------------------------
# Adjustment using calc_rate.ft objects
# Specimen rate
sp_rate <- flowthrough_mult.rd \%>\%
  inspect.ft(time = 1, out.oxy = 2, in.oxy = 6) \%>\%
  calc_rate.ft(from = 30, flowrate = 0.1)

# Background rate
bg_rate <- flowthrough_mult.rd \%>\%
  inspect.ft(time = 1, out.oxy = 5, in.oxy = 9) \%>\%
  calc_rate.ft(flowrate = 0.1)

# Perform adjustment
adj_rate <- adjust_rate.ft(sp_rate, by = bg_rate)
print(adj_rate)
summary(adj_rate)
# ----------------------------------------------------
}
