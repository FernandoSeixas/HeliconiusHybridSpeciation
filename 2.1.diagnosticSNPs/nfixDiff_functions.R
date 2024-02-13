
## Function to subset SNPs (for visualization purposes)
subset_within_blocks = function(x, step) {
  subSNPs = data.frame()
  for (bl in unique(x$block)) {
    block_bl = subset(x, block == bl)
    if (nrow(block_bl) == 1) {
      subSNPs = rbind(subSNPs, block_bl)
    }
    if (nrow(block_bl) >  1) {
      sub_block_bl = block_bl[seq(1,nrow(block_bl),step),]
      subSNPs = rbind(subSNPs, sub_block_bl) 
    }
  }
  
  return(subSNPs)
}

## Function to perform "genotype plot" 
plot_genotype = function(snps_df, ch, stp) {
  #
  subgt = subset(gt, chromNb %in% ch)
  subgt = subset_within_blocks(subgt, stp)
  #/ plot species diagnostic SNPs along the chromosomes
  t_panel = chrLen %>%
    filter(chromNb %in% ch ) %>%
    # plot
    ggplot() +
    geom_segment(aes(x=0, xend=len/1000000, y=0, yend=0)) +
    geom_point(data=subgt, aes(x=UPstart/1000000, y=0), shape=21,
               color=ifelse(subgt$block %in% seq(1,100,2), "#969696","#252525"),
               fill=ifelse(subgt$block %in% seq(1,100,2), "#bdbdbd","#252525")
    ) +
    # beautify
    scale_x_continuous(name="", breaks=seq(0,30,2), expand=expansion(mult = 0.05)) +
    scale_y_continuous(name="", limits = c(0,0), expand=c(0.0,0.0) )+
    facet_grid(~chromNb, scales = "free_x" ) +
    theme_classic() +
    theme(
      panel.background = element_blank(),
      panel.spacing.x = unit(5, "lines"),
      strip.background = element_blank(),
      # strip.text.x = element_blank(),
      axis.text.x = element_text(angle=90, hjust = 1, vjust = .5),
      axis.text.y = element_blank(),
      axis.ticks.y = element_blank(),
      axis.line.y = element_blank(),
      axis.line.x = element_blank(),
      legend.position = "none",
      plot.margin = unit(c(0, .5, 0, 0), "cm")
    )
  #/ Plot
  b_panel = snps_df %>%
    filter(chromNb %in% ch ) %>%
    filter(relpos %in% subgt$relpos) %>%
    # filter(spp != "luc") %>%
    # filter(!spp %in% c("ser","eas") ) %>%
    # plot
    ggplot() +
    geom_tile(aes(x=relpos, y=variable, fill=value, color=value), lwd=.5, linejoin = "mitre") +
    # beautify
    scale_x_discrete(expand=c(0,0), name="Chromosome") +
    scale_y_discrete(expand=c(0,0), name="") +
    scale_color_manual(values = borderPal) +
    scale_fill_manual(values = colPal) +
    facet_grid(spp~chromNb, drop = T, scales="free", space="free") +
    # facet_grid(subspp~chromNb, drop = T, scales="free", space="free") +
    # facet_grid(spp~chromNb, drop = T, scales="free", space="free") +
    theme_minimal() +
    theme(
      panel.spacing.x = unit(1, "lines"),
      axis.text.x = element_blank(),
      axis.text.y = element_blank(),
      legend.position = "none"
    )
  ## Combine plots
  GTplot = plot_grid(t_panel,b_panel, nrow=2, rel_heights = c(1,4) )
  return(GTplot)
}



