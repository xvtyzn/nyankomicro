#' Show the results of deseq2 on the phylogenetic tree
#'
#' @param physeq phyloseq object
#' @param deseq2_results deseq2 results object
#' @param level visualize taxonomy level
#' @param alpha threshold of adjusted p-values
#'
#' @return ggplot2 object
#'
#' @import dplyr
#' @import tibble
#' @import ggplot2
#' @import ggtree
#' @import aplot
#' @import DESeq2
#' @importFrom phyloseq tax_table
#' @importFrom phyloseq prune_taxa
#' @importFrom phyloseq phy_tree
#' @importFrom phyloseq otu_table
#' @importFrom phyloseq prune_taxa
#' @export
#'
deseq2_tree <- function(physeq, deseq2_results, level = c("Kingdom", "Phylum",
    "Class", "Order", "Family", "Genus", "Species"), alpha = 0.05, sample_annotation = "Status") {
    sig_asv <- deseq2_results %>% as.data.frame() %>% dplyr::filter(padj < alpha)

    sig_tax <- physeq %>% tax_table() %>% as.data.frame() %>% rownames_to_column("ASV") %>%
        filter(ASV %in% rownames(sig_asv))

    sigtab <- cbind(sig_asv, sig_tax)

    physeq_sig <- prune_taxa(sigtab$ASV, physeq)

    gt <- physeq_sig %>% phy_tree() %>% ggtree() + geom_tiplab(align = TRUE)

    rate_otu <- t(otu_table(physeq))/rowSums(t(otu_table(physeq)))
    sig_rate_otu <- as.data.frame(rate_otu[, rownames(sigtab)])

    tt <- cbind(log(sig_rate_otu + 1), sample_data(physeq_sig)[, 1]) %>% rownames_to_column("Sample") %>%
        pivot_longer(c(-Sample, -Status), names_to = "ASV", values_to = "read")

    gh <- tt %>% ggplot() + geom_tile(aes(x = Sample, y = ASV, fill = get(sample_annotation),
        alpha = read)) + scale_alpha_continuous(aes(show.legend = Relative_Abundance)) +
        ylab(NULL) + theme_minimal() + theme(axis.text.x = element_text(angle = 45,
        hjust = 1), axis.text.y = element_blank(), axis.ticks.y = element_blank())

    fc_gg <- sigtab %>% ggplot(aes(y = ASV, x = log2FoldChange, color = get(level))) +
        geom_point(size = 3) + geom_segment(aes(x = 0, xend = log2FoldChange,
        y = ASV, yend = ASV), color = "grey") + theme(axis.text.x = element_text(angle = -90,
        hjust = 0, vjust = 0.5)) + ylab(NULL) + theme_minimal() + theme(axis.text.x = element_text(angle = 90,
        hjust = 0), axis.text.y = element_blank(), axis.ticks.y = element_blank()) +
        scale_color_simpsons() + theme(legend.position = "none")

    p_gg2 <- sigtab %>% mutate(log2padj = -log2(padj))

    p_gg <- p_gg2 %>% ggplot(aes(y = ASV, x = log2padj, fill = get(level))) + geom_bar(stat = "identity") + ylab(NULL) +
        theme_minimal() + theme(axis.text.x = element_text(angle = 90, hjust = 0),
        axis.text.y = element_blank(), legend.text = element_text(face = "italic")) +
        scale_fill_simpsons()

    ggtree_korogi <- fc_gg %>% insert_left(p_gg) %>% insert_left(gh) %>% insert_left(gt)

    return(ggtree_korogi)
}
