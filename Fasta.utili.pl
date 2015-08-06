#!/usr/bin/env perl 
use strict;
use warnings;
use utf8;
use 5.010;
use Data::Dumper;
use Bio::SeqIO;
use Getopt::Long; 
use Switch;
use List::Util qw/sum min max/;

my (@file,$moulde,$cutofflenth,$outfile,$HELP);

GetOptions(
	"i:s{,}" =>\@file,
	"m:s" =>\$moulde,
	"cut:i" => \$cutofflenth,
	"o:s" =>\$outfile,
	"h|?"=>sub {
	say "\nUSAGE:";
	say "Fasta.utili.pl -m <method> -i <input file> -cut <len cutoff> -o <output file> -h <show this USAGE>";
	say "   include those method:";
	say "     mean : FASTA file mean len";
	say "     max : FASTA file max len";
	say "     min : FASTA file min len";
	say "     N50 : FASTA file N50 value";
	say "     N90 : FASTA file N90 value";
	say "     GC : GC content percentage in the Sequences";
	say "     seqcount : count of seqences in FASTA file";
	say "     total_len : FASTA file total length";
	say "     filter : FASTA file length cutoff (need output file specified)";
	say "     muti2uniq : dump several fasta files into one (need output file specified)";
	say "     do_meta_Scf_report : Print Meta-Genomics Scaffold summary ";
	say "     do_meta_CDS_report:  Print Meta-Genomics CDS summary\n\n";
	exit(0);
	}
);


switch($moulde){
case "mean"			 	{say mean_len(@file)}
case "max"				{say max_len(@file)}
case "min"				{say min_len(@file)}
case "seqcount" 		{print `grep -c ">" @file`}
case "N50"				{say N50(@file)}
case "N90"				{say N90(@file)}
case "total_len"		{say Total_len(@file)}
case "do_meta_Scf_report"	{say do_meta_Scf_report(@file)}
case "do_meta_CDS_report"	{say do_meta_CDS_report(@file)}
case "filter"			{filter(@file,$outfile)}
case "muti2uniq"		{mutiple2uniq($outfile,@file)}
case "GC"				{GC(@file)}

}

sub GC{
	my $file = shift;
	my ($Gcontent,$Ccontent,$totlength) = (0,0,0);
	my $in = Bio::SeqIO->new( -format => 'fasta' ,-file => $file);

	while(my $seqobj = $in->next_seq() ){
		$totlength += $seqobj->length;
		$Gcontent +=() = $seqobj->seq =~ m/G/g;
		$Ccontent +=() = $seqobj->seq =~ m/C/g;
	}
	say sprintf("%.2f",($Gcontent+$Ccontent)*100/$totlength),"%";

}


sub do_meta_Scf_report{

	my $file = shift;
	my ($tol_len,$N50,$max,$seq_count,$average_len);
	$seq_count = 0;
	$max = 0;

	$cutofflenth = 0 unless defined $cutofflenth ;
	my $in = Bio::SeqIO->new( -format => 'fasta' ,-file => $file);
	my @tot;

	while(my $seqobj = $in->next_seq() ){
		next unless $seqobj->length() >= $cutofflenth;
		push @tot,$seqobj->length() ;
		$seq_count++;

		$seqobj->length() >= $max ?  $max = $seqobj->length(): next ;
	}
	
	@tot = sort {$a <=> $b } map {$_ >= 0 ? $_:() } @tot;
	$tol_len = sum(@tot);
	$average_len = sprintf("%.2f", $tol_len / $seq_count);
	my $thr = 50*$tol_len/100;	
	my $pos = 0;
	for(@tot){
		$pos += $_;
		if($pos >= $thr){
			$N50 = $_;
			last;
		}
	}
	return join "\t", ($seq_count,$tol_len,$N50,$max,$average_len);
  
}

