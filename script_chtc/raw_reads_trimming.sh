#!/bin/bash

# unpack trimmomatic and java installation
unzip Trimmomatic-0.39.zip
tar -xzvf jre-8u231-linux-x64.tar.gz

# make sure the script will use your trimmomatic and java installation
# adding Trimmomatic-0.39/ to PATH may not work
export PATH=$(pwd)/Trimmomatic-0.39:$PATH
export JAVA_HOME=$(pwd)/jre1.8.0_231
export PATH=$(pwd)/jre1.8.0_231/bin:$PATH

# all 10 files: R1/R2 in L001/L002/L003/L004
cp /mnt/gluster/qzhang333/$6*.fastq.gz .          

# unzip raw reads
gzip -d $6_$1_R1_001.fastq.gz
gzip -d $6_$1_R2_001.fastq.gz
gzip -d $6_$2_R1_001.fastq.gz
gzip -d $6_$2_R2_001.fastq.gz
gzip -d $6_$3_R1_001.fastq.gz
gzip -d $6_$3_R2_001.fastq.gz
gzip -d $6_$4_R1_001.fastq.gz
gzip -d $6_$4_R2_001.fastq.gz
gzip -d $6_$5_R1_001.fastq.gz
gzip -d $6_$5_R2_001.fastq.gz


# trimming: quality trmming, for R1/R2 in lane1
java -jar Trimmomatic-0.39/trimmomatic-0.39.jar PE -threads 1 \
$6_$1_R1_001.fastq \
$6_$1_R2_001.fastq \
$6_$1_R1_001_trimmomaticTrimmed_paired.fastq \
$6_$1_R1_001_trimmomaticTrimmed_unpaired.fastq \
$6_$1_R2_001_trimmomaticTrimmed_paired.fastq \
$6_$1_R2_001_trimmomaticTrimmed_unpaired.fastq \
TRAILING:20 MINLEN:30

# clean raw seq
rm $6_$1_R1_001.fastq
rm $6_$1_R2_001.fastq

# trimming: quality trmming, for R1/R2 in lane2
java -jar Trimmomatic-0.39/trimmomatic-0.39.jar PE -threads 1 \
$6_$2_R1_001.fastq \
$6_$2_R2_001.fastq \
$6_$2_R1_001_trimmomaticTrimmed_paired.fastq \
$6_$2_R1_001_trimmomaticTrimmed_unpaired.fastq \
$6_$2_R2_001_trimmomaticTrimmed_paired.fastq \
$6_$2_R2_001_trimmomaticTrimmed_unpaired.fastq \
TRAILING:20 MINLEN:30

# clean raw seq
rm $6_$2_R1_001.fastq
rm $6_$2_R2_001.fastq

# trimming: quality trmming, for R1/R2 in lane3
java -jar Trimmomatic-0.39/trimmomatic-0.39.jar PE -threads 1 \
$6_$3_R1_001.fastq \
$6_$3_R2_001.fastq \
$6_$3_R1_001_trimmomaticTrimmed_paired.fastq \
$6_$3_R1_001_trimmomaticTrimmed_unpaired.fastq \
$6_$3_R2_001_trimmomaticTrimmed_paired.fastq \
$6_$3_R2_001_trimmomaticTrimmed_unpaired.fastq \
TRAILING:20 MINLEN:30

# clean raw seq
rm $6_$3_R1_001.fastq
rm $6_$3_R2_001.fastq

# trimming: quality trmming, for R1/R2 in lane4
java -jar Trimmomatic-0.39/trimmomatic-0.39.jar PE -threads 1 \
$6_$4_R1_001.fastq \
$6_$4_R2_001.fastq \
$6_$4_R1_001_trimmomaticTrimmed_paired.fastq \
$6_$4_R1_001_trimmomaticTrimmed_unpaired.fastq \
$6_$4_R2_001_trimmomaticTrimmed_paired.fastq \
$6_$4_R2_001_trimmomaticTrimmed_unpaired.fastq \
TRAILING:20 MINLEN:30

# clean raw seq
rm $6_$4_R1_001.fastq
rm $6_$4_R2_001.fastq

# trimming: quality trmming, for R1/R2 in lane5
java -jar Trimmomatic-0.39/trimmomatic-0.39.jar PE -threads 1 \
$6_$5_R1_001.fastq \
$6_$5_R2_001.fastq \
$6_$5_R1_001_trimmomaticTrimmed_paired.fastq \
$6_$5_R1_001_trimmomaticTrimmed_unpaired.fastq \
$6_$5_R2_001_trimmomaticTrimmed_paired.fastq \
$6_$5_R2_001_trimmomaticTrimmed_unpaired.fastq \
TRAILING:20 MINLEN:30

