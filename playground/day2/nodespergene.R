setwd("/data3/genome_graphs/CPANG19")
library(jsonlite)
library(tidyverse)
library(tidyjson)

# extract only the "path" part from the JSON using jq on the command line
paths <- read_file("playground/day2/6ref_annot_paths.json")
prettyp <- prettify(paths)

# extract node IDs per path
nodes <- paths %>%
  as.tbl_json %>%
  gather_array %>%
  spread_values(name=jstring("name")) %>%
  enter_object("mapping") %>%
  gather_array %>%
  enter_object("position") %>%
  spread_values(node=jnumber("node_id"))

# count node IDs per path
path_nodes <- nodes %>%
  group_by(name) %>%
  summarise(nodes=n_distinct(node))

# get gene length (downloaded tab-separated annotation from NCBI)
#!! length does not fit GFF annotation (prob protein length?) !! calculate from stop-start instead
annot <- read.table("playground/day2/GCF_000864765.1_ViralProj15476_genomic.tab", header=TRUE, sep="\t")
annot$gene.length <- annot$Stop-annot$Start

gene_nodes <- path_nodes[path_nodes$name %in% annot$Locus, ]
genes <- merge(gene_nodes, annot, by.x="name", by.y="Locus")

plot(genes$nodes, genes$gene.length)

variability <- data.frame(
  gene = genes$name,
  nodes = genes$nodes,
  length = genes$gene.length,
  norm.nodes = genes$nodes/genes$Length
)

ggplot(variability, aes(gene,norm.nodes)) +
  geom_point() + 
  ylab("number of nodes / gene length") + xlab("viral structural proteins") +
  labs(title="Number of nodes per gene", subtitle="divided by 'length' in the annotation") + 
  theme_linedraw()