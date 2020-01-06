#!/bin/bash

# unpack trimmomatic and java installation
unzip Trimmomatic-0.39.zip
tar -xzvf jre-8u231-linux-x64.tar.gz

# make sure the script will use your trimmomatic and java installation
# adding Trimmomatic-0.39/ to PATH may not work
export PATH=$(pwd)/Trimmomatic-0.39:$PATH
export JAVA_HOME=$(pwd)/jre1.8.0_231
export PATH=$(pwd)/jre1.8.0_231/bin:$PATH

# copy raw reads from cluster here
# cp /mnt/gluster/qzhang333/$1_R1_001.fastq.gz .
# cp /mnt/gluster/qzhang333/$1_R2_001.fastq.gz .

# all 8 files: R1/R2 in L001/L002/L003/L004
cp /mnt/gluster/qzhang333/$1*.fastq.gz .          

# unzip raw reads
gzip -d $1_L001_R1_001.fastq.gz
gzip -d $1_L001_R2_001.fastq.gz
gzip -d $1_L002_R1_001.fastq.gz
gzip -d $1_L002_R2_001.fastq.gz
gzip -d $1_L003_R1_001.fastq.gz
gzip -d $1_L003_R2_001.fastq.gz
gzip -d $1_L004_R1_001.fastq.gz
gzip -d $1_L004_R2_001.fastq.gz

# trimming: quality trmming, for R1/R2 in L001
java -jar Trimmomatic-0.39/trimmomatic-0.39.jar PE -threads 1 \
$1_L001_R1_001.fastq \
$1_L001_R2_001.fastq \
$1_L001_R1_001_trimmomaticTrimmed_paired.fastq \
$1_L001_R1_001_trimmomaticTrimmed_unpaired.fastq \
$1_L001_R2_001_trimmomaticTrimmed_paired.fastq \
$1_L001_R2_001_trimmomaticTrimmed_unpaired.fastq \
TRAILING:20 MINLEN:30

# clean raw seq
rm $1_L001_R1_001.fastq
rm $1_L001_R2_001.fastq

# trimming: quality trmming, for R1/R2 in L002
java -jar Trimmomatic-0.39/trimmomatic-0.39.jar PE -threads 1 \
$1_L002_R1_001.fastq \
$1_L002_R2_001.fastq \
$1_L002_R1_001_trimmomaticTrimmed_paired.fastq \
$1_L002_R1_001_trimmomaticTrimmed_unpaired.fastq \
$1_L002_R2_001_trimmomaticTrimmed_paired.fastq \
$1_L002_R2_001_trimmomaticTrimmed_unpaired.fastq \
TRAILING:20 MINLEN:30

# clean raw seq
rm $1_L002_R1_001.fastq
rm $1_L002_R2_001.fastq

# trimming: quality trmming, for R1/R2 in L003
java -jar Trimmomatic-0.39/trimmomatic-0.39.jar PE -threads 1 \
$1_L003_R1_001.fastq \
$1_L003_R2_001.fastq \
$1_L003_R1_001_trimmomaticTrimmed_paired.fastq \
$1_L003_R1_001_trimmomaticTrimmed_unpaired.fastq \
$1_L003_R2_001_trimmomaticTrimmed_paired.fastq \
$1_L003_R2_001_trimmomaticTrimmed_unpaired.fastq \
TRAILING:20 MINLEN:30

# clean raw seq
rm $1_L003_R1_001.fastq
rm $1_L003_R2_001.fastq

# trimming: quality trmming, for R1/R2 in L004
java -jar Trimmomatic-0.39/trimmomatic-0.39.jar PE -threads 1 \
$1_L004_R1_001.fastq \
$1_L004_R2_001.fastq \
$1_L004_R1_001_trimmomaticTrimmed_paired.fastq \
$1_L004_R1_001_trimmomaticTrimmed_unpaired.fastq \
$1_L004_R2_001_trimmomaticTrimmed_paired.fastq \
$1_L004_R2_001_trimmomaticTrimmed_unpaired.fastq \
TRAILING:20 MINLEN:30

# clean raw seq
rm $1_L004_R1_001.fastq
rm $1_L004_R2_001.fastq

# cancatenate 4 lanes, R1 paired
cat $1_L001_R1_001_trimmomaticTrimmed_paired.fastq >> $1_R1_trimmomaticTrimmed_paired.fastq
cat $1_L002_R1_001_trimmomaticTrimmed_paired.fastq >> $1_R1_trimmomaticTrimmed_paired.fastq
cat $1_L003_R1_001_trimmomaticTrimmed_paired.fastq >> $1_R1_trimmomaticTrimmed_paired.fastq
cat $1_L004_R1_001_trimmomaticTrimmed_paired.fastq >> $1_R1_trimmomaticTrimmed_paired.fastq

# cancatenate 4 lanes, R2 paired
cat $1_L001_R2_001_trimmomaticTrimmed_paired.fastq >> $1_R2_trimmomaticTrimmed_paired.fastq
cat $1_L002_R2_001_trimmomaticTrimmed_paired.fastq >> $1_R2_trimmomaticTrimmed_paired.fastq
cat $1_L003_R2_001_trimmomaticTrimmed_paired.fastq >> $1_R2_trimmomaticTrimmed_paired.fastq
cat $1_L004_R2_001_trimmomaticTrimmed_paired.fastq >> $1_R2_trimmomaticTrimmed_paired.fastq

# cancatenate 4 lanes, R1 unpaired
cat $1_L001_R1_001_trimmomaticTrimmed_unpaired.fastq >> $1_R1_trimmomaticTrimmed_unpaired.fastq
cat $1_L002_R1_001_trimmomaticTrimmed_unpaired.fastq >> $1_R1_trimmomaticTrimmed_unpaired.fastq
cat $1_L003_R1_001_trimmomaticTrimmed_unpaired.fastq >> $1_R1_trimmomaticTrimmed_unpaired.fastq
cat $1_L004_R1_001_trimmomaticTrimmed_unpaired.fastq >> $1_R1_trimmomaticTrimmed_unpaired.fastq

# cancatenate 4 lanes, R2 unpaired
cat $1_L001_R2_001_trimmomaticTrimmed_unpaired.fastq >> $1_R2_trimmomaticTrimmed_unpaired.fastq
cat $1_L002_R2_001_trimmomaticTrimmed_unpaired.fastq >> $1_R2_trimmomaticTrimmed_unpaired.fastq
cat $1_L003_R2_001_trimmomaticTrimmed_unpaired.fastq >> $1_R2_trimmomaticTrimmed_unpaired.fastq
cat $1_L004_R2_001_trimmomaticTrimmed_unpaired.fastq >> $1_R2_trimmomaticTrimmed_unpaired.fastq

# compress output
gzip $1_R1_trimmomaticTrimmed_paired.fastq
gzip $1_R2_trimmomaticTrimmed_paired.fastq
gzip $1_R1_trimmomaticTrimmed_unpaired.fastq
gzip $1_R2_trimmomaticTrimmed_unpaired.fastq

# transfer trimmed seq back to gluster
mv $1_R1_trimmomaticTrimmed_paired.fastq.gz /mnt/gluster/qzhang333
mv $1_R2_trimmomaticTrimmed_paired.fastq.gz /mnt/gluster/qzhang333
mv $1_R1_trimmomaticTrimmed_unpaired.fastq.gz /mnt/gluster/qzhang333
mv $1_R2_trimmomaticTrimmed_unpaired.fastq.gz /mnt/gluster/qzhang333

# clean individual seq data
rm *.fastq
