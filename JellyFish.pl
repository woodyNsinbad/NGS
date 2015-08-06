#!/usr/bin/env perl 
use strict;
use warnings;
use utf8;
use Getopt::Long;
use 5.010;
use lib "/home/wudi/lib";
require "ABQsub.pl";
require "ABSyS.pl";

my ($read1,$read2,$outputdir,$prefix,$kmer);

GetOptions(
	"r1:s" => \$read1,
	"r2:s" => \$read2,
	"k:i"  => \$kmer,
	"o:s"  => \$outputdir,
	"n:s"  => \$prefix,
	"h|?"  => sub {
				   say "\nUSAGE:";
				   say "  JellyFish.pl -r1 <read1> -r2 <read2> -k <k-mer> -o <out put dir> -n <output file prefix>\n\n";
				   exit(0);
			   }
);

my $fastq2fasta = "/share/software/software/fastx_toolkit-0.0.14_install/bin/fastq_to_fasta";
my $jellyfish = "/share/software/software/jellyfish-2.1.1_install/bin/jellyfish";


$read1 = ABSOLUTE_DIR($read1);
$read2 = ABSOLUTE_DIR($read2);
$outputdir = ABSOLUTE_DIR($outputdir);



open FH,">$outputdir/jellyfish.sh";

print FH "$fastq2fasta -i $read1 -o $outputdir/r1.fasta\n";
print FH "$fastq2fasta -i $read2 -o $outputdir/r2.fasta\n";
print FH "$jellyfish count <(cat $outputdir/r1.fasta $outputdir/r2.fasta) -m $kmer -t 5 -s 100M -o $outputdir/$prefix.bjf \n" ;
print FH "$jellyfish histo  $outputdir/$prefix.bjf -l 0 -t 2 -o $outputdir/$prefix.sts.txt \n";

#Cut_shell_qsub ("$outputdir/jellyfish.sh","5", "200M", "all.q");


exit(0)
