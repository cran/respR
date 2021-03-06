# This file contains functions used to plot all the figures in the package. We
# have grouped all of these together so that we can edit the functions easily.
# They are not to be used on their own, and will not be exported for use in the
# package.

# We have also deliberately decided to use base graphics, as ggplot2 was too
# slow when plotting large datasets. Unless ggplot2 improves, we will probably
# not switch to it.


# Plotting defaults -------------------------------------------------------

# define colours
r1 <- adjustcolor("black", alpha.f = .9)  # primary colour
r2 <- adjustcolor("goldenrod1", alpha.f = 1)  # secondary colour
r3 <- adjustcolor("darkgrey", alpha.f = .2)  # plot background colour
d1 <- adjustcolor("tomato", alpha.f = .75)
d2 <- adjustcolor("darkslateblue", alpha.f = .75)
# colours for flowthrough plots
ftcol_in <- adjustcolor("turquoise", alpha.f = 1) # inflow oxy
ftcol_out <- adjustcolor("lightgreen", alpha.f = 1) # outflow oxy
ftcol_del <- adjustcolor("black", alpha.f = 0.9) # delta oxy
ftcol_rate_pt <- adjustcolor("goldenrod1", alpha.f = 1) # highlighted rate points
ftcol_rate_bx <- adjustcolor("goldenrod1",  alpha.f = 0.2) # highlighted rate region box bg
ftcol_rate_ln <- adjustcolor("goldenrod1",  alpha.f = 0.25) # highlighted rate region line

# panel <- c(rect(par("usr")[1], par("usr")[3], par("usr")[2],
#   par("usr")[4], col = r3), grid(col = "white", lty = 1, lwd = 1.5))

# default plotting character
pch_def <- 16

# not used very much....
cex_def <- 0.5

# default tick size
tck_def <- -0.015 # size of axis ticks

# default axis distances
# 1 = distance of axis label from axis
# 2 = distance of tick labels from ticks
# 3 = distance of ticks from axis
mgp_def <- c(0, 0.2, 0)

# default margins
# outer
oma_def <- c(0.4, 1, 1.5, 0.4)
# inner
mai_def <- c(0.3, 0.15, 0.35, 0.15)
# To give slightly more space for plots without two titles
# currently applied in:
#   - inspect
#   - inspect.ft
#   - calc_rate.ft
mai_def_top_ext <- c(0.3, 0.15, 0.2, 0.15)


# default axis rotation
las_def <- 0


# Plotting functions ------------------------------------------------------

# axes = which axes to draw
# mgp_bt etc = separate mgp for axes if needed
multi.p <- function(df, sdf, rsq, title = TRUE, xl = '', yl = '',
                    axes = c(1,2,3), legend = TRUE,
                    bt_mgp = NULL,
                    lf_mgp = NULL,
                    tp_mgp = NULL,
                    rt_mgp = NULL,
                    ...) {

  par(...)
  names(df) <- c("x", "y")
  if (!is.null(nrow(sdf)))
    sdf <- list(sdf)
  plot(df, xlab = xl, ylab = yl, bg = r1, col = r1, cex = .3,
       panel.first = grid(lwd = .7),
       axes = FALSE)
  invisible(lapply(sdf, function(x) points(x, bg = r2, col = r2)))
  invisible(lapply(sdf, function(z) {
    names(z) <- c("x", "y")  # rename columns, in case they're not x and y
    ## This fails and breaks return if the z data happens to contain an NA
    ## Rare, but i have seen it happen...
    clip(min(na.omit(z$x)),
         max(na.omit(z$x)),
         min(na.omit(z$y)),
         max(na.omit(z$y)))
    abline(lm(y ~ x, z), lwd = 1.2, lty = 3)
  }))

  if(1 %in% axes) axis(side = 1, col.axis = "blue", mgp = bt_mgp)
  if(2 %in% axes) axis(side = 2, col.axis = "black", mgp = lf_mgp)

  box()

  if(legend && 1 %in% axes) legend("bottomleft",
                                   "Time",
                                   text.col = "blue",
                                   bg = "gray90",
                                   cex = 0.5)
  if(legend && 3 %in% axes) legend("topright",
                                   "Row",
                                   text.col = "red",
                                   bg = "gray90",
                                   cex = 0.5)
  ## add row index axis
  par(new = TRUE, ...)
  plot(seq(1, nrow(df)),
       df[[2]],
       xlab = "",
       ylab = "",
       pch = "",
       cex = .5,
       axes = FALSE)
  if(3 %in% axes) axis(side = 3, col.axis = "red", mgp = tp_mgp)

  if (title == T)
    title(main = ("Full Timeseries"), line = 1.2, font = 2)
}

