setwd("/data3/genome_graphs/CPANG19")

library(ape)
library(ggplot2)
library(ggtree)

# load data matrix
core_dist <- read.table("/data3/genome_graphs/panX_paeru/core_gene_alignments/27_isolates/27_isolates.dst", header=T, row.names=1)
core_mat <- as.matrix(core_dist)

# load isolate background
background <- read.table("playground/Pandora/isolate_background.csv", sep=",", header=TRUE)

# create neighbour-joining tree
core_mat_tree <- nj(core_mat)

# visualise tree (isolate names are apparently a bit too long so the plot needs tweaking)
tr <- ggtree(core_mat_tree, layout="rectangular")
tr <- tr %<+% background + geom_tiplab(aes(color=factor(Background)), size=4)
tr <- tr + scale_color_manual(values=c("black", "darkgray"))
tr <- tr + coord_cartesian(clip = 'off') + 
  theme_tree(plot.margin=margin(6, 60, 6, 6))
tr
