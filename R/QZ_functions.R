### Purpose: generate commom used functions
###          1. 
###          2. 
###          3. 

# load required libraries
library(qtl2)
library(grid)
library(dplyr)
library(tidyr)
library(ggsci)
library(tibble)
library(ggplot2)
library(reshape2)
library(pheatmap)
library(gridExtra)
library(data.table)
library(RColorBrewer)

options(stringsAsFactors = FALSE)

# ggplot color bar function
gg_color_hue <- function(n) {
    hues = seq(15, 375, length = n + 1)
    hcl(h = hues, l = 65, c = 100)[1:n]
}

# rankZ function
rankZ = function(x) {
    x = rank(x, na.last = "keep", ties.method = "average") / (sum(!is.na(x)) + 1)
    return(qnorm(x))
}

### fisher's exact test
#   Input: 1) allKO: array of all KEGG K number
#          2) myKO: array of interested KEGG K number
# 
#   Example: allKO: c("K00001", "K00002","K00003","K00004")
#            myKO: c(""K00002","K00003")
#
fisher_exact_test <- function(allKO, myKO){
    
    allTbl <- KEGG_path[which(KEGG_path$KO %in% allKO),]
    myTbl <- KEGG_path[which(KEGG_path$KO %in% myKO),]
    
    allTbl_freq <- as.data.frame(table(allTbl$path_definition))
    names(allTbl_freq) <- c("path", "allFreq")
    myTbl_freq <- as.data.frame(table(myTbl$path_definition))
    names(myTbl_freq) <- c("path", "myFreq")
    
    tbl_freq <- merge(allTbl_freq, myTbl_freq, by = "path", all = T)
    tbl_freq[is.na(tbl_freq)] <- 0
    
    tbl_out <- cbind(tbl_freq, as.data.frame(matrix(ncol = 5, nrow = nrow(tbl_freq))))
    names(tbl_out)[4:8] <- c("pathInt", "pathNoInt", "backInt", "backNoInt", "pval")
    
    for (i in 1:nrow(tbl_out)){
        tbl_out$pathInt[i] <- tbl_out$myFreq[i]
        tbl_out$pathNoInt[i] <- tbl_out$allFreq[i] - tbl_out$myFreq[i]
        tbl_out$backInt[i] <- sum(tbl_out$myFreq) - tbl_out$myFreq[i]
        tbl_out$backNoInt[i] <- sum(tbl_out$allFreq) - sum(tbl_out$myFreq) - (tbl_out$allFreq[i] - tbl_out$myFreq[i])
        
        fisher_tbl <- matrix(as.integer(tbl_out[i,4:7]), byrow = TRUE, 2,2)
        fisher_result <- fisher.test(fisher_tbl, alternative = "greater", conf.int = TRUE, conf.level = 0.95)
        
        tbl_out$pval[i] <- fisher_result$p.value
    }
    
    tbl_out <- tbl_out[which(tbl_out$myFreq > 1),]
    tbl_out$bonferroni <- p.adjust(tbl_out$pval, method = "bonferroni")
    tbl_out$bh <- p.adjust(tbl_out$pval, method = "BH")
    
    return(tbl_out)
}

### function to plot founder allele effects, give 8 values
#
#   Inputs: 8 founder allele effects vector with A-H order (can have in their names)
# 
#   Example: eff: c(-0.2, -0.1, 0, 0, 0.2, 0.1, 0.3, -0.3)
#
CCcolor <- CCcolors
allele_eff_plot <- function(eff) {
    plot.df <- as.data.frame(matrix(nrow = 8, ncol = 0))
    plot.df$eff <- as.numeric(eff[,c("A", "B", "C", "D", "E", "F", "G", "H")])
    plot.df$strain <- factor(names(CCcolors), level=names(CCcolors))
    ylim <- max(abs(plot.df$eff)) + 0.2
    p <- ggplot(plot.df) + 
        geom_point(aes(x=strain, y=eff, color=strain), size=4) +
        geom_hline(yintercept=0) +
        theme_classic() +
        theme(axis.text.x = element_text(size = 8),
              axis.text.y = element_text(size = 11)) +
        scale_color_manual(values =  CCcolor) +
        scale_y_continuous(limits = c(-ylim, ylim)) +
        xlab("") +
        ylab("")
    
    return(p)
}

