% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/auto_rate_funs.R
\name{time_roll}
\alias{time_roll}
\title{Perform time-width rolling regression}
\usage{
time_roll(dt, width, parallel = FALSE)
}
\arguments{
\item{width}{numeric. width in time}

\item{df}{data.frame object.}
}
\value{
a data.table object
}
\description{
This is an internal function. Used by \code{\link[=auto_rate]{auto_rate()}}.
}
\keyword{internal}
