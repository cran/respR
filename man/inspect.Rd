% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/inspect.R
\name{inspect}
\alias{inspect}
\title{Explore and visualise respirometry data and check for common errors}
\usage{
inspect(
  x,
  time = NULL,
  oxygen = NULL,
  width = 0.1,
  plot = TRUE,
  add.data = NULL,
  ...
)
}
\arguments{
\item{x}{data.frame. Any object of class \code{data.frame} (incl. \code{data.table},
\code{tibble}, etc.). Should contain paired numeric values of time and oxygen.}

\item{time}{integer or string. Defaults to \code{1}. Specifies the column of the
Time data as either a column number or the name.}

\item{oxygen}{integer or string, or vector of either. Defaults to \code{2}.
Specifies the column(s) of the Oxygen data as either a vector of column
numbers or names.}

\item{width}{numeric, 0.01 to 1. Defaults to \code{0.1}. Width used in the rolling
regression plot as proportion of total length of data.}

\item{plot}{logical. Defaults to \code{TRUE}. Plots the data. If \code{time} and single
\code{oxygen} columns selected, plots timeseries data, plus plot of rolling
rate. If multiple \code{oxygen} columns, plots all timeseries data only.}

\item{add.data}{integer or string. Defaults to \code{NULL}. Specifies the column
number or name of an optional additional data source that will be plotted
in blue alongside the full oxygen timeseries.}

\item{...}{Allows additional plotting controls to be passed, such as \code{legend = FALSE}, \code{quiet = TRUE}, \code{rate.rev = FALSE} and \code{pos}. A different \code{width}
can also be passed in \code{plot()} commands on output objects.}
}
\value{
Output is a \code{list} object of class \code{inspect}, with a \verb{$dataframe}
containing the specified \code{time} and \code{oxygen} columns, inputs, and metadata
which can be passed to \code{\link[=calc_rate]{calc_rate()}} or \code{\link[=auto_rate]{auto_rate()}} to determine
rates. If there are failed checks or warnings, the row locations of the
potentially problematic data can be found in \verb{$locs}.
}
\description{
\code{inspect()} is a data exploration and preparation function that visualises
respirometry data and checks it for errors that may affect the use of further
functions in \code{respR}. It also subsets specified columns into a new \code{list}
object that can be used in subsequent functions, reducing the need for
additional inputs. Note, use of \code{inspect} to prepare data for the subsequent
functions is optional. Functions in \code{respR} can accept regular \code{R} data
objects including data frames, data tables, tibbles, vectors, etc. It is a
quality control and exploratory step to help users view and prepare their
data prior to analysis.
}
\details{
Given an input data frame, \code{x}, the function scans the specified \code{time} and
\code{oxygen} columns for the following issues. Columns are specified by using the
column number (e.g. \code{time = 1}), or by name (e.g. \code{time = "Time.Hrs"}). If
\code{time} and \code{oxygen} are left \code{NULL} the default of \verb{time = 1, oxygen = 2} is
applied.
\subsection{Check for numeric data}{

\code{respR} requires data be in the form of paired values of numeric time and
oxygen. All columns are checked that they contain numeric data before any
other checks are performed. If any of the inspected columns do not contain
numeric data the remaining checks for that column are skipped, and the
function exits returning \code{NULL}, printing the summary of the checks. No plot
is produced. Only when all inspected columns pass this numeric check can the
resulting output object be saved and passed to other \code{respR} functions.
}

\subsection{Other checks}{

The \code{time} column is checked for missing (\code{NA/NaN}) values, positive and
negative infinite values (\code{Inf/-Inf}), that values are sequential, that there
are no duplicate times, and that it is numerically evenly-spaced. Oxygen
columns are checked for missing (\code{NA/NaN}) and infinite values (\code{Inf/-Inf}).
See \strong{Failed Checks} section for what it means for analyses if these checks
result in warnings. If the output is assigned, the specified \code{time} and
\code{oxygen} columns are extracted and saved to a \code{list} object for use in later
functions such as \code{\link[=calc_rate]{calc_rate()}} and \code{\link[=auto_rate]{auto_rate()}}. A plot is also
produced.
}

\subsection{Plot}{

If \code{plot = TRUE} (the default), a plot of the oxygen timeseries is produced
in the upper panel. In addition, a rolling regression plot in the lower panel
shows the rate of change in oxygen across a rolling window specified using
the \code{width} operator (default is \code{width = 0.1}, or 10\% of the entire
dataset). This plot provides a quick visual inspection of how the rate varies
over the course of the experiment. Regions of stable and consistent rates can
be identified on this plot as flat or level areas. This plot is for
exploratory purposes only; later functions allow rate to be calculated over
specific regions. Each individual rate value is plotted against the centre of
the time window used to calculate it.

\emph{\strong{Note:}} Since \code{respR} is primarily used to examine oxygen consumption,
the oxygen rate plot is by default plotted on a reverse y-axis. In \code{respR}
oxygen uptake rates are negative since they represent a negative slope of
oxygen against time. In these plots the axis is reversed so that higher
uptake rates (i.e. more negative) will be higher on these plots. If you are
interested instead in oxygen production rates, which are positive, the
\code{rate.rev = FALSE} input can be passed in either the \code{inspect} call, or when
using \code{plot()} on the output object. In this case, the rate values will be
plotted numerically, and higher oxygen \emph{production} rates will be higher on
the plot.
}

\subsection{Plot an additional data source}{

Using the \code{add.data} input an additional data source, for example
temperature, can be plotted alongside the oxygen timeseries. This should be
either a column number (e.g. \code{add.data = 3}) or name (e.g. \code{add.data = "Temperature"}) indicating a column in the input \code{x} data frame sharing the
same time data. None of the data checks are performed on this column; it is
simply to give a basic visual aid in the plot to, for example, help decide if
regions of the data should be used or not used because this parameter was
variable. Values are saved in the output as a vector under \verb{$add.data}. It is
plotted in blue on a separate y-axis on the main timeseries plot. It is \emph{not}
plotted if multiple oxygen columns are inspected. See examples.
}

\subsection{Additional plotting options}{

A different \code{width} value can be passed to see how it affects estimation of
the rolling rate. If axis labels obscure parts of the plot they can be
suppressed using \code{legend = FALSE}. Suppress console output messages with
\code{quiet = TRUE}. If multiple columns have been inspected, the \code{pos} input can
be used to examine each time~oxygen dataset. If axis labels (particularly
y-axis) are difficult to read, \code{las = 2} can be passed to make axis labels
horizontal, and  \code{oma} (outer margins, default \code{oma = c(0.4, 1, 1.5, 0.4)})
or \code{mai} (inner margins, default \code{mai = c(0.3, 0.15, 0.35, 0.15)}) can be
used to adjust plot margins. See examples.
}

\subsection{Multiple Columns of Oxygen Data}{

For a quick overview of larger datasets, multiple oxygen columns can be
inspected for errors and plotted by using the \code{oxygen} input to select
multiple columns. These must share the same \code{time} column. In this case, data
checks are performed, with a plot of each oxygen time series, but no rolling
rate plot is produced. All data are plotted on the same axis range of both
time and oxygen (total range of data). This is chiefly exploratory
functionality to allow for a quick overview of a dataset, and it should be
noted that while the output \code{inspect} object will contain all columns in its
\verb{$dataframe} element, subsequent functions in \code{respR} (\code{calc_rate},
\code{auto_rate}, etc.) will by default only use the first two columns (\code{time},
and the first specified \code{oxygen} column). To analyse multiple columns and
determine rates, best practice is to inspect and assign each time-oxygen
column pair as separate \code{inspect} objects. See Examples.
}

\subsection{Flowthrough Respirometry Data}{

For flowthrough respirometry data, see the specialised \code{\link[=inspect.ft]{inspect.ft()}}
function.
}

\subsection{Failed Checks}{

The most important data check in \code{inspect} is that all data columns are
numeric. If any column fails this check, the function skips the remaining
checks for that column, the function exits returning \code{NULL}, and no output
object or plot is produced.

The other failed check that requires action is the check for infinite values
(\code{Inf/-Inf}). Some oxygen sensing systems add these in error when
interference or data dropouts occur. Infinite values will cause problems when
it comes to calculating rates, so need to be removed. If found, locations of
these are printed and can be found in the output object under \verb{$locs}. Note,
these values are not plotted, so special note should be taken of the warnings
and console printout.

The remaining data checks in \code{inspect} are mainly exploratory and help
diagnose and flag potential issues with the data that might affect rate
calculations. For instance, long experiments may have had sensor dropouts the
user is unaware of. Some might not be major issues. For instance, an uneven
time warning can result from using decimalised minutes, which is a completely
valid time metric, but happens to be numerically unevenly spaced. As an
additional check, if uneven time is found, the minimum and maximum intervals
in the time data are in the console output, so a user can see immediately if
there are large gaps in the data.

If some of these checks produce warnings, it should \emph{generally} not hinder
analysis of the data. \code{respR} has been coded to rely on linear regressions on
exact data values, and not make assumptions about data spacing or order.
Therefore issues such as missing or NA/NaN values, duplicate or
non-sequential time values, or uneven time spacing should not cause any
erroneous rate results, as long as they do not occur over large regions of
the data. \code{inspect} however outputs locations (row numbers) of where these
issues occur (located in the \verb{$locs} element of the output), allowing users
to amend them before analysis. We would strongly recommend that to be
completely confident in any results from analysis of such data, and avoid
obscure errors, these issues be addressed before proceeding.
}

\subsection{S3 Generic Functions}{

Saved output objects can be used in the generic S3 functions \code{plot()},
\code{print()} and \code{summary()}.
\itemize{
\item \code{plot()}: plots the result.
\item \code{print()}: prints a summary of the checks performed on the data. If issues
are found, locations (row numbers) are printed (up to first 20 occurrences).
\item \code{summary()}: simple wrapper for \code{print()} function. See above.
}
}

\subsection{More}{

For additional help, documentation, vignettes, and more visit the \code{respR}
website at \url{https://januarharianto.github.io/respR/}
}
}
\examples{
\donttest{
## By default, assumes time is col 1 and oxygen col2:
inspect(sardine.rd)

## Instead, specify time and oxygen columns as either number or name
inspect(sardine.rd, time = 1, oxygen = 2)
inspect(urchins.rd, time = "time.min", oxygen = "a")

## Use add.data input to plot an additional data type
## (this column is not checked)
inspect(sardine.rd, time = 1, oxygen = 2, add.data = 3)

## Adjust the width of the rolling rate plot:
inspect(sardine.rd, 1, 2, width = 0.2)

## Inspect specific columns in multicolumn datasets:
inspect(urchins.rd, time = 1, oxygen = 4)

## Inspect multiple columns for a quick overview
## of a large dataset:
inspect(urchins.rd, time = 1, oxygen = c(11:19))

## Inspect oxygen production data, use a width that gives
## a better rolling rate, and use extra plotting options to
## suppress legend, and ensure rates are plotted not reversed:
inspect(algae.rd, time = 1, oxygen = 2, width = 0.4,
        legend = FALSE, rate.rev = FALSE)

## Pass additional plotting inputs to override defaults and
## allow better y-axis label visibility
inspect(sardine.rd, time = 1, oxygen = 2,
        las = 1, mai = c(0.3, 0.35, 0.35, 0.15))
}
}
