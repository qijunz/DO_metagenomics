#!/bin/bash

# unpack bowtie and metaspades
unzip bowtie2-2.3.4-linux-x86_64.zip
tar -xzvf samtools_1.9.tar.gz
tar -xzf bedtools2-2.28.0.tar.gz

# set PATH and BT2_HOME
export PATH=$(pwd)/bowtie2-2.3.4-linux-x86_64:$PATH
export BT2_HOME=$(pwd)/bowtie2-2.3.4-linux-x86_64
export PATH=$(pwd)/samtools_1.9/bin:$PATH
export PATH=$(pwd)/bedtools2-2.28.0/bin:$PATH

#transfer and unpack reads
cp /mnt/gluster/qzhang333/DO_sample$1_R1_mouseFiltered.fq.gz .
cp /mnt/gluster/qzhang333/DO_sample$1_R2_mouseFiltered.fq.gz .

gzip -d *fq.gz


# transfer contigs fa file
cp /mnt/gluster/qzhang333/DO$1.500bp.contigs.fa .

### 1. Alignment
# make new directory for bowtie2 alignemnt out
mkdir DO$1_contig
cd DO$1_contig/

#index a reference genome
$BT2_HOME/bowtie2-build ../DO$1.500bp.contigs.fa DO$1.contigs

# reads alignment to akk contigs
$BT2_HOME/bowtie2 -x ./DO$1.contigs -1 ../DO_sample$1_R1_mouseFiltered.fq -2 ../DO_sample$1_R2_mouseFiltered.fq --very-sensitive-local --no-unal -p 8 -S DO$1.sam

# convert SAM file to a sorted BAM file, and create a BAM index
samtools view -bS DO$1.sam | samtools sort -o DO$1_sorted.bam

rm DO$1.sam

# build index for igv visualization
samtools index DO$1_sorted.bam

### 2. contig coverage
../automate_fasta_length_table.pl ../DO$1.500bp.contigs.fa > contig_length_tab_file.txt
genomeCoverageBed -ibam DO$1_sorted.bam -g contig_length_tab_file.txt > genome_bed_file.bed
../automate_contig_coverage_from_bedtools.pl genome_bed_file.bed > DO$1_coverage.tab

cd ..

tar -cvzf DO$1_contig.tar.gz DO$1_contig

### move 500bp contigs back
mv DO$1_contig.tar.gz /mnt/gluster/qzhang333

rm *.fq
rm bowtie2-2.3.4-linux-x86_64.zip
rm samtools_1.9.tar.gz
rm DO$1.500bp.contigs.fa
