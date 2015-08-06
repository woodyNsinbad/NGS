#!/usr/bin/env perl 
use strict;
use warnings;
use utf8;
use 5.010;
use Getopt::Long;


my ($infile,$outfile);

GetOptions(
	"i:s" =>\$infile ,
	"o:s" =>\$outfile,
	"h|?"=> sub{say "kraken2krona.pl -i <kraken statistical file> -o <Krona Tax file>";exit(0)}
);


open FH, "$infile";
open OUT,">$outfile";



while(<FH>){
	chomp;
	my @array = split "\t",$_;
	print OUT "-","\t",$array[4],"\t","-","\t",$array[2],"\n";	

}

close FH;
close OUT;

