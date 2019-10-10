setwd("/data3/genome_graphs/CPANG19/playground/day1")
options(stringsAsFactors=FALSE)

library(tidyverse)

bwa <- read.table("bwa_mem.scores.tsv", header=FALSE)
vg <- read.table("vg_map.scores.tsv", header=FALSE, fill=TRUE)

sum(is.na(vg$V2))

bwa[duplicated(bwa$V1), ]
vg[duplicated(vg$V1), ]

bwa.flt <- bwa %>%
  group_by(V1) %>%
  filter(!any(row_number() > 1)) %>%
  ungroup()

combi <- full_join(bwa.flt, vg, by="V1")
colnames(combi) <- c("read.name", "bwa.score", "vg.score")

combi <- combi %>%
  mutate(vg.score-bwa.score)
colnames(combi) <- c("read.name", "bwa.score", "vg.score", "diff")

ggplot(combi, aes(diff)) + geom_histogram() + theme_minimal()
table(combi$diff)
