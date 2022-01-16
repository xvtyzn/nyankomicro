#' Create a bacterial composition plot
#'
#' Create a bacterial composition plot using a specific threshold value.
#'
#' @title microbiome_barplot
#' @param physeq phyloseq object
#' @param level taxonomy level
#' @param plot_category metadata category (expect a vector of strings containing categories)
#' @param plot_percent threshold persent
#' @param color_methods coloring methods
#' @param manual_color_palette
#' @param threshold the way of calculating threshold values
#' @param na_str taxa name to be Undetermined
#'
#' @return barplot of microbiome composition as ggplot2 object
#' @importFrom speedyseq tax_glom
#' @importFrom phyloseq transform_sample_counts
#' @importFrom phyloseq tax_table
#' @importFrom phyloseq otu_table
#' @importFrom phyloseq sample_data
#' @importFrom reshape2 melt
#' @importFrom purrr reduce
#' @importFrom stats formula
#' @importFrom purrr is_null
#' @import dplyr
#' @import tibble
#' @import ggplot2
#' @import ggh4x
#'
#' @export
#'
#'
microbiome_barplot <- function(physeq, level = c("Kingdom", "Phylum", "Class",
    "Order", "Family", "Genus", "Species"), plot_category, plot_percent = 10,
    color_methods = c("abundance", "common", "manual"), manual_color_palette = NULL,
    threshold = "max", na_str = c("unidentified", "uncultured")) {

    all_ggdata <- microbiome_bardata(physeq, level, plot_category, plot_percent,
                                     threshold, na_str)

    if(color_methods == "abundance"){
      colors <- rev(colors[1:length(unique(all_ggdata$Taxa))])
      colors[1:2] <- c("grey30", "grey")
    } else if(color_methods == "common"){
      undetermined_names <- c("Undetermined", as.character(unique(all_ggdata$Taxa[nrow(all_ggdata)])))

      colors <- switch(level,
                       "Kingdom" = colors_kingdom,
                        "Phylum" = colors_phylum,
                        "Class" = colors_class,
                        "Order" = colors_order,
                        "Family" = colors_family,
                        "Genus" = colors_genus)

      # アノテーションに含まれるもののみを取り出す
      colors <- colors[names(colors) %in% as.character(unique(all_ggdata$Taxa))]

      add_taxnomy <- switch(level,
                            "Phylum" = setdiff(unique(all_ggdata$Taxa), c(names(colors_phylum), undetermined_names)),
                            "Class" = setdiff(unique(all_ggdata$Taxa), c(names(colors_class), undetermined_names)),
                            "Order" = setdiff(unique(all_ggdata$Taxa), c(names(colors_order), undetermined_names)),
                            "Family" = setdiff(unique(all_ggdata$Taxa), c(names(colors_family), undetermined_names)),
                            "Genus" = setdiff(unique(all_ggdata$Taxa), c(names(colors_genus), undetermined_names)))

      add_taxnomy_colors <- switch(level,
                                   "Phylum" = colors_phylum_other[1:length(add_taxnomy)],
                                   "Class" = colors_class_other[1:length(add_taxnomy)],
                                   "Order" = colors_order_other[1:length(add_taxnomy)],
                                   "Family" = colors_family_other[1:length(add_taxnomy)],
                                   "Genus" = colors_genus_other[1:length(add_taxnomy)])

      names(add_taxnomy_colors) <- add_taxnomy
      other_color <- c("grey", "grey30")
      names(other_color) <- undetermined_names
      colors <- rev(c(colors, add_taxnomy_colors, other_color))

    } else if (color_methods == "manual"){

      if(is_null(manual_color_palette)){
        stop("カラーパレットが指定されていません")
      } else {
        undetermined_names <- c("Undetermined", as.character(unique(all_ggdata$Taxa[nrow(all_ggdata)])))
        other_color <- c("grey", "grey30")
        names(other_color) <- undetermined_names

        colors <- manual_color_palette[[1]]
        colors <- colors[names(colors) %in% as.character(unique(all_ggdata$Taxa))]

        remaining_tax <- setdiff(unique(all_ggdata$Taxa), c(names(colors), undetermined_names))
        add_colors <- manual_color_palette[[2]][1:length(remaining_tax)]
        names(add_colors) <- remaining_tax

        colors <- rev(c(colors, add_colors,other_color))
      }

    } else{
      stop("有効なcolor methodsが指定されていません")
    }


    gg_bar <- ggplot2::ggplot(all_ggdata, aes(x = Sample, y = value, fill = Taxa)) +
      geom_bar(stat = "identity") +
      facet_nested(formula(paste("~",paste(plot_category, collapse = "+"))), margins = FALSE,
                   drop = TRUE, scales = "free", space = "free") +
      scale_fill_manual(values = colors) +
      theme_classic() + theme(axis.text.x = element_text(angle = 45,hjust = 1)) +
      ylab("Relative abundance (%)") +
      guides(fill = guide_legend(reverse = TRUE)) +
      labs(fill = level)

    if(level %in% c("Family", "Genus", "Species")){
      gg_bar <- gg_bar + theme(axis.text.x = element_text(angle = 45,hjust = 1),
                               legend.text = element_text(face = "italic"))
    }

    return(gg_bar)
}


