% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/subset_rate.R
\name{subset_rate}
\alias{subset_rate}
\title{Subset auto_rate results based on a range of criteria}
\usage{
subset_rate(x, method = NULL, n = NULL, plot = FALSE)
}
\arguments{
\item{x}{list. An object of class \code{auto_rate} or \code{auto_rate_subset}.}

\item{method}{string. Method by which to subset rate results. Matching
results are \emph{retained} in the output. See Details.}

\item{n}{numeric. Number, percentile, or range of results to return depending
on \code{method}. See Details.}

\item{plot}{logical. Default FALSE. Plots a summary of subset locations
within data (up to a maximum of the first 20 ranked results).}
}
\value{
The output of \code{subset_rate} is a \code{list} object which retains the
\code{auto_rate} class, with an additional \code{auto_rate_subset} class applied.

It contains two additional elements: \verb{$original} contains the original,
unaltered \code{auto_rate} object, which will be retained unaltered through
multiple subsetting operations, that is even after processing through the
function multiple times. \verb{$subset_calls} contains the calls for every
subsetting operation that has been applied to the \verb{$original} object, from
the first to the most recent. If using piping (\verb{\%>\%} or \verb{|>}), the \code{x}
input in these appears as \code{"x = ."} where it has been piped from the
previous call. These additional elements ensure the output contains the
complete, reproducible history of the \code{auto_rate} object having been
subset.

The \verb{$summary} table contains a \verb{$rank} column and the \emph{original} rank of
each result is retained. A \verb{$subset_regs} value is added to \verb{$metadata}
indicating the number of regressions remaining after subsetting.
}
\description{
The \code{auto_rate} function is powerful, but the output can be
large and difficult to explore, especially when there are hundreds to
thousands of results. In addition, the \code{"linear"} method may identify
linear regions, but from areas of the data that are not of experimental
interest. As an advanced, machine learning based process, it can be
somewhat fallible and on occasion may return questionable results.

The \code{subset_rate} function helps explore, reorder, and filter \code{auto_rate}
results according to various criteria. For example, extracting only
positive or negative rates, only the highest or lowest rates, only those
from certain data regions, and numerous other methods that allow advanced
filtering of results so the rates extracted are well-defined towards the
research question of interest. This also allows for highly consistent
reporting of results and rate selection criteria.

Multiple subsetting criteria can be applied by assigning the output and
processing it through the function multiple times using different methods,
or alternatively via \verb{\%>\%} piping. See Examples.

\emph{Note:} when choosing a \code{method}, keep in mind that to remain
mathematically consistent, \code{respR} outputs oxygen consumption (i.e.
respiration) rates as negative values. This is particularly important in
the difference between \code{highest/lowest} and \code{minimum/maximum} methods. See
Details.

When a rate result is omitted by the subsetting criteria, it is removed
from the \verb{$rate} element of the \code{auto_rate} object, and all associated data
in \verb{$summary} (i.e. the associated row) is removed. Some methods can be
used with an \code{n = NULL} input to reorder the \verb{$rate} and \verb{$summary}
elements in various ways. See Examples.

Generally speaking, for most large datasets we recommend using
\code{\link[=subset_data]{subset_data()}} and then running \code{auto_rate} on the subset(s) of the data
you are interested in, rather than run it on the whole dataset and relying
on \code{subset_rate} to filter out results afterwards.
}
\details{
These are the current methods by which rates in \code{auto_rate} objects
can be subset. Matching results are \emph{retained} in the output. Some methods
can also be used to reorder the results.
\subsection{\code{positive}, \code{negative}}{

Subsets all \code{positive} (>0) or \code{negative} (<0) rates. \code{n} is ignored.
Useful, for example, in intermittent respirometry where \code{auto_rate} may
output rates from regions of oxygen increase during flushes. Note, \code{respR}
outputs oxygen consumption (i.e. respiration) rates as \emph{negative} values,
production rates as \emph{positive}.
}

\subsection{\code{nonzero}, \code{zero}}{

Retains all \code{nonzero} rates (i.e. removes any zero rates), or retains
\emph{only} \code{zero} rates (i.e. removes all rates with any value). \code{n} is
ignored.
}

\subsection{\code{lowest}, \code{highest}}{

These methods can only be used when rates all have the same sign, that is
are all negative or all positive. These subset the highest and lowest
\emph{\strong{absolute}} rate values. For example, if rates are all negative, \code{method = 'highest'} will retain the highest magnitude rates regardless of the
sign. \code{n} should be an integer indicating the number of lowest/highest
rates to retain. If \code{n = NULL} the results will instead be reordered by
lowest or highest rate without any removed. See \code{minimum} and \code{maximum}
options for extracting \emph{numerically} lowest and highest rates.
}

\subsection{\code{lowest_percentile}, \code{highest_percentile}}{

These methods can also only be used when rates all have the same sign.
These retain the \code{n}'th lowest or highest percentile of \emph{\strong{absolute}} rate
values. For example, if rates are all negative \code{method = 'highest_percentile'} will retain the highest magnitude \code{n}'th percentile
regardless of the sign. \code{n} should be a percentile value between 0 and 1.
For example, to extract the lowest 10th percentile of absolute rate values,
you would enter \verb{method = 'lowest_percentile', n = 0.1}.
}

\subsection{\code{minimum}, \code{maximum}}{

In contrast to \code{lowest} and \code{highest}, these are \emph{strictly numerical}
options which take full account of the sign of the rate, and can be used
where rates are a mix of positive and negative. For example, \code{method = 'minimum'} will retain the minimum value numerical rates, which in the case
of negative rates will actually be the highest uptake rates. \code{n} is an
integer indicating how many of the min/max rates to retain. If \code{n = NULL}
the results will instead be reordered by minimum or maximum rate without
any removed.
}

\subsection{\code{minimum_percentile}, \code{maximum_percentile}}{

Like \code{min} and \code{max} these are \emph{strictly numerical} inputs which retain the
\code{n}'th minimum or maximum percentile of the rates and take full account of
the sign. Here \code{n} should be a percentile value between 0 and 1. For
example, if rates are all negative (i.e. typical uptake rates), to extract
the lowest 10th percentile of rates, you would enter \verb{method = 'maximum_percentile', n = 0.1}. This is because the \emph{lowest} negative rates
are numerically the \emph{maximum} rates (\code{highest/lowest} percentile methods
would be a better option in this case however).
}

\subsection{\code{rate}, \code{rsq}, \code{rank}, \code{row}, \code{time}, \code{density}}{

These methods refer to the respective columns of the \verb{$summary} data frame.
For these, \code{n} should be a vector of two values. Matching regressions in
which the respective parameter falls within the \code{n} range (inclusive) are
retained. For example, to retain only rates where the \code{rate} value is
between 0.05 and 0.08: \verb{method = 'rate', n = c(0.05, 0.08)}. To retain all
rates with a R-Squared 0.90 or above: \verb{method = 'rsq', n = c(0.9, 1)}. The
\code{row} and \code{time} ranges refer to the \verb{$row}-\verb{$endrow} or \verb{$time}-\verb{$endtime}
columns and the original raw data (\verb{$dataframe} element of the input), and
can be used to constrain results to rates from particular regions of the
data (although usually a better option is to \code{\link{subset_data}}
prior to analysis). \code{rank} refers to the first column of the summary table,
which denotes the rank or ordering of the results as determined by the
selected \code{method} input in the original \code{auto_rate} analysis. This \code{rank}
value is retained unchanged regardless of how the results are subsequently
subset or reordered. Note, \code{time} is not the same as \code{duration} - see later
section - and \code{row} does not refer to rows of the summary table - see
\code{manual} method for this. For all of these methods (except \code{rate}), if \code{n = NULL} the results will instead be reordered by that respective column with
none removed.
}

\subsection{\code{time_omit}, \code{row_omit}}{

These methods refer to the original data, and are intended to \emph{exclude}
rates determined over particular data regions. This is useful in the case
of, for example, a data anomaly such as a spike or sensor dropout. For
these inputs, \code{n} are values (a single value or multiple) indicating data
timepoints or rows of the original data to exclude. Only rates (i.e.
regressions) which \emph{do not} utilise those particular values are retained in
the output. For example, if an anomaly occurs precisely at timepoint 3000,
\code{time_omit = 3000} means only rates determined solely over regions before
and after this will be retained. If it occurs over a range this can be
entered as, \code{time_omit = c(3000:3200)}. If you want to exclude a regular
occurrence, for example the flushes in intermittent-flow respirometry they
can be entered as a vector, e.g. \code{row_omit = c(1000, 2000, 3000)}. Values
must match exactly to a value present in the dataset.
}

\subsection{\code{oxygen}}{

This can be used to constrain rate results to regions of the data based on
oxygen values. \code{n} should be a vector of two values in the units of oxygen
in the raw data. Only rate regressions in which all datapoints occur within
this range (inclusive) are retained. Any which use even a single value
outside of this range are excluded. Note the summary table columns \code{oxy}
and \code{endoxy} refer to the first and last oxygen values in the rate
regression, which should broadly indicate which results will be removed or
retained, but this method examines \emph{every} oxygen value in the regression,
not just first and last.
}

\subsection{\code{oxygen_omit}}{

Similar to \code{time_omit} and \code{row_omit} above, this can be used to \emph{omit}
rate regressions which use particular oxygen values. For this \code{n} are
values (single or multiple) indicating oxygen values in the original raw
data to exclude. Every oxygen value used by each regression is checked, and
to be excluded an \code{n} value must match \emph{exactly} to one in the data.
Therefore, note that if a regression is fit across the data region where
that value would occur, it is not necessarily excluded unless that \emph{exact
value} occurs. You need to consider the precision of the data values
recorded. For example, if you wanted to exclude any rate using an oxygen
value of \code{7.0}, but your data are recorded to two decimals, any rates fit
across these data would be retained: \code{c(7.03, 7.02, 7.01, 6.99, 6.98, ...)}. To get around this you can use regular R syntax to input vectors at
the correct precision, such as seq, e.g. \code{seq(from = 7.05, to = 6.96, by = -0.01)}. Similarly, this can be used to input ranges of oxygen values to
exclude.
}

\subsection{\code{duration}}{

This method allows subsetting of rates which occur within a duration range.
Here, \code{n} should be a numeric vector of two values indicating the duration
range you are interested in retaining. Use this to set minimum and maximum
durations in the time units of the original data. For example, \code{n = c(0,500)} will retain only rates determined over a maximum of 500 time
units. To retain rates over a minimum duration, set this using the minimum
value plus the maximum duration (or simply infinity, e.g. \code{n = c(500,Inf)}).
}

\subsection{\code{manual}}{

This method simply allows particular rows of the \verb{$summary} data frame to
be manually selected to be retained. For example, to keep only the top row
(usually the top ranked result according to the \code{method}, but note some
methods can be used to reorder the table): \verb{method = 'manual', n = 1}. To
keep multiple rows use regular \code{R} selection syntax: \code{n = 1:3}, \code{n = c(1,2,3)}, \code{n = c(5,8,10)}, etc. No value of \code{n} should exceed the number
of rows in the \verb{$summary} data frame.
}

\subsection{\code{overlap}}{

This method removes rates which overlap, that is, linear regions or
regressions calculated by \code{auto_rate} which partly or completely share the
same rows of the original data. The \code{auto_rate} \code{linear} method may
identify multiple linear regions, some of which may substantially overlap,
or even be completely contained within others. In such cases summary
operations such as taking an average of the rate values may be
questionable, as certain values will be weighted higher due to these
multiple, overlapping results. This method removes overlapping rates, using
\code{n} as a threshold to determine degree of permitted overlap. It is
recommended this method be used after other selection criteria have been
applied, as it is quite aggressive about removing rates, and can be \emph{very}
computationally intensive when there are many results.

While it can be used with \code{auto_rate} results determined via the \code{rolling},
\code{lowest}, or \code{highest} methods, by their nature these methods produce \emph{all
possible} overlapping regressions, ordered in various ways, so other
subsetting methods are more appropriate. The \code{overlap} method is generally
intended to be used in combination with the \code{auto_rate} \code{linear} results,
but may prove useful in other analyses.

The \code{\link[=plot_ar]{plot_ar()}} function is very useful for plotting \code{auto_rate} objects,
and the results of \code{subset_rate} operations upon them, to visualise where
regression results in the summary table occur in relation to the original
dataset. See Examples.

Permitted overlap is determined by \code{n}, which indicates the proportion of
each particular regression which must overlap with another for it to be
regarded as overlapping. For example, \code{n = 0.2} means a regression would
have to overlap with at least one other by at least 20\% of its total length
to be regarded as overlapping.

The \code{overlap} method performs two operations:

First, regardless of the \code{n} value, any rate regressions which are
completely contained within another are removed (this is also the only
operation if \code{n = 1}).

Secondly, for each regression in \verb{$summary} starting from the bottom of the
summary table (usually the lowest ranked result, but this depends on the
\code{auto_rate} analysis method used and if any reordering has been performed),
the function checks if it overlaps with any others (accounting for \code{n}). If
not, the next lowest is checked, and the function progresses up the summary
table until it finds one that does. The first to be found overlapping is
then removed, and the process repeats starting again from the bottom of the
summary table. This means lower ranked results are removed first. This is
repeated iteratively until only non-overlapping rates (accounting for \code{n})
remain.

If \code{n = 0}, only rates which do not overlap at all, that is share \emph{no}
data, are retained. If \code{n = 1}, only rates which are 100\% contained within
at least one other are removed.
}

\subsection{Reordering results}{

Several methods can be used to \emph{reorder} results rather than subset them,
by not entering an \code{n} input (that is, letting the \code{n = NULL} default be
applied). Several of these methods are named the same as those in
\code{auto_rate} and have equivalent outcomes, so this allows results to be
reordered without re-running the analysis.

The \code{row} and \code{rolling} methods reorder sequentially by the starting row of
each regression (\verb{$row} column).

The \code{time} method reorders sequentially by the starting time of each
regression (\verb{$time} column).

\code{linear} and \code{density} are essentially identical, reordering by the
\verb{$density} column. This metric is only produced by the \code{auto_rate} \code{linear}
method. These will have no effect on results originating from other
\code{auto_rate} methods where the density column is all \code{NA}.

\code{rank} reorders by \verb{$rank}, the first column of the summary table, which
denotes the rank or position of each result as determined by the selected
\code{method} in the original \code{auto_rate} analysis. This \code{rank} value is
retained unchanged regardless of how the results are subsequently subset or
reordered. Essentially this method will restore the original \code{auto_rate}
method ordering after other reordering methods have been applied.

\code{rsq} reorders by \verb{$rsq} from highest value to lowest.

\code{highest} and \code{lowest} reorder by absolute values of the \verb{$rate} column,
that is highest or lowest in magnitude regardless of the sign. They can
only be used when rates all have the same sign.

\code{maximum} and \code{minimum} reorder by numerical values of the \verb{$rate} column,
that is maximum or minimum in numerical value taking account of the sign,
and can be used when rates are a mix of negative and positive.

Note that after reordering, outputs of \code{print()}, \code{summary()}, \code{plot()}
etc. will still refer to the \emph{original} ordering or analysis method used in
the \code{auto_rate} analysis (the \verb{$method} element of the \code{auto_rate} object).
}

\subsection{Plot}{

While output objects are plotted as normal \code{auto_rate} objects if used in
\code{plot()}, \code{subset_rate} has its own plotting functionality. This simply
plots a grid of the remaining rates in \verb{$summary} up to the first 20. This
is simple functionality to give the user an idea of how subsetting is
reducing the number of rates, and where the remaining rates occur within
the data. It is really only useful once rates are down to fewer than 20
remaining, or for examining the effects of different subsetting options on
a small selection of rates. Therefore, the default is \code{plot = FALSE} to
prevent this being produced for every single subsetting operation.
}

\subsection{More}{

This help file can be found online
\href{https://januarharianto.github.io/respR/reference/subset_rate.html}{here},
where it is much easier to read.

For additional help, documentation, vignettes, and more visit the \code{respR}
website at \url{https://januarharianto.github.io/respR/}
}
}
\examples{
## Subset only negative rates
 ar_obj <- inspect(intermittent.rd, plot = FALSE) \%>\%
   auto_rate(plot = FALSE)
 ar_subs_neg <- subset_rate(ar_obj, method = "negative", plot = FALSE)
}