### function to plot allele effect
#
# input:
#   ch:    the position of chromosome
#   start: start position of interested region
#   end:   end postion of interested region
# 
# return the tbl with phenotype name, A-H allele effects, heatmap label, phenotype type
#
qtl_selection <- function(ch, start, end) {
    meta.ko <- qtl.KO %>%
        mutate(label = paste0(pheno, ": ", gene_name, ", ", gene_definition)) %>%
        select(pheno, chr, peak_mbp, lod, A, B, C, D, E, F, G, H, label) %>%
        mutate(group = "KO") %>%
        filter(chr == ch, peak_mbp > start, peak_mbp < end)
    
    meta.mag <- qtl.MAG %>%
        mutate(label = paste0(pheno, ": ", genus)) %>%
        select(pheno, chr, peak_mbp, lod, A, B, C, D, E, F, G, H, label) %>%
        mutate(group = "MAG") %>%
        filter(chr == ch, peak_mbp > start, peak_mbp < end)
    
    meta.mag.akk <- qtl.MAG.akk %>%
        mutate(label = paste0(pheno, ": A.muciniphila")) %>%
        select(pheno, chr, peak_mbp, lod, A, B, C, D, E, F, G, H, label) %>%
        mutate(group = "MAG.Akk") %>%
        filter(chr == ch, peak_mbp > start, peak_mbp < end)
    
    meta.taxa <- qtl.taxa %>%
        mutate(label = pheno) %>%
        select(pheno, chr, peak_mbp, lod, A, B, C, D, E, F, G, H, label) %>%
        mutate(group = "taxa") %>%
        filter(chr == ch, peak_mbp > start, peak_mbp < end)
    
    lipid <- qtl.lipid %>%
        mutate(label = identifier) %>%
        mutate(pheno = identifier, chr = qtl.chr, peak_mbp = qtl.pos, lod = qtl.lod) %>%
        select(pheno, chr, peak_mbp, lod, A, B, C, D, E, F, G, H, label) %>%
        mutate(group = "lipid") %>%
        filter(chr == ch, peak_mbp > start, peak_mbp < end)
    
    rna <- qtl.rna %>%
        mutate(label = paste0("eQTL: ", gene_name)) %>%
        mutate(chr = qtl_chr) %>%
        select(pheno, chr, peak_mbp, lod, A, B, C, D, E, F, G, H, label) %>%
        mutate(group = "eQTL") %>%
        filter(chr == ch, peak_mbp > start, peak_mbp < end)
    
    return(rbind(meta.ko, meta.mag, meta.mag.akk, meta.taxa, lipid, rna))
}

# function of allele effects heatmap of interested QTL region 
qtl_heatmap <- function(qtl_tbl, ch, start, end) {
    plot.df <- qtl_tbl %>%
        column_to_rownames("label") %>%
        select(A, B, C, D, E, F, G, H)
    
    anno.row <- qtl_tbl[,"group",drop=F]
    names(anno.row) <- "Group"
    rownames(anno.row) <- rownames(plot.df)
    
    p <- pheatmap(plot.df,
                  cluster_cols = F,
                  color = colorRampPalette(rev(brewer.pal(n = 8, name = "RdYlBu")))(400), 
                  breaks = seq(-2, 2, by = 0.01),
                  border_color = NA,
                  annotation_row = anno.row,
                  scale = "row",
                  clustering_method = "ward.D2",
                  annotation_colors = list(Group = c(lipid = "#63C29C", 
                                                     eQTL= "#FFCB04", 
                                                     KO = "grey40", 
                                                     taxa = "grey70", 
                                                     MAG = "grey90",
                                                     MAG.Akk = "#3d84b8"))[1],
                  cellwidth = 20,
                  cellheight = 5,
                  fontsize_row = 5,
                  main = paste0("Allele Effects: Chr", ch, ": ", start, "-", end, "Mbp"))
    
    cuttree <- length(table(cutree(p$tree_row,h = 5)))
    
    p_curtree <- pheatmap(plot.df,
                          cluster_cols = F,
                          color = colorRampPalette(rev(brewer.pal(n = 8, name = "RdYlBu")))(400), 
                          breaks = seq(-2, 2, by = 0.01),
                          border_color = NA,
                          annotation_row = anno.row,
                          scale = "row",
                          clustering_method = "ward.D2",
                          annotation_colors = list(Group = c(lipid = "#63C29C", 
                                                             eQTL = "#FFCB04", 
                                                             KO = "grey40", 
                                                             taxa = "grey70", 
                                                             MAG ="grey90",
                                                             MAG.Akk = "#3d84b8"))[1],
                          cellwidth = 20,
                          cellheight = 5,
                          fontsize_row = 5,
                          cutree_rows = cuttree, 
                          main = paste0("Allele Effects: Chr", ch, ": ", start, "-", end, "Mbp"))
    
    
    return(p_curtree)
}

### function to filter snps based on desired pattern
### SNPs are obtained from https://www.sanger.ac.uk/sanger/Mouse_SnpViewer/rel-1505, using the filter of DO/CC founder to select strain
# 
# Input: 1. snp tsv downloaded from https://www.sanger.ac.uk/sanger/Mouse_SnpViewer/rel-1505
#        main column names: "Ref", "129S1_SvImJ", "A_J", "CAST_EiJ", "NOD_ShiLtJ", "NZO_HlLtJ", "PWK_PhJ", "WSB_EiJ"
#        2. group1: vector for one or more of 8 founder strains
#        3. group2: vector for one or more of 8 founder strains
#

