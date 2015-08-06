library("seqinr")
library("ggplot2")
args <-commandArgs(TRUE)

if (is.na(args[1])){
	print("USAGE: \n")
	print("Rscript plot_fasta.R plot_name input_file plot_path \n")
	q()
}

fastaseq.name      = args[1]
fastaseq.file.path = args[2]
fastaseq.plot.path = args[3]

fastaseq<-read.fasta(fastaseq.file.path)
fasta.length<-getLength(fastaseq)
breaks <-c(0,100,200,300,500,1000,1500,2000,2500,3000,max(fasta.length))

fasta.hist<-hist(fasta.length,
	plot=F)

jpeg(paste(fastaseq.plot.path,fastaseq.name,".jpg",sep = ""),width = 900,height = 600 ) 

plot(fasta.hist$mids,
     fasta.hist$counts,
	type="n",
	xaxt="n",
	ylab="CDS Number",
	xlab="CDS Length",
	main="CDS Histgram",
	bg = "lightgrey"
	)

plot(fasta.hist,add=T,freq=T,col="#4682B4")

at <- log10(breaks)
axis(1,at=at,labels = 10^breaks,)
#axis(2,at=seq(0,max(fasta.hist$count),l =50),labels = TRUE,pos =0)
q()
