# purpose: functions for individual hotspots in chr


# Manhattan Plotting for individual chromosome, zoom in hotspots
# 
# input:
# 
# qtl_scan1_list         -qtl_scan1 list for all single phe qtl scan (a rds file)
# pmap                   -physical map for the 69k grid
# phe_KO_df_subset       -subset of all phe_KO_df (save time to extract qtl_scan1)
# plot_chr               -chr to plot
# x_lo                   -minimal value in x axis
# x_hi                   -maximal value in x axis
# plot_out_file          -outpur plotting file name with directory

manhattan_plotting_individual_chromosome_zoomin <- function(qtl_scan1_list, pmap, phe_KO_df_subset, plot_chr, x_lo, x_hi, plot_out_file) {
    
    phenotypes <- colnames(phe_KO_df_subset)
    
    pdf(file = plot_out_file, width = 9, height = 6)
    
    # track progress
    tally <- 0
    total <- length(phenotypes)
    
    for (phename in phenotypes) {
        tally = sum(tally, 1)
        cat ("On phenotype ", tally, " of", total, "\n")
        
        phe <- phe_KO_df_subset[,phename, drop=FALSE]
        phe <- na.omit(phe)
        
        # Load QTL scan1:
        qtl_scan1 <- qtl_scan1_list[[phename]]
        
        # convert qtl2 output to qtl1 for manhattan plotting
        converted_outpg <- scan_qtl2_to_qtl(qtl_scan1, pmap)  # convert qtl2 -> qtl1
        peaks <- summary(converted_outpg)                     # get peaks
        nrows_peaks <- nrow(peaks)
        
        ###############################
        ##### Manhattan Plotting ######
        plot_title <- paste0("Summed KO QTLs in chr", plot_chr, ", rankz transformed")
        if (tally == 1) { # if it's the first pass, create the graph:
            
            # type="n" means don't plot the curve
            plot(converted_outpg, bandcol="gray82", bgrect="gray92", type="n", chr = plot_chr, xlim = c(x_lo, x_hi), ylim = c(5.5,11), ylab = "LOD", main = plot_title)
            # only plot chr15 point
            points(xaxisloc.scanone(converted_outpg, plot_chr, peaks[plot_chr,2], chr = plot_chr), peaks[plot_chr,3], pch=21, bg="darkblue")
        } else {
            points(xaxisloc.scanone(converted_outpg, plot_chr, peaks[plot_chr,2], chr = plot_chr), peaks[plot_chr,3], pch=21, bg="darkblue")
        }
        ##### Plotting End ##########
        #############################
    }
    cat ("program complete", "\n")
    dev.off()
}



