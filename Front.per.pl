#!/usr/bin/env perl 
use strict;
use warnings;
use utf8;
use Bio::SeqIO;
use Getopt::Long;
use 5.010;
use Data::Dumper;
#use String::Util;
use sort 'stable';

my ($file_name,$out);

GetOptions(
	"i=s" => \$file_name,
	"o=s" => \$out,
	"h|?" => sub{say "Front.per.pl -i <input file> -o <out.txt>";exit}
);
my %hash;
my $seq_num = 0;



my $seqin = Bio::SeqIO->new( -format => 'Fasta' , -file => "$file_name");

while((my $seqobj = $seqin->next_seq())) {
	$hash{$seqobj->id}->{"len"} = $seqobj->length;
	$hash{$seqobj->id}->{"seq"} = $seqobj->seq;
	$seq_num++;
}

my %lab;





foreach (1 .. 30){
	$lab{sprintf "%d",($_ * $seq_num/100)} = $_;
}

$seq_num = 0;
my $seq_sum_len;

open OUT,">$out";

foreach my $id  (sort {$hash{$b}->{"len"} <=> $hash{$a}->{"len"}} keys %hash){
	$seq_num++;
	$seq_sum_len += $hash{$id}->{"len"};
#	say $hash{$id}->{"len"};
	if(exists $lab{$seq_num}){
		print OUT $lab{$seq_num}."%","\t",sprintf("%.2f",$seq_sum_len / $seq_num ),"\t",$seq_num,"\n";
	}elsif($seq_num == 1000){
		print OUT "#1000","\t",sprintf("%.2f",$seq_sum_len / $seq_num )	,"\n";
		
	}
}

close OUT;

exit(0);
