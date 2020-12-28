# Metagenomic pipeline from shotgun DNA reads to function quantification

## **Step1: Metagenomic *de novo* assembly**

- [metaSPAdes manual](http://cab.spbu.ru/files/release3.12.0/manual.html)
- Parameters used are: `metaspades.py -k 21,33,55,77 --pe1-1 R1.fq --pe1-2 R2.fq`
- Contigs shorter than 500bp were discarded from further processing. All original PE reads in the sample were aligned to all assembled contigs longer than 500bp by Bowtie2, default parameters to calculate assembly rate in each sample.
- Detailed assembly quality evaluation can be done via [quast](http://quast.bioinf.spbau.ru/manual.html).
- Outputs are stored in folder `spades_out/` with files:
    1. All [default outputs](http://cab.spbu.ru/files/release3.12.0/manual.html#sec3.5) from `metaspades.py` 
    2. Filtered contigs are stored in main out dir with name of `$sample.contigs.500bp.fasta` where `$sample` is your custom sample name you can specify when run the pipeline script.

## **Step2: Genes/ORFs prediction**

- Open reading frames (ORFs) prediction is performed by [Prodigal](https://github.com/hyattpd/Prodigal) with the argument `-p meta`.
- Three output files are stored in `prodigal_out` folder:
    1. `$sample.orfs.out` is Genbank-like format of predicted ORFs, format details are referred to [output format](https://github.com/hyattpd/prodigal/wiki/understanding-the-prodigal-output#gene-coordinates). 
    2. `$sample.orfs.faa` is amino acid sequences (Protein Translations) of predicted ORFs.
    3. `$sample.orfs.fna` is nucleotide sequences of predicted ORFs.

- Two output files are stored in main out dir:
    1. `$sample.orfs.100bp.faa` is amino acid sequences (Protein Translations) of predicted ORFs with at least 100bp.
    2. `$sample.orfs.100bp.fna` is nucleotide sequences of predicted ORFs with at least 100bp.

## **Step3: Gene functional annotation using KEGG database**

- Predicted ORFs will be annotated using KEGG database to get KEGG Orthology number for each ORF.
- Annotation is done by [kofam](https://www.genome.jp/tools/kofamkoala/), witch use [HMMER](http://hmmer.org/)/HMMSEARCH against KOfam (a customized HMM database of KEGG Orthologs (KOs)) to get K number assignments with scores above the predefined thresholds.
- More specifically, we use only prokaryotes kofam profiles.
- Output file is stored in main out dir:
    1. `$sample.kofam.out.txt` with two columns: 1st column is predicted gene ID and 2nd column is annotated KO number.

## **Step4: Estimate gene abundance**

- Gene quantification is done by [RSEM](https://deweylab.github.io/RSEM/). All predicted ORFs (>100bp) were pooled together as the mapping reference. Bowtie2 index was built first and RSEM was run by these parameters: `rsem-calculate-expression --bowtie2 --paired-end --estimate-rspd --no-bam-output`
- Output files are stored in `rsem_out`:
    1. `rsem_out/$sample.rsem.genes.results` is the estimated gene counts for each gene.
- To get KO abundance matrix, the estimated gene TPM values were summed together and matrix is stored in main out dir with name of `$sample.gene.tpm.sum2ko.tsv`

## Notes to run pipeline on UW-Madsion CHTC

- One example to run this pipeline on UW-Madsion CHTC cluster is shown in `chtc` folder: there are two files:
    1. `metagenomic_pipeline_KO_test_HMDP0001.sh` is the executable bash script.
    2. `metagenomic_pipeline_KO_test_HMDP0001.sub` is CHTC submit script.
    