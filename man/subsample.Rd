% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/subsample.R
\name{subsample}
\alias{subsample}
\title{Subsample a data frame object}
\usage{
subsample(x, n = NULL, length.out = NULL, random_start = FALSE, plot = TRUE)
}
\arguments{
\item{x}{data frame or vector. The data to subsample.}

\item{n}{numeric. Subsample every \code{n} elements or rows.}

\item{length.out}{numeric. Subsample to a specific length or number of rows.}

\item{random_start}{logical. Defaults to FALSE. If TRUE, randomises the start
position from which to start the subsample (applies to \code{n} input only).}

\item{plot}{logical. Defaults to TRUE. Plots the data. If there are multiple
columns in the data frame, only the first two are plotted. Vectors are
plotted against a position index.}
}
\value{
Returns a subsampled data frame or vector object depending on input.
}
\description{
A simple function that subsamples a data frame or numeric vector in order to
"thin" large datasets.
}
\details{
Two subsampling methods are provided. The \code{n} input selects every n'th
element or row, or alternatively the \code{length.out} input uniformly subsamples
the data to the desired length.
\subsection{More}{

For additional help, documentation, vignettes, and more visit the \code{respR}
website at \url{https://januarharianto.github.io/respR/}
}
}
\examples{
# Subsample by every 200th row:
subsample(squid.rd, n = 200)

# Subsample to 100 rows:
subsample(sardine.rd, length.out = 100)

# Subsample with random starting position:
subsample(sardine.rd, n = 20, random_start = TRUE)

# Subsample a vector
subsample(sardine.rd[[2]], n = 20)
}
