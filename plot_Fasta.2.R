library("seqinr")
args <-commandArgs(TRUE)
#if (is.na(args[1])){
#	print("USAGE: \n")
#	print("Rscript plot_fasta.R plot_name input_file plot_path \n")
#	q()
#}

fastaseq.name      = args[1]
fastaseq.file.path = args[2]
fastaseq.plot.path = args[3]
fastaseq<-read.fasta(fastaseq.file.path)
fasta.length<-getLength(fastaseq)
breaks <-c(0,100,200,300,500,1000,1500,2000,2500,3000,max(fasta.length))
rank.name <- c("0~100",
"100~200",
"200~300",
"300~500",
"500~1000",
"1000~1500",
"1500~2000",
"2000~2500",
"2500~3000",
">3000"
)
fasta.hist<-hist(fasta.length,breaks=breaks,plot=F)
jpeg(paste(fastaseq.plot.path,fastaseq.name,".jpg",sep = ""),width = 900,height = 600 ) 
barplot(fasta.hist$counts,names.arg=rank.name,
col="#4682B4",
ylim = c(0,max(fasta.hist$counts)+100),
xlab="CDS Length (bp)",ylab="CDS NUMBER",main="CDS distribution")

q()
