#!/bin/bash

#unpack RSEM, Bowtie
tar -xzvf RSEM-1.3.1.tar.gz
unzip bowtie2-2.3.4-linux-x86_64.zip

# set PATH
export PATH=$(pwd)/bowtie2-2.3.4-linux-x86_64:$PATH
export PATH=$(pwd)/RSEM-1.3.1/bin:$PATH
export PATH=$(pwd)/RSEM-1.3.1/bin/samtools-1.3:$PATH

#transfer and unpack reads
cp /mnt/gluster/qzhang333/DO_sample021_R1_mouseFiltered.fq.gz .
cp /mnt/gluster/qzhang333/DO_sample021_R2_mouseFiltered.fq.gz .

gzip -d *fq.gz

# transfer mouse metagenome reference
cp /mnt/gluster/qzhang333/296DOmice_1.9M_GeneSet_rsem-prepared-bowtie2-20181215.tar.gz .

tar -xzvf 296DOmice_1.9M_GeneSet_rsem-prepared-bowtie2-20181215.tar.gz
rm *.tar.gz

# make directory for reference building and expression calculating
mkdir rsem-1.9M-Genes-DO021

# calculate expression
rsem-calculate-expression -p 8 --bowtie2 --paired-end DO_sample021_R1_mouseFiltered.fq DO_sample021_R2_mouseFiltered.fq ./ref/296DOmice_1.9M_GeneSet ./rsem-1.9M-Genes-DO021/DO021

# move gene result file out
mv ./rsem-1.9M-Genes-DO021/DO021.genes.results DO021.rsem.1.9M.GeneSet.bowtie2.genes.results
mv DO021.rsem.1.9M.GeneSet.bowtie2.genes.results /mnt/gluster/qzhang333

rm -rf ref
rm -rf rsem-1.9M-Genes-DO021
rm *.fq
