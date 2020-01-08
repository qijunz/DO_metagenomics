#!/bin/bash

#unpack RSEM, Bowtie
tar -xzvf RSEM-1.3.1.tar.gz
unzip bowtie2-2.3.4-linux-x86_64.zip

# set PATH
export PATH=$(pwd)/bowtie2-2.3.4-linux-x86_64:$PATH
export PATH=$(pwd)/RSEM-1.3.1/bin:$PATH
export PATH=$(pwd)/RSEM-1.3.1/bin/samtools-1.3:$PATH

# ref seq file from gluster
cp /mnt/gluster/qzhang333/Mus_musculus.GRCm38.dna.toplevel.fa.gz .
cp /mnt/gluster/qzhang333/Mus_musculus.GRCm38.98.chr.gtf.gz .

gunzip Mus_musculus.GRCm38.dna.toplevel.fa.gz
gunzip Mus_musculus.GRCm38.98.chr.gtf.gz

#index a reference genome
mkdir ref_mm10

# build index
rsem-prepare-reference --gtf Mus_musculus.GRCm38.98.chr.gtf \
--bowtie2 Mus_musculus.GRCm38.dna.toplevel.fa ref_mm10/DORNA_mm10_mouseGenome -p 4

tar -czvf DORNA_mm10_mouseGenome_rsem-bowtie2-prepared-index-20191206.tar.gz ref_mm10

mv DORNA_mm10_mouseGenome_rsem-bowtie2-prepared-index-20191206.tar.gz /mnt/gluster/qzhang333

rm bowtie2-2.3.4-linux-x86_64.zip
rm RSEM-1.3.1.tar.gz
rm Mus_musculus.GRCm38.dna.toplevel.fa
rm Mus_musculus.GRCm38.98.chr.gtf
