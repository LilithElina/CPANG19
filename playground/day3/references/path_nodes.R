setwd("/data3/genome_graphs/CPANG19")
library(jsonlite)
library(tidyverse)
library(tidyjson)
library(VennDiagram)

# extract only the "path" part from the JSON using jq on the command line
path_file <- read_file("playground/day3/references/FivePsaeAnnot_zwf1_paths.json")

# extract node IDs per path
nodes <- path_file %>%
  as.tbl_json %>%
  gather_array %>%
  spread_values(name=jstring("name")) %>%
  enter_object("mapping") %>%
  gather_array %>%
  enter_object("position") %>%
  spread_values(node=jnumber("node_id"))

# get only nodes of paths of interest and make a venn diagram
noi <- nodes %>%
  group_by(name) %>%
  filter(all(name %in% c("cdhA", "phzC2", "pys2", "zwf1"))) %>%
  group_split() %>%
  sapply("[[", "node") %>%
  venn.diagram(filename="playground/day3/pics/venn_zwf1.png", imagetype="png",
               category.names=c("cdhA", "phzC2", "pys2", "zwf1"))
# Careful with category.names! They will be in oder of the paths, not in order of the filter command.



# count node IDs per path
path_nodes <- nodes %>%
  group_by(name) %>%
  summarise(nodes=n_distinct(node))

# get the nodes per path
paths <- nodes %>%
  group_split(name)