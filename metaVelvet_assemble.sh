#! /usr/bin/sh

### A SHELL SCRIPT FOR METAVELVET & BAMBUS2 ###

$READ1 = $1
$READ2 = $2
$OUTPUTDIR = $3 

#### MAKE CONTIG ###

/home/mengfei/workdir/pipline/metagenomics/software/velvet-1.2.10/velveth /home/wudi/workdir/test3/metavelvetwushui/wushui.metavelvet3rd 31 -fastq -separate -shortPaired /share/seq_dir1/Item1/BFC2014485-20/150512_D00477_0280_AH2YWJBCXX/zhangyanDNA-LJ_L1_I008.R1.clean.fastq.gz  /share/seq_dir1/Item1/BFC2014485-20/150512_D00477_0280_AH2YWJBCXX/zhangyanDNA-LJ_L1_I008.R2.clean.fastq.gz
/home/mengfei/workdir/pipline/metagenomics/software/velvet-1.2.10/velvetg /home/wudi/workdir/test3/metavelvetwushui/wushui.metavelvet3rd -exp_cov auto -ins_length 500 -read_trkg yes 
/home/mengfei/workdir/pipline/metagenomics/software/MetaVelvet-1.2.01/meta-velvetg  /home/wudi/workdir/test3/metavelvetwushui/wushui.metavelvet3rd -ins_length 500 -amos_file yes -scaffolding yes

################

### BAMBUS2 ####

### Prepare ###

/home/mengfei/workdir/pipline/metagenomics/software/metAMOS-1.5rc3/AMOS/Linux-x86_64/bin/bank-transact -m /home/wudi/workdir/test3/metavelvetwushui/wushui.metavelvet3rd/meta-velvetg.asm.afg -b /home/wudi/workdir/test3/metavelvetwushui/wushui.metavelvet3rd/bank/ -cf  ## FAST
/home/mengfei/workdir/pipline/metagenomics/software/metAMOS-1.5rc3/AMOS/Linux-x86_64/bin/asmQC -b  /home/wudi/workdir/test3/metavelvetwushui/wushui.metavelvet3rd/bank -scaff -recompute -update -numsd 2  
/home/mengfei/workdir/pipline/metagenomics/software/metAMOS-1.5rc3/AMOS/Linux-x86_64/bin/bank-unlock /home/wudi/workdir/test3/metavelvetwushui/wushui.metavelvet3rd/bank

### BEGIN ###

/home/mengfei/workdir/pipline/metagenomics/software/metAMOS-1.5rc3/AMOS/Linux-x86_64/bin/clk -b  /home/wudi/workdir/test3/metavelvetwushui/wushui.metavelvet3rd/bank ## FAST
/home/mengfei/workdir/pipline/metagenomics/software/metAMOS-1.5rc3/AMOS/Linux-x86_64/bin/Bundler -b /home/wudi/workdir/test3/metavelvetwushui/wushui.metavelvet3rd/bank -t M ## FAST
/home/mengfei/workdir/pipline/metagenomics/software/metAMOS-1.5rc3/AMOS/Linux-x86_64/bin/MarkRepeats -b /home/wudi/workdir/test3/metavelvetwushui/wushui.metavelvet3rd/bank   | tee /home/wudi/workdir/test3/metavelvetwushui/wushui.metavelvet3rd/wushui.repeat.txt ## SLOW ##!!!
/home/mengfei/workdir/pipline/metagenomics/software/metAMOS-1.5rc3/AMOS/Linux-x86_64/bin/OrientContigs -b /home/wudi/workdir/test3/metavelvetwushui/wushui.metavelvet3rd/bank  -repeats /home/wudi/workdir/test3/metavelvetwushui/wushui.metavelvet3rd/wushui.repeat.txt -all

#####################################

/home/mengfei/workdir/pipline/metagenomics/software/metAMOS-1.5rc3/AMOS/Linux-x86_64/bin/bank2fasta -eid -b /home/wudi/workdir/test3/metavelvetwushui/wushui.metavelvet3rd/bank > /home/wudi/workdir/test3/metavelvetwushui/wushui.metavelvet3rd/wushui3.contig
/home/mengfei/workdir/pipline/metagenomics/software/metAMOS-1.5rc3/AMOS/Linux-x86_64/bin/OutputMotifs  -b /home/wudi/workdir/test3/metavelvetwushui/wushui.metavelvet3rd/bank > /home/wudi/workdir/test3/metavelvetwushui/wushui.metavelvet3rd/wushui3.motifs 
 
