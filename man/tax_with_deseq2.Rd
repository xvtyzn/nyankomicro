% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/deseq2_tree.R
\name{tax_with_deseq2}
\alias{tax_with_deseq2}
\title{phyloseqとdeseq2の統合}
\usage{
tax_with_deseq2(physeq, deseq2_results, alpha = 0.05)
}
\arguments{
\item{physeq}{phyloseq object}

\item{deseq2_results}{deseq2 results}

\item{alpha}{threshold of deseq2 for visualization}
}
\value{
sigtab
}
\description{
phyloseqとdeseq2の統合
}
