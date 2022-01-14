colors <- c("#E41A1C", "#377EB8", "#4DAF4A", "#984EA3", "#FF7F00", "#FFFF33",
            "#A65628", "#F781BF", "#66C2A5", "#FC8D62", "#8DA0CB", "#E78AC3", "#A6D854",
            "#FFD92F", "#E5C494", "#B3B3B3", "#8DD3C7", "#FFFFB3", "#BEBADA", "#FB8072",
            "#80B1D3", "#FDB462", "#B3DE69", "#FCCDE5", "#D9D9D9", "#BC80BD", "#CCEBC5",
            "#FFED6F", "#A6CEE3", "#1F78B4", "#B2DF8A", "#33A02C", "#FB9A99", "#E31A1C",
            "#FDBF6F", "#FF7F00", "#CAB2D6", "#6A3D9A", "#FFFF99", "#B15928")

colors_kingdom <- c("Bacteria" = "#E41A1C",
                    "Archaea" = "#377EB8",
                    "Eukaryota" = "#4DAF4A")

colors_phylum <- c("Proteobacteria" = "#E41A1C",
                   "Firmicutes" = "#377EB8",
                   "Actinobacteriota" = "#4DAF4A",
                   "Bacteroidota" = "#984EA3",
                   "Cyanobacteria" = "#FF7F00",
                   "Desulfobacterota" = "#FFFF33",
                   "Chloroflexi" = "#A65628",
                   "Halobacterota" = "#F781BF",
                   "Spirochaetota" = "#66C2A5",
                   "Campylobacterota" = "#FC8D62")

colors_phylum_other <- c("#8DA0CB", "#E78AC3", "#A6D854", "#FFD92F", "#E5C494", "#B3B3B3", "#8DD3C7",
                         "#FFFFB3", "#BEBADA", "#FB8072",
                   "#80B1D3", "#FDB462", "#B3DE69", "#FCCDE5", "#D9D9D9", "#BC80BD", "#CCEBC5",
                   "#FFED6F", "#A6CEE3", "#1F78B4", "#B2DF8A", "#33A02C", "#FB9A99", "#E31A1C",
                   "#FDBF6F", "#FF7F00", "#CAB2D6", "#6A3D9A", "#FFFF99", "#B15928")

colors_class <- c("Gammaproteobacteria" = "#E41A1C",
                  "Bacilli" = "#377EB8",
                  "Actinobacteria" = "#4DAF4A",
                  "Alphaproteobacteria" = "#984EA3",
                  "Clostridia" = "#FF7F00",
                  "Bacteroidia" = "#FFFF33",
                  "Cyanobacteriia" = "#A65628",
                  "Anaerolineae" = "#F781BF",
                  "Syntrophia" = "#66C2A5",
                  "Spirochaetia" = "#FC8D62",
                  "Campylobacteria" = "#8DA0CB",
                  "Synergistia" = "#E78AC3")

colors_class_other <- c("#A6D854",
                        "#FFD92F", "#E5C494", "#B3B3B3", "#8DD3C7", "#FFFFB3", "#BEBADA", "#FB8072",
                        "#80B1D3", "#FDB462", "#B3DE69", "#FCCDE5", "#D9D9D9", "#BC80BD", "#CCEBC5",
                        "#FFED6F", "#A6CEE3", "#1F78B4", "#B2DF8A", "#33A02C", "#FB9A99", "#E31A1C",
                        "#FDBF6F", "#FF7F00", "#CAB2D6", "#6A3D9A", "#FFFF99", "#B15928")

