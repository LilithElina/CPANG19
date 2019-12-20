#!/usr/bin/env python3
# -*- coding: utf-8 -*-

#-------------------------------------------------------------------------------
# Name:         CleanCombineGff.py
# Purpose:      clean and combine GFF files form pseudomonas.com to annotate 
#               variant graphs
# 
# NOTE:         Make sure there are no extra semicolons in the attributes field!
#
# Author:       spo12
#
# Created:      18.12.2019
# Updated:      20.12.2019
# Copyright:    (c) spo12 2019
#-------------------------------------------------------------------------------



## Load libraries and prepare global variables ##
import sys
import re
from collections import defaultdict

annots = {}
features = set()

## Check argument(s) ##

try:
  infile = sys.argv[1]
except:
  print("\nPlease identify an input file with GFF files to use\n")
  sys.exit()


## Load GFF files ##
# Open the input file and read the lines containing the gff file information.
# Split file name and genome name, and save the genome name as key for a new
# dictionary in the annots dictionary.
# Then open the annotation file and, looping over the lines, skip the header
# lines. Clean and split the annotation lines and add the feature names to
# a set which can be printed to check what kind of features the annotations
# contain. Exclude features such as "region" from the annotations, then 
# extract feature information like start and stop coordinates.
# Take the attribute string and split it at the separating semicolons. Also
# start a new dictionary for each annotation line. Loop over the single
# attributes and capitalise the first letter of every tag (since that is
# apparently expected by vg). Then split the attribute string at the equal
# sign that is not surrounded by whitespace to create key,value pairs. Add
# those to the temporary attributes dictionary.
# Look for "Locus" in the attributes, as this marks CDS annotations which have
# the protein/product description as "Name". Replace that "Name" with the
# "Locus" tag. If both "Alias" and "Name" are present, join both, else if only
# "Alias" is present, assign the "Alias" (locus tag) also as "Name". If all
# else fails and "Name" does not exist, create the "Name" attribute as the type
# of the feature (gene, CDS, ...).
# Join the entries in the attributes dictionary into a GFF ready string.
# Remove the old attributes element from the annotation line and instead add
# the new string.
# Using the defaultdict(dict) method, create dictionary entries for each
# start_stop feature position consisting again of dictionaries with one entry
# per feature at that location (to combine gene and CDS features, for example).

with open(infile, "r") as f:
  for line in f:
    line = line.rstrip()
    info = line.split("\t")
    ref = info[1]
    annots[ref] = defaultdict(list)
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
            attd = {}
            for a in atts:
              if a:
                b = a[:1].upper() + a[1:]
                key,value = re.compile("(?<=\S)\=(?=\S*)").split(b)
                attd[key] = value
            if "Locus" in attd:
              attd["Name"] = attd["Locus"]
            elif "Alias" in attd and "Name" in attd:
              attd["Name"] += "_" + attd["Alias"]
            elif "Alias" in attd and not "Name" in attd:
              attd["Name"] = attd["Alias"]
            elif "Name" not in attd:
              attd["Name"] = typ
            attn = ";".join(['{}={}'.format(k,v) for k,v in attd.items()])
            i.pop()
            i.append(attn)
            annots[ref][reg].append("\t".join(i[1:]))


## Create a combined annotation ##
# Create a new GFF output file, identifying the gff version in the header
# similar to the input files.
# Loop over the annots dictionary structure using keys and values - one key
# per reference genome. Then loop over keys and values of the sub-dictionary
# containing information per location (start_stop information). Check if 
# there is more than one key-value pair, and if so (it's always CDS and gene)
# find the "gene" one. Write that to the output file.

with open("PseudomonasAnnotationAll.gff", "w") as out:
  out.write("#gff-version 3")
  for key, value in annots.items():
    for k, v in value.items():
      if len(v) >= 2:
        gene = [str for str in v if str.find("gene", 0, 72)][0]
      else:
        gene = v[0]
      print(key, gene)
      out.write("\n"+ key +"\t"+ gene)
