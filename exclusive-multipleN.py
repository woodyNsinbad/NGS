#! /usr/bin/python

from Bio import SeqIO

for seq_record in SeqIO.parse("/mnt/md0/UEC.work/liukai/DB/Zhejiang/wangjing/test/plot/1.txt", "fasta"):
#for seq_record in SeqIO.parse("test2.fa", "fasta"):

        ##########################
	#seqname=seq_record.id 
	easy_bar=0
	short_seq=""
	flag = 0
	start = 1 
	
	for i in range(len(seq_record.seq)):
		nuc = seq_record.seq[i]
		easy_bar = easy_bar+1
		

		if nuc != "N" :
			flag = 0
			short_seq = short_seq+nuc

		elif (nuc == "N" and flag == 0):

			print ">"+seq_record.id+":"+str(start)+"-"+str(easy_bar-1)
			print short_seq
			flag = 1
			short_seq = ""

		elif nuc == "N" and flag == 1: 
			
			start = easy_bar+1

		if  i == len(seq_record.seq)-1 and nuc != "N":
			print ">"+seq_record.id+":"+str(start)+"-"+str(len(seq_record.seq))
			print short_seq
	 
	#print short_seq,len(seq_record.seq)			


