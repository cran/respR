% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/auto_rate.int.R
\name{auto_rate.int}
\alias{auto_rate.int}
\title{Run auto_rate on multiple replicates in intermittent-flow respirometry data}
\usage{
auto_rate.int(
  x,
  starts = NULL,
  wait = NULL,
  measure = NULL,
  by = "row",
  method = "linear",
  width = NULL,
  n = 1,
  plot = TRUE,
  ...
)
}
\arguments{
\item{x}{object of class \code{inspect} or \code{data.frame}. This is the timeseries of
paired values of oxygen against time containing multiple replicates from
which to calculate rates.}

\item{starts}{Numeric. Row locations or times (in the units of the data in
\code{x}) of the start of each replicate. If a single value it indicates a
regular interval in rows or time starting from row 1. If a vector, each
entry is the start row or time of an individual replicate. Use of rows or
time is controlled via \code{by}.}

\item{wait}{Numeric. A row length or time duration to be applied at the start
of each replicate to \emph{exclude} these data from any rate calculations. Can
be a single value to apply the same wait phase to each replicate, or a
vector of the same length as \code{starts} of different wait phases for each
replicate. Optional.}

\item{measure}{Numeric. A row length or time duration to be applied at the
end of the \code{wait} phase (if used), and used to exclude the flush period.
This is the region within which the \code{auto_rate} analysis is conducted for
each replicate. Can be a single value to apply the same measure phase to
each replicate, or a vector of the same length as \code{starts} of different
measure phases for each replicate. Default is \code{NULL} in which case the
entire replicate is used (which is rarely what is wanted).}

\item{by}{String. \code{"row"} or \code{"time"}. Controls how \code{starts}, \code{wait} and
\code{measure} are applied. It also controls how the \code{width} is applied in the
\code{auto_rate} analysis - see \code{help("auto_rate")}. Default is \code{"row"}.}

\item{method}{string. The \code{auto_rate} \code{method} to use. Default is \code{"linear"}.
Others include \code{"lowest"} and \code{"highest"}. See \code{help("auto_rate")} for
descriptions and other methods.}

\item{width}{numeric. The \code{width} to use in the \code{auto_rate} analysis.
Mandatory and should be entered in the correct units of the \code{by} input. See
\code{help("auto_rate")} and vignettes on website for how width affects
analyses.}

\item{n}{integer. How many \code{auto_rate} results to return for each replicate.
Default is \code{1}.}

\item{plot}{logical. Default is \code{TRUE}. Plots the results. See 'Plotting'
section for details.}

\item{...}{Allows additional plotting controls to be passed, such as \code{type},
\code{pos}, \code{legend}, and \code{quiet}.}
}
\value{
Output is a \code{list} object of class \code{auto_rate.int} containing a
\code{auto_rate} object for each replicate in \verb{$results}. The output also
contains a \verb{$summary} table which includes the full rate regression results
from each replicate with replicate number indicated by the \verb{$rep} column.
Output also contains a \verb{$rate} element which contains the rate values from
each replicate in order. The function call, inputs, and other metadata are
also included. Note, that if you have many replicates this object can be
rather large (several MB).
}
\description{
\code{auto_rate.int} allows you to run the \code{auto_rate()} function on multiple
replicates in intermittent-flow respirometry. A \code{wait} and \code{measure} phase
can be specified for each replicate, and the \code{auto_rate} analysis is
performed within the \code{measure} region.
}
\details{
\code{auto_rate.int} uses the \code{starts} input to subset each replicate. The \code{wait}
and \code{measure} inputs control which parts of each replicate data are excluded
and included from the rate calculation. It runs \code{auto_rate} on the \code{measure}
phase in each replicate saving the top \code{n} ranked results and extracting the
rate and other data to a summary table.

The \code{x} input should be an\code{inspect} object. Alternatively, it can be a
two-column data frame containing paired values of time and oxygen from an
intermittent-flow experiment in columns 1 and 2 respectively (though we
always recommend processing such data in \code{inspect()} first). If a multiple
column dataset is entered as \code{x} the first two columns are selected by
default. If these are not the intended data use \code{inspect} to select the
correct time and oxygen columns.
\subsection{\code{auto_rate} inputs}{

You should be familiar with how \code{auto_rate} works before using this function.
See \code{help("auto_rate")} and vignettes on the website for full details.

The \code{auto_rate} inputs can be changed by entering different \code{method} and
\code{width} inputs. The \code{by} input controls how the \code{width} is applied. Note if
using a proportional \code{width} input (i.e. between 0 and 1 representing a
proportion of the data length) this applies to the length of the \code{measure}
phase of each particular replicate.

The \code{n} input controls how many \code{auto_rate} results from each replicate to
return in the output. By default this is only the top ranked result for the
particular \code{method}, i.e. \code{n = 1}. This can be changed to return more,
however consider carefully if this is necessary as the output will
necessarily contain many more rate results which may make it difficult to
explore and select results (although see \code{select_rate()}).
}

\subsection{Specifying replicate structure}{

The \code{starts} input specifies the locations of the start of each replicate in
the data in \code{x}. This can be in one of two ways:
\itemize{
\item A single numeric value specifying the number of rows in each replicate
starting from the data in the first row. This option should only be used when
replicates cycle at regular intervals. This can be a regular row or time
interval, as specified via the \code{by} input. If the first replicate does not
start at row 1, the data should be subset so that it does (see
\code{subset_data()}) and example
\href{https://januarharianto.github.io/respR/articles/intermittent_long.html}{here}.
For example, \verb{starts = 600, by = "row"} means the first replicate starts at
row 1 and ends at row 600, the second starts at row 601 ends at 1200, and so
on.
\item A numeric vector of row locations or times, as specified via the \code{by}
input, of the start of each individual replicate. The first replicate does
not have to start at the first row of the data, and all data after the last
entry is assumed to be part of the final replicate. Regular \code{R} syntax such
as \code{seq()}, \code{1:10}, etc. is also accepted, so can be used to specify both
regular and irregular replicate spacing.
}

For both methods it is assumed each replicate ends at the row preceding the
start of the next replicate, or in the case of the last replicate the final
row of the dataset. Also for both methods, \code{by = "time"} inputs do not need
to be exact; the closest matching values in the time data are used.

Results are presented in the \code{summary} table with \code{rep} and \code{rank} columns to
distinguish those from different replicates and their ranking within
replicates (if multiple results per replicate have been returned by
increasing the \code{n} input).
}

\subsection{Specifying rate region}{

The \code{wait} and \code{measure} inputs are used to specify the region from which to
extract a rate and exclude flush periods. They can be entered as row
intervals or time values in the units of the input data. The \code{wait} phase
controls the amount of data at the start of each replicate to be ignored,
that is excluded from any rate calculations. The \code{measure} phase determines
the region after this from which a rate is calculated. Unlike
\code{calc_rate.int()}, \code{auto_rate.int} will not necessarily use all of the data
in the \code{measure} phase, but will run the \code{auto_rate} analysis \emph{within} it
using the \code{method}, \code{width} and \code{by} inputs. This may result in rates of
various widths depending on the inputs. See \code{auto_rate()} for defaults and
full details of how selection inputs are applied.

There is no \code{flush} phase input since this is assumed to be from the end of
the \code{measure} phase to the end of the replicate.

Both \code{wait} and \code{measure} can be entered in one of two ways:
\itemize{
\item Single numeric values specifying a row width or a time period, as specified
via the \code{by} input. Use this if you want to use the \emph{same} \code{wait} and
\code{measure} phases in every replicate.
\item If \code{starts} is a vector of locations of the start of each replicate, these
inputs can also be vectors of equal length of row lengths or time periods as
specified via the \code{by} input. This is only useful if you want to use
\emph{different} \code{wait} and/or \code{measure} phases in different replicates.
}

If \code{wait = NULL} no wait phase is applied. If \code{measure = NULL} the data used
for analysis is from the start of the replicate or end of the \code{wait} phase to
the last row of the replicate. This will typically include the flush period,
so is rarely what you would want.
}

\subsection{Example}{

See examples below for actual code, but here is a simple example. An
experiment comprises replicates which cycle at ten minute intervals with data
recorded every second. Therefore each replicate will be 600 rows long.
Flushes of the respirometer take 3 minutes at the end of each replicate. We
want to exclude the first 2 minutes (120 rows) of data in each, and run an
\code{auto_rate} analysis to get an oxygen uptake rate within the following five
minute period (300 rows), leaving the three minutes of flushing (180 rows)
excluded. The inputs for this would be:

\verb{starts = 600, wait = 120, measure = 300, by = "row"}
}

\subsection{Plot}{

If \code{plot = TRUE} (the default), the result for each rate is plotted on a grid
up to a maximum of 20. There are three ways of plotting the results, which
can be selected using the \code{type} input:
\itemize{
\item \code{type = "rep"}: The default. Each individual replicate is plotted with the
rate region highlighted in yellow. The \code{wait} and \code{measure} phases are also
highlighted as shaded red and green regions respectively. These are also
labelled if \code{legend = TRUE}.
\item \code{type = "full"}: Each replicate rate is highlighted in the context of the
whole dataset. May be quite difficult to interpret if dataset is large.
\item \code{type = "ar"}: Plots individual replicate results as \code{auto_rate} objects.
Note, these will only show the \code{measure} phase of the data.
}

For all plot types \code{pos} can be used to select which rate(s) to plot (default
is 1:20), where \code{pos} indicates rows of the \verb{$summary} table (and hence which
\verb{$rep} and \verb{$rank}). This can be passed either in the main function call or
when calling \code{plot()} on output objects. Note for all plot types if \code{n} has
been changed to return more than one rate per replicate these will also be
plotted.
}

\subsection{S3 Generic Functions}{

Saved output objects can be used in the generic S3 functions \code{plot()},
\code{print()}, \code{summary()}, and \code{mean()}. For all of these \code{pos} selects rows of
the \verb{$summary} table.
\itemize{
\item \code{plot()}: plots the result. See Plot section above.
\item \code{print()}: prints the result of a single rate, by default the first. Others
can be printed by passing the \code{pos} input. e.g. \code{print(x, pos = 2)}
\item \code{summary()}: prints summary table of all results and metadata, or the rows
specified by the \code{pos} input. e.g. \code{summary(x, pos = 1:5)}. The \verb{$rep} column
indicates the replicate number, and \verb{$rank} column the ranking of each rate
\emph{within} each replicate (only used if a different \code{n} has been passed,
otherwise they are all \code{1}). The summary table (or \code{pos} rows) can be
exported as a separate data frame by passing \code{export = TRUE}.
\item \code{mean()}: calculates the mean of the rates from every row or those
specified by the \code{pos} input. e.g. \code{mean(x, pos = 1:5)} Note if a different
\code{n} has been passed this may include multiple rates from each replicate. The
mean can be exported as a numeric value by passing \code{export = TRUE}.
}
}

\subsection{More}{

For additional help, documentation, vignettes, and more visit the \code{respR}
website at \url{https://januarharianto.github.io/respR/}
}
}
\examples{
\donttest{
# Irregular replicate structure ------------------------------------------

# Prepare the data to use in examples
# Note in this dataset each replicate is a different length!
data <- intermittent.rd
# Convert time to minutes (to show different options below)
data[[1]] <- round(data[[1]]/60, 2)
# Inspect
urch_insp <- inspect(data)

# Calculate the most linear rate within each replicate
auto_rate.int(urch_insp,
              starts = c(1, 2101, 3901),
              by = "row",
              method = "linear",
              width = 400) \%>\%
  summary()

# Calculate the lowest rate within each replicate across
# 5 minutes (300 rows). For this we need to specify a 'measure' phase
# so that the flush is excluded.
auto_rate.int(urch_insp,
              starts = c(1, 2101, 3901),
              measure = 1000,
              by = "row",
              method = "lowest",
              width = 300) \%>\%
  summary()

# You can even specify different 'measure' phases in each rep
auto_rate.int(urch_insp,
              starts = c(1, 2101, 3901),
              measure = c(1000, 800, 600),
              by = "row",
              method = "lowest",
              width = 300) \%>\%
  summary()

# We usually don't want to use the start of a replicate just after the flush,
# so we can specify a 'wait' phase. We can also specify 'starts', 'wait',
# 'measure', and 'width' in units of time instead of rows.
#
# By time
# (this time we save the result)
urch_res <- auto_rate.int(urch_insp,
                          starts = c(0, 35, 65), # start locations in minutes
                          wait = 2,              # wait for 2 mins
                          measure = 10,          # measure phase of 10 mins
                          by = "time",           # apply inputs by time values
                          method = "lowest",     # get the 'lowest' rate...
                          width = 5) \%>\%          #  ... of 5 minutes width
  summary()

# Regular replicate structure --------------------------------------------

# If replicates cycle at regular intervals, 'starts' can be used to specify
# the spacing in rows or time, starting at row 1. Therefore data must be
# subset first so that the first replicate starts at row 1.
#
# Subset and inspect data
zeb_insp <- zeb_intermittent.rd \%>\%
  subset_data(from = 5840,
              to = 75139,
              by = "row",
              quiet = TRUE) \%>\%
  inspect()

# Calculate the most linear rate from the same 6-minute region in every
# replicate. Replicates cycle at every 660 rows.
zeb_res <- auto_rate.int(zeb_insp,
                         starts = 660,
                         wait = 120, # exclude first 2 mins
                         measure = 360, # measure period of 6 mins after 'wait'
                         method = "linear",
                         width = 200, # starting value for linear analysis
                         plot = TRUE) \%>\%
  summary()

# S3 functions ------------------------------------------------------------

# Outputs can be used in print(), summary(), and mean().
# 'pos' can be used to select replicate ranges
summary(zeb_res)
mean(zeb_res, pos = 1:5)

# There are three ways by which the results can be plotted.
# 'pos' can be used to select replicates to be plotted.
#
# type = "rep" - the default. Each replicate plotted on a grid with rate
# region highlighted (up to a maximum of 20).
plot(urch_res)

# type = "full" - each replicate rate region plotted on entire data series.
plot(urch_res, pos = 1:2, type = "full")
# Of limited utility when datset is large
plot(zeb_res, pos = 10, type = "full")

# type = "ar" - the 'auto_rate' object for selected replicates in 'pos' is plotted
# Note this shows the 'measure' phase only
plot(urch_res, pos = 2, type = "ar")

# See vignettes on website for how to adjust and convert rates from auto_rate.int
}
}
