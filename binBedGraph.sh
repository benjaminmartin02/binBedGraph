#!/bin/bash


if [[ $1 == "-h" ]]; then
    echo "Usage: $(basename "$0") -h or -help

Bin bedgraph data. This script splits the genome into bins and sums the bedgraph scores over each bin:
$(basename "$0") yoursample.bedGraph output_filename binsize chrsizes_file

Note, because any bedgrah window overlapping the bins will be added to the sum, you should use unbinned data as your input bedgraph, as bnning already binned data is potentially problematic.

sbatch -p short -t 120 --mem 40G $(basename "$0") yoursample.bedGraph yoursample_100bp_bins.bedGraph 100 mm10_chrsizes.txt
"
exit
fi

# for working on O2 environment, load the following modules
# for other environments, make sure bedops, bedtools, and ucsc-tools are available and remove the module purgee/load lines of code
module purge
module load gcc/6.2.0
module load bedtools/2.27.1
module load bedops/2.4.30
module load ucsc-tools/363

  BG=${1}
  LABEL=${2}
  BIN=${3}
  chrsizes=${4}
  temp_label=`echo "${RANDOM}_${RANDOM}_${RANDOM}"`
   #generate a unique label to avoid overwriting intermediate files
   
   echo "bedGraph to bin: ${BG}"
   echo "Label for output: $LABEL"
   echo "Bin size: ${BIN}"
   echo "chrsize file is: ${chrsizes}"
   
   echo "making chromosome bins"   
   
   
  #make bed file of chromosome bounds
  awk '{ print $1"\t0\t"$2; }' ${chrsizes} | sort -k 1,1 -k 2,2n > temp_${temp_label}_chr.bounds.bed
  
  #chop chromosomes into bins
  bedops --chop ${BIN} temp_${temp_label}_chr.bounds.bed | awk '{OFS="\t";print($1,$2,$3,"id-"NR)}' > temp_${temp_label}_chop.bed
  
  
  #remove track and empty lines from BG
  awk '{if($1 != ""){print $0}}' $BG | grep -v 'track' > temp_${temp_label}.bedGraph
  
  echo "making binned bedgraph"
  #calculate per bp sums over intervals
  
  bedtools map -a temp_${temp_label}_chop.bed -b temp_${temp_label}.bedGraph -c 4 -o sum | awk '{if($5 != "."){OFS="\t";print($1,$2,$3,$5)}}' > ${LABEL}
  
  echo "removing intermediate files"
  #rm intermediate files
  rm temp_${temp_label}_chop.bed
  rm temp_${temp_label}_chr.bounds.bed
  rm temp_${temp_label}.bedGraph
  
  echo "Done!"
  



