#! /usr/bin/perl
use warnings;
use strict;
use lib "/lib/LetitGO/";
use CaKer;
use 5.010;
use Data::Dumper ;
use Spreadsheet::WriteExcel;


my $all_pro = read_file("/mnt/data/ZJ/all_pro");
my $diff_pro = read_file2("/mnt/data/ZJ/diff.ratio");
my @diff_ref = (keys %{$diff_pro});

my $all = CaKer->new($all_pro,"hsa");
my $diff = CaKer->new(\@diff_ref,"hsa");

my $hp = &CaKer::phyper_test($all,$diff,$diff_pro);
my $temp = &CaKer::cake_maker($hp,$diff);
my $workbook = Spreadsheet::WriteExcel->new('KEGG_summary.xls');
my $worksheet = $workbook->add_worksheet();

my @header = ("Pathway_acc",
			  "Pathway_Name",
			  "P-value",
              "# Protein in Background",
              "# Protein in Diff Exp",
			  "Protein List");

$worksheet->write_row(0,0,\@header);
my @order_keys = sort{ $hp->{$a}->[2] <=> $hp->{$b}->[2] } grep {!/#/} keys %{$hp};

my $line_tag = 1;

foreach(@order_keys){
	$worksheet->write_row($line_tag,0,$hp->{$_});
	$hp->{$_}->[0] =~ /([0-9]+)/;
	$worksheet->write_url($line_tag,6,".\\src\\$1.html");


	$line_tag++;
}


$workbook->close();

my $i = 1;
foreach(@{$temp}){

	&CaKer::get_context($_);
	print "Done $i\n";
	$i++;
}



##########################################33

sub read_file{
	my $file_name = shift;

	open FH,$file_name;
	my $result;
		while(<FH>){
			chomp;
			push @$result,$_;
		}
close FH;

	return $result;
}

##########################################


sub read_file2{

	my $file_name = shift;

	open FH,$file_name;
	my $result;
		while(<FH>){
			chomp;
			my @array = split "\t",$_;
			$result->{$array[0]} = $array[1];
		}
	close FH;
	return $result;
}
