## Exonic regions *************************

## Prepare files 
sbatch ~/code/heliconius_seixas/2.elevatus_pardalinus/2.SpeciesTree/bpp01/bpp-a01-2.prepData.slurm \
  exonic.minL100.maxL250.minG2000 \
  ser_par_ele_bar

## Run BPP
sbatch ~/code/heliconius_seixas/2.elevatus_pardalinus/2.SpeciesTree/bpp01/bpp-a01-3.runBPP.slurm \
  "exonic.minL100.maxL250.minG2000" \
  "ser_par_ele_bar" \
  "4 parser parama eleama eleeas" \
  "3 3 3 3" \
  "((parser,parama),(eleama,eleeas));" \
  "((parser,eleama),(parama,eleeas));" \
  "((parser,eleeas),(parama,eleama));"


## Non coding regions *************************
#/ Prepare files 
sbatch ~/code/heliconius_seixas/2.elevatus_pardalinus/2.SpeciesTree/bpp01/bpp-a01-2.prepData.slurm \
  noncod.m100.m250.g2000.b2000 \
  ser_par_ele_bar_mel
#/ Run BPP
sbatch ~/code/heliconius_seixas/2.elevatus_pardalinus/2.SpeciesTree/bpp01/bpp-a01-3.runBPP.slurm \
  "noncod.m100.m250.g2000.b2000" \
  "ser_par_ele_bar_mel" \
  "5 parser parama eleama eleeas melagl" \
  "3 3 3 3 3" \
  "(((parser,parama),(eleama,eleeas)),melagl);" \
  "(((parser,eleama),(parama,eleeas)),melagl);" \
  "(((parser,eleeas),(parama,eleama)),melagl);"