# a plot of the subset only
sub.p <- function(sdf, rep = 1, rsq, rownums, title = TRUE, legend = TRUE, ...) {
  par(...)
  if (is.null(nrow(sdf)))
    sdf <- sdf[[rep]]
  names(sdf) <- c("x", "y")
  fit <- lm(y ~ x, sdf)
  # generate equation to paste into plot
  cf <- signif(coef(fit), 3)
  eq <- paste0("y = ", cf[1], ifelse(sign(cf[2]) == 1, " + ", " - "),
               abs(cf[2]), " x ")
  # plot the graph
  plot(sdf, xlab = "", ylab = "", bg = r2, col = r2,
       panel.first = grid(lwd = .7),
       axes = FALSE)
  abline(fit, lwd = 1.5, lty = 2)

  axis(side = 1, col.axis = "blue")
  axis(side = 2, col.axis = "black")
  box()

  ## add row index axis
  par(new = TRUE, ...)
  plot(rownums,
       sdf[[2]],
       xlab = "",
       ylab = "",
       pch = "",
       cex = .5,
       axes = FALSE)
  axis(side = 3, col.axis = "red")

  if(title) title(main = ("Close-up Region"), line = 1.2, font = 2)
  if(legend) title(main = eq, line = -1.5, font.main = 1)
  if(legend && !is.null(rsq)) title(main = paste0("r2 = ", rsq), line = -2.5, font.main = 1)
}

# a plot of residuals
residual.p <- function(fit, ...) {
  par(...)
  plot(fit$fitted.values, fit$residuals, xlab = "", ylab = "", bg = r2,
       col = r2, ylim = c(max(fit$residuals), -max(fit$residuals)),
       panel.first = grid(lwd = .7))
  ## fails with values 5 or less, so just don't bother drawing it
  if(length(fit$fitted.values) > 5)
    lines(suppressWarnings(loess.smooth(fit$fitted.values, fit$residuals)),
          col = "black", lwd = 2)
  title(main = ("Std. Residuals \nvs Fitted Values"), line = 0.3, font = 2)
  abline(0, 0, lty = 3, lwd = 1.5)
}

# a q-q plot
qq.p <- function(fit, ...) {
  par(...)
  # problems with rstandard if only 2 values, so do this
  if(length(fit$fitted.values) > 2) vals <- rstandard(fit) else
    vals <- fit$fitted.values

  qqnorm(vals, main = "", xlab = "", ylab = "", bg = r2, col = r2,
         panel.first = grid(lwd = .7))
  title(main = ("Theoretical Q. \nvs Std. Residuals"), line = 0.3, font = 2)
  qqline(vals, lty = 3, lwd = 1.5)
}

# kernel density plot
density.p <- function(dens, peaks, rank = 1, ...) {
  par(...)
  plot(dens, main = "", xlab = "", ylab = "", panel.first = grid(lwd = .7))
  polygon(dens, col = r2, border = r2)
  title(main = expression(bold("Density of Rolling"~beta[1])), line = 0.5)
  abline(v = peaks[rank, ][1][,1], lty = 2)  # indicate position on density plot
}

# rolling regression
rollreg.p <- function(rolldf, ranked.b1, rownums, xlim, rate.rev = TRUE, ...) {
  par(...)
  ylim <- grDevices::extendrange(nainf.omit(rolldf[[2]]), f = 0.05)
  if(rate.rev) ylim <- rev(ylim) ## reverse y-axis
  plot(rolldf, xlab = "", ylab = "", bg = r2, col = r2,
       ylim = ylim,
       xlim = xlim,
       lwd = 1, panel.first = grid(lwd = .7),
       axes = FALSE)

  axis(side = 1, col.axis = "blue")
  axis(side = 2, col.axis = "black")
  abline(h = ranked.b1, lty = 2)
  box()

  ## add row index axis
  par(new = TRUE, ...)
  plot(rownums,
       xlab = "",
       ylab = "",
       pch = "",
       cex = .5,
       axes = FALSE)
  axis(side = 3, col.axis = "red")
  title(main = ("Rolling Rate"), line = 1.2, font = 2)
}


