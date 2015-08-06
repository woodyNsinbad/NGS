#! /usr/bin/perl

use warnings;
use strict;
use lib "/lib/LetitGO/";
use BPIDigger;
use File::Slurp;

use 5.10.0;

my $protein_file = $ARGV[0];
my $peptide_file = $ARGV[1];

my $data_set = BPIDigger->new($protein_file,$peptide_file);
my $channels = $data_set->get_channels();

foreach(@$channels){
	my $cha = $_;
	my $t = $data_set->get_Quant_info_ttest($_);
	my @haha;
	$cha =~ s/\//vs/; 
	system("touch $cha");
		foreach(keys %$t){
			my $temp = $_."\t".$t->{$_}->{quant}."\t".$t->{$_}->{"p-value"}."\n";
			push @haha,$temp	
	}

			write_file("$cha",@haha);
}


exit 0;
