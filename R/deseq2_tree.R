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
#' @importFrom tidyr pivot_longer
#' @importFrom phyloseq tax_table
#' @importFrom phyloseq prune_taxa
#' @importFrom phyloseq phy_tree
#' @importFrom phyloseq otu_table
#' @importFrom phyloseq prune_taxa
#' @export
#'
deseq2_tree <- function(physeq, deseq2_results, level = c("Kingdom", "Phylum",
    "Class", "Order", "Family", "Genus", "Species"), alpha = 0.05, sample_annotation = "Status", colors = nyankocolors) {

    colors <- c("#E41A1C", "#377EB8", "#4DAF4A", "#984EA3", "#FF7F00", "#FFFF33",
                "#A65628", "#F781BF", "#66C2A5", "#FC8D62", "#8DA0CB", "#E78AC3", "#A6D854",
                "#FFD92F", "#E5C494", "#B3B3B3", "#8DD3C7", "#FFFFB3", "#BEBADA", "#FB8072",
                "#80B1D3", "#FDB462", "#B3DE69", "#FCCDE5", "#D9D9D9", "#BC80BD", "#CCEBC5",
                "#FFED6F", "#A6CEE3", "#1F78B4", "#B2DF8A", "#33A02C", "#FB9A99", "#E31A1C",
                "#FDBF6F", "#FF7F00", "#CAB2D6", "#6A3D9A", "#FFFF99", "#B15928")

    sig_asv <- deseq2_results %>% as.data.frame() %>% dplyr::filter(padj < alpha)

    sig_tax <- physeq %>% tax_table() %>% as.data.frame() %>% rownames_to_column("ASV") %>%
        filter(ASV %in% rownames(sig_asv))

    sigtab <- cbind(sig_asv, sig_tax)

    physeq_sig <- prune_taxa(sigtab$ASV, physeq)

    gt <- physeq_sig %>% phy_tree() %>% ggtree() + geom_tiplab(align = TRUE) + xlim(0, 0.08)

    rate_otu <- t(otu_table(physeq))/rowSums(t(otu_table(physeq)))
    sig_rate_otu <- as.data.frame(rate_otu[, rownames(sigtab)])

    tt <- cbind(log(sig_rate_otu + 1), sample_data(physeq_sig)[, sample_annotation]) %>% rownames_to_column("Sample") %>%
        pivot_longer(c(-Sample, -UQ(sample_annotation)), names_to = "ASV", values_to = "read")

    gh <- tt %>% ggplot() + geom_tile(aes(x = Sample, y = ASV, fill = get(sample_annotation),
        alpha = read)) + scale_alpha_continuous(aes(show.legend = Relative_Abundance)) +
        ylab(NULL) + theme_minimal() + theme(axis.text.x = element_text(angle = 45,
        hjust = 1), axis.text.y = element_blank(), axis.ticks.y = element_blank())

    fc_gg <- sigtab %>% ggplot(aes(y = ASV, x = log2FoldChange, color = get(level))) +
        geom_point(size = 3) + geom_segment(aes(x = 0, xend = log2FoldChange,
        y = ASV, yend = ASV), color = "grey") + theme(axis.text.x = element_text(angle = -90,
        hjust = 0, vjust = 0.5)) + ylab(NULL) + theme_minimal() + theme(axis.text.x = element_text(angle = 45,
        hjust = 0), axis.text.y = element_blank(), axis.ticks.y = element_blank()) +
        scale_color_manual(values = colors) + theme(legend.position = "none")

    p_gg2 <- sigtab %>% mutate(log2padj = -log2(padj))

    p_gg <- p_gg2 %>% ggplot(aes(y = ASV, x = log2padj, fill = get(level))) + geom_bar(stat = "identity") + ylab(NULL) +
        theme_minimal() + theme(axis.text.x = element_text(angle = 45, hjust = 0),
        axis.text.y = element_blank(), legend.text = element_text(face = "italic")) +
        scale_fill_manual(values = colors)

    ggtree_korogi <- fc_gg %>% insert_left(p_gg) %>% insert_left(gh) %>% insert_left(gt)

    return(ggtree_korogi)
}
