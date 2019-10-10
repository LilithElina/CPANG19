#!/bin/bash

for i in 0.7 0.5 0.1 0.01
do
  echo $i
  vcffilter -f "AF < ${i}" 1mb1kgp/z.vcf.gz > max_af_${i}_filtered.vcf
  vg construct -r 1mb1kgp/z.fa -v max_af_${i}_filtered.vcf > max_af_${i}.vg
  vg index -x max_af_${i}.xg -g max_af_${i}.gcsa -k 16 max_af_${i}.vg
  vg map -x max_af_${i}.xg -g max_af_${i}.gcsa -G z.sim > max_af_${i}.gam
  vg view -a max_af_${i}.gam | jq .identity | awk '{i+=$1; n+=1} END {print i/n}'
done 