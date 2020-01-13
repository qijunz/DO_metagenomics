# DO metagenomics analysis

## **Metagenomics pipeline (assembly, annotation)**

### **Step 1: Raw reads quality control and trimming (via Trimmomatic)**
- [Trimmomatic](http://www.usadellab.org/cms/?page=trimmomatic) is a Java based tool.
- CHTC job scripts example: `script_chtc/raw_reads_trimming.sh` and `script_chtc/raw_reads_trimming.sub`
- Input data are R1/R2 fastq reads (if the libraries are run in seperated lanes, trimming them seperately and concat them later): `$1_L00[1234]_R[12]_001.fastq.gz`
- In the example chtc script, each sample sequenced on 5 seperated lanes, thus, there are 5 arguments for lanes in shell script, you may want to change this depend on your case.
- Output files are concat paired and unpaired fastq data (replace $1 with unique sample ID):
    * `$1_R[12]_trimmomaticTrimmed_paired.fastq.gz`
    * `$1_R[12]_trimmomaticTrimmed_unpaired.fastq.gz`

### **Step 2: Remove host DNA reads**
- CHTC job scripts example: `script_chtc/WGS_removeHostReads.sh` and `script_chtc/WGS_removeHostReads.sub`
- Input data are trimmed R1/R2 fastq reads: `$1_R[12]_trimmomaticTrimmed_paired.fastq.gz` (replace $1 with unique sample ID).
- Output files are reconstructed unmapped and mapped paired fastq reads (replace $1 with unique sample ID):
    * `$1_R[12]_trimmed_paired_mouseDNAremoved.fastq.gz`
    * `$1_R[12]_trimmed_paired_mouseDNA.fastq.gz`

### **Step 3: Metagenomic assembly (via metaSPAdes)**
- [metaSPAdes manual](http://cab.spbu.ru/files/release3.12.0/manual.html)
- CHTC job scripts example: `script_chtc/assembly_metaspades.sh` and `script_chtc/assembly_metaspades.sub`
- Parameters used are: `metaspades.py -k 21,33,55,77 --pe1-1 R1.fq --pe1-2 R2.fq`
- Contigs shorter than 500bp were discarded from further processing. All original PE reads in the sample were aligned to all assembled contigs longer than 500bp by Bowtie2, default parameters to calculate assembly rate in each sample.
- Detailed assembly quality evaluation can be done via [quast](http://quast.bioinf.spbau.ru/manual.html).

### **Step 4: Genes/ORFs prediction**
- If the goal is to get metagenome-assembled genomes, skip the rest steps and direct to binning analysis.
- Genes prediction was performed by MetaGeneMark, using di-codon frequences estimated by GC content of a give sequence (by HMM) to predict whole ORFs in each assembled contig. All predicted genes shorter than 100bp were discarded from further processing.
```
# mgm
mgm/gmhmmp -d -m MetaGeneMark_v1.mod assembled_contigs/DOmice.500bp.contigs.fa \
           -o results_gene/DOmice.contigs.lst
# trim lst file, convert to fasta, add DO sample ID in the begining of each gene header
awk '/^[>AGCT]/ { print $0 }' results_gene/DOmice.contigs.lst | awk 'NR > 1' | sed "s/>/>${DOmice}_/" > results_gene/DOmice.genes.fasta

# keep genes >100bp
awk '!/^>/ {printf "%s", $0; n = "\n"} /^>/ {print n $0; n = ""} END {printf "%s", n}' results_gene/DOmice.genes.fasta | awk '{y= i++ % 2 ; L[y]=$0; if(y==1 && length(L[1])>=100) {printf("%s\n%s\n",L[0],L[1]);}}' > results_gene/DOmice.genes.100bp.fasta

```
- Prodigal can also used to predict ORFs.

### **Step 5: Genes redundancy removing (via CD-HIT)**
- All predicted ORFs longer than 100bp were compared pair-wise to remove redundancy using criterion of 95% identity at the nucleotide level over 90% of the length of the shorter ORFs by CD-HIT (on CHTC):
```
# run cd-hit
cd-hit-est -i 296DOmice_metaspades_mgm_genes_100bp_concat.fasta \
           -o DO_all296_genes.fa \
           -c 0.95 -n 8 -aS 0.9 -g 1 -G 0 -T 0 -M 200000 -B 1
```
- In each cluster, it picked the longest gene as representative and discarded all others.

### **Step 6: Gene abundance estimation and quantification**
- All PE reads in each sample were aligned to non-redundant gene catalog generated from step4 by Bowtie2.
- [RSEM](https://github.com/bli25broad/RSEM_tutorial) was used for metagene abundance estimation. 
- CHTC job scripts example for index building: `script_chtc/rsem_bowtie2_index.sh` and `script_chtc/rsem_bowtie2_index.sub`
- CHTC job scripts example: `script_chtc/rsem_bowtie2.sh` and `script_chtc/rsem_bowtie2.sub`

### **Step 7: Gene taxonomy assignment: NCBI NR database**
- NCBI NR database were downloaded from NCBI ftp, 2018-12-17: `ftp://ftp.ncbi.nlm.nih.gov/blast/db/FASTA/nr.gz`
- NCBI protein accession numbers to taxon ids map are downloaded from: `ftp://ftp.ncbi.nlm.nih.gov/pub/taxonomy/accession2taxid/prot.accession2taxid.gz`
- NCBI taxonomy features were downloaded from: `ftp://ftp.ncbi.nlm.nih.gov/pub/taxonomy/taxdmp.zip`
- Alignment were performed by DIAMOND (v.0.9.23):
```
# set up a reference database for DIAMOND
diamond-linux64-0.9.23/diamond makedb --in nr.faa \
                                      -d nr \ 
                                      --taxonmap prot.accession2taxid.gz \
                                      --taxonnodes nodes.dmp

# alignment
diamond-linux64-0.9.23/diamond blastx -d nr \
                                      -q 296DOmice_1.9M_GeneSet.fa \
                                      --more-sensitive \
                                      -f 102 -c 1 -b 10 \
                                      -o YourSample_blastx_ncbi_nr.txt
```
- Use default cutoff for alignment: e-value <1x10-3 and bits score >50. Taxonomic assignment were deter- mined by LCA (Lowest Common Ancestor) algorithm if there are multiple alignments. 

### **Step 8: Gene functional classification: KEGG database**
- Gene functional classification for all NR metagenes were performed by [GhostKAOLA server](https://www.kegg.jp/ghostkoala/) using 2,698,820 prokaryotes genus pan-genomes (Jan 2019).
- The cutoff for K number set as first bit score > 60.


## **Metagenomic binning by Autometa**

### **Step 1: Contigs Coverage Calculation**
- After metaSPAdes assembly, each sample, filtered contigs fasta file is generated: `DOXXX.500bp.contigs.fa`
- Align metagenomic reads within their library to contigs, and calculate coverage.
- CHTC job scripts example: `script_chtc/binning_coverage_tbl.sh` and `script_chtc/binning_coverage_tbl.sub`

### **Step 2: Autometa binning**
- Using Docker image (ijmiller2/autometa:docker_patch) run on CHTC
- CHTC job scripts example: `script_chtc/binning_autometa_docker.sh` and `script_chtc/binning_autometa_docker.sub`

### **Step 3: Bins quantification**
- Quantification via Bowtie2/Bedtool and in-house scrip (the script designed for one PE samples mapped to multiple bins):
    * `Python/bins_coverage_quantification.py` (main script)
    * `Python/fasta_length_table.py`
    * `Python/contig_coverage_from_bedtools.py`

- CHTC job scripts example: `script_chtc/binning_bins_quantification.sh` and `script_chtc/binning_bins_quantification.sub`

### **Step 4: CheckM for bins quality evaluation**
- [CheckM](https://github.com/Ecogenomics/CheckM/wiki) using a broader set of marker genes specific to the position of a genome within a reference genome tree and information about the collection of these genes.

