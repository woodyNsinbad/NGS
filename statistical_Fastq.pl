#!/usr/bin/perl 
use strict;
use warnings;
use utf8;
use Regexp::Common;
use Data::Dumper;
use 5.010;

sub get_Q20_Q30 {
	my $file = shift;
	my @result ; 
	my $lins = `/home/wudi/Work/seq_crumbs-master/bin/calculate_stats $file`;
	$lins =~ / Q20:.($RE{num}{real})/x;
	push @result,$1;
	$lins =~ / Q30:.($RE{num}{real})/x;
	push @result,$1;
	return \@result;
}

sub total_bases_number{
	my $file = shift;
	my $base_number = `awk 'BEGIN{sum=0;}{if(NR%4==2){sum+=length(\$1);}}END{print sum;}'  $file`;
	chomp($base_number);
	return $base_number;
}

sub total_sequences_number{
	my $file = shift;
	my $total_lines = `wc -l $file |cut -d ' ' -f 1 `;
	return $total_lines/4 ;
}

1;
