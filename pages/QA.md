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

## [Pandora]({{ site.baseurl }}{% post_url 2019-09-27-testing_pandora %})

### General

- What are the numbers in the PRG file?
  - They are separators of different paths in the graph.
- Why are single gene graphs so loopy?
  - This is due to the way Bandage visualises the graphs, maybe try a different tool.
- Why don't we get the same output when mapping single or multiple samples?

### `pandora map`

- Where can I find gene presence/absence information?
  - There *should* be a matrix file.
- Suggestion for fasta reference for VCF creation when using panX data?
  - That *should* not be necessaryto create a VCF file.
- What does the de novo discovery do, exactly?
  - The de novo discovery tool can be used to augment/complement the original graph.
- What are the graphs created after mapping?

### `pandora compare`

- What are the sequences in pandora_multisample.vcf_ref.fa?
- What is the GAPS value in the VCF files?
- What does it mean when a variant has almost equal forward and reverse coverage?
