#' Title
#'
#' @param physeq
#' @param category
#'
#' @return
#' @export
#'
#' @examples
taxonomy_plot <- function(physeq, category = NULL){

  # categoryごとに描くことを放置
  # category_list <- physeq %>%
  #   sample_data() %>%
  #   as_tibble() %>%
  #   select(!!sym(category)) %>%
  #   unlist() %>%
  #   unique() %>%
  #   as_tibble()

   tax_phy <- physeq %>%
    tax_table()

   tax_asv_rate_plot <- annotate_rate(physeq) %>%
     ggplot(aes(x = domain, y = count)) +
     geom_bar(stat = "identity", position = "dodge") + theme_minimal()

   return(tax_asv_rate_plot)
}

#' Title
#'
#' @param physeq
#'
#' @return
#' @export
#'
#' @examples
annotate_rate <- function(physeq){
  tax_df <- physeq %>%
    tax_table %>% as.data.frame

  tax_num <- nrow(tax_df)
  domain_name <- c("Kingdom", "Phylum", "Class", "Order", "Family", "Genus", "Species")

  rate_domain <- domain_name %>%
    map_dbl(abundace_cal, tax_df, tax_num)

  count_tb <- tibble(domain = factor(domain_name, levels = domain_name),
                    count = rate_domain)
  return(count_tb)
}

#' Title
#'
#' @param tax
#' @param df
#' @param tax_num
#'
#' @return
#' @export
#'
#' @examples
abundace_cal <- function(tax, df, tax_num){

  rate <- df %>%
    select(tax) %>%
    na.omit %>%
    nrow %>%
    divide_by(tax_num)

  return(rate)
}

