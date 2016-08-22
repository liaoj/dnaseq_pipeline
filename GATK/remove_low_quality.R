argv <- commandArgs(TRUE)
data <- read.table(argv[1],sep="\t",header=F)
write.table(data[data[,7] != "LowQual",],
	file=paste(strsplit(argv[1],".vcf")[[1]],"end.vcf",sep="_"),
	sep="\t",col.names=F,row.names=F,quote=F)