#' Plots multiple auto_rate results in a nice way
#' using base plot
#' x = auto_rate or auto_rate_subset object
#'
#' @keywords internal
plot_ar_grid <- function(x, ...){

  parorig <- par(no.readonly = TRUE) # save original par settings
  on.exit(par(parorig)) # revert par settings to original

  totres <- length(x$rate)
  res <- length(x$rate)

  par(oma = c(2, 2, 2, 0.5), mar = c(0.1, 0.1, 2, 0.1))

  plot.sub.grid <- function(x, res, bt, lf, tp) {
    for(i in 1:res) {
      dt <- x$dataframe
      rate <- x$rate[i]
      start <- x$summary$row[i]
      end <- x$summary$endrow[i]
      sdt <- dt[start:end]
      ax <- c()
      if(i %in% bt) ax <- c(ax, 1)
      if(i %in% lf) ax <- c(ax, 2)
      if(i %in% tp) ax <- c(ax, 3)
      multi.p(dt, sdt, legend = F, title = F, axes = ax,
              tck = -0.005,
              mgp = c(0, 0.2, 0),
              tp_mgp = c(0, 2, 0),
              las = 1)
      #title(glue::glue("tmp title"))
      title(glue::glue("Subset {i} of {totres}:\nRate: {signif(rate, digits = 3)}"),
            cex.main = 0.9)
    }
  }

  if(res == 0) message("subset_rate: No results to plot!")
  if(res == 1)          {
    par(mfrow = c(1,1))
    bt <- 1
    lf <- 1
    tp <- 1
    plot.sub.grid(x, res, bt, lf, tp)
  }
  if(res == 2)          {
    par(mfrow = c(1,2))
    bt <- 1:2
    lf <- 1
    tp <- 1:2
    plot.sub.grid(x, res, bt, lf, tp)
  }
  if(res %in% c(3,4))   {
    par(mfrow = c(2,2))
    bt <- 3:4
    lf <- c(1,3)
    tp <- 1:2
    plot.sub.grid(x, res, bt, lf, tp)
  }
  if(res %in% c(5,6))   {
    par(mfrow = c(2,3))
    bt <- 4:6
    lf <- c(1,4)
    tp <- 1:3
    plot.sub.grid(x, res, bt, lf, tp)
  }
  if(res %in% c(7,8,9)) {
    par(mfrow = c(3,3))
    bt <- 7:9
    lf <- c(1,4,7)
    tp <- 1:3
    plot.sub.grid(x, res, bt, lf, tp)
  }
  if(res %in% c(10:12)) {
    par(mfrow = c(3,4))
    bt <- 9:12
    lf <- c(1,5,9)
    tp <- 1:4
    plot.sub.grid(x, res, bt, lf, tp)
  }
  if(res %in% c(13:16)) {
    par(mfrow = c(4,4))
    bt <- 13:16
    lf <- c(1,5,9,13)
    tp <- 1:4
    plot.sub.grid(x, res, bt, lf, tp)
  } ## start to get margins too large errors
  if(res %in% c(17:20)) {
    par(mfrow = c(4,5))
    bt <- 16:20
    lf <- c(1,6,11,16)
    tp <- 1:5
    plot.sub.grid(x, res, bt, lf, tp)
  }
  if(res > 20){
    res <- 20
    par(mfrow = c(4,5))
    bt <- 16:20
    lf <- c(1,6,11,16)
    tp <- 1:5
    message("subset_rate: Over 20 results remaining. Plotting first 20 only...")
    plot.sub.grid(x, res, bt, lf, tp)
  }
}



