---
layout: post
title: "Day 3 - Bacterial Pangenomics"
categories: [exercise, psae]
author: LilithElina
---

The exercises of [day one]({{ site.baseurl }}{% post_url 2019-10-07-toy_examples_protocol %}) and [day two]({{ site.baseurl }}{% post_url 2019-10-14-HIV_exercises_protocol %}) were centered around relatively small data / genomes. Now, [day three]({{ "/pages/bacteria.html" | relative_url }}) moves on to - bacteria!

The objectives were two-fold: we were provided with whole genome and single gene sequences and were supposed to create a graph of a single gene and build a graph-based pangenome. Then we should have figured out ways to learn if a gene is present or absent in a strain, and identify a set of genes present in all strains (the core genome) versus genes that are missing in some strains (accessory genes).

In the course we were working with *E. coli* data that Mikko had prepared for us. I am going to work with *Pseudomonas aeruginosa* instead, since the objectives (except maybe for the single gene graph) are my work goals as well, so I can use this to start working on my own data.

* Do not remove this line (it will not be displayed)
{:toc}

## Getting started

I have a [protocol]({{ "/course_results/Day3.Script.txt" | relative_url }}) from the course as inspiration, in addition to the actual course materials, where we extracted sequences of *gyrA* from all provided *E. coli* strains to create a graph, and then moved on to create a whole genome graph using 10 random *E. coli* strains. The latter we used to map the *gyrA* fasta sequence to see where it was located in the graph, and we also mapped provided short reads and all gene sequences of a not included strain to the "pangenome".

## *Pseudomonas aeruginosa* references

