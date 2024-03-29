% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/microbiome_barplot.R
\name{microbiome_bardata}
\alias{microbiome_bardata}
\title{microbiome_barplot}
\usage{
microbiome_bardata(
  physeq,
  level = c("Kingdom", "Phylum", "Class", "Order", "Family", "Genus", "Species"),
  plot_category,
  plot_percent = 10,
  threshold = "max",
  na_str = c("unidentified", "uncultured")
)
}
\arguments{
\item{physeq}{phyloseq object}

\item{level}{taxonomy level}

\item{plot_category}{metadata category}

\item{plot_percent}{threshold persent}

\item{threshold}{the way of calculating threshold values}

\item{na_str}{taxa name to be Undetermined}
}
\value{


barplot of microbiome composition as ggplot2 input data
}
\description{
Create a bacterial composition data for a plot
}
\details{
Create a bacterial composition data using a specific threshold value.
}
