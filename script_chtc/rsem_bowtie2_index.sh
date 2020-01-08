#!/bin/bash

#unpack RSEM, Bowtie
tar -xzvf RSEM-1.3.1.tar.gz
unzip bowtie2-2.3.4-linux-x86_64.zip

# set PATH
export PATH=$(pwd)/bowtie2-2.3.4-linux-x86_64:$PATH
export PATH=$(pwd)/RSEM-1.3.1/bin:$PATH
export PATH=$(pwd)/RSEM-1.3.1/bin/samtools-1.3:$PATH

# ref seq file from gluster
cp /mnt/gluster/qzhang333/your_post_CD-HIT_NR_metagenes_seqs.fa .

#index a reference genome
mkdir ref

# build index
rsem-prepare-reference --bowtie2 your_post_CD-HIT_NR_metagenes_seqs.fa ref/296DOmice_1.9M_GeneSet -p 4

tar -czvf 296DOmice_1.9M_GeneSet_rsem-prepared-bowtie2-20181215.tar.gz ref

mv 296DOmice_1.9M_GeneSet_rsem-prepared-bowtie2-20181215.tar.gz /mnt/gluster/qzhang333

rm bowtie2-2.3.4-linux-x86_64.zip
rm RSEM-1.3.1.tar.gz
rm your_post_CD-HIT_NR_metagenes_seqs.fa
