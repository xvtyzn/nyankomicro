library(phyloseq)
library(nyankomicro)
library(DESeq2)
library(tidyverse)
data("GlobalPatterns")

subGP <- subset_samples(GlobalPatterns, SampleType %in% c("Skin", "Tongue") )

deseq2_subGP <- subGP %>%
  phyloseq_to_deseq2(~SampleType) %>%
  DESeq(test="Wald", fitType="parametric") %>%
  results(cooksCutoff = FALSE)

ggtree_subGP <- deseq2_tree(subGP, deseq2_subGP,level = "Phylum", alpha = 0.01,
                            sample_annotation = "SampleType")

ggtree_subGP
