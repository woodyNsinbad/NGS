#! /share/software/software/R-3.1.0_installdir/bin/Rscript 

library("seqinr")
args <-commandArgs(TRUE)
if (is.na(args[1])){
	print("USAGE:")
	print("   Rscript plot_fasta.R <plot_name> <input_file> <plot_path>")

	q()
}

fastaseq.name      = args[1]
fastaseq.file.path = args[2]
fastaseq.plot.path = args[3]
fastaseq<-read.fasta(fastaseq.file.path)
fasta.length<-getLength(fastaseq)
plot.breaks <-seq(0,3000,by = 100)
breaks <-c(plot.breaks,max(fasta.length))
breaks.names <-rep("",26)
breaks.names[2] = "300"
breaks.names[5] = "600"
breaks.names[9] = "1000"
breaks.names[10] = "1500"
breaks.names[15] = "2000"
breaks.names[20] = "2500"
breaks.names[25] = ">3000"
pdf(paste(fastaseq.plot.path,fastaseq.name,".df",sep = ""),width = 900,height = 600 ) 
jpeg(paste(fastaseq.plot.path,fastaseq.name,".jpg",sep = ""),width = 900,height = 600 ) 
fasta.hist<-hist(fasta.length,breaks=breaks,freq = F,plot=F)
#xlab="Scaffold Length (bp)",ylab="Scaffold NUMBER",main="Scaffold Length distribution"
#)

print(fasta.hist)


barplot(fasta.hist$counts[4:31],
names.arg = breaks.names,
col="#4682B4",
ylim = c(0,max(fasta.hist$counts)*1.1),

xlab="Scaffold Length (bp)",ylab="Scaffold Number",main="Scaffold Length distribution")

q()
