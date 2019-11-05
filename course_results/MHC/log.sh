# pw-align MHC sequences (haplotypes)
minimap2 -c -x asm20 -X -t 4 MHC/MHC.fa.gz MHC/MHC.fa.gz | gzip > MHC.paf.gz

# Creates a graph from pw-aligned sequences 
seqwish -s MHC/MHC.fa.gz -p MHC.paf.gz -t 4 -b MHC -g MHC.gfa

# Convert gfa to vg format. We chopped it because vg gcsa does not support nodes > 1024
vg view -F MHC.gfa -v | vg mod -X 256 -M 8 - | vg sort - > MHC.vg

# Build indices
vg index -x MHC.xg MHC.vg
vg prune -k 16 -e 3 -s 0 MHC.vg > MHC.pruned.vg
vg index -g MHC.gcsa MHC.pruned.vg

# Concatenate all FASTA files for new haplotypes and flatten the sequences because vg mgsa complains. It does complain even if we do this :( Probably because seqs are highly conserved
cat MHC/IMGT_alleles/*_gen.fasta > all_gen.fasta
awk '/^>/ {printf("\n%s\n",$0);next; } { printf("%s",$0);}  END {printf("\n");}' < all_gen.fasta  > all_gen_flat.fasta

# Upgrade the MHC graph with new haplotype sequences. This takes tooooo long because it makes an index every time it aligns a sequence.
vg msga -f all_gen.fasta -g MHC.vg -t 4 > all.vg

# Calculate depth of short reads (illumina)
samtools depth MHC/TrioData/illumina/HG00512.bam | awk 'BEGIN {FS="\t"} {qual += $3} END {print qual / NR}'
samtools depth MHC/TrioData/illumina/HG00513.bam | awk 'BEGIN {FS="\t"} {qual += $3} END {print qual / NR}'
samtools depth MHC/TrioData/illumina/HG00514.bam | awk 'BEGIN {FS="\t"} {qual += $3} END {print qual / NR}'

# Calculate the genome size 
samtools faidx MHC/MHC.fa 
cat MHC/MHC.fa.fai

# Edit config.yaml to run error correction of long reads, for every one of the three parent-child samples. Using snakemake

# We killed vg mgsa because it creates an index every time it aligns a new seq.
# Instead, we run minimap2 so that it only keeps the first best alignment
minimap2 -cx asm20 -t 8 -a --secondary=no MHC/MHC.fa MHC/IMGT_alleles/hla_gen.fasta > hla_gen.MHC.sam

# Then vg inject to make a gam alignment
vg inject -x MHC.xg -t 8  hla_gen.MHC.sam > hla_gen.MHC.gam

# We need to augment the graph with the new haplotypes
vg augment -i MHC.vg hla_gen.MHC.gam -A MHC.aug.gam > MHC.aug.vg

# Build Index
vg index -x MHC.aug.xg MHC.aug.vg

# Map (error-corrected) reads to graph from Chinese parent-child
GraphAligner -g MHC.aug.vg -f corrected_reads/output2/corrected.fa -a HG00512.gam
GraphAligner -g MHC.aug.vg -f corrected_reads/output3/corrected.fa -a HG00513.gam
GraphAligner -g MHC.aug.vg -f corrected_reads/output4/corrected.fa -a HG00514.gam

# Map Long Reads (HG002) to graph
GraphAligner -t 2 -g MHC.aug.vg -f MHC/HG002/HG002.PacBio.15kbCCS.Q20.hs37d5.pbmm2.MAPQ60.HP10xtrioRTG.MHConly.newsplit.28498559.H1.fastq.gz -a HG002.pb.H1.gam &
GraphAligner -t 2 -g MHC.aug.vg -f MHC/HG002/HG002.PacBio.15kbCCS.Q20.hs37d5.pbmm2.MAPQ60.HP10xtrioRTG.MHConly.newsplit.28498559.H2.fastq.gz -a HG002.pb.H2.gam &
GraphAligner -t 2 -g MHC.aug.vg -f MHC/HG002/HG002.PacBio.15kbCCS.Q20.hs37d5.pbmm2.MAPQ60.HP10xtrioRTG.MHConly.newsplit.28498559.untagged.fastq.gz -a HG002.pb.untagged.gam &
GraphAligner -t 2 -g MHC.aug.vg -f MHC/HG002/HG002_Promethion.MHConly.28498559.H1.fastq.gz -a HG002.prom.H1.gam &
GraphAligner -t 2 -g MHC.aug.vg -f MHC/HG002/HG002_Promethion.MHConly.28498559.H2.fastq.gz -a HG002.prom.H2.gam &
GraphAligner -t 2 -g MHC.aug.vg -f MHC/HG002/HG002_Promethion.MHConly.28498559.untagged.fastq.gz -a HG002.prom.untagged.gam &

# Pack alignments to get coverage (per base)
vg pack -x MHC.aug.xg -g HG00512.gam -d > HG00512.cov.txt
vg pack -x MHC.aug.xg -g HG00513.gam -d > HG00513.cov.txt
vg pack -x MHC.aug.xg -g HG00514.gam -d > HG00514.cov.txt

vg pack -x MHC.aug.xg -g HG002.pb.H1.gam -d > HG002.pb.H1.cov.txt
vg pack -x MHC.aug.xg -g HG002.pb.H2.gam -d > HG002.pb.H2.cov.txt
vg pack -x MHC.aug.xg -g HG002.pb.untagged.gam -d > HG002.pb.untagged.cov.txt
vg pack -x MHC.aug.xg -g HG002.prom.H1.gam -d > HG002.prom.H1.cov.txt
vg pack -x MHC.aug.xg -g HG002.prom.H2.gam -d > HG002.prom.H2.cov.txt
vg pack -x MHC.aug.xg -g HG002.prom.untagged.gam -d > HG002.prom.untagged.cov.txt

# Extract nodelist for every path (corresponds to an haplotype) from graph
vg paths -x MHC.aug.xg -X -Q "HLA:HLA" | vg view -a - | jq '{name: .name, nodes: ([.path.mapping[].position.node_id | tostring] | join(","))}' | grep "name" -A 1 | grep "^\-\-" -v > nodes_all.txt

# Next we map the 