#' Create a bacterial composition data for a plot
#'
#' Create a bacterial composition data using a specific threshold value.
#'
#' @title microbiome_barplot
#' @param physeq phyloseq object
#' @param level taxonomy level
#' @param plot_category metadata category
#' @param plot_percent threshold persent
#' @param threshold the way of calculating threshold values
#' @param na_str taxa name to be Undetermined
#'
#' @return
#' @export
#' @return barplot of microbiome composition as ggplot2 input data
#' @importFrom speedyseq tax_glom
#' @importFrom phyloseq transform_sample_counts
#' @importFrom phyloseq tax_table
#' @importFrom phyloseq otu_table
#' @importFrom phyloseq sample_data
#' @importFrom reshape2 melt
#' @importFrom purrr reduce
#' @import dplyr
#' @import tibble
#' @import ggplot2
#'
#' @examples
microbiome_bardata <- function(physeq, level = c("Kingdom", "Phylum", "Class",
                                                 "Order", "Family", "Genus", "Species"), plot_category, plot_percent = 10,
                               threshold = "max", na_str = c("unidentified", "uncultured")) {

    agg_phylo <- speedyseq::tax_glom(physeq, level, NArm = F)
    agg_phylo_rel <- transform_sample_counts(agg_phylo, function(x) 100 * x/sum(x))
    level_tax <- tax_table(agg_phylo_rel)[, level] %>% as.data.frame() %>% rownames_to_column("ASV")

    if (!is.character(level_tax[,2])){
      level_tax[,2] <- as.character(level_tax[,2])
      }

    level_tax[is.na(level_tax)] <- "Undetermined"

    taxotu_table <- otu_table(agg_phylo_rel) %>% as.data.frame() %>% rownames_to_column("ASV") %>%
        left_join(level_tax, by = ("ASV" = "ASV")) %>% select(-ASV) %>% group_by(across(all_of(level))) %>%
        summarise_all(sum) %>% remove_rownames() %>% column_to_rownames(level)
    taxotu_table$mean <- apply(taxotu_table, 1, mean)

    if (threshold == "min") {
        taxotu_table$threshold <- apply(taxotu_table, 1, min)
    } else if (threshold == "max") {
        taxotu_table$threshold <- apply(taxotu_table, 1, max)
    } else if (threshold == "mean") {
        taxotu_table$threshold <- apply(taxotu_table, 1, mean)
    } else {
        warning("You have not set function option.
            This time, we will show a taxa of at least N%.\n")
        taxotu_table$threshold <- apply(taxotu_table, 1, max)
    }

    undetermined_str <- paste(c("Undetermined", na_str), collapse = "|")

    undetermined <- taxotu_table %>%
        rownames_to_column("domain") %>%
        filter(grepl(undetermined_str, domain)) %>%
        column_to_rownames("domain") %>%
        colSums()

    show_tax <- taxotu_table %>% rownames_to_column("domain") %>% filter(!grepl(undetermined_str, domain)) %>%
        filter(threshold >= plot_percent) %>% column_to_rownames("domain") %>%
        arrange(desc(mean))

    unshow_tax <- taxotu_table %>% rownames_to_column("domain") %>% filter(!grepl(undetermined_str, domain)) %>%
        filter(threshold < plot_percent) %>% column_to_rownames("domain") %>%
        colSums()

    all_list <- list(show_tax, undetermined, unshow_tax)
    all_tax <- purrr::reduce(all_list, rbind)
    n <- nrow(all_tax)
    rownames(all_tax)[n-1] <- "Undetermined"
    rownames(all_tax)[n] <- paste0("Others (<", plot_percent, "%)")

    all_tax_table <- all_tax %>% dplyr::select(-c(threshold,mean)) %>% t()

    sample_status <- agg_phylo %>% sample_data() %>% as.matrix() %>% as.data.frame() %>%
        rownames_to_column("Sample")

    all_ggdata <- all_tax_table %>% as.data.frame() %>% rownames_to_column("Sample") %>%
        left_join(sample_status, by = ("Sample" = "Sample")) %>% reshape2::melt()

    taxa_data_uniq <- unique(all_ggdata$variable)
    all_ggdata$Taxa <- factor(all_ggdata$variable, levels = rev(taxa_data_uniq))
    return(all_ggdata)
}

#' create manual palette
#'
#' @param taxonomy_vec
#'
#' @return
#' @export
#'
#' @examples
create_color_palette <- function(taxonomy_vec){

  manual_colors <- colors[1:length(taxonomy_vec)]
  names(manual_colors) <- taxonomy_vec
  tmp1 <- length(taxonomy_vec)+1
  tmp2 <- length(colors) - length(taxonomy_vec)
  remaining_colors <- colors[tmp1:tmp2]
  return_color <- list(manual_colors, remaining_colors)

  return(return_color)
}
