#!/bin/bash


mkdir DO_contig_autometa_taxonomy_docker_input

cp /mnt/gluster/qzhang333/DO_contig_autometa_taxonomy_docker_input/DO021.500bp.contigs.fa DO_contig_autometa_taxonomy_docker_input
cp /mnt/gluster/qzhang333/DO_contig_autometa_taxonomy_docker_input/DO021_coverage.tab DO_contig_autometa_taxonomy_docker_input

mkdir DO_contig_autometa_taxonomy_docker_input/ncbi_db/

cp /mnt/gluster/qzhang333/DO_contig_autometa_taxonomy_docker_input/ncbi_db/names.dmp DO_contig_autometa_taxonomy_docker_input/ncbi_db/
cp /mnt/gluster/qzhang333/DO_contig_autometa_taxonomy_docker_input/ncbi_db/nodes.dmp DO_contig_autometa_taxonomy_docker_input/ncbi_db/
cp /mnt/gluster/qzhang333/DO_contig_autometa_taxonomy_docker_input/ncbi_db/nr.dmnd DO_contig_autometa_taxonomy_docker_input/ncbi_db/
cp /mnt/gluster/qzhang333/DO_contig_autometa_taxonomy_docker_input/ncbi_db/prot.accession2taxid DO_contig_autometa_taxonomy_docker_input/ncbi_db/

# run run_autometa.py
run_autometa.py \
   --assembly DO_contig_autometa_taxonomy_docker_input/DO021.500bp.contigs.fa \
   --processors 16 \
   --length_cutoff 3000 \
   --maketaxtable \
   --ML_recruitment \
   --db_dir DO_contig_autometa_taxonomy_docker_input/ncbi_db \
   --cov_table DO_contig_autometa_taxonomy_docker_input/DO021_coverage.tab \
   --output_dir DO021_autometa_out


mkdir DO021_autometa_out/cluster_process_output

# run cluster_process.py
cluster_process.py \
   --bin_table DO021_autometa_out/ML_recruitment_output.tab \
   --column ML_expanded_clustering \
   --fasta DO021_autometa_out/Bacteria.fasta \
   --db_dir DO_contig_autometa_taxonomy_docker_input/ncbi_db \
   --do_taxonomy \
   --output_dir DO021_autometa_out/cluster_process_output


# tar output directory
tar -czvf DO021_autometa_out_IJM.tar.gz DO021_autometa_out

mv DO021_autometa_out_IJM.tar.gz /mnt/gluster/qzhang333/

rm -R DO_contig_autometa_taxonomy_docker_input