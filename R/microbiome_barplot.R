#' Create a bacterial composition plot
#'
#' Create a bacterial composition plot using a specific threshold value.
#'
#' @param physeq phyloseq object
#' @param level taxonomy level
#' @param plot_category metadata category
#' @param plot_percent threshold persent
#' @param threshold the way of calculating threshold values
#'
#' @return barplot of microbiome composition as ggplot2 object
#' @importFrom phyloseq tax_glom
#' @importFrom phyloseq transform_sample_counts
#' @importFrom phyloseq tax_table
#' @importFrom phyloseq otu_table
#' @importFrom phyloseq sample_data
#' @import dplyr
#' @import tibble
#' @import ggplot2
#'
#' @export
#'
#' @examples
#'
#'
microbiome_barplot <- function(physeq,
                               level = c("Kingdom","Phylum","Class","Order",
                                         "Family","Genus","Species"),
                               plot_category, plot_percent = 10,
                               threshold = "max"){

  COLORS <- c("#E41A1C","#377EB8","#4DAF4A","#984EA3","#FF7F00","#FFFF33","#A65628",
              "#F781BF","#66C2A5","#FC8D62","#8DA0CB","#E78AC3","#A6D854","#FFD92F",
              "#E5C494","#B3B3B3","#8DD3C7","#FFFFB3","#BEBADA","#FB8072","#80B1D3",
              "#FDB462","#B3DE69","#FCCDE5","#D9D9D9","#BC80BD","#CCEBC5","#FFED6F",
              "#A6CEE3","#1F78B4","#B2DF8A","#33A02C","#FB9A99","#E31A1C","#FDBF6F",
              "#FF7F00","#CAB2D6","#6A3D9A","#FFFF99","#B15928")

  agg_phylo <- tax_glom(physeq, level, NArm=F)
  agg_phylo_rel <- transform_sample_counts(agg_phylo, function(x)100* x / sum(x))
  level_tax <- tax_table(agg_phylo_rel)[,level] %>%
    as.data.frame() %>%
    rownames_to_column("ASV")
  level_tax[is.na(level_tax)] <- "Undetermined"

  taxotu_table <- otu_table(agg_phylo_rel) %>%
    as.data.frame() %>%
    rownames_to_column("ASV") %>%
    left_join(level_tax, by = ("ASV" = "ASV")) %>%
    select(-ASV) %>%
    group_by(across(all_of(level))) %>%
    summarise_all(sum) %>%
    column_to_rownames(level)

  if(threshold == "min"){
    taxotu_table$threshold <- apply(taxotu_table, 1, min)
  } else if(threshold == "max"){
    taxotu_table$threshold <- apply(taxotu_table, 1, max)
  } else if(threshold == "mean"){
    taxotu_table$threshold <- apply(taxotu_table, 1, mean)
  } else {
    warning("You have not set function option.
            This time, we will show a taxa of at least N%.\n")
    taxotu_table$threshold <- apply(taxotu_table, 1, max)
  }
  undetermined <- taxotu_table["Undetermined", ]

  show_tax <- taxotu_table %>%
    rownames_to_column("domain") %>%
    filter(domain != "Undetermined") %>%
    filter(threshold >= plot_percent) %>%
    column_to_rownames("domain")

  unshow_tax <- taxotu_table %>%
    rownames_to_column("domain") %>%
    filter(domain != "Undetermined") %>%
    filter(threshold < plot_percent) %>%
    column_to_rownames("domain") %>%
    colSums()

  all_list <- list(show_tax, undetermined, unshow_tax)
  all_tax <- purrr::reduce(all_list, rbind)
  n <- nrow(all_tax)
  rownames(all_tax)[n] <- paste0("Others (<",plot_percent,"%)")

  all_tax_table <- all_tax %>%
    select(-threshold) %>%
    t()

  if(nrow(all_tax) > length(COLORS)){
    stop("You have exceeded the number of colors allowed.
         Increase the percent value for thresholds.\n")
  }

  sample_status <- agg_phylo %>%
    sample_data() %>%
    as.matrix() %>%
    as.data.frame() %>%
    rownames_to_column("Sample")

  all_ggdata <- all_tax_table %>%
    as.data.frame() %>%
    rownames_to_column("Sample") %>%
    left_join(sample_status,  by = ("Sample" = "Sample")) %>%
    reshape2::melt()

  taxa_data_uniq <- unique(all_ggdata$variable)
  all_ggdata$Taxa <- factor(all_ggdata$variable, levels = rev(taxa_data_uniq))
  COLORS <- rev(COLORS[1:length(taxa_data_uniq)])
  COLORS[1:2] <- c("grey30", "grey")

  gg_bar <- ggplot2::ggplot(all_ggdata,aes(x = Sample, y=value, fill = Taxa)) +
    geom_bar(stat="identity") +
    facet_grid(~get(plot_category), margins = FALSE,
               drop = TRUE, scales = "free", space = "free") +
    scale_fill_manual(values = COLORS, name = " ") +
    theme_classic() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    ggtitle(level) +
    ylab("Relative abundance (%)")

  return(gg_bar)
}