# clean raw seq
rm $6_$5_R1_001.fastq
rm $6_$5_R2_001.fastq

# cancatenate 5 lanes, R1 paired
cat $6_$1_R1_001_trimmomaticTrimmed_paired.fastq >> $6_R1_trimmomaticTrimmed_paired.fastq
cat $6_$2_R1_001_trimmomaticTrimmed_paired.fastq >> $6_R1_trimmomaticTrimmed_paired.fastq
cat $6_$3_R1_001_trimmomaticTrimmed_paired.fastq >> $6_R1_trimmomaticTrimmed_paired.fastq
cat $6_$4_R1_001_trimmomaticTrimmed_paired.fastq >> $6_R1_trimmomaticTrimmed_paired.fastq
cat $6_$5_R1_001_trimmomaticTrimmed_paired.fastq >> $6_R1_trimmomaticTrimmed_paired.fastq

# cancatenate 5 lanes, R2 paired
cat $6_$1_R2_001_trimmomaticTrimmed_paired.fastq >> $6_R2_trimmomaticTrimmed_paired.fastq
cat $6_$2_R2_001_trimmomaticTrimmed_paired.fastq >> $6_R2_trimmomaticTrimmed_paired.fastq
cat $6_$3_R2_001_trimmomaticTrimmed_paired.fastq >> $6_R2_trimmomaticTrimmed_paired.fastq
cat $6_$4_R2_001_trimmomaticTrimmed_paired.fastq >> $6_R2_trimmomaticTrimmed_paired.fastq
cat $6_$5_R2_001_trimmomaticTrimmed_paired.fastq >> $6_R2_trimmomaticTrimmed_paired.fastq

# cancatenate 5 lanes, R1 unpaired
cat $6_$1_R1_001_trimmomaticTrimmed_unpaired.fastq >> $6_R1_trimmomaticTrimmed_unpaired.fastq
cat $6_$2_R1_001_trimmomaticTrimmed_unpaired.fastq >> $6_R1_trimmomaticTrimmed_unpaired.fastq
cat $6_$3_R1_001_trimmomaticTrimmed_unpaired.fastq >> $6_R1_trimmomaticTrimmed_unpaired.fastq
cat $6_$4_R1_001_trimmomaticTrimmed_unpaired.fastq >> $6_R1_trimmomaticTrimmed_unpaired.fastq
cat $6_$5_R1_001_trimmomaticTrimmed_unpaired.fastq >> $6_R1_trimmomaticTrimmed_unpaired.fastq

# cancatenate 5 lanes, R2 unpaired
cat $6_$1_R2_001_trimmomaticTrimmed_unpaired.fastq >> $6_R2_trimmomaticTrimmed_unpaired.fastq
cat $6_$2_R2_001_trimmomaticTrimmed_unpaired.fastq >> $6_R2_trimmomaticTrimmed_unpaired.fastq
cat $6_$3_R2_001_trimmomaticTrimmed_unpaired.fastq >> $6_R2_trimmomaticTrimmed_unpaired.fastq
cat $6_$4_R2_001_trimmomaticTrimmed_unpaired.fastq >> $6_R2_trimmomaticTrimmed_unpaired.fastq
cat $6_$5_R2_001_trimmomaticTrimmed_unpaired.fastq >> $6_R2_trimmomaticTrimmed_unpaired.fastq

# compress output
gzip -f $6_R1_trimmomaticTrimmed_paired.fastq
gzip -f $6_R2_trimmomaticTrimmed_paired.fastq
gzip -f $6_R1_trimmomaticTrimmed_unpaired.fastq
gzip -f $6_R2_trimmomaticTrimmed_unpaired.fastq

# transfer trimmed seq back to gluster
mv $6_R1_trimmomaticTrimmed_paired.fastq.gz /mnt/gluster/qzhang333
mv $6_R2_trimmomaticTrimmed_paired.fastq.gz /mnt/gluster/qzhang333
mv $6_R1_trimmomaticTrimmed_unpaired.fastq.gz /mnt/gluster/qzhang333
mv $6_R2_trimmomaticTrimmed_unpaired.fastq.gz /mnt/gluster/qzhang333

# clean individual seq data
rm *.fastq
