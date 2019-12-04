#!/usr/bin/env python3
# -*- coding: utf-8 -*-

#-------------------------------------------------------------------------------
# Name:         CleanCombineGff.py
# Purpose:      clean and combine GFF files form pseudomonas.com to annotate 
#               variant graphs
#
# Author:       spo12
#
# Created:      19.11.2019
# Updated:      25.11.2019
# Copyright:    (c) spo12 2019
#-------------------------------------------------------------------------------



## Load libraries and prepare global variables ##
import sys
from collections import defaultdict

annots = {}
features = set()
genes = []

## Check argument(s) ##

try:
  infile = sys.argv[1]
except:
  print("\nPlease identify an input file with GFF files to use\n")
  sys.exit()


## Load GFF files ##
# Open the input file and read the lines containing the gff file information.
# Split file name and genome name, and save the genome name as key for a new
# dictionary of dictionaries in the annots dictionary.
# Then open the annotation file and, looping over the lines, skip the header
# lines. Clean and split the annotation lines and add the feature names to
# a set which can be printed to check what kind of features the annotations
# contain. Exclude features such as "region" from the annotations, then 
# extract feature information like start and stop coordinates.
# Take the attribute string and split it at the separating semicolons. Loop
# over the single attributes and capitalise the first letter of every tag
# (since that is apparently expected by vg). Save the changed information in
# a list which can then be joined with semicolons again (to avoid having one)
# after the last attribute).
# Find "Name", "Alias", or "Locus" tags in the attributes and save them
# for reference. Using the defaultdict(dict) method, create dictionary
# entries for each start_stop feature position consisting again of
# dictionaries with one entry per feature at that location (to combine
# gene and CDS features, for example). That key value pair has the gene 
# name, alias, or locus tag (if applicable, and feature type otherwise) as
# key, and a modified GFF file line as value. To create this line, remove
# the first (seqid) and last (attributes) from the original line and add
# in the changed attributes (with capital letter tags).

with open(infile, "r") as f:
  for line in f:
    line = line.rstrip()
    info = line.split("\t")
    ref = info[1]
    annots[ref] = defaultdict(dict)
    with open(info[0]) as gff:
      for l in gff:
        if not l.startswith("#"):
          l = l.rstrip()
          i = l.split("\t")
          features.add(i[2])
          typ = i[2]
          if typ != "region":
            start = i[3]
            end = i[4]
            reg = "%s_%s" %(start, end)
            att = i[8]
            atts = att.split(";")
            attl = []
            for a in atts:
              b = a[:1].upper() + a[1:]
              attl.append(b)
            attn = ";".join(attl)
            pos_n = attn.rfind("Name")
            pos_a = attn.rfind("Alias")
            pos_l = attn.rfind("Locus")
            if pos_n != -1:
              name = attn[pos_n+5:].split(";")
              gene = name[0]
            elif pos_a != -1:
              alias = attn[pos_a+6:].split(";")
              gene = alias[0]
            elif pos_l != -1:
              locus = attn[pos_l+6:].split(";")
              gene = locus[0]
            else:
              gene = typ
            i.pop()
            i.append(attn)
            annots[ref][reg][gene] = "\t".join(i[1:])

## Create a combined annotation ##
# Create a new GFF output file, identifying the gff version in the header
# similar to the input files.
# Loop over the annots dictionary structure using keys and values - one key
# per reference genome. Then loop over keys and values of the sub-dictionary
# containing information per location (start_stop information). Check if 
# there is more than one key-value pair, and if so (it's always CDS and gene)
# find the "gene" one. Take the gene or feature names and collect them in
# a list to check for duplicates. Anything not seen before is printed to the
# output file.

with open("PseudomonasAnnotation.gff", "w") as out:
  out.write("#gff-version 3")
  for key, value in annots.items():
    for k, v in value.items():
      if len(v.keys()) >= 2:
        if v[list(v)[0]].find("gene", 0, 72) != -1:
          gene = list(v)[0]
        else:
          gene = list(v)[1]
      else:
        gene = list(v)[0]
      if gene not in genes:
        genes.append(gene)
        out.write("\n"+ key +"\t"+ v[gene])
