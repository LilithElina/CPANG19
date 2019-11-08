---
layout: post
title: "Day 2 - HIV Exercises"
categories: exercise
author: LilithElina
---

While we were provided materials for the toy examples in [day one]({{ site.baseurl }}{% post_url 2019-10-07-toy_examples_protocol %}), I have to download the HIV data for day two myself. At least we have the sources in [the materials]({{ "/pages/HIV_exercises.html" | relative_url }}), so it shouldn't be a problem, and I would like to do this before starting with our own bacterial data. I also have an RMarkdown [protocol]({{ "/course_results/aims_and_results.Rmd" | relative_url }}) from my group for this day which I will partly follow.

* Do not remove this line (it will not be displayed)
{:toc}

## Getting started

Let's see where the [example data](https://github.com/cbg-ethz/5-virus-mix) is...  
Reference sequences for the five HIV strains used are directly located in the referenced GitHub repo, and raw reads (Illumina, PacBio, and 454) of a mix of all five strains can theoretically be downloaded from SRA. In practice, the links given in the repo do not work, but the [data still exists at NCBI](https://www.ncbi.nlm.nih.gov/sra?LinkName=biosample_sra&from_uid=2340078).

```bash
cd /data3/genome_graphs/CPANG19/playground
mkdir day2
cd day2
fastq-dump SRR961514
```

```
2019-10-18T08:57:38 fastq-dump.2.3.5 err: error unexpected while resolving tree within virtual file system module - failed to resolve accession 'SRR961514' - Obsolete software. See https://github.com/ncbi/sra-tools/wiki/Obsolete-software ( 406 )

Redirected!!!

2019-10-18T08:57:39 fastq-dump.2.3.5 err: name incorrect while evaluating path within network system module - Scheme is 'https'
2019-10-18T08:57:39 fastq-dump.2.3.5 err: item not found while constructing within virtual database module - the path 'SRR961514' cannot be opened as database or table
spo12@CPI-SL64001:/data3/genome_graphs/CPANG19/playground/day2$ fastq-dump SRX342702
2019-10-18T08:58:56 fastq-dump.2.3.5 err: error unexpected while resolving tree within virtual file system module - failed to resolve accession 'SRX342702' - Obsolete software. See https://github.com/ncbi/sra-tools/wiki/Obsolete-software ( 406 )

Redirected!!!

2019-10-18T08:58:56 fastq-dump.2.3.5 err: name incorrect while evaluating path within network system module - Scheme is 'https'
2019-10-18T08:58:56 fastq-dump.2.3.5 err: item not found while constructing within virtual database module - the path 'SRX342702' cannot be opened as database or table
```

Sadly, we have an old version of the SRA Toolkit installed, so I would have to [clean that up](https://github.com/ncbi/sra-tools/wiki/Obsolete-software) before I can download the data, or I can just do it manually...

```bash
mkdir reads
cd reads
fastq-dump SRR961669.2
fastq-dump SRR961514.1
cd ..
```

Not all of the files listed online could be downloaded by simply clicking on them, but I have a set of PacBio reads (SRR961669) and a set of Illumina reads (SRR961514) now, that should be enough to play around with.

## Previous aims

During the course, my group's aims were to compare different variant graph construction methods as well as finding variation in viral genes. I'm not going to retrace all the steps we took (like the de novo assembly of PacBio reads), but at least the parts I can do without installing additional software I might not need later on.

## AIM 1 - Construction methods for genome graphs

For this part, we used HIV-1 (which was also provided in the course) together with the five reference sequences to create a genome graph for HIV. The complete HIV-1 genome can be found at [NCBI](https://www.ncbi.nlm.nih.gov/genome/?term=hiv-1).

### `vg msga` with a single genome graph as base

First, we created and indexed a genome graph based solely on HIV-1.

```bash
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/864/765/GCF_000864765.1_ViralProj15476/GCF_000864765.1_ViralProj15476_genomic.fna.gz
gunzip GCF_000864765.1_ViralProj15476_genomic.fna.gz
vg construct -r GCF_000864765.1_ViralProj15476_genomic.fna > hiv.vg
vg index -x hiv.xg hiv.vg -g hiv.gcsa
vg msga -f REF.fasta -g hiv.vg > hiv_6genomes.vg
```

Then we used `vg msga` to create a multiple sequence alignment of the five reference sequences together with the graph, writing everything in the form of a new variant graph.

This was already too big for the standard DOT format, so we visualised it in Bandage instead:

```bash
vg view hiv_6genomes.vg > hiv_6genomes.gfa
```

![variant graph in Bandage]({{ "/playground/day2/pics/Bandage_hiv_6genomes.PNG" | relative_url }})  
*variant graph in Bandage*

I'd also like to try the [Inkscape](https://inkscape.org/) method suggested in the course instructions as well:

```bash
vg index -x hiv_6genomes.xg hiv_6genomes.vg
vg viz -x hiv_6genomes.xg -o hiv_6genomes.svg
```

This kind of visualisation is much nicer, since you can see the paths of the genomes through the graph:

![variant graph with vg viz and Inkscape - start]({{ "/playground/day2/pics/Inkscape_hiv_6genomes_b.PNG" | relative_url}})  
*variant graph with vg viz and Inkscape - start*
![variant graph with vg viz and Inkscape - random region]({{ "/playground/day2/pics/Inkscape_hiv_6genomes.PNG" | relative_url }})  
*variant graph with vg viz and Inkscape - random region*


### minimap2 with seqwish and odgi

Another way to generate a genome graph from the six given reference genomes is creating a multiple sequence alignment (MSA) with [minimap2](https://github.com/lh3/minimap2) and then using Erik's tool [seqwish](https://github.com/ekg/seqwish) to create a graph from that. This graph can be visualised and manipulated with [odgi](https://github.com/vgteam/odgi), another tool from the vg team.

#### Installing minimap2, seqwish, and odgi

To be able to that, I first have to install those tools...

```bash
cd ../../../
git clone https://github.com/lh3/minimap2
cd minimap2 && make
git clone https://github.com/ekg/seqwish
cd seqwish
cmake -H. -Bbuild && cmake --build build -- -j3
git clone https://github.com/vgteam/odgi
cd odgi
cmake -H. -Bbuild && cmake --build build -- -j 3
cd /usr/bin/
sudo ln -s /data3/genome_graphs/minimap2/minimap2
sudo ln -s /data3/genome_graphs/seqwish/bin/seqwish
cd /data3/genome_graphs/
```

Minimap2 and seqwish were really easy to install, but odgi ended in an error message:

```
Scanning dependencies of target odgi_pybind11
[100%] Building CXX object CMakeFiles/odgi_pybind11.dir/src/pythonmodule.cpp.o
In file included from /data3/genome_graphs/odgi/deps/pybind11/include/pybind11/pytypes.h:12:0,
                 from /data3/genome_graphs/odgi/deps/pybind11/include/pybind11/cast.h:13,
                 from /data3/genome_graphs/odgi/deps/pybind11/include/pybind11/attr.h:13,
                 from /data3/genome_graphs/odgi/deps/pybind11/include/pybind11/pybind11.h:44,
                 from /data3/genome_graphs/odgi/src/pythonmodule.cpp:6:
/data3/genome_graphs/odgi/deps/pybind11/include/pybind11/detail/common.h:112:20: fatal error: Python.h: No such file or directory
compilation terminated.
CMakeFiles/odgi_pybind11.dir/build.make:62: recipe for target 'CMakeFiles/odgi_pybind11.dir/src/pythonmodule.cpp.o' failed
make[2]: *** [CMakeFiles/odgi_pybind11.dir/src/pythonmodule.cpp.o] Error 1
CMakeFiles/Makefile2:318: recipe for target 'CMakeFiles/odgi_pybind11.dir/all' failed
make[1]: *** [CMakeFiles/odgi_pybind11.dir/all] Error 2
make[1]: *** Waiting for unfinished jobs....
[100%] Built target odgi
Makefile:83: recipe for target 'all' failed
make: *** [all] Error 2
```

I'll try building [pybind11](https://github.com/pybind/pybind11) "manually":

```bash
cd odig/deps/pybind11/
mkdir build
cd build
cmake ..
```

```
CMake Error at tests/CMakeLists.txt:217 (message):
  Running the tests requires pytest.  Please install it manually (try:
  /usr/bin/python3.6 -m pip install pytest)


-- Configuring incomplete, errors occurred!
See also "/data3/genome_graphs/odgi/deps/pybind11/build/CMakeFiles/CMakeOutput.log".
```

```bash
/usr/bin/python3.6 -m pip install pytest
cmake ..
make check -j 4
```

The `cmake` call worked now, but `make check` ended in the same error as before:

```
Scanning dependencies of target cross_module_gil_utils
[  2%] Building CXX object tests/CMakeFiles/cross_module_gil_utils.dir/cross_module_gil_utils.cpp.o
In file included from /data3/genome_graphs/odgi/deps/pybind11/include/pybind11/pytypes.h:12:0,
                 from /data3/genome_graphs/odgi/deps/pybind11/include/pybind11/cast.h:13,
                 from /data3/genome_graphs/odgi/deps/pybind11/include/pybind11/attr.h:13,
                 from /data3/genome_graphs/odgi/deps/pybind11/include/pybind11/pybind11.h:44,
                 from /data3/genome_graphs/odgi/deps/pybind11/tests/cross_module_gil_utils.cpp:9:
/data3/genome_graphs/odgi/deps/pybind11/include/pybind11/detail/common.h:112:20: fatal error: Python.h: No such file or directory
compilation terminated.
tests/CMakeFiles/cross_module_gil_utils.dir/build.make:62: recipe for target 'tests/CMakeFiles/cross_module_gil_utils.dir/cross_module_gil_utils.cpp.o' failed
make[3]: *** [tests/CMakeFiles/cross_module_gil_utils.dir/cross_module_gil_utils.cpp.o] Error 1
CMakeFiles/Makefile2:197: recipe for target 'tests/CMakeFiles/cross_module_gil_utils.dir/all' failed
make[2]: *** [tests/CMakeFiles/cross_module_gil_utils.dir/all] Error 2
make[2]: *** Waiting for unfinished jobs....
tests/test_cmake_build/CMakeFiles/test_subdirectory_target.dir/build.make:57: recipe for target 'tests/test_cmake_build/CMakeFiles/test_subdirectory_target' failed
make[3]: *** [tests/test_cmake_build/CMakeFiles/test_subdirectory_target] Error 1
CMakeFiles/Makefile2:467: recipe for target 'tests/test_cmake_build/CMakeFiles/test_subdirectory_target.dir/all' failed
make[2]: *** [tests/test_cmake_build/CMakeFiles/test_subdirectory_target.dir/all] Error 2
tests/test_cmake_build/CMakeFiles/test_subdirectory_embed.dir/build.make:57: recipe for target 'tests/test_cmake_build/CMakeFiles/test_subdirectory_embed' failed
make[3]: *** [tests/test_cmake_build/CMakeFiles/test_subdirectory_embed] Error 1
CMakeFiles/Makefile2:300: recipe for target 'tests/test_cmake_build/CMakeFiles/test_subdirectory_embed.dir/all' failed
make[2]: *** [tests/test_cmake_build/CMakeFiles/test_subdirectory_embed.dir/all] Error 2
tests/test_cmake_build/CMakeFiles/test_subdirectory_function.dir/build.make:57: recipe for target 'tests/test_cmake_build/CMakeFiles/test_subdirectory_function' failed
make[3]: *** [tests/test_cmake_build/CMakeFiles/test_subdirectory_function] Error 1
CMakeFiles/Makefile2:327: recipe for target 'tests/test_cmake_build/CMakeFiles/test_subdirectory_function.dir/all' failed
make[2]: *** [tests/test_cmake_build/CMakeFiles/test_subdirectory_function.dir/all] Error 2
CMakeFiles/Makefile2:237: recipe for target 'tests/CMakeFiles/check.dir/rule' failed
make[1]: *** [tests/CMakeFiles/check.dir/rule] Error 2
Makefile:216: recipe for target 'check' failed
make: *** [check] Error 2
```

Apparently this could be a [problem](https://stackoverflow.com/questions/21530577/fatal-error-python-h-no-such-file-or-directory) with python(3)-dev...

```bash
sudo apt-get install python3-dev
sudo apt-get install python-dev
```

Interestingly, both versions are installed and up to date. I'm guessing that the fact we have both versions (as we need Python 2.7 and Python 3 on the server) is the real problem here? Or I have to further specify the Python version.

```bash
sudo apt-get install python3.5-dev
```

No, still the same answer - it's already up to date.

I think I have to [adjust a file](https://stackoverflow.com/questions/8282231/i-have-python-on-my-ubuntu-system-but-gcc-cant-find-python-h/19344978) somewhere:
"/data3/genome_graphs/odgi/deps/pybind11/include/pybind11/detail/common.h" contains a line `#include <Python.h>`, maybe I can put a better path here? We have a number of Python.h files:

```bash
locate Python.h
```

The list includes these among many others:

```
/usr/bin/miniconda3/include/python2.7/Python.h
/usr/bin/miniconda3/pkgs/python-2.7.15-h5a48372_1009/include/python2.7/Python.h
/usr/include/python2.7/Python.h
/usr/include/python3.5m/Python.h
```

I'm going to try it with "#include </usr/include/python3.5m/Python.h>":

```bash
cmake -H. -Bbuild && cmake --build build -- -j 3
```

```
Scanning dependencies of target odgi_pybind11
[100%] Building CXX object CMakeFiles/odgi_pybind11.dir/src/pythonmodule.cpp.o
In file included from /data3/genome_graphs/odgi/deps/pybind11/include/pybind11/pytypes.h:12:0,
                 from /data3/genome_graphs/odgi/deps/pybind11/include/pybind11/cast.h:13,
                 from /data3/genome_graphs/odgi/deps/pybind11/include/pybind11/attr.h:13,
                 from /data3/genome_graphs/odgi/deps/pybind11/include/pybind11/pybind11.h:44,
                 from /data3/genome_graphs/odgi/src/pythonmodule.cpp:6:
/data3/genome_graphs/odgi/deps/pybind11/include/pybind11/detail/common.h:113:25: fatal error: frameobject.h: No such file or directory
compilation terminated.
CMakeFiles/odgi_pybind11.dir/build.make:62: recipe for target 'CMakeFiles/odgi_pybind11.dir/src/pythonmodule.cpp.o' failed
make[2]: *** [CMakeFiles/odgi_pybind11.dir/src/pythonmodule.cpp.o] Error 1
CMakeFiles/Makefile2:318: recipe for target 'CMakeFiles/odgi_pybind11.dir/all' failed
make[1]: *** [CMakeFiles/odgi_pybind11.dir/all] Error 2
Makefile:83: recipe for target 'all' failed
make: *** [all] Error 2
```

Well, now another file is missing...  
There are actually three files in a row that probably come from the same directory, so I'm going to "fix" all three in the same way.

```bash
cd ../../
cmake -H. -Bbuild && cmake --build build -- -j 3
```

And it's done, now just make sure the program can be called universally on the server:

```bash
cd /usr/bin/
sudo ln -s /data3/genome_graphs/odgi/bin/odgi
cd /data3/genome_graphs/
```

#### Create the MSA with minimap2

Minimap2 is a pairwise aligner of genomic sequences, but can also do a multiple sequence alignment if multiple sequences are contained in the same fasta file (I manually copied the HIV-1 sequence into the REF.fasta file):

```bash
cd CPANG19/playground/day2/
minimap2 -X -c -x asm20 6ref.fasta 6ref.fasta > all_vs_all.paf
```

We give the fasta file twice to tell minimap2 to align all sequences with all.  
The `-X` option tells minimap2 to avoid self and dual mappings, `-c` sets the [CIGAR](https://genome.sph.umich.edu/wiki/SAM#What_is_a_CIGAR.3F) output to [PAF](https://github.com/lh3/miniasm/blob/master/PAF.md), which is supported by seqwish, and `-x` sets the "asm-to-ref" mapping to 20, for ~5% sequence divergence, I think. I believe "asm" just means assembly, and according to the minimap2 README, the scoring system has to be adjusted for sequence divergence when doing whole genome or assembly alignments. Why "asm20" is the right choice here I don't know.

```
[M::mm_idx_gen::0.007*0.60] collected minimizers
[M::mm_idx_gen::0.011*1.13] sorted minimizers
[M::main::0.011*1.13] loaded/built the index for 6 target sequence(s)
[M::mm_mapopt_update::0.011*1.07] mid_occ = 100
[M::mm_idx_stat] kmer size: 19; skip: 10; is_hpc: 0; #seq: 6
[M::mm_idx_stat::0.012*1.03] distinct minimizers: 4531 (52.90% are singletons); average occurrences: 2.290; average spacing: 5.548
[M::worker_pipeline::0.063*2.15] mapped 6 sequences
[M::main] Version: 2.17-r954-dirty
[M::main] CMD: minimap2 -X -c -x asm20 6ref.fasta 6ref.fasta
[M::main] Real time: 0.065 sec; CPU: 0.136 sec; Peak RSS: 0.011 GB
```

This tool is really fast with an all versus all alignment of six *E. coli* genomes. Awesome!

#### Graph creation with seqwish

Seqwish can take pairwise sequence alignments and convert those to a variation graph:

```bash
seqwish -s 6ref.fasta -p all_vs_all.paf -b hiv.seqwish -g hiv_seqwish.gfa
```

The program takes the sequences that were used for the alignment (i.e. the input used for minimap2) with `-s` and the PAF formatted alignments with `-p`. `-b` sets a base name used for temporary files and `-g` sets the file name for the GFA output graph.

The program run is also very fast, but doesn't provide any additional output.

#### Graph representation with odgi

Odgi is a new tool from the vg team to facilitate large genomic variation graph representation with the minimum memory overhead. It can be used to visualise variation graphs, taking GFA formats as input.

```bash
odgi build -g hiv_seqwish.gfa -o - | odgi sort -i - -o hiv_seqwish.og
odgi viz -i hiv_seqwish.og -o hiv_seqwish.png -x 2000 -R
```

`odgi build` creates the dynamic succinct graph, with `-g` specifying the input GFA file, and `-o` the output destination. Directly following that command with `odgi sort` creates a topologically sorted graph, where `-i` specifies the index file to sort and `-o` is again the output destination.

Finally, the graph can be visualised as PNG with `odgi viz`, which creates the following additional output:

```
path 0 896 0.484472 0.378882 0.136646 185 145 52
path 1 HXB2 0.295597 0.566038 0.138365 113 217 53
path 2 JRCSF 0.241379 0.334483 0.424138 92 128 162
path 3 NL43 0.285393 0.530337 0.18427 109 203 70
path 4 YU2 0.348348 0.352853 0.298799 133 135 114
path 5 NC_001802.1 0.194203 0.318841 0.486957 74 122 186
```

The options are the same as before (`-i` and `-o`), with the addition of `-x` for the path padding and `-R` indicating that there should be only one path per row. The additional output lists the different paths and other, not further specified data about them.

![variant graph with seqwish and odgi]({{ "/playground/day2/pics/hiv_seqwish.png" | relative_url }})  
*variant graph with seqwish and odgi*

The resulting graph shows coloured paths per reference genome, and hints at a circular structure, with one line connecting both ends of the graph representation.

This was also discussed in the course, and problematic are probably the long terminal repeats (LTRs) of the HIV genome(s) which irritate seqwish:

![HIV genome structure](https://image.slidesharecdn.com/lectureonaidsforfirstmbbs-140825045915-phpapp02/95/a-lecture-on-aids-for-mbbs-2014-10-638.jpg?cb=1408943225)  
*HIV genome structure*
{: #genome }

### `vg msga` using only the six reference FASTA

Instead of creating a "linear" graph first and then adding the other references, it's also possible to use `vg msga` directly on the six reference FASTA file:

```bash
vg msga -f 6ref.fasta > 6ref.vg
```

This is a little slower than the minimap2/seqwish approach and I wouldn't recommend it with much more or longer sequences.

Indexing is also problematic at this scale, so we prune the graph to reduce complexity for the GCSA2 algorithm as described in the [course materials]({{ "/pages/HIV_exercises.html" | relative_url }}):

```bash
vg prune 6ref.vg > 6ref_prune.vg
vg index -x 6ref.xg 6ref.vg
vg index -g 6ref.gcsa 6ref_prune.vg
```

Now I can again create an SVG file to look at in Inkscape:

```bash
vg viz -x 6ref.xg -o 6ref.svg
```

![variant graph with vg viz and Inkscape - start]({{ "/playground/day2/pics/Inkscape_6ref.PNG" | relative_url }})  
*variant graph with vg viz and Inkscape - start*

This graph is again linear and at least the start of the graph looks exactly like that of the first graph, created on the basis of HIV-1 with the five other references added.

### Mapping long reads to variation graphs

After we created several variation graphs, we set out to use them as mapping reference for the Nanopore reads (SRR961669), and to augment the graphs with the read information. I'm using the graph I created last to do this, since it seems to be identical to the first one I created with vg.

```bash
vg map -x 6ref.xg -g 6ref.gcsa -f reads/SRR961669.2.fastq > 6ref_nano.gam
```

This took just a few minutes, but now I'm wondering if I can also map reads to the graph created with seqwish. After all, I only need the two indices for that. Of course, `vg index` needs a graph in VG format to index, but we can convert from GFA to VG with `vg view`:

```bash
vg view -F hiv_seqwish.gfa -v > hiv_seqwish.vg
```

This I can now prune, index, and use for mapping as before (`-d` gives the base name for both indices):

```bash
vg prune hiv_seqwish.vg > hiv_seqwish_prune.vg
vg index -x hiv_seqwish.xg hiv_seqwish.vg
vg index -g hiv_seqwish.gcsa hiv_seqwish_prune.vg
vg map -d hiv_seqwish -f reads/SRR961669.2.fastq > hiv_seqwish_nano.gam
```

Like in [day one]({{ site.baseurl }}{% post_url 2019-10-07-toy_examples_protocol %}), we can now have a look at the mean read identity to see if the different graphs lead to different mapping results:

```bash
vg view -a 6ref_nano.gam | jq .identity | awk '{i+=$1; n+=1} END {print i/n}'
vg view -a hiv_seqwish_nano.gam | jq .identity | awk '{i+=$1; n+=1} END {print i/n}'
```

This takes some time to compute (I assume we have a lot more reads here than in the simulated read set). The mean identity of the reads mapped to the `vg msga` graph is 0.891313, while the mean identity of the reads mapped to the seqwish graph is a tiny little bit lower with 0.891064, but I would say there's really no difference between the approaches when it comes to create a reference for read mapping.

#### Augmenting variation graphs with mapped reads

Augmenting the graph with the aligned reads facilitates variant calling and creating pileups, so we tried that as well.

```bash
vg augment -i 6ref.vg 6ref_nano.gam > 6ref_nano.aug.vg
```

The `-i` option tells `vg augment` to include the paths of the alignments into the graph, so we can visualise them. The standard call of this function as written in the [vg Wiki](https://github.com/vgteam/vg/wiki/Basic-Operations) is the following:

```bash
vg augment -a pileup -Z samp.trans -S samp.support 6ref.vg 6ref_nano.gam > samp.aug.vg
```

That one does not work, though, as the `-a` and `-S` options are already deprecated. That is disappointing, as I would have liked a pileup option. We didn't discuss other ways to obtain a pileup, so for now I don't know if it's even possible.

Instead, let's feed the augmented graph to odgi and see what it looks like:

```bash
vg view 6ref_nano.aug.vg > 6ref_nano.gfa
odgi build -g 6ref_nano.gfa -o - | odgi sort -i - -o 6ref_nano.og
```

First, the graph has to be converted to GFA format, then we can build the dynamic graph with odgi as before. Only, this time it didn't work:

```
terminate called after throwing an instance of 'std::logic_error'
  what():  basic_string::_M_construct null not valid
terminate called after throwing an instance of 'std::ios_base::failure[abi:cxx11]'
  what():  incompatible parameter B: iostream error
Aborted (core dumped)
```

Let's see if that happens in `odgi build` or `odgi sort`:

```bash
odgi build -g 6ref_nano.gfa -o tmp.og
```

```
terminate called after throwing an instance of 'std::logic_error'
  what():  basic_string::_M_construct null not valid
Aborted (core dumped)
```

This is one of the two error messages. I assume that the second one results from `odgi sort` not getting any input through the pipe, since `odgi build` doesn't generate any.

So, is there something wrong with my GFA? We used exactly the same code in the course and it worked... Luckily, odgi comes with some options to get more details about the problem.

```bash
odgi build -g 6ref_nano.gfa -o tmp.og -p
```

The `-p` option gives additional output about the progress of the graph building. In this case it reads:

```
node 62000
edge 140000
terminate called after throwing an instance of 'std::logic_error'
  what():  basic_string::_M_construct null not valid
Aborted (core dumped)
```

What does the output look like when the process runs through?

```bash
odgi build -g hiv_seqwish.gfa -o tmp.og -p
```

```
node 2000
edge 3000
path 6
```

Right, so I probably have a problem with the paths.

```bash
vg view -j -F 6ref_nano.aug.vg | jq ".path"
```

This command extracts all paths from the augmented graph and that seems to be fine... It should be the same for the GFA, since that was produced from the vg file I just used.

```bash
vg view -j -F 6ref_nano.gfa | jq ".path"
```

```
ERROR: Signal 11 occurred. VG has crashed. Run 'vg bugs --new' to report a bug.
Stack trace path: /tmp/vg_crash_ynzxeK/stacktrace.txt
```

OK, so it's a problem with the GFA file, since it's not the extraction of paths that isn't working, but already the conversion to JSON itself (the error comes from vg, not from jq). Nevertheless, odgi only seems to run into problems when reaching the paths part, so I'll try augmenting the graph without the `-i` (merging paths implied by alignments into the graph).

```bash
vg augment 6ref.vg 6ref_nano.gam > 6ref_nano.aug.vg
vg view 6ref_nano.aug.vg > 6ref_nano.gfa
odgi build -g 6ref_nano.gfa -o - | odgi sort -i - -o 6ref_nano.og
```

The augmentation is much faster without the `-i`, and odgi doesn't have problems this time, either. Great! I would have liked to see the difference between this and the version with merged paths, though.

Anyway, what does this augmented graph look like?

```bash
odgi stats -i 6ref_nano.og -S
```

```
length: 279198
nodes:  62215
edges:  140350
paths:  6
```

`odgi stats` returns data about the graph: length and number of nodes, edges, and paths. There are only six paths, referencing the six references, so how is this graph different from the original?

```bash
vg view 6ref.vg > 6ref.gfa
odgi build -g 6ref.gfa -o - | odgi sort -i - -o 6ref.og
odgi stats -i 6ref.og -S
```

```
length: 10957
nodes:  3139
edges:  4207
paths:  6
```

The original graph is a lot shorter and contains less nodes and edges, so we definitely added sequence data to the original.


```bash
odgi viz -i 6ref_nano.og -A SRR -R -S -x 5000 -P 1 -X 3 -o 6ref_nano.png
odgi viz -i 6ref.og -A SRR -R -S -x 5000 -P 1 -X 3 -o 6ref.png
```

We used some more options in the `odgi vis` call this time: `-A` is supposed to add "alignment-related visual motifs" to paths with certain prefixes (in this case "SRR"), which I guess is useless here since I couldn't include alignment paths. `-R` is again the option to display one path per row, `-S` visualises forward and reverse strands, `-x` sets the width of the output image, `-P` sets the path height, and `-X` the path padding.

![variant graph with vg msga and odgi]({{ "/playground/day2/pics/6ref.png" | relative_url }})  
*variant graph with vg msga and odgi*
![augmented variant graph with odgi]({{ "/playground/day2/pics/6ref_nano.png" | relative_url }})  
*augmented variant graph with odgi*

The augmented graph contains a lot of sequence fragments that don't fit any of the six reference genomes, which is interesting since the HIV strain mix that was sequenced here consisted of five of those strains only. Our conclusion in the course was that it is "tricky" to augment the variation graph with long reads, and maybe that is what we meant, but we never further discussed this as far as I can remember.


## AIM2 - Where is variation in viral genes?

The second question we wanted to answer was where the most variation can be found in the HIV genes. We did this in a quick-and-dirty fashion by augmenting our genome graph with the HIV-1 annotation and then analysing the annotated sequences.

### Augmenting a graph with genome annotation

I am going to augment the third graph I created - the one based on the six references, created with `vg msga`. Since the seqwish graph is circular, I prefer the vg graphs...

First, I have to fetch the annotation from [NCBI](ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/864/765/GCF_000864765.1_ViralProj15476/GCF_000864765.1_ViralProj15476_genomic.gff.gz), though.

```bash
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/864/765/GCF_000864765.1_ViralProj15476/GCF_000864765.1_ViralProj15476_genomic.gff.gz
gunzip GCF_000864765.1_ViralProj15476_genomic.gff.gz
```

There is an actual annotation function called `vg annotate` that can add GFF ([General Feature Format](https://en.wikipedia.org/wiki/General_feature_format)) or BED ([Browser Extensible Data](http://genome.ucsc.edu/FAQ/FAQformat#format1)) files to an xg indexed graph and return a gam, vg or tsv file:

```bash
vg annotate -x 6ref.xg -f GCF_000864765.1_ViralProj15476_genomic.gff > 6ref_annot.tsv
```

The TSV file is not readable, though, so I think this part of the help information for `vg augment` is not correct, or I misunderstood something.

```bash
vg annotate -x 6ref.xg -f GCF_000864765.1_ViralProj15476_genomic.gff > 6ref_annot.vg
vg view 6ref_annot.vg -j
```

```
terminate called after throwing an instance of 'std::runtime_error'
  what():  [io::ProtobufIterator] tag "GAM" for Protobuf that should be "VG"
ERROR: Signal 6 occurred. VG has crashed. Run 'vg bugs --new' to report a bug.
Stack trace path: /tmp/vg_crash_5G4Xup/stacktrace.txt
```

The same is true for ending the output file on ".vg". Apparently the output is in GAM format and that's that.

```bash
vg annotate -x 6ref.xg -f GCF_000864765.1_ViralProj15476_genomic.gff > 6ref_annot.gam
```

In order to be able to visualise this, I have to augment the annotation into the graph... Let's see if `vg augment -i` works this time:

```bash
vg augment 6ref.vg -i 6ref_annot.gam > 6ref_annot.vg
vg index -x 6ref_annot.xg 6ref_annot.vg
vg viz -x 6ref_annot.xg -o pics/6ref_annot.svg
```

![variant graph with annotation - start]({{ "/playground/day2/pics/6ref_annot_start.PNG" | relative_url }})  
*variant graph with annotation - start*

This worked, yay!  
As a reminder: 896, HXB2, JRCSF, NL43, and YU2 are the five reference genomes from the mix, and NC_00.1802.1 is the HIV-1 reference genome I downloaded from NCBI. The other paths that are now present in the graph are the genes from the annotation. Scroll back up to the [HIV genome structure](#genome) figure for a reminder of the HIV genome structure.

![variant graph with annotation - first genes]({{ "/playground/day2/pics/6ref_annot_1gene.PNG" | relative_url }})  
*variant graph with annotation - first gene*

It seems that four entries in the annotation are the same in the beginning - NP_057849.4, NP_057850.1, *gag*, and *gag-pol*, but NP_057849.4 and *gag* end sooner than the other two, so I assume that NP_057849.4 is, in fact, *gag*, and NP_057850.1 is *gag-pol* (i.e. the *gag* gene together with the *pol* gene).

## Open questions day two

- How to decide on a `-x` setting in minimap2?
- What is the significance of the additional output of `odgi viz`?
- Is there still a pileup option/tool somewhere, if `vg augment` doesn't do it?
- What is the problem with `vg augment -i` for mapped reads?
- What's so tricky about augmenting the graph with long reads? Why don't they fit to the references?

<br/>

-----

<br/>

Back to [main page]({{ "/index.html" | relative_url }}).