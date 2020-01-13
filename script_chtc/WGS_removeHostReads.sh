#!/bin/bash

# unpack bowtie2 and samtool installation
unzip bowtie2-2.3.4-linux-x86_64.zip
tar -xzvf samtools_1.9.tar.gz
tar -xzf python-3.6.7.tar.gz

# add bowtie2 and samtool path
export PATH=$(pwd)/bowtie2-2.3.4-linux-x86_64:$PATH
export BT2_HOME=$(pwd)/bowtie2-2.3.4-linux-x86_64
export PATH=$(pwd)/samtools_1.9/bin:$PATH
export PATH=$(pwd)/python-3.6.7/bin:$PATH

# transfer trimmed reads and indexed mouse genome
cp /mnt/gluster/qzhang333/$1_R1_trimmomaticTrimmed_paired.fastq.gz .  
cp /mnt/gluster/qzhang333/$1_R2_trimmomaticTrimmed_paired.fastq.gz . 
cp /mnt/gluster/qzhang333/Mus_musculus_GRCm38_Rel98_bowtie2_index.tar.gz .

# uncompress
gunzip $1_R1_trimmomaticTrimmed_paired.fastq.gz
gunzip $1_R2_trimmomaticTrimmed_paired.fastq.gz
tar -xzvf Mus_musculus_GRCm38_Rel98_bowtie2_index.tar.gz

# clear .fastq.gz
rm *.fastq.gz

# alignment WGS reads to mouse genome
bowtie2 -x Mus_musculus_GRCm38_Rel98_bowtie2_index/ref \
        -1 $1_R1_trimmomaticTrimmed_paired.fastq \
        -2 $1_R2_trimmomaticTrimmed_paired.fastq \
        -p 4 |
samtools view -bS > $1_mouseGenome.bam

# get mouse genome unmapped sam file
samtools view -s -f 4 -f 8 -o $1_mouseDNAremoved.sam $1_mouseGenome.bam

# reconstruct unmapped and mapped reads from R1/R2 raw reads
python WGS_unmapped_FASTQ_rebuiled_from_mouseDNAremovedBAM.py \
       -s $1_mouseDNAremoved.sam \
       -F $1_R1_trimmomaticTrimmed_paired.fastq \
       -R $1_R2_trimmomaticTrimmed_paired.fastq \
       -Fu $1_R1_trimmed_paired_mouseDNAremoved.fastq \
       -Fm $1_R1_trimmed_paired_mouseDNA.fastq \
       -Ru $1_R2_trimmed_paired_mouseDNAremoved.fastq \
       -Rm $1_R2_trimmed_paired_mouseDNA.fastq

# compress fastq data
gzip -f $1_R1_trimmed_paired_mouseDNAremoved.fastq
gzip -f $1_R1_trimmed_paired_mouseDNA.fastq
gzip -f $1_R2_trimmed_paired_mouseDNAremoved.fastq
gzip -f $1_R2_trimmed_paired_mouseDNA.fastq

# transfer reconstruct unmapped and mapped reads into gluster
mv $1_R1_trimmed_paired_mouseDNAremoved.fastq.gz /mnt/gluster/qzhang333/
mv $1_R1_trimmed_paired_mouseDNA.fastq.gz /mnt/gluster/qzhang333/
mv $1_R2_trimmed_paired_mouseDNAremoved.fastq.gz /mnt/gluster/qzhang333/
mv $1_R2_trimmed_paired_mouseDNA.fastq.gz /mnt/gluster/qzhang333/

# clear data
rm -R Mus_musculus_GRCm38_Rel98_bowtie2_index
rm Mus_musculus_GRCm38_Rel98_bowtie2_index.tar.gz
rm *.fastq
rm $1_mouseGenome.bam
rm $1_mouseDNAremoved.sam
