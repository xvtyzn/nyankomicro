library(phyloseq)
library(nyankomicro)
data("GlobalPatterns")

testthat::context("barplot parameter test")

class_level_5 <- microbiome_barplot(GlobalPatterns, "Class", "SampleType", 5)
