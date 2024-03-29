% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{background_con.rd}
\alias{background_con.rd}
\title{Background respirometry data (constant)}
\format{
A data frame object consisting of 20664 rows (approx 6 h of data),and
2 columns: \verb{$Time} in seconds, \verb{$Oxygen} in \% air saturation.
}
\usage{
background_con.rd
}
\description{
Background oxygen consumption data. After the initial 30 minutes, data shows
a generally constant background rate. Taken from a Loligo swim tunnel
background recording. Oxygen recorded via a Witrox sensor in \% air saturation
over nearly 6 hours at 1 second intervals. Data is from a real experiment.
}
\details{
\itemize{
\item Dissolved oxygen units: \verb{\% Air Saturation}
\item Time units: \code{seconds}
\item Swim tunnel volume (L): \code{12.3}
\item Temperature (°C): \code{14.5}
\item Salinity: \code{34}
\item Atm. Pressure (bar): \code{1.013253}
}
}
\author{
Nicholas Carey
}
\keyword{datasets}
