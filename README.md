
<!-- README.md is generated from README.Rmd. Please edit that file -->

# nyankomicro

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)

<!-- badges: end -->

nyankomicro is a in-house package that aims to make the plots more
beautiful.

The barplots created by various packages force annotations when the
annotation for a particular domain is unknown (e.g., NA, uncultured,
uncultured bacterium, etc.), which confuses the discussion. To avoid
these confusions, this package uniquely sets unknown annotations as
Undetermined. It will also show the taxonomy to be displayed if it is N%
or more in at least one sample.

## Installation

You can install the released version of demopckg from
[GitHub](https://github.com) with:

``` r
devtools::install_github("xvtyzn/nyankomicro")
```

## example

``` r
library(phyloseq)
library(nyankomicro)
data("GlobalPatterns")

microbiome_barplot(GlobalPatterns, "Order", "SampleType", 10)
#> Using Sample, X.SampleID, Primer, Final_Barcode, Barcode_truncated_plus_T, Barcode_full_length, SampleType, Description as id variables
```

<img src="man/figures/README-exaple-1.png" width="100%" />
