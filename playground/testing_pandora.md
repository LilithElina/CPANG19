
## Testing Pandora with panX data

Pandora needs pangenome graphs as input in order to work. These should be generated with [make_prg](https://github.com/rmcolq/make_prg), and the usage example on [GitHub](https://github.com/rmcolq/pandora) suggests to use multiple sequence alignments from [panX](http://pangenome.de/) as input for that. Great, this looks like something Sara would like!

I'm going to download "core gene alignments" and "all gene alignments" for *Pseudomonas aeruginosa*, of course. I wish you could do that using wget or something...

```bash
cd /data3/genome_graphs/
mkdir panX_paeru
cd panX_paeru
wget http://pangenome.de/dataset/Pseudomonas_aeruginosa/core_gene_alignments.tar.gz
wget http://pangenome.de/dataset/Pseudomonas_aeruginosa/all_gene_alignments.tar.gz
```

### Core genes

Well then, make_prg needs an index file of the multiple sequence alignments it's going to combine.

```
tar -xzvf core_gene_alignments.tar.gz
```