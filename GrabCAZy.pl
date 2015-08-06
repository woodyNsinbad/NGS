#!/usr/bin/env perl 
use strict;
use warnings;
use utf8;
use 5.010;
use LWP::Simple;
use Bio::SeqIO;
use Bio::Seq;
#use Bio::DB::GenBank;
use Data::Dumper;

my $base_url = "http://www.cazy.org/";
my @emzynes = ("Glycoside-Hydrolases",
               "GlycosylTransferases",
               "Polysaccharide-Lyases",
               "Carbohydrate-Esterases",
               "Auxiliary-Activities");

my %ontolog;

open LOG,">./catch.cazy.log";




#my $db_h = Bio::DB::GenBank->new();
my $outfile = Bio::SeqIO->new(-file => ">CAZy20150804.fasta" ,
	                          -format => 'fasta');

foreach(@emzynes){
	my $enzynes_name = $_;	
	my $emzy_url = $base_url."$enzynes_name.html";
	my $tmp = get($emzy_url);
	my	@array = $tmp =~ m/(http:\/\/www\.cazy\.org\/[A-Z].+?\.html)/smg;
		foreach (@array){
			my $url = $_;
			$url =~ s{http:\/\/www\.cazy\.org\/(.*)\.html}
					  {http:\/\/www.cazy.org\/$1_all.html};
			my $CAZy_acc = $1;
			my @protein_Acc = get_protein_acc($url);

			foreach(@protein_Acc){
				my $NCBI_acc = $_;
				my $seq;
				eval {$seq = get_NCBIproteinseq($NCBI_acc);};
					if($@){
						print LOG "uncatch\t",$CAZy_acc ,"\t",$NCBI_acc,"\n";
						next;
					}
				
					if($seq eq ''){
						print LOG "uncatch\t",$CAZy_acc ,"\t",$NCBI_acc,"\n";
						next;
					}
				eval {
						my $seq_obj = Bio::Seq->new( -seq => $seq,
				         			                   -id  => "$CAZy_acc\|"."$NCBI_acc",
										 );
						$outfile->write_seq($seq_obj);};
					if($@){
						print LOG "uncatch\t",$CAZy_acc ,"\t",$NCBI_acc,"\n";
						next;

					}
			}
		}
}

sub get_protein_acc {
	my $url_ini = $_[0];
	my $array_ref = $_[1];
	my @result;

	if ( $array_ref ) { 
			@result = @$array_ref ;
	};

	my $tmp = get($url_ini);
	my @protein_Acc = $tmp =~ m/href=http:\/\/www\.ncbi\.nlm\.nih\.gov\/entrez\/viewer\.fcgi\?db=protein&val=(.*?) /smg;

	@result = (@result,@protein_Acc);
	if ( $tmp =~ m/href\='(.+?\.html\?debut_PRINC=\d+?#pagination_PRINC)' class='lien_pagination' rel\='next'/){
			return get_protein_acc($base_url."$1",\@result);
		}else{
			return @result;
		};
	
}	

sub get_NCBIproteinseq{
	my $acc = shift;
	my $url = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=protein&id=$_&rettype=fasta"	;
	my $fasta  = get($url);
	my @temp = split "\n",$fasta ;
	shift @temp;
	return join "",@temp;
}


