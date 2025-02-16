% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/rasterizeLine.R
\name{rasterizeLine}
\alias{rasterizeLine}
\title{Faster rasterize for lines}
\usage{
rasterizeLine(sfLine, rast, value)
}
\arguments{
\item{sfLine}{an sf object to be rasterized}

\item{rast}{a raster to use as template for the output raster}

\item{value}{a number value to give the background ie 0 or NA}
}
\value{
a RasterLayer where the value of cells that touch the line will be
  the row index of the line in the sf
}
\description{
Rasterize a line using \code{stars} because \code{fasterize} doesn't work on lines and
rasterize is slow. Deprecated use \code{terra::rasterize}
}
\examples{
CLUSexample <- prepExData(CLUSexample)
roadsLine <- sf::st_sf(geometry = sf::st_sfc(sf::st_linestring(
matrix(c(0.5, 4.5, 4.5, 4.51),
       ncol = 2, byrow = TRUE) 
)))

# Deprecated rasterizeLine(roadsLine, CLUSexample$cost, 0)   
# Use terra::rasterize
terra::rasterize(roadsLine, CLUSexample$cost, background = 0)

}