I'm going to do something similar here. I'll start with a few reference sequences from [pseudmonas.com](http://pseudomonas.com/strain/download?c1=organism&v1=pseudomonas+aeruginosa&v2=complete&c2=assemblyLevel); there are 208 strains with complete genomes included in the database right now, while [NCBI](https://www.ncbi.nlm.nih.gov/genome/genomes/187) lists 209 complete genomes. We usually use *P. aeruginosa* PA14 as reference, or PAO1 (which is the recommended standard), and in phylogenetic trees we use strains from the popular five on pseudomonas.com (PAO1, PA14, LESB58, PA7). In general, it seems that most sets of *P. aeruginosa* strains can be divided into "PA14-like" and "PAO1-like" strains and a small group of outliers related to PA7. The PAO1 group usually includes most other reference strains as well (e.g. [here](https://www.biorxiv.org/content/biorxiv/early/2019/05/24/643676/F1.large.jpg), [here](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4600120/figure/fig1/), or [here](https://www.frontiersin.org/files/Articles/151186/fmicb-06-01036-HTML/image_m/fmicb-06-01036-g001.jpg)).

## "Pangenome" graph based on five reference genomes

To start, I will create a genome graph based on the top five *P. aeruginosa* reference strains, and depending on how long that takes I can then think about using all 208 strains instead. Since *P. aeruginosa* has a well conserved genome, it might not even be necessary to use so many whole genomes - augmenting the starting graph with missing sequences and variations could also be a good strategy.

```bash
mkdir day3
cd day3/
mkdir pics
mkdir references
cd references/
wget http://pseudomonas.com/downloads/pseudomonas/pgd_r_19_1/Pseudomonas_aeruginosa_PAO1_107/Pseudomonas_aeruginosa_PAO1_107.fna.gz
wget http://pseudomonas.com/downloads/pseudomonas/pgd_r_19_1/Pseudomonas_aeruginosa_UCBPP-PA14_109/Pseudomonas_aeruginosa_UCBPP-PA14_109.fna.gz
wget http://pseudomonas.com/downloads/pseudomonas/pgd_r_19_1/Pseudomonas_aeruginosa_LESB58_125/Pseudomonas_aeruginosa_LESB58_125.fna.gz
wget http://pseudomonas.com/downloads/pseudomonas/pgd_r_19_1/Pseudomonas_aeruginosa_PA7_119/Pseudomonas_aeruginosa_PA7_119.fna.gz
wget http://pseudomonas.com/downloads/pseudomonas/pgd_r_19_1/Pseudomonas_aeruginosa_PAK_6441/Pseudomonas_aeruginosa_PAK_6441.fna.gz
gunzip *.gz
```

Case in point: the group that created [PPanGGOLiN](https://github.com/labgem/PPanGGOLiN), a different pangenome graph approach, analysed 3958 *P. aeruginosa* genomes from [GenBank](https://www.ncbi.nlm.nih.gov/genbank/) and found a quite large "soft core" genome (as shown in the [publication](https://www.biorxiv.org/content/10.1101/836239v1.full)).


### Graph creation with minimap2 and seqwish

As I've already seen in [day two]({{ site.baseurl }}{% post_url 2019-10-14-HIV_exercises_protocol %}) that using `vg msga` can be quite slow when creating a graph based on multiple genomes, I'm going to use the [minimap2](https://github.com/lh3/minimap2)+[seqwish](https://github.com/ekg/seqwish) approach again. Since the genomes are circular in *Pseudomonas* anyway, there shouldn't be any confusion about that this time.

First, I have to combine the five fasta sequence files into one multi-fasta file:

```bash
for i in $(ls *fna)
do
  cat $i >> FivePsae.fasta
done
```

Now I can run minimap2 to do the alignment and then use seqwish to create a graph from that:

```bash
minimap2 -X -c -x asm20 FivePsae.fasta FivePsae.fasta | gzip > FivePsae.paf.gz
seqwish -s FivePsae.fasta -p FivePsae.paf.gz -b FivePsae.work -g FivePsae.gfa | pv -l
```

I'm still using the `-x asm20` for lack of a better idea. Very useful is also the option to pipe in gzip to create a compressed output and save some space.

```
[M::mm_idx_gen::1.495*1.00] collected minimizers
[M::mm_idx_gen::1.695*1.23] sorted minimizers
[M::main::1.695*1.23] loaded/built the index for 5 target sequence(s)
[M::mm_mapopt_update::1.796*1.21] mid_occ = 100
[M::mm_idx_stat] kmer size: 19; skip: 10; is_hpc: 0; #seq: 5
[M::mm_idx_stat::1.860*1.21] distinct minimizers: 2341228 (48.14% are singletons); average occurrences: 2.504; average spacing: 5.506
[M::worker_pipeline::19.029*2.24] mapped 5 sequences
[M::main] Version: 2.17-r954-dirty
[M::main] CMD: minimap2 -X -c -x asm20 FivePsae.fasta FivePsae.fasta
[M::main] Real time: 19.072 sec; CPU: 42.664 sec; Peak RSS: 0.868 GB
```

Creating the alignment was again very fast (19 seconds), so I believe that adding at least a few more genomes wouldn't be a problem. Since seqwish doesn't include output with run time, I've included `| pv -l` in my call to be able to accurately stop the time.

```
   0  0:01:09 [   0 /s] [<=>                                                                                ]
```

This is a pretty handy tool, and shows that seqwish is also really fast (one minute) for the five reference genomes.

### Graph visualisation

Of course I now want to take a look at my *P. aeruginosa* mini-pangenome! I'll start with odgi, but I'm probably going to use `vg viz` as well.

```bash
odgi build -g FivePsae.gfa -o - | odgi sort -i - -o FivePsae.og
odgi viz -i FivePsae.og -o ../pics/FivePsae.png -x 2000 -R
```

Again, `odgi viz` gives out some additional information about the paths in the graph:

```
path 0 refseq|NC_011770|chromosome 0.65 0.152778 0.197222 249 58 75
path 1 refseq|NC_009656.1|chromosome 0.254032 0.254032 0.491935 97 97 188
path 2 refseq|NZ_CP020659.1|chromosome 0.474088 0.0690979 0.456814 181 26 175
path 3 refseq|NC_002516.2|chromosome 0.460952 0.48 0.0590476 176 184 23
path 4 refseq|NC_008463.1|chromosome 0.430809 0.0443864 0.524804 165 17 20
```

![pangenome graph based on five references]({{ "/playground/day2/pics/FivePsae.png" | relative_url }})  
*pangenome graph based on five references*

There are a lot of edges in this graph, and while `odgi viz` creates a nice overview of this, I think `vg viz` is better if you want to see some details (like which genome is which).

```bash
vg view -F FivePsae.gfa -v > FivePsae.vg
vg index -x FivePsae.xg FivePsae.vg
vg viz -x FivePsae.xg -o ../pics/FivePsae.svg
```

These steps take a little time, but now I have an SVG file that I can load into Inkscape to check out... and it's empty. I can't see any graph inside, just the border box that's usually around the image. I wonder where the graph got lost - let's find it!

File sizes of my different graph formats:

format | size |
:------|-----:|
GFA    | 97M  |
OG     | 92M  |
VG     | 28M  |
XG     | 136M |

Hmm, the vg graph is a lot smaller than the other two, but the index is big and at least for [day two]({{ site.baseurl }}{% post_url 2019-10-14-HIV_exercises_protocol %}), the graph created with seqwish and then converted to vg looks similar (size wise). The conversion had worked there, too, as I was able to map reads to the converted graph.

What does the vg file look like, then? Let's ask [jq](https://stedolan.github.io/jq/):

```bash
vg view FivePsae.vg -j | jq ".path"
```

Great, paths are there just fine. Maybe the whole graph is too big for `vg viz`? I'll try looking at just a few nodes instead.  
Since jq listed a bunch of nodes to the console for me, I can just choose a number from there:

```bash
vg find -n 668831 -x FivePsae.xg -c 10 | vg view -dp - | dot -Tpdf -o ../pics/FivePsae_668831.pdf
```

That is also working perfectly: [*DOT version of node 668831 and surroundings (PDF)*]({{ "/playground/day3/pics/FivePsae_668831.pdf" | relative_url }})

So now I know that the graph **and** the index are fine, and it's `vg viz` that... can't cope with the amount of data?

```bash
vg find -n 668831 -x FivePsae.xg -c 10 | vg view -v - > FivePsae_668831.vg
vg index -x FivePsae_668831.xg FivePsae_668831.vg
vg viz -x FivePsae_668831.xg -o ../pics/FivePsae_668831.svg
```

Apparently yes, since this worked fine as well:

![vg viz version of node 668831 and surroundings]({{ "/playground/day3/pics/FivePsae_668831.PNG" | relative_url }})  
*vg viz version of node 668831 and surroundings*

There is yet another visualisation tool that I have not yet tested, but we're very interested in: [IVG](https://vgteam.github.io/sequenceTubeMap/), which creates sequence tube maps. Sadly, this online tool can only take uploads of up to 5 MB, and apparently it can't deal with graphs that only contain a few extracted nodes, either:

```
terminate called after throwing an instance of 'std::runtime_error' what(): Attempted to get handle for node 101 not present in graph ERROR: Signal 6 occurred. VG has crashed. Run 'vg bugs --new' to report a bug. Stack trace path: /tmp/vg_crash_aQ6V67/stacktrace.txt 
```

Apparently my only way to look at the graph is using `odgi viz` (or just looking at parts and not the whole thing). Since the additional output of `odgi viz` lists the path identities, at least I believe I know which genome is which:

| path | colour | RefSeq        | name   |
|------|--------|---------------|--------|
| 0    | red    | NC_011770     | LESB58 |
| 1    | blue   | NC_009656.1   | PA7    |
| 2    | pink   | NZ_CP020659.1 | PAK    |
| 3    | green  | NC_002516.2   | PAO1   |
| 4    | purple | NC_008463.1   | PA14   |

Scrolling through the graph, there are multiple regions visible which are specific for a single genome, mostly for LESB58, but also for PA7 and PAK. I'm a little surprised that LESB58 seems to be so different from the others, since it usually clusters with PAO1 and PAK, while PA7 is always shown as a - very different - outlier. Of course, the coloured paths are basically just the multiple sequence alignment and the edges show the real genome composition in the end - only they are very hard to interpret in this format.

### Annotating the graph

Before I move on to mapping samples to the graph, I would like to be able to identify genes and other features of the reference genomes in the graph. Similar to my [analysis of HIV]({{ site.baseurl }}{% post_url 2019-10-14-HIV_exercises_protocol %}) I could then also look at "variation" in the genes, based on the number of nodes per gene. My problem here is that I have five annotated references that make up the graph, and many of the annotated genes will be the same (remember, big [soft core genome](https://www.biorxiv.org/content/10.1101/836239v1.full)). Since vg gives each gene its own path, I assume it would be a bit too much to augment the graph with all five complete annotations. Instead, I want to try and create one annotation for all five references.

First, I'll download the annotations for all five in GFF3 format, since vg needs GFF (or BED, but that's not listed on [pseudomonas.com](http://pseudomonas.com/strain/download)):

```bash
mkdir annotations
cd annotations
wget http://pseudomonas.com/downloads/pseudomonas/pgd_r_19_1/Pseudomonas_aeruginosa_PAO1_107/Pseudomonas_aeruginosa_PAO1_107.gff.gz
wget http://pseudomonas.com/downloads/pseudomonas/pgd_r_19_1/Pseudomonas_aeruginosa_UCBPP-PA14_109/Pseudomonas_aeruginosa_UCBPP-PA14_109.gff.gz
wget http://pseudomonas.com/downloads/pseudomonas/pgd_r_19_1/Pseudomonas_aeruginosa_LESB58_125/Pseudomonas_aeruginosa_LESB58_125.gff.gz
wget http://pseudomonas.com/downloads/pseudomonas/pgd_r_19_1/Pseudomonas_aeruginosa_PA7_119/Pseudomonas_aeruginosa_PA7_119.gff.gz
wget http://pseudomonas.com/downloads/pseudomonas/pgd_r_19_1/Pseudomonas_aeruginosa_PAK_6441/Pseudomonas_aeruginosa_PAK_6441.gff.gz
gunzip *.gz
```

Since I don't want to do a homology search or anything, I'll keep it "simple": I'll look for gene names and if they are the same in multiple files, I'll keep only one of them. I will also sort through the gene/CDS duplicates and probably only keep the gene entries if start and stop are equivalent to a CDS entry.

There will be another problem, though: the GFF files I downloaded start every entry with "chromosome" as seqid instead of a valid RefSeq or other identifier for the genomes. I don't think that will work with `vg annotate`, but I'll check first:

```bash
vg annotate -x FivePsae.xg -f annotations/Pseudomonas_aeruginosa_PAO1_107.gff > FivePsaePAO1.gam
```

```
warning: path "chromosome" not found in index, skipping
```

No, it's not working. So here is what I have/want to accomplish using a Python script:

- exchange "chromosome" with an actual path/reference name
  - maybe change the path names from "`refseq|NC_011770|chromosome`" to just "NC_011770" using jq first?
- remove duplicate gene/CDS entries
- filter genes in different references so every gene is only annotated once (or at least most genes are)


#### Preparing the annotation

I decided to keep the path names as they are to save some time. The Python script I wrote (using Python 3) is called [`CleanCombineGff.py`]({{ "/playground/day3/references/annotation/CleanCombineGff.py" | relative_url }}) and resides in the same directory as the annotation files. The script reads a file listing GFF files to clean and combine, ignores features that are not needed, removes duplicate gene/CDS entries and only keeps one gene annotation for all references (based on gene name).

```bash
python3 CleanCombineGff.py annot_list.tab
```

```bash
wc -l PseudomonasAnnotation.gff
```

```
25187 PseudomonasAnnotation.gff
```

Each single annotation file contains between 11,000 and 13,000 entries, while the combined annotation file contains only 25,000 hopefully unique entries. Now let's add those to the variant graph.

```bash
cd ../
vg annotate -x FivePsae.xg -f annotations/PseudomonasAnnotation.gff > FivePsaeAnnot.gam
vg augment FivePsae.vg -i FivePsaeAnnot.gam > FivePsaeAnnot.vg
vg index -x FivePsaeAnnot.xg FivePsaeAnnot.vg
```

The annotation is really fast, while augmentation and indexing take some time. Again, we can't possibly visualise the whole graph with all the paths, so I have to select a region I want to visualise. This can be done using `vg paths`, which - I believe - can select paths by name from a variant graph:

```bash
vg paths -x FivePsaeAnnot.xg -X -Q "gyrA" > FivePsaeAnnotgyrA.gam
```

Again (similar to `vg annotate` in [day two]({{ site.baseurl }}{% post_url 2019-10-14-HIV_exercises_protocol %}), `vg paths` does not create a vg output file even when given the `-V` option - it turns out as gam anyway, so I'm using `-X` (to create a gam file) just to be consistent. The output file does not contain any paths, though - interesting...

```bash
vg paths -x FivePsaeAnnot.xg -L
```

This command is supposed to list all paths in the file. The output is this:

```
refseq|NC_002516.2|chromosome
refseq|NC_008463.1|chromosome
refseq|NC_009656.1|chromosome
refseq|NC_011770|chromosome
refseq|NZ_CP020659.1|chromosome
```

Since `vg annotate` did not complain about the annotation format or seqid (first column in the gff), I assumed that everything worked this time, but the annotation does not seem to be there.

What is inside FivePsaeAnnot.gam, then?

```bash
vg view -a FivePsaeAnnot.gam | jq '.path' > FivePsaeAnnotPaths.json
```

I tried to have a look at the gam file after conversion to json using [tidyjson](https://github.com/sailthru/tidyjson), but I get an error in return:

```
Error: parse error: trailing garbage
          "393756"       }     }   ] } {   "mapping": [     {       "e
                     (right here) ------^
```

Something seems to have gone wrong in this file somewhere, even though there was no previous error message.

Does something similar happen when I just try to annotate one of the references?  
In order to figure that out, I have to adjust an annotation file to have the right seqid (fitting one of the paths in the variant graph), which I'm just going to do manually with the PAO1 annotation.

```bash
vg annotate -x FivePsae.xg -f annotations/Pseudomonas_aeruginosa_PAO1_107_corrected.gff > FivePsaePAO1Annot.gam
vg augment FivePsae.vg -i FivePsaePAO1Annot.gam > FivePsaePAO1Annot.vg
vg index -x FivePsaePAO1Annot.xg FivePsaePAO1Annot.vg
vg paths -x FivePsaePAO1Annot.xg -L
```

```
Pseudomonas aeruginosa PAO1 refseq|NC_002516.2|chromosome, complete genome.
refseq|NC_002516.2|chromosome
refseq|NC_008463.1|chromosome
refseq|NC_009656.1|chromosome
refseq|NC_011770|chromosome
refseq|NZ_CP020659.1|chromosome
```

OK, so now I have one single path from the annotation, that is new. I did exactly the same thing for the [HIV data]({{ site.baseurl }}{% post_url 2019-10-14-HIV_exercises_protocol %}), and when I use `vg paths -L` on these data, I get a list of two paths per gene, just as I saw in the visualisation. Why is this not happening here? It's not like I updated vg or anything, so the software didn't change.

For some reason `vg annotate` took only the first line from my PAO1 gff file and annotated that into the graph, right? I think I'd like to have a look at that...

```bash
vg paths -x FivePsaePAO1Annot.xg -X -Q "Pseudomonas aeruginosa PAO1 refseq|NC_002516.2|chromosome, complete genome." > FivePsaePAO1Annotpath.gam
```

Since this file is now supposed to only contain parts of the graph that contain the path I chose, I should be able to get any random node ID from it (or the json version of it) and visualise that.

```bash
vg view -a FivePsaePAO1Annotpath.gam | jq '.path'
vg find -n 489302 -x FivePsaePAO1Annot.xg -c 10 | vg view -v - > FivePsaePAO1Annot_489302.vg
vg index -x FivePsaePAO1Annot_489302.xg FivePsaePAO1Annot_489302.vg
vg viz -x FivePsaePAO1Annot_489302.xg -o ../pics/FivePsaePAO1Annot_489302.svg
```

```
graph path 'Pseudomonas aeruginosa PAO1 refseq|NC_002516.2|chromosome, complete genome.' invalid: edge from 489292 start to 489312 end does not exist
graph path 'Pseudomonas aeruginosa PAO1 refseq|NC_002516.2|chromosome, complete genome.' invalid: edge from 489292 start to 489312 end does not exist
[vg view] warning: graph is invalid!
```

Despite a warning from the `vg find` command, this code works:

![vg viz version of node 489302 and surroundings]({{ "/playground/day3/pics/FivePsaePAO1Annot_489302.PNG" | relative_url }})  
*vg viz version of node 489302 and surroundings*

Right, so in general I know what I have to do. Now the question remains why it doesn't work as expected, and I have an idea - there is one interesting difference between the gff file I downloaded for HIV and the one for PAO1 (or any of the other reference strains): every line in the bacterial annotation ends with a semicolon (semicolons separate the entries in the attributes string), while the HIV annotation does not have a semicolon at the end of a line. Maybe that is taken as a sign that the annotated entry is not finished yet?  
I'm going to remove the trailing semicolons from the already corrected PAO1 annotation and try again:

```bash
vg annotate -x FivePsae.xg -f annotations/Pseudomonas_aeruginosa_PAO1_107_corrected.gff > FivePsaePAO1Annot.gam
vg augment FivePsae.vg -i FivePsaePAO1Annot.gam > FivePsaePAO1Annot.vg
vg paths -v FivePsaePAO1Annot.vg -L
```

```
refseq|NC_002516.2|chromosome
refseq|NC_008463.1|chromosome
refseq|NC_009656.1|chromosome
refseq|NC_011770|chromosome
refseq|NZ_CP020659.1|chromosome
```

Interesting! We're down again to the five original paths, with nothing new added. This must somehow be related to the format of my files, but I struggle to see it. Both the HIV annotation and my file have [LF](https://en.wikipedia.org/wiki/Newline#Representation) line breaks according to [Notepad++](https://notepad-plus-plus.org/), both are tab separated files with the same number of columns.  
In the attributes column there is one more difference I only noticed now after checking out the [GFF specifications](https://github.com/The-Sequence-Ontology/Specifications/blob/master/gff3.md): their tags usually start with a capital letter, which is only partly true in the HIV annotation (but true for all features that were annotated in the graph) and only partly true in PAO1, where the official (?) "name" tag does not start with a capital "N" as expected, except for in the first entry... Could it be that stupid?

```bash
vg annotate -x FivePsae.xg -f annotations/Pseudomonas_aeruginosa_PAO1_107_corrected.gff > FivePsaePAO1Annot.gam
vg augment FivePsae.vg -i FivePsaePAO1Annot.gam > FivePsaePAO1Annot.vg
vg paths -v FivePsaePAO1Annot.vg -L
```

And suddenly I have a loooong list of paths in my annotated graph! I need emojis in this protocol...

I still don't understand why the version without trailing semicolons didn't even get the first feature annotated, but that's a question for another day and for now I just hope it's not a relevant one.



## Open questions

- Is there another way to visualise a whole genome graph?
- How can I annotate the graph? Is a specific formatting of GFF files required?
  - The files just have to strictly follow the specifications, I believe.