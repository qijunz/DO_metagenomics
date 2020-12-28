#!/bin/bash

# create log file
touch $1.log

# unpack pipeline 
tar -xzf chtc_metagenomic.tar.gz

# set path
export PATH=$(pwd)/chtc_metagenomic/bin:$PATH
export PATH=$(pwd)/chtc_metagenomic/python-3.6.7/bin:$PATH
export PYTHONPATH=$(pwd)/chtc_metagenomic/python-3.6.7-packages
export PATH=$(pwd)/chtc_metagenomic/bowtie2-2.3.4-linux-x86_64:$PATH

# need to install and compile Ruby every time
>&2 echo "downloading ruby from website...."
wget https://cache.ruby-lang.org/pub/ruby/2.7/ruby-2.7.0.tar.gz

>&2 echo "unpacking ruby source code..."
tar -xzvf ruby-2.7.0.tar.gz
cd ruby-2.7.0

>&2 echo "compiling ruby source code (configure)..."
./configure --prefix=$(pwd)/../chtc_metagenomic/

>&2 echo "compiling ruby source code (make)..."
make

>&2 echo "compiling ruby source code (make install)..."
make install

# check if ruby installed or not
which ruby > $1.log 2>&1

cd ..
rm ruby-2.7.0.tar.gz

# transfer input data
cp /staging/groups/rey_group_datashare/Ath-HMDP_clean_reads/$1_R1_trimmed_paired_mouseDNAremoved.fastq.gz .
cp /staging/groups/rey_group_datashare/Ath-HMDP_clean_reads/$1_R2_trimmed_paired_mouseDNAremoved.fastq.gz .

gzip -d *fastq.gz

# create output dir 
mkdir metagenomic_out_$1

# run pipeline
python chtc_metagenomic/pipeline.py -F $1_R1_trimmed_paired_mouseDNAremoved.fastq -R $1_R2_trimmed_paired_mouseDNAremoved.fastq -o metagenomic_out_$1/ -d chtc_metagenomic/data/ -s $1

# tar output 
tar -czf metagenomic_out_$1.tar.gz metagenomic_out_$1

# move output to staging/qzhang333
mv metagenomic_out_$1.tar.gz /staging/qzhang333

# clear other data
rm -R chtc_metagenomic
rm chtc_metagenomic.tar.gz
rm *.fastq