colors_order <- c("Enterobacterales" = "#E41A1C",
                  "Bacillales" = "#377EB8",
                  "Lactobacillales" = "#4DAF4A",
                  "Pseudomonadales" = "#984EA3",
                  "Burkholderiales" = "#FF7F00",
                  "Micrococcales" = "#FFFF33",
                  "Rhizobiales" = "#A65628",
                  "Streptomycetales" = "#F781BF",
                  "Chloroplast" = "#66C2A5",
                  "Bacteroidales" = "#FC8D62",
                  "Corynebacteriales" = "#8DA0CB",
                  "Peptostreptococcales-Tissierellales" = "#E78AC3",
                  "Flavobacteriales" = "#A6D854",
                  "Staphylococcales" = "#FFD92F",
                  "Anaerolineales" = "#E5C494")

colors_order_other <- c("#B3B3B3", "#8DD3C7", "#FFFFB3", "#BEBADA", "#FB8072",
                        "#80B1D3", "#FDB462", "#B3DE69", "#FCCDE5", "#D9D9D9", "#BC80BD", "#CCEBC5",
                        "#FFED6F", "#A6CEE3", "#1F78B4", "#B2DF8A", "#33A02C", "#FB9A99", "#E31A1C",
                        "#FDBF6F", "#FF7F00", "#CAB2D6", "#6A3D9A", "#FFFF99", "#B15928")

colors_family <- c("Morganellaceae" = "#E41A1C",
                   "Bacillaceae" = "#377EB8",
                   "Pseudomonadaceae" = "#4DAF4A",
                   "Lactobacillaceae" = "#984EA3",
                   "Enterobacteriaceae" = "#FF7F00",
                   "Moraxellaceae" = "#FFFF33",
                   "Streptomycetaceae" = "#A65628",
                   "Streptococcaceae" = "#F781BF",
                   "Enterococcaceae" = "#66C2A5",
                   "Rhizobiaceae" = "#FC8D62",
                   "Microbacteriaceae" = "#8DA0CB",
                   "Staphylococcaceae" = "#E78AC3",
                   "Vibrionaceae" = "#A6D854",
                   "Micrococcaceae" = "#FFD92F",
                   "Anaerolineaceae" = "#E5C494",
                   "Comamonadaceae" = "#B3B3B3",
                   "Flavobacteriaceae" = "#8DD3C7",
                   "Burkholderiaceae" = "#FFFFB3",
                   "Rhodobacteraceae" = "#BEBADA")

colors_family_other <- c("#FB8072",
                          "#80B1D3", "#FDB462", "#B3DE69", "#FCCDE5", "#D9D9D9", "#BC80BD", "#CCEBC5",
                          "#FFED6F", "#A6CEE3", "#1F78B4", "#B2DF8A", "#33A02C", "#FB9A99", "#E31A1C",
                          "#FDBF6F", "#FF7F00", "#CAB2D6", "#6A3D9A", "#FFFF99", "#B15928")

colors_genus <- c("Bacillus" = "#E41A1C",
                  "Arsenophonus" = "#377EB8",
                  "Pseudomonas" = "#4DAF4A",
                  "Streptomyces" = "#984EA3",
                  "Acinetobacter" = "#FF7F00",
                  "Enterococcus" = "#FFFF33",
                  "Streptococcus" = "#A65628",
                  "Staphylococcus" = "#F781BF",
                  "Buchnera" = "#66C2A5",
                  "Vibrio" = "#FC8D62",
                  "Microbacterium" = "#8DA0CB",
                  "Escherichia-Shigella" = "#E78AC3",
                  "Enterobacter" = "#A6D854")

colors_genus_other <- c("#FFD92F", "#E5C494", "#B3B3B3", "#8DD3C7", "#FFFFB3", "#BEBADA", "#FB8072",
                        "#80B1D3", "#FDB462", "#B3DE69", "#FCCDE5", "#D9D9D9", "#BC80BD", "#CCEBC5",
                        "#FFED6F", "#A6CEE3", "#1F78B4", "#B2DF8A", "#33A02C", "#FB9A99", "#E31A1C",
                        "#FDBF6F", "#FF7F00", "#CAB2D6", "#6A3D9A", "#FFFF99", "#B15928")
