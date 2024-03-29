% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/convert_rate.ft.R
\name{plot.convert_rate.ft}
\alias{plot.convert_rate.ft}
\title{Plot convert_rate.ft objects}
\usage{
\method{plot}{convert_rate.ft}(
  x,
  type = "full",
  pos = NULL,
  quiet = FALSE,
  highlight = NULL,
  legend = TRUE,
  rate.rev = TRUE,
  ...
)
}
\arguments{
\item{x}{convert_rate.ft object}

\item{type}{"full", "rate", or "overlap"}

\item{pos}{Which summary rows to plot?}

\item{quiet}{logical. Suppress console output.}

\item{highlight}{Which summary row result to highlight in overlap plots.}

\item{legend}{logical. Suppress labels and legends.}

\item{rate.rev}{logical. Control direction of y-axis in rate plot.}

\item{...}{Pass additional plotting parameters}
}
\value{
A plot. No returned value.
}
\description{
Plot convert_rate.ft objects
}
\keyword{internal}
