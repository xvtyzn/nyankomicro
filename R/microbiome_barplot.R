#' Create a bacterial composition plot
#'
#' Create a bacterial composition plot using a specific threshold value.
#'
#' @title microbiome_barplot
#' @param physeq phyloseq object
#' @param level taxonomy level
#' @param plot_category metadata category
#' @param plot_percent threshold persent
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
#' @import dplyr
#' @import tibble
#' @import ggplot2
#'
#' @export
#'
#'
microbiome_barplot <- function(physeq, level = c("Kingdom", "Phylum", "Class",
    "Order", "Family", "Genus", "Species"), plot_category, plot_percent = 10,
    threshold = "max", na_str = c("unidentified", "uncultured")) {

    all_ggdata <- microbiome_bardata(physeq, level, plot_category, plot_percent,
                                     threshold, na_str)
    colors <- rev(colors[1:length(taxa_data_uniq)])
    colors[1:2] <- c("grey30", "grey")

    gg_bar <- ggplot2::ggplot(all_ggdata, aes(x = Sample, y = value, fill = Taxa)) +
        geom_bar(stat = "identity") + facet_grid(~get(plot_category), margins = FALSE,
        drop = TRUE, scales = "free", space = "free") + scale_fill_manual(values = colors) +
        theme_classic() + theme(axis.text.x = element_text(angle = 45,
        hjust = 1), legend.text = element_text(face = "italic")) + ylab("Relative abundance (%)") + guides(fill = guide_legend(reverse = TRUE)) +
        labs(fill = level)

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

    all_tax_table <- all_tax %>% select(-c(threshold,mean)) %>% t()

    if (nrow(all_tax) > length(colors)) {
        stop("You have exceeded the number of colors allowed.
         Increase the percent value for thresholds.\n")
    }

    sample_status <- agg_phylo %>% sample_data() %>% as.matrix() %>% as.data.frame() %>%
        rownames_to_column("Sample")

    all_ggdata <- all_tax_table %>% as.data.frame() %>% rownames_to_column("Sample") %>%
        left_join(sample_status, by = ("Sample" = "Sample")) %>% reshape2::melt()

    taxa_data_uniq <- unique(all_ggdata$variable)
    all_ggdata$Taxa <- factor(all_ggdata$variable, levels = rev(taxa_data_uniq))
    return(all_ggdata)
}

