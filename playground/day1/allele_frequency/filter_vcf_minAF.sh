#!/bin/bash

for i in 0.7 0.5 0.1 0.01
do
  echo $i
  vcffilter -f "AF > ${i}" 1mb1kgp/z.vcf.gz > min_af_${i}_filtered.vcf
  vg construct -r 1mb1kgp/z.fa -v min_af_${i}_filtered.vcf > min_af_${i}.vg
  vg index -x min_af_${i}.xg -g min_af_${i}.gcsa -k 16 min_af_${i}.vg
  vg map -x min_af_${i}.xg -g min_af_${i}.gcsa -G z.sim > min_af_${i}.gam
  vg view -a min_af_${i}.gam | jq .identity | awk '{i+=$1; n+=1} END {print i/n}'
done 