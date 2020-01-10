#!/bin/bash

for dir in /data3/genome_graphs/panX_paeru/core_gene_alignments/27_isolates/*/;
do
  echo ">"$(basename $dir)
  if test -f "$dir/pandora.consensus.fq"; then
    awk -v ORS="NNANN" '(NR%4==2)' $dir/pandora.consensus.fq
  elif test -f "$dir/pandora.consensus.fq.gz"; then
    gunzip $dir/pandora.consensus.fq.gz
    awk -v ORS="NNANN" '(NR%4==2)' $dir/pandora.consensus.fq
  fi
  echo
done >> 27_isolates.merged.fasta
