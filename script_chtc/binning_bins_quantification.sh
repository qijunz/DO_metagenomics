#!/bin/bash

# unpack bowtie and metaspades
unzip bowtie2-2.3.4-linux-x86_64.zip
tar -xzf samtools_1.9.tar.gz
tar -xzf bedtools2-2.28.0.tar.gz
tar -xzf python-3.6.7.tar.gz

# set PATH and BT2_HOME
export PATH=$(pwd)/bowtie2-2.3.4-linux-x86_64:$PATH
export BT2_HOME=$(pwd)/bowtie2-2.3.4-linux-x86_64
export PATH=$(pwd)/samtools_1.9/bin:$PATH
export PATH=$(pwd)/bedtools2-2.28.0/bin:$PATH
export PATH=$(pwd)/python-3.6.7/bin:$PATH

# transfer bins
cp /mnt/gluster/qzhang333/bins_rename_reconstructed_repInClusterByMash.tar.gz .

# bins dir
tar -xzf bins_rename_reconstructed_repInClusterByMash.tar.gz

mv bins_rename_reconstructed_repInClusterByMash/$2.fasta .
rm bins_rename_reconstructed_repInClusterByMash/*
mv $2.fasta bins_rename_reconstructed_repInClusterByMash

#transfer and unpack reads
cp /mnt/gluster/qzhang333/DO_sample$1_R1_mouseFiltered.fq.gz .
cp /mnt/gluster/qzhang333/DO_sample$1_R2_mouseFiltered.fq.gz .

gzip -d *fq.gz

# run bins_coverage_quantification.py
python bins_coverage_quantification.py -b bins_rename_reconstructed_repInClusterByMash -F DO_sample$1_R1_mouseFiltered.fq -R DO_sample$1_R2_mouseFiltered.fq -o DO$1_$2_out -s DO$1 -p 1

# compress out folder
tar -czvf DO$1_$2_out.tar.gz DO$1_$2_out

# clean other data
rm *.fq
rm -R DO$1_$2_out
rm bins_rename_reconstructed_repInClusterByMash.tar.gz
