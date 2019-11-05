# Read file containing paths (list of nodes) for every haplotype
tab <- read.delim('nodes_all.txt', quote = "\"", head = F, sep = ' ')[, 3:4]
tab <- apply(tab, 2, as.character)
idx_name <- grep("name", tab[, 1])
idx_nodes <- grep("nodes", tab[, 1])
# Parse the table so that haplotypes are in column 1 and nodelists are in column 2
df <- cbind.data.frame(haplotype = tab[idx_name, 2], nodelist = tab[idx_nodes, 2])
df$haplotype <- gsub(pattern = ',',replacement = '', df$haplotype)
# Add a column indicating the gene
df$gene <- do.call(rbind, strsplit(do.call(rbind, strsplit(df$haplotype, split = "_"))[, 2], split = "\\*"))[, 1]

library(data.table)
# Get filenames containing coverage, for every sample
f <- list.files(pattern = "*.cov.txt")

# Calculate the mean coverage for every haplotye and sample
haplocovs <- sapply(f, function(i) {
  cov <- fread(i, head = T, key = 'node.id')
  
  haplocov <- sapply(df$nodelist, function(x){
    nodelist <- as.integer(unlist(strsplit(as.character(x), split = ',')))
    n <- cov[.(nodelist), mean(coverage),]
    return(n)
  })
  
  return(haplocov)
})

df <- cbind(df, haplocovs)
df$nodelist <- NULL


a <- df[df$gene== 'A', c(1, 11)]
a[order(a[,2], decreasing = T),]


dt <- data.table(df, key = 'gene')
dt <- melt(dt)

setkey(dt, 'gene')


dt2 <- dt[, list(haplotype[which.max(value)]), by = c('gene', 'variable')]
df2 <- as.data.frame(dt2)

df2[df2$gene == 'A' & grepl('HG0051', df2$variable),]

hg0051 <- dcast(df2[grepl('HG0051', df2$variable),], gene ~ variable)
hg0051[apply(hg0051[,2:4],1, FUN = function(x) length(unique(x)) > 1),]
