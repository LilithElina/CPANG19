---
layout: page
title: Q&A
---

* Do not remove this line (it will not be displayed)
{:toc}

## vg

### [Day 1]({{ site.baseurl }}{% post_url 2019-10-07-toy_examples_protocol %})

- How to choose `k` for GCSA indexing or graph construction?
- What are the length values in the mapping results?
- Why do some reads not have a mapping score in vg?

### [Day 2]({{ site.baseurl }}{% post_url 2019-10-14-HIV_exercises_protocol %})

- How to decide on a `-x` setting in minimap2?
- What is the significance of the additional output of `odgi viz`?
- Is there still a pileup option/tool somewhere, if `vg augment` doesn't do it?
- What is the problem with `vg augment -i`?
- What's so tricky about augmenting the graph with long reads? Why don't they fit to the references better?

### [Day 3]({{ site.baseurl }}{% post_url 2019-11-13-bacteria_exercises_protocol %})

- Is there another way to visualise a whole genome graph?
- How can I annotate the graph? Is a specific formatting of GFF files required?
  - The files just have to strictly follow the specifications, I believe.
- How does `vg viz` work compared to `vg view (-d)`? Are the nodes sorted differently, and if so, why?
- How does `vg find -N` work? Why are more nodes included than were on the list?

## [Pandora]({{ site.baseurl }}{% post_url 2019-09-27-testing_pandora %})

Answers are mostly from Zamin Iqbal and [Rachel Colquhoun](https://lilithelina.github.io/CPANG19/exercise/psae/2019/09/27/testing_pandora.html#comment-4719203354).

### General

- What are the numbers in the PRG file?
  - They are separators of different paths in the graph.
- Why are single gene graphs so loopy?
  - This is due to the way Bandage visualises the graphs, maybe try a different tool.
- Why don't we get the same output when mapping single or multiple samples?
  - "There are slightly different output files when running pandora map on a single sample or pandora compare on several. The reason for this is that they are designed to be used in different scenarios. It doesn't really make sense to run pandora map separately on many samples and then "merge" the VCFs because each will be with respect to a different reference by default. However, we may want to know what gene sequences we see when we only have a single sample and that is why we still have pandora map as an option."

### `pandora map`

- Where can I find gene presence/absence information?
  - ~~There *should* be a matrix file.~~ It can be inferred from the pandora.consensus.fq.gz file, since that contains all mosaic sequences ffor genes that were found in the sample.
- Suggestion for fasta reference for VCF creation when using panX data?
  - That is not necessary to create a VCF file, you just need to use the `--output_vcf` or `--genotype` options (additional explanation [here](https://github.com/rmcolq/pandora/issues/205)).
- What does the de novo discovery do, exactly?
  - The de novo discovery tool can be used to augment/complement the original graph.
- What are the graphs created after mapping?

### `pandora compare`

- What are the sequences in pandora_multisample.vcf_ref.fa?
  - "The sequences in the pandora_multisample.vcf_ref.fa are the "reference sequence" which the VCF is with respect to. Because the reference contains multiple alleles, we have to pick one of them to be the equivalent of the "wild type". These reference sequences are chosen as paths through the graph, aiming to minimize the distance between each sample and this "reference" (so that we get more SNPs in the VCF and fewer long alleles called)"
- What is the GAPS value in the VCF files?
  - "When we calculate the coverage on an allele, we are actually calculating the coverage on kmers which cover the allele. Similarly, we can look at the fraction of these kmers which have no coverage. This is represented by the GAPS field. If an allele is the true allele, not only do we expect to see (relatively) consistent/high coverage over the allele, we also do not expect to see many kmers with no coverage overlapping that allele."
- What does it mean when a variant has almost equal forward and reverse coverage?
  - " For Illumina data, most variants should have almost equal forward and reverse coverage because we expect on average half of reads to have been generated in the forward direction along the genome, and half in the reverse. For Nanopore data, sequencing biases make it more likely to have a skew between the coverage each way."
- What is the reference in the VCF file?
  - The reference are the sequences in pandora_multisample.vcf_ref.fa.

