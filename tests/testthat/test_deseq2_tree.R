library(phyloseq)
library(nyankomicro)
data("GlobalPatterns")

testthat::context("deseq2 phylogenetic tree test")

deseq_tree <- deseq2_tree(physeq, deseq2_korogi,level = "Order", alpha = 0.05, sample_annotation = "Status")
