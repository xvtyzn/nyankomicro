#' Show the results of deseq2 on the phylogenetic tree
#'
#' @param physeq phyloseq object
#' @param deseq2_results deseq2 results object
#' @param level visualize taxonomy level
#' @param alpha threshold of adjusted p-values
#' @param sample_annotation sample metadata used for drawing
#' @param colors color palette
#' @param tree_adjust value for ggtree positioning.
#' @param vis_domain domain level
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
#' @importFrom speedyseq tax_glom
#' @export
#'
deseq2_tree <- function(physeq, deseq2_results, level = c("Kingdom", "Phylum",
    "Class", "Order", "Family", "Genus", "Species"), alpha = 0.05,
    sample_annotation = "Status", vis_domain = FALSE, colors = nyankocolors, tree_adjust = 1.2) {

    # 色の定義 (いらないのでは？？？)
    colors <- c("#E41A1C", "#377EB8", "#4DAF4A", "#984EA3", "#FF7F00", "#FFFF33",
                "#A65628", "#F781BF", "#66C2A5", "#FC8D62", "#8DA0CB", "#E78AC3", "#A6D854",
                "#FFD92F", "#E5C494", "#B3B3B3", "#8DD3C7", "#FFFFB3", "#BEBADA", "#FB8072",
                "#80B1D3", "#FDB462", "#B3DE69", "#FCCDE5", "#D9D9D9", "#BC80BD", "#CCEBC5",
                "#FFED6F", "#A6CEE3", "#1F78B4", "#B2DF8A", "#33A02C", "#FB9A99", "#E31A1C",
                "#FDBF6F", "#FF7F00", "#CAB2D6", "#6A3D9A", "#FFFF99", "#B15928")

    # それぞれの結果を統合
    sigtab <- tax_with_deseq2(physeq, deseq2_results, alpha)

    if(isTRUE(vis_domain)){
      # NAとなっているtaxonomyを除去する
      sigtab_naomitted <- sigtab %>%
        filter(!is.na(!!sym(level)))

      omitted_asvs <- sigtab %>%
        filter(is.na(!!sym(level))) %>%
        nrow()

      print(paste0(omitted_asvs, "ASVs were removed", "\n"))
      sigtab <- sigtab_naomitted

      sigtax <- sigtab %>% select(level) %>% unlist() %>% unique()
      physeq_sig <- prune_taxa(sigtab$ASV, physeq)

      physeq_sig <- tax_glom(physeq_sig, level)
      physeq <- speedyseq::tax_glom(physeq, level)

      tree_glomed <- physeq_sig %>%
        phy_tree()

      tree_glomed$tip.label <- tax_table(physeq_sig)[,level] %>% as.character()

      gt <- tree_glomed %>%
        ggtree() + geom_tiplab(align = TRUE) + xlim(0, tree_adjust)

      # lon2FoldChange box and Scatter plot
      fc_gg <- sigtab %>% ggplot(aes(y = !!sym(level), x = log2FoldChange, fill = !!sym(level))) +
        geom_point(aes(y = !!sym(level), color = !!sym(level)), position = position_jitter(width = 0.15), size = 1, alpha = 0.4) +
        geom_boxplot(width = 0.2, outlier.shape = NA, alpha = 0.8)  +
        theme(axis.text.x = element_text(angle = -90, hjust = 0, vjust = 0.5)) +
        ylab(NULL) + theme_minimal() + theme(axis.text.x = element_text(angle = 45, hjust = 0),
                                             axis.text.y = element_blank(), legend.text = element_text(face = "italic")) +
        scale_fill_manual(values = colors) + scale_color_manual(values = colors) + labs(fill = level) + theme(legend.position = "none")

      # log2pvalues
      p_gg <- sigtab %>% ggplot(aes(y = !!sym(level), x = padj, fill = !!sym(level))) +
        geom_point(aes(y = !!sym(level), color = !!sym(level)), position = position_jitter(width = 0.15), size = 1, alpha = 0.4) +
        geom_boxplot(width = 0.2, outlier.shape = NA, alpha = 0.8)  +
        ylab(NULL) +
        scale_x_log10() +
        theme_minimal() + theme(axis.text.x = element_text(angle = 45, hjust = 0),
                                axis.text.y = element_blank(), legend.text = element_text(face = "italic")) +
        scale_fill_manual(values = colors) + scale_color_manual(values = colors) + labs(fill = level)

      # the number of asvs
      num_tax <- sigtab %>%
        group_by(!!sym(level)) %>%
        summarise(num = n()) %>%
        ggplot(aes(y = !!sym(level), x = num, fill = !!sym(level))) + geom_bar(stat = "identity") +
        theme_minimal() + theme(axis.text.x = element_text(angle = 45, hjust = 0),
                                axis.text.y = element_blank(), legend.text = element_text(face = "italic")) +
        ylab(NULL) +
        scale_fill_manual(values = colors)

      # merge using aplot
      ggtree_plot <- fc_gg %>%
        insert_left(p_gg) %>%
        insert_left(num_tax) %>%
        insert_left(gt)

    } else {
      physeq_sig <- prune_taxa(sigtab$ASV, physeq)

      gt <- physeq_sig %>%
        phy_tree() %>%
        ggtree() + geom_tiplab(align = TRUE) + xlim(0, tree_adjust)

      rate_otu <- transform_sample_counts(physeq, function(x) 100 * x/sum(x)) %>% otu_table() %>% as.data.frame() %>% t()
      sig_rate_otu <- as.data.frame(rate_otu[, rownames(sigtab)])

      tt <- cbind(log(sig_rate_otu + 1), sample_data(physeq_sig)[, sample_annotation]) %>%
        rownames_to_column("Sample") %>%
        pivot_longer(c(-Sample, -UQ(sample_annotation)), names_to = "ASV", values_to = "read")

      mylevels <- tt$Sample
      tt$Sample <- factor(tt$Sample,levels=unique(mylevels))

      gh <- tt %>% ggplot() + geom_tile(aes(x = Sample, y = ASV, fill = get(sample_annotation),
                                            alpha = read)) + scale_alpha_continuous(aes(show.legend = "Relative Abundance")) +
        ylab(NULL) + theme_minimal() + theme(axis.text.x = element_text(angle = 45,
                                                                        hjust = 1), axis.text.y = element_blank(), axis.ticks.y = element_blank()) + labs(fill = sample_annotation)

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
        scale_fill_manual(values = colors) + labs(fill = level)

      ggtree_plot <- fc_gg %>%
        insert_left(p_gg) %>%
        insert_left(gh) %>%
        insert_left(gt)
    }

    return(ggtree_plot)
}

#' phyloseqとdeseq2の統合
#'
#'
#'
#' @param physeq phyloseq object
#' @param deseq2_results deseq2 results
#' @param alpha threshold of deseq2 for visualization
#'
#' @return sigtab
#' @export
#'
#' @importFrom dplyr filter
#' @importFrom tibble rownames_to_column
#' @importFrom phyloseq tax_table
#'
#' @examples
tax_with_deseq2 <- function(physeq, deseq2_results, alpha = 0.05){
  # deseq2の結果からpvalueで抽出
  sig_asv <- deseq2_results %>%
    as.data.frame() %>%
    dplyr::filter(padj < alpha)

  # taxonomyの結果からdeseq2の結果に合うように抽出
  sig_tax <- physeq %>%
    tax_table() %>%
    as.data.frame() %>%
    rownames_to_column("ASV") %>%
    filter(ASV %in% rownames(sig_asv))

  # それぞれの結果を統合
  sigtab <- cbind(sig_asv, sig_tax)

  return(sigtab)
}