sub do_meta_CDS_report{

	my $file = shift;
	my ($tol_len,$seq_count,$average_len);
	$seq_count = 0;
	my $in = Bio::SeqIO->new( -format => 'fasta' ,-file => $file);
	my @tot;

	while(my $seqobj = $in->next_seq() ){
		push @tot,$seqobj->length() ;
		$seq_count++;
	}
	$tol_len = sum(@tot);
	$average_len = sprintf("%.2f", $tol_len / $seq_count);
	return join "\t", ($seq_count,$tol_len,$average_len);

}

sub N50{
	my $file = shift;
	my $in = Bio::SeqIO->new( -format => 'fasta' ,-file => $file);
	my @tot;
	while(my $seqobj = $in->next_seq() ){
	push @tot,$seqobj->length() ;
	}
	@tot = sort {$a <=> $b } map {$_ >= 0 ? $_:() } @tot;
	my $thr = 50*sum(@tot)/100;	
	my $pos = 0;
	for(@tot){
		$pos += $_;
		if($pos >= $thr){
			return $_;
			last;
		}
	}
}

sub N90{
	my $file = shift;
	my $in = Bio::SeqIO->new( -format => 'fasta' ,-file => $file);
	my @tot;
	while(my $seqobj = $in->next_seq() ){
	push @tot,$seqobj->length() ;
	}
	@tot = sort {$a <=> $b } map {$_ >= 0 ? $_:() } @tot;
	my $thr = 90*sum(@tot)/100;	
	my $pos = 0;
	for(@tot){
		$pos += $_;
		if($pos >= $thr){
			return $_;
			last;
		}
	}
}

sub Total_len {
	my $file = shift;
	my $in = Bio::SeqIO->new( -format => 'fasta' ,-file => $file);
	my $tot;
	while(my $seqobj = $in->next_seq() ){
		$tot += $seqobj->length() ;
	}
	return $tot;
}

sub max_len {
	my $file = shift;
	my $in = Bio::SeqIO->new( -format => 'fasta' ,-file => $file);
	my $max_len = 0;
	while(my $seqobj = $in->next_seq() ){
		$seqobj->length() >= $max_len ?  $max_len = $seqobj->length() : next;
	}
	return $max_len;
}
sub min_len {
	my $file = shift;
	my $in = Bio::SeqIO->new( -format => 'fasta' ,-file => $file);
	my $max_len  = 100000;
	while(my $seqobj = $in->next_seq() ){

		$seqobj->length() <= $max_len ?  $max_len = $seqobj->length() : next;
	}
	return $max_len;
}

sub mean_len{
	my $file = shift;
	my $in = Bio::SeqIO->new( -format => 'fasta' ,-file => $file);
	my $lab = 1;
	my $sum = 0;
	while(my $seqobj = $in->next_seq() ){
		$sum += $seqobj->length;
		$lab ++;
	}
	return sprintf ("%.2f",$sum / $lab);
}



sub filter{
	my $file = shift;
	my $outfile = shift;

	my $in = Bio::SeqIO->new( -format => 'fasta' ,-file => $file);
	
	die "Specify the output file please\n" unless defined $outfile;
	$cutofflenth = 0 unless defined $cutofflenth;

	my $out = Bio::SeqIO->new( -format => 'fasta' ,-file => ">$outfile");

	while(my $seqobj = $in->next_seq() ){
		next unless $seqobj->length >= $cutofflenth;
		$out->write_seq($seqobj)	
	}
	exit(0);
}


sub mutiple2uniq{
	my $outfile = shift;
	my @files = @_;
	my (%hash,$in);
	
	my $out = Bio::SeqIO->new( -format => 'fasta' ,-file => ">$outfile");
	foreach(@files){
		$in = Bio::SeqIO->new( -format => 'fasta' ,-file => $_);	
		while(my $seqobj = $in->next_seq() ){
			if (exists $hash{$seqobj->seq}){next}
			$out->write_seq($seqobj);
			$hash{$seqobj->seq} = 1;	
		}
	}
	exit(0);
}