#' Plot auto_rate summary tables
#'
#' Plots `auto_rate` summary table regressions in a way that visualises how they
#' are positioned within the data timeseries. If it is an `auto_rate_subset`
#' object, it will plot the subset regressions using the ranks of the original
#' results, so you can compare the subset and original.
#'
#' @param x `auto_rate` or `auto_rate_subset` object
#' @param highlight integer. Which result in the summary table to highlight on
#'   the plots. Defaults to 1. If it is outside the range of the `pos` input it
#'   will be shown on the top plot, but will not be visible on the bottom plot.
#' @param pos integer(s). What range of original summary table rows to plot in
#'   lower plot. Defaults to all.
#' @param legend logical. Suppress plot legends.
#' @param ... Allows additional plotting controls to be passed.
#'
#' @return A plot of the auto_rate object results
#'
#' @export
plot_ar <- function(x, highlight = NULL, pos = NULL, legend = TRUE, ...){

  parorig <- par(no.readonly = TRUE) # save original par settings
  on.exit(par(parorig)) # revert par settings to original

  if(!("auto_rate" %in% class(x)))
    stop("plot_ar: 'x' should be an 'auto_rate' or 'auto_rate_subset' object.")

  ## warning if empty - but return to allow piping
  if(length(x$rate) == 0){
    message("plot_ar: Nothing to plot! No rates found in 'auto_rate' object.")
    return(invisible(x))
  }

  ## set layout
  m <- rbind(c(1,1,1), c(2,2,2), c(2,2,2))
  layout(m)

  # Apply default plotting params
  par(oma = oma_def,
      mai = mai_def_top_ext,
      las = las_def,
      mgp = mgp_def,
      tck = tck_def,
      pch = pch_def,
      cex = 1,
      cex.main = 1,
      ps = 10)
  par(...)

  ## is it a subset object?
  subset <- !is.null(x$original) # has it already been subset?

  ## apply default pos
  if(is.null(pos))
    if(subset) pos <- 1:nrow(x$original$summary) else
      pos <- 1:nrow(x$summary)

  ## Extract data
  dt <- x$dataframe
  summ <- x$summary
  # if(subset){
  #   indx <- which(x$summary$rank %in% pos)
  #   summ <- x$original$summary[indx]
  # }

  # apply default of highlight being the highest rank pos
  if(is.null(highlight)) highlight <- 1

  # If highlight isn't in pos ranks set it to highest rank one
  if(highlight > nrow(summ)) {
    message("plot_ar: 'highlight' too high. Applying default of first row.")
    highlight <- 1
  }

  # # # highlight row shouldn't be outside pos selection range
  # if(!(hl %in% pos)) {
  #   message("plot_ar: 'highlight' is not within 'pos' range. Applying default of highest ranking result within 'pos' range.")
  #   hl <- pos[1]
  # }


  # highlight subset
  start <- summ$row[highlight]
  end <- summ$endrow[highlight]
  rownums <- start:end
  sub_dt <- dt[start:end]

  multi.p(dt, sub_dt, axes = c(2,3), legend = legend)
  mtext("Full Timeseries",
        outer = TRUE, cex = 1.2, line = 0, font = 2)

  # Overlap plot ------------------------------------------------------------

  # Axis limits
  ## how many summary rows to plot. if already filtered, original
  # if(subset) maxy <- nrow(o_summ) else
  #    maxy <- nrow(summ)
  miny <- min(pos)
  maxy <- max(pos)
  minx <- 0
  maxx <- nrow(dt)

  plot(minx:maxx,
       seq(miny, maxy, length.out=length(minx:maxx)),
       ylim = c(maxy,miny),
       col = "white",
       ylab="",
       xlab="",
       axes = FALSE,
       panel.first = grid(lwd = .7))
  box()
  for(i in 1:nrow(summ))
    segments(x0 = summ$row[i],
             y0 = summ$rank[i],
             x1 = summ$endrow[i],
             y1 = summ$rank[i],
             lwd=3, col = r1)
  axis(side = 2, col.axis = "black")
  segments(x0 = summ$row[highlight],
           y0 = summ$rank[highlight],
           x1 = summ$endrow[highlight],
           y1 = summ$rank[highlight],
           lwd=3, col = r2)
  mtext("Original Summary Table Rank (Descending)",
        outer = FALSE, cex = 1.2, line = 0.8, font = 2)
  # invisible plot to get time axis
  par(new=TRUE)
  plot(dt[[1]], dt[[2]], pch = "", xlab = "", ylab = "", axes = FALSE)
  axis(side = 1, col.axis = "blue")
  if(legend) legend("bottomleft",
                    "Time",
                    text.col = "blue",
                    bg = "gray90",
                    cex = 0.5)

  invisible(return(x)) ## to allow it to be used within pipes - still prints though...
}