# unfinished
founder_snp_filter <- function(all_snp, group1, group2) {
    # filter out uncertain snp
    names(all_snp)[c(7,9,11,13,15,17,19)] <- c("Csq_129", "Csq_AJ", "Csq_CAST", "Csq_NOD", "Csq_NZO", "Csq_PWK", "Csq_WSB")
    all_snp <- all_snp %>%
        filter(Ref != "-", `129S1_SvImJ` != "-", A_J != "-", CAST_EiJ != "-",
               PWK_PhJ != "-", NOD_ShiLtJ != "-", NZO_HlLtJ != "-", WSB_EiJ != "-")
    
    if (length(group1) == 1) {
        out_snp <- all_snp[which(all_snp[,group1[1]] != all_snp[,group2[1]] & all_snp[,group2[1]] == all_snp[,group2[2]] & 
                                 all_snp[,group2[1]] == all_snp[,group2[3]] & all_snp[,group2[1]] == all_snp[,group2[4]] & 
                                 all_snp[,group2[1]] == all_snp[,group2[5]] & all_snp[,group2[1]] == all_snp[,group2[6]] & 
                                 all_snp[,group2[1]] == all_snp[,group2[7]]),]
    }
    
    if (length(group1) == 2) {
        out_snp <- all_snp[which(all_snp[,group1[1]] != all_snp[,group2[1]] & all_snp[,group1[1]] == all_snp[,group1[2]] & 
                                 all_snp[,group2[1]] == all_snp[,group2[3]] & all_snp[,group2[1]] == all_snp[,group2[4]] & 
                                 all_snp[,group2[1]] == all_snp[,group2[5]] & all_snp[,group2[1]] == all_snp[,group2[6]] & 
                                 all_snp[,group2[1]] == all_snp[,group2[2]]),]
    }
    
    if (length(group1) == 3) {
        out_snp <- all_snp[which(all_snp[,group1[1]] != all_snp[,group2[1]] & all_snp[,group1[1]] == all_snp[,group1[2]] & 
                                 all_snp[,group1[1]] == all_snp[,group1[3]] & all_snp[,group2[1]] == all_snp[,group2[4]] & 
                                 all_snp[,group2[1]] == all_snp[,group2[5]] & all_snp[,group2[1]] == all_snp[,group2[3]] & 
                                 all_snp[,group2[1]] == all_snp[,group2[2]]),]
    }
    
    if (length(group1) == 4) {
        out_snp <- all_snp[which(all_snp[,group1[1]] != all_snp[,group2[1]] & all_snp[,group1[1]] == all_snp[,group1[2]] & 
                                 all_snp[,group1[1]] == all_snp[,group1[3]] & all_snp[,group1[1]] == all_snp[,group1[4]] & 
                                 all_snp[,group2[1]] == all_snp[,group2[4]] & all_snp[,group2[1]] == all_snp[,group2[3]] & 
                                 all_snp[,group2[1]] == all_snp[,group2[2]]),]
    }
    
    if (length(group1) == 5) {
        out_snp <- all_snp[which(all_snp[,group1[1]] != all_snp[,group2[1]] & all_snp[,group1[1]] == all_snp[,group1[2]] & 
                                 all_snp[,group1[1]] == all_snp[,group1[3]] & all_snp[,group1[1]] == all_snp[,group1[4]] & 
                                 all_snp[,group1[1]] == all_snp[,group1[5]] & all_snp[,group2[1]] == all_snp[,group2[3]] & 
                                 all_snp[,group2[1]] == all_snp[,group2[2]]),]
    }
    
    if (length(group1) == 6) {
        out_snp <- all_snp[which(all_snp[,group1[1]] != all_snp[,group2[1]] & all_snp[,group1[1]] == all_snp[,group1[2]] & 
                                 all_snp[,group1[1]] == all_snp[,group1[3]] & all_snp[,group1[1]] == all_snp[,group1[4]] & 
                                 all_snp[,group1[1]] == all_snp[,group1[5]] & all_snp[,group1[1]] == all_snp[,group1[6]] & 
                                 all_snp[,group2[1]] == all_snp[,group2[2]]),]
    }
    
    if (length(group1) == 7) {
        out_snp <- all_snp[which(all_snp[,group1[1]] != all_snp[,group2[1]] & all_snp[,group1[1]] == all_snp[,group1[2]] & 
                                 all_snp[,group1[1]] == all_snp[,group1[3]] & all_snp[,group1[1]] == all_snp[,group1[4]] & 
                                 all_snp[,group1[1]] == all_snp[,group1[5]] & all_snp[,group1[1]] == all_snp[,group1[6]] & 
                                 all_snp[,group1[1]] == all_snp[,group1[7]]),]
    }
    
    return(out_snp)
}





