---
layout: post
title: "Side Quest"
categories: [analysis, psae]
author: LilithElina
---

## Finding *ras1*, *ris1* and *tse6* in my reference genome graph

There was a [publication in Nature](https://www.nature.com/articles/s41586-019-1735-9) last November that showed that *Pseudomonas aeruginosa* strain PA14 has replaced the C-terminus of Tse6, a type VI secretion system effector protein in strain PAO1, to generate a different inter-bacterial toxin. This new toxin, named Ras1, comes with its own immunity protein (Ris1), since the one effective against Tse6 (Tsi6) doesn't work on this new protein.

Of course we were interested to see how these differences are represented in the reference genome graph I already have, and what these genes look like in our clinical *P. aeruginosa* isolates.  
The genes of interest are: PA0093 (*tse6*), PA14_01140 (annotated as *tse6*, now named *ras1*), and PA14_01130 (*ris1*, but not annotated as that yet).

```bash
vg paths -x FivePsaeAnnotAll.xg -X -Q "tse6" > sideQuest/FivePsaeAnnotAll_tse6.gam
vg paths -x FivePsaeAnnotAll.xg -X -Q "PA14_01130" > sideQuest/FivePsaeAnnotAll_PA14_01130.gam
cd sideQuest/
vg view -a FivePsaeAnnotAll_tse6.gam | jq -r '([.path.mapping[].position.node_id | unique | tostring] | join("\n"))' > tse6_nodes.txt
vg view -a FivePsaeAnnotAll_PA14_01130.gam | jq -r '([.path.mapping[].position.node_id | unique | tostring] | join("\n"))' > PA14_01130_nodes.txt
vg find -N nodes.txt -x ../FivePsaeAnnotAll.xg -c 10 | vg view -v - > FivePsaeAnnotAll_nodes.vg
vg index -x FivePsaeAnnotAll_nodes.xg FivePsaeAnnotAll_nodes.vg
vg viz -x FivePsaeAnnotAll_nodes.xg -o FivePsaeAnnotAll_nodes.svg
```

I combined the nodes I found using `vg path` and `vg view` on the genes of interest into one file manually, and also removed duplicates from there to avoid error messages. I am still not a fan of the `vg viz` version of visualising sub-graphs, so I didn't have an in-depth look at this one.

[![Region of interest visualised with `vg viz`]({{ "/playground/day3/references/sideQuest/pics/FivePsaeAnnotAll_nodes.svg" | relative_url }})]({{ "/playground/day3/references/sideQuest/pics/FivePsaeAnnotAll_nodes.svg" | relative_url }})
*Region of interest visualised with `vg viz`* (click to zoom)

Instead, I visualised the sub-graph with [IVG](https://vgteam.github.io/sequenceTubeMap/) and learned an important lesson: IVG uses a path of your choice as reference for the graph to display. This was apparent here because the part of *tse6* that is not homologous in PAO1 and PA14 was only displayed as a single node - either for PAO1 or PA14, depending which reference path (PA0093 or PA14_01140) was chosen.

![Sub-graph based on the path of ras1]({{ "/playground/day3/references/sideQuest/pics/ras1_graph.PNG" | relative_url }})  
*Sub-graph based on the path of ras1 (shown in purple)*

![Sub-graph based on the path of tse6]({{ "/playground/day3/references/sideQuest/pics/tse6_graph.PNG" | relative_url }})  
*Sub-graph based on the path of tse6 (shown in red)*

![Start of the vg viz representation of a sub-graph with a merged oprD path]({{ "/playground/day3/references/sideQuest/pics/ras1_refs_graph.PNG" | relative_url }})  
*Sub-graph based on the path of ras1 (purple), with tse6 (red) and genome sequences of PA7 (blue), LESB58 (orange), and PAK (green)*

![Start of the vg viz representation of a sub-graph with a merged oprD path]({{ "/playground/day3/references/sideQuest/pics/tse6_refs_graph.PNG" | relative_url }})  
*Sub-graph based on the path of tse6 (red), with ras1 (purple) and genome sequences of PA7 (blue), LESB58 (orange), and PAK (green)*

All these sub-graph variations show how similar the first part of the gene is (it's on the negative strand so the graphs have to be read from right to left), with mostly single nucleotide exchanges between PA14 and PAO1. The versions with the other three reference genomes included show that LESB58 and PAK contain a similar *tse6* to PAO1, while PA7 apparently shares part of the PA14 variation.  
It would be nice to be able to move outside of the selected path's frame of reference to see, for example, the whole sequence of the PA7 version of *tse6*/*ras1*. As it is, you have to select that gene as the reference path and reload the graph; this reveals that there is another node of 536 nucleotides which marks the end of the PA7 gene (PSPA7_067). For comparison: the PA14 specific node of *ras1* is 607 nucleotides long, and the node of the other references containing *tse6* is 540 bases long.

I also had a look at *ris1* (the immunity conferring gene) and it only appears in PA14 as a single 233 nucleotide long node. I assume PA7 contains yet another effector and immunity gene/protein pair which could be interesting to analyse.

### Going into the details

To see if it is possible to display the divergent region of *ras1*/*tse6*, I again tried to create a PDF file from `vg view`, but still received the same error message as before (at some point in my [day 3 protocol]({{ site.baseurl }}{% post_url 2019-11-13-bacteria_exercises_protocol %})).

```bash
vg view -d FivePsaeAnnotAll_nodes.vg | dot -Tpdf -o FivePsaeAnnotAll_nodes.pdf
```

```
graph path 'refseq|NC_002516.2|chromosome' invalid: edge from 12429 end to 12462 start does not exist
[vg view] warning: graph is invalid!
Warning: Could not load "/usr/bin/miniconda3/lib/graphviz/libgvplugin_pango.so.6" - It was found, so perhaps one of its dependents was not.  Try ldd.
Warning: Could not load "/usr/bin/miniconda3/lib/graphviz/libgvplugin_pango.so.6" - It was found, so perhaps one of its dependents was not.  Try ldd.
Format: "pdf" not recognized. Use one of: canon cmap cmapx cmapx_np dot dot_json eps fig gv imap imap_np ismap json json0 mp pdf pic plain plain-ext png pov ps ps2 svg svgz tk vdx vml vmlz xdot xdot1.2 xdot1.4 xdot_json
```

OK, so I'll try `ldd` as suggested.

```bash
ldd /usr/bin/miniconda3/lib/graphvizibgvplugin_pango.so.6
```

```
        linux-vdso.so.1 =>  (0x00007ffc33be7000)
        libgvc.so.6 => /usr/bin/miniconda3/lib/graphviz/../libgvc.so.6 (0x00007f1c82860000)
        libltdl.so.7 => /usr/bin/miniconda3/lib/graphviz/../libltdl.so.7 (0x00007f1c82855000)
        libxdot.so.4 => /usr/bin/miniconda3/lib/graphviz/../libxdot.so.4 (0x00007f1c8284e000)
        libcgraph.so.6 => /usr/bin/miniconda3/lib/graphviz/../libcgraph.so.6 (0x00007f1c82833000)
        libcdt.so.5 => /usr/bin/miniconda3/lib/graphviz/../libcdt.so.5 (0x00007f1c8282a000)
        libpathplan.so.4 => /usr/bin/miniconda3/lib/graphviz/../libpathplan.so.4 (0x00007f1c8281f000)
        libexpat.so.1 => /usr/bin/miniconda3/lib/graphviz/../libexpat.so.1 (0x00007f1c827ea000)
        libz.so.1 => /usr/bin/miniconda3/lib/graphviz/../libz.so.1 (0x00007f1c827d0000)
        libpangocairo-1.0.so.0 => /usr/bin/miniconda3/lib/graphviz/../libpangocairo-1.0.so.0 (0x00007f1c827c0000)
        libcairo.so.2 => /usr/bin/miniconda3/lib/graphviz/../libcairo.so.2 (0x00007f1c825e1000)
        libpangoft2-1.0.so.0 => /usr/bin/miniconda3/lib/graphviz/../libpangoft2-1.0.so.0 (0x00007f1c827a6000)
        libpango-1.0.so.0 => /usr/bin/miniconda3/lib/graphviz/../libpango-1.0.so.0 (0x00007f1c8275c000)
        libfontconfig.so.1 => /usr/bin/miniconda3/lib/graphviz/../libfontconfig.so.1 (0x00007f1c82714000)
        libgobject-2.0.so.0 => /usr/bin/miniconda3/lib/graphviz/../libgobject-2.0.so.0 (0x00007f1c82588000)
        libglib-2.0.so.0 => /usr/bin/miniconda3/lib/graphviz/../libglib-2.0.so.0 (0x00007f1c82465000)
        libfreetype.so.6 => /usr/lib/x86_64-linux-gnu/libfreetype.so.6 (0x00007f1c8219f000)
        libm.so.6 => /lib/x86_64-linux-gnu/libm.so.6 (0x00007f1c81e96000)
        libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f1c81acc000)
        libdl.so.2 => /lib/x86_64-linux-gnu/libdl.so.2 (0x00007f1c818c8000)
        libfribidi.so.0 => /usr/bin/miniconda3/lib/graphviz/.././libfribidi.so.0 (0x00007f1c818a8000)
        libgthread-2.0.so.0 => /usr/bin/miniconda3/lib/graphviz/.././libgthread-2.0.so.0 (0x00007f1c818a3000)
        libharfbuzz.so.0 => /usr/bin/miniconda3/lib/graphviz/.././libharfbuzz.so.0 (0x00007f1c817a3000)
        libpthread.so.0 => /lib/x86_64-linux-gnu/libpthread.so.0 (0x00007f1c81586000)
        libpixman-1.so.0 => /usr/bin/miniconda3/lib/graphviz/.././libpixman-1.so.0 (0x00007f1c814cd000)
        libpng16.so.16 => /usr/bin/miniconda3/lib/graphviz/.././libpng16.so.16 (0x00007f1c81494000)
        libxcb-shm.so.0 => /usr/bin/miniconda3/lib/graphviz/.././libxcb-shm.so.0 (0x00007f1c8148f000)
        libxcb.so.1 => /usr/bin/miniconda3/lib/graphviz/.././libxcb.so.1 (0x00007f1c81462000)
        libxcb-render.so.0 => /usr/bin/miniconda3/lib/graphviz/.././libxcb-render.so.0 (0x00007f1c81452000)
        libXrender.so.1 => /usr/bin/miniconda3/lib/graphviz/.././libXrender.so.1 (0x00007f1c81445000)
        libX11.so.6 => /usr/bin/miniconda3/lib/graphviz/.././libX11.so.6 (0x00007f1c81301000)
        libXext.so.6 => /usr/bin/miniconda3/lib/graphviz/.././libXext.so.6 (0x00007f1c812ec000)
        librt.so.1 => /lib/x86_64-linux-gnu/librt.so.1 (0x00007f1c810e4000)
        libxml2.so.2 => /usr/bin/miniconda3/lib/graphviz/.././libxml2.so.2 (0x00007f1c80f7b000)
        libuuid.so.1 => /usr/bin/miniconda3/lib/graphviz/.././libuuid.so.1 (0x00007f1c80f72000)
        libffi.so.6 => /usr/bin/miniconda3/lib/graphviz/.././libffi.so.6 (0x00007f1c80f67000)
        libpcre.so.1 => /usr/bin/miniconda3/lib/graphviz/.././libpcre.so.1 (0x00007f1c80f1f000)
        libiconv.so.2 => /usr/bin/miniconda3/lib/graphviz/.././libiconv.so.2 (0x00007f1c80e37000)
        libpng12.so.0 => /lib/x86_64-linux-gnu/libpng12.so.0 (0x00007f1c80c11000)
        /lib64/ld-linux-x86-64.so.2 (0x00007f1c826ea000)
        libgraphite2.so.3 => /usr/bin/miniconda3/lib/graphviz/../././libgraphite2.so.3 (0x00007f1c80be3000)
        libXau.so.6 => /usr/bin/miniconda3/lib/graphviz/../././libXau.so.6 (0x00007f1c80bdd000)
        libXdmcp.so.6 => /usr/bin/miniconda3/lib/graphviz/../././libXdmcp.so.6 (0x00007f1c80bd5000)
        libicuuc.so.64 => /usr/bin/miniconda3/lib/graphviz/../././libicuuc.so.64 (0x00007f1c809fd000)
        liblzma.so.5 => /usr/bin/miniconda3/lib/graphviz/../././liblzma.so.5 (0x00007f1c809d4000)
        libicudata.so.64 => /usr/bin/miniconda3/lib/graphviz/.././././libicudata.so.64 (0x00007f1c7ef8f000)
        libstdc++.so.6 => /usr/bin/miniconda3/lib/graphviz/.././././libstdc++.so.6 (0x00007f1c7ee1b000)
        libgcc_s.so.1 => /usr/bin/miniconda3/lib/graphviz/.././././libgcc_s.so.1 (0x00007f1c7ee07000)
```

I've never done this before, but it doesn't look like anything is actually missing. Since that part of the error is only a warning, maybe the part about the not recognised PDF format is the real problem. A [proposed solution](https://gitlab.com/graphviz/graphviz/issues/1315) for this is to run `dot -c`:

```
sudo -i
dot -c
exit
vg view -d FivePsaeAnnotAll_nodes.vg | dot -Tpdf -o FivePsaeAnnotAll_nodes.pdf
```

```
Format: "pdf" not recognized. Use one of: canon cmap cmapx cmapx_np dot dot_json eps fig gv imap imap_np ismap json json0 mp pic plain plain-ext pov ps ps2 svg svgz tk vdx vml vmlz xdot xdot1.2 xdot1.4 xdot_json
graph path 'refseq|NC_002516.2|chromosome' invalid: edge from 12429 end to 12462 start does not exist
[vg view] warning: graph is invalid!
```

Well, at least now it doesn't list pdf in the suggestions anymore! SVG, then?

```bash
vg view -d FivePsaeAnnotAll_nodes.vg | dot -Tsvg -o FivePsaeAnnotAll_nodes_dot.svg
```

```
graph path 'refseq|NC_002516.2|chromosome' invalid: edge from 12429 end to 12462 start does not exist
[vg view] warning: graph is invalid!
```

[![Region of interest visualised with `dot`]({{ "/playground/day3/references/sideQuest/pics/FivePsaeAnnotAll_nodes_dot.svg" | relative_url }})]({{ "/playground/day3/references/sideQuest/pics/FivePsaeAnnotAll_nodes_dot.svg" | relative_url }})
*Region of interest visualised with `dot`* (click to zoom)

Except for the invalid edge because of a missing node, this actually worked. Still, I would prefer to get PDFs as well... Apparently we have Pango installed, but it's not connected to graphviz anymore. So far, the only solution I could find is to re-install graphviz, but conda would remove A LOT of other programs if I tried to remove it first, and that is not an option right now.

In any case, this sub-graph representation is not very helpful without the annotated paths. To keep things as simple as possible, I'm going to add the paths, but remove the sequences from the nodes.

```bash
vg view -dpS FivePsaeAnnotAll_nodes.vg | dot -Tsvg -o pics/FivePsaeAnnotAll_nodes_paths_dot.svg
```

I still get the same error about the missing node, but I won't show it here again.

[![Simplified region of interest visualised with `dot` including paths]({{ "/playground/day3/references/sideQuest/pics/FivePsaeAnnotAll_nodes_paths_dot.svg" | relative_url }})]({{ "/playground/day3/references/sideQuest/pics/FivePsaeAnnotAll_nodes_paths_dot.svg" | relative_url }})
*Simplified region of interest visualised with `dot` including paths* (click to zoom)

The nice thing about this format is that you can do text searches on it. That makes it easier to find for example PA14_01130 (*ris1*), which is only present with two nodes - one of 223 bp length, and one with an additional 10 bp which the gene shares with *ras1* (PA14_01140). That is a little irritating, since there is no mention of the two genes overlapping, but looking at the annotation it's true: *ris1* start at 111205 and *ras1* ends at 111195 (remember, the genes are on the negative strand). I could not see this in IVG.

This representation of the sub-graph shows that there are two beginnings to the graph on the left side, representing multiple genes I am not interested in right now. One is for PA7 alone, the other represents the other strains and separates at the end of *tsi6* (the *tse6* immunity gene). Then, *ras1* and *tse6* start at the same position, but on different branches. The third branch still only belongs to PA7, with PSPA7_0166 and PSPA7_0167. PA14 and PA7 merge at node 711086 for 16 bp (with one single variant) before merging with the other strains again at node 12473. From then on, there is only one branch for all strains with smaller variations.

While this representation might not look as nice as a sequence tube map, it's easier to understand as everything is there to see, you only have to find it.

### The operon in PA7

This topic is quite fascinating. In [PAO1](http://pseudomonas.com/feature/show/?id=102919&view=operons), the predicted operon for this T6SS effector and immunity complex contains three genes: *tsi6*, *tse6*, and *eagT6* (a chaperone for Tse6). It is located on the negative strand, surrounded by genes on the positive strand.  
The predicted operon in [PA14](http://pseudomonas.com/feature/show/?id=1651025&view=operons) consists of *tsi6*, PA14_01130 (*ris1*), and *tse6*/*ras1*. Adjacent and also on the negative strand is again *eagT6*, but it's apparently not counted into the operon.  
The same operon in [PA7](http://pseudomonas.com/feature/show/?id=1663126&view=operons) contains only genes annotated as hypothetical so far (even though *tse6* is basically as close to the PAO1 version as in PA14). It consists of five genes: PSPA_0164 to PSPA_0168. Analogous to the other strains (and based on the graph as well) PSPA_0167 is a version of *tse6*/*ras1* and PSPA_0168 is *eagT6* (96.7% blastn identity in PAK and PA14). The other three genes don't match anything else in the graph, even though PSPA7_0165 is listed as ortholog to *tsi6* in PAO1 and PA14. PSPA_0164 doesn't even have any orthologs listed on [pseudomonas.com](http://pseudomonas.com/orthologs/list?id=1663120), and PSPA_0166 only has orthologs annotated as hypothetical in less well known strains.
