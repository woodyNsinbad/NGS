#! /usr/bin/python
from optparse import OptionParser
import pandas as pd

usage_msg = """usage: %prog -i <contra gene cnv list> -d < biomart file > -o <output log2 file>"""

optParser = OptionParser(usage=usage_msg,add_help_option=True)
optParser.add_option("-i",action="store",type="string",dest="inputfile")
optParser.add_option("-o",action="store",type="string",dest="outputfile")
optParser.add_option("-d",action="store",type="string",dest="biomart_file")

options,args = optParser.parse_args()

## Pandas is python extension for data frame ## 
## while numpy is for the matrix ## 
data1 = pd.read_csv(options.biomart_file,sep="\t")
data2 = pd.read_csv(options.inputfile,sep="\t")
## 
final = pd.merge(data1,data2,on = "Gene")
final = final[["Gene","ID","mean.LR"]]
final = final.rename(columns={"Gene":"#Gene Name",
                              "ID":"Uniprot ID",
			      "mean.LR":"Log2 Ratio"})
final.to_csv(options.outputfile,sep="\t",index=False)
