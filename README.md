
<!-- README.md is generated from README.Rmd. Please edit that file -->

# nyankomicro

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)

<!-- badges: end -->

nyankomicro is a in-house package that aims to make the plots more
beautiful.

Bar charts produced by various packages can confuse discussions if the
annotations for a particular domain are unknown (e.g. NA, uncultured,
uncultured bacteria, etc.). To avoid such confusion, this package
uniquely sets unknown annotations as Undetermined. Also, the taxonomy to
be visualized will be shown if it is N% or more in at least one sample.

## Installation

You can install the released version of demopckg from
[GitHub](https://github.com) with:

``` r
devtools::install_github("xvtyzn/nyankomicro")
```

``` r
devtools::update_packages("nyankomicro")
```

## Example

### Barplot

``` r
library(phyloseq)
library(nyankomicro)
data("GlobalPatterns")

microbiome_barplot(GlobalPatterns, "Order", "SampleType", 10)
```

<img src="man/figures/README-example1-1.png" width="100%" />

The above result contains an Order YS2, so if you would like to
re-classify these as Undetermined, you can do the following.

``` r
microbiome_barplot(GlobalPatterns, "Order", "SampleType", 10, na_str = "YS2")
```

<img src="man/figures/README-example1 YS2 to Undetermined-1.png" width="100%" />

Following the naming conventions for bacteria, italics are used to
classify bacteria below the family level.

``` r
microbiome_barplot(GlobalPatterns, "Family", "SampleType", 10)
```

<img src="man/figures/README-example1 family level-1.png" width="100%" />

You can also visualize the nested categories.

``` r
data(enterotype)
enterotype_na_omited <- subset_samples(enterotype, !is.na(Nationality))

microbiome_barplot(enterotype_na_omited, "Genus", c("Nationality", "ClinicalStatus"), 10)
```

<img src="man/figures/README-example1 nested-1.png" width="100%" />

### Taxonomic annotation

#### 

この結果は、それぞれのasvに対する非荷重の結果となっており、各ASVがサンプルごとにどれくらいの割合で存在するかを考慮していない。

``` r
#taxonomy_plot(GlobalPatterns)
```

#### カテゴリごとのannotation 割合

#### taxonomy levelを指定した際のannotation 割合

### DEseq2 plot

#### ASV level

The results of Deseq2 tests can be visualized together with a
phylogenetic tree. The visualization can be created for each ASV level
and for each domain you would like to focus on.

``` r
library(DESeq2)
library(tidyverse)
data("GlobalPatterns")

subGP <- subset_samples(GlobalPatterns, SampleType %in% c("Skin", "Tongue") )
  
deseq2_subGP <- subGP %>%
  phyloseq_to_deseq2(~SampleType) %>%
  DESeq() %>%
  results(cooksCutoff = FALSE)

ggtree_subGP <- deseq2_tree(subGP, deseq2_subGP,level = "Phylum", alpha = 0.01,
                            sample_annotation = "SampleType")
ggtree_subGP
```

<img src="man/figures/README-example2-1.png" width="100%" />

#### Genus level

Here are the results generated for each genus. It is based on taxnomy
annotation of phyloseq and summarized by tax_glom of speedyseq. So ASVs
that do not have annotation to genus (NA) are removed.

こちらは、Genusごとに作成した結果です。phyloseqのtaxnomy
annotationに基づいて、speedyseqのtax_glomによってまとめています。そのため、genusまでannotationがつかない
(NAとなっている) ASVは除去されます。

``` r
ggtree_subGP_genus <- deseq2_tree(subGP, deseq2_subGP,level = "Genus", alpha = 0.01,
                            sample_annotation = "SampleType", vis_domain = TRUE)
#> [1] "12ASVs were removed\n"
ggtree_subGP_genus
```

<img src="man/figures/README-example2 family-1.png" width="100%" />

### Core microbiome estimation

コアmicrobiomeの決定には複数の議論が存在します。

そのため、以下ではcore
microbiomeの決定のために便利な幾つかの関数を提示します

#### threholdによる変動

``` r
data("GlobalPatterns")

subGP2 <- subset_samples(GlobalPatterns, SampleType %in% c("Skin", "Tongue", "Feces") )
```

#### ベン図での可視化

#### Upset図による可視化
