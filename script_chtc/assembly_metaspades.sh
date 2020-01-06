#!/bin/bash

# unpack bowtie and metaspades
unzip bowtie2-2.3.4-linux-x86_64.zip
tar -zxf SPAdes-3.11.1-Linux.tar.gz
tar -xzvf python-3.6.6.tar.gz

# set spades and python
export PATH=$(pwd)/SPAdes-3.11.1-Linux/bin:$PATH
export PATH=$(pwd)/python-3.6.6/bin:$PATH

#set PATH and BT2_HOME
export PATH=$(pwd)/bowtie2-2.3.4-linux-x86_64:$PATH
export BT2_HOME=$(pwd)/bowtie2-2.3.4-linux-x86_64

#transfer and unpack reads
cp /mnt/gluster/qzhang333/DO1_sample22_R1_mouseFiltered.fq.gz .
cp /mnt/gluster/qzhang333/DO1_sample22_R2_mouseFiltered.fq.gz .

gzip -d *fq.gz

### metaspades assambly
mkdir metaspades_DO022

metaspades.py -k 21,33,55,77 --pe1-1 DO1_sample22_R1_mouseFiltered.fq --pe1-2 DO1_sample22_R2_mouseFiltered.fq -o metaspades_DO022

tar -cvzf metaspades_DO022.tar.gz metaspades_DO022

### bowtie2 re-mapping
# remove contigs less than 500bp
awk '!/^>/ {printf "%s", $0; n = "\n"} /^>/ {print n $0; n = ""} END {printf "%s", n}' metaspades_DO022/contigs.fasta > metaspades_DO022.contigs.oneline.fasta
awk '{y= i++ % 2 ; L[y]=$0; if(y==1 && length(L[1])>=500) {printf("%s\n%s\n",L[0],L[1]);}}' metaspades_DO022.contigs.oneline.fasta > DO022.contigs.fa

rm metaspades_DO022.contigs.oneline.fasta

#index a reference genome
mkdir bowtie2_DO022
cd bowtie2_DO022/
$BT2_HOME/bowtie2-build ../DO022.contigs.fa DO022_contigs

#alignment
$BT2_HOME/bowtie2 -x DO022_contigs -1 ../DO1_sample22_R1_mouseFiltered.fq -2 ../DO1_sample22_R2_mouseFiltered.fq -S DO022.contigs.sam

cd ..

tar -cvzf bowtie2_DO022.tar.gz bowtie2_DO022

### integrate metaspades and bowtie2 output to one directory
mkdir metaspades_bowtie2_DO022
mv ./metaspades_DO022.tar.gz metaspades_bowtie2_DO022
mv ./bowtie2_DO022.tar.gz metaspades_bowtie2_DO022
tar -cvzf metaspades_bowtie2_DO022.tar.gz metaspades_bowtie2_DO022
mv metaspades_bowtie2_DO022.tar.gz /mnt/gluster/qzhang333

### move 500bp contigs back
mv DO022.contigs.fa DO022.500bp.contigs.fa
mv DO022.500bp.contigs.fa /mnt/gluster/qzhang333

rm *.fq
rm SPAdes-3.11.1-Linux.tar.gz
rm python-3.6.6.tar.gz
