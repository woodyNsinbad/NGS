#!/usr/bin/perl -w

use LWP::Simple qw(get mirror);
use strict;
use SOAP::Lite;
use LWP; 
use LWP::UserAgent;
use HTTP::Request::Common;
use   File::Path;

# loading kegg wdsl
my $kegg_db = 'http://soap.genome.jp/KEGG.wsdl';
my $serv = SOAP::Lite->service( $kegg_db );

###$anno refers to *.annotate

#Term	Database	Id	Sample number	Backgroud number	P-Value	Corrected P-Value	Genes	Hyperlink
#Complement and coagulation cascades	KEGG PATHWAY	ko04610	8 / 20	15 / 71	0.0197737808497	None	CO3_HUMAN|A2MG_BOVIN|CO9_BOVIN|CO3_BOVIN|A2MG_HUMAN|F12AI_BOVIN|THRB_BOVIN|PLMN_BOVIN	http://www.genome.jp/kegg-bin/show_pathway?ko04610
#African trypanosomiasis	KEGG PATHWAY	ko05143	4 / 20	6 / 71	0.0489239489797	None	HBB_PIG|HBD_ATEGE|APOA1_BOVIN|HBB_FELCA	http://www.genome.jp/kegg-bin/show_pathway?ko05143
#Malaria	KEGG PATHWAY	ko05144	3 / 20	4 / 71	0.0648237249584	None	HBB_FELCA|HBD_ATEGE|HBB_PIG	http://www.genome.jp/kegg-bin/show_pathway?ko05144
#Chagas disease (American trypanosomiasis)	KEGG PATHWAY	ko05142	2 / 20	3 / 71	0.189484734494	None	CO3_BOVIN|CO3_HUMAN	http://www.genome.jp/kegg-bin/show_pathway?ko05142
#Leishmaniasis	KEGG PATHWAY	ko05140	2 / 20	3 / 71	0.189484734494	None	CO3_BOVIN|CO3_HUMAN	http://www.genome.jp/kegg-bin/show_pathway?ko05140
#Staphylococcus aureus infection	KEGG PATHWAY	ko05150	3 / 20	6 / 71	0.214687570886	None	CO3_BOVIN|PLMN_BOVIN|CO3_HUMAN	http://www.genome.jp/kegg-bin/show_pathway?ko05150
#Phagosome	KEGG PATHWAY	ko04145	6 / 20	16 / 71	0.260658892898	None	TBA8_BOVIN|CO3_HUMAN|CO3_BOVIN|TBA2_HOMAM|TBA_TRYBR|TBAT_ONCMY	http://www.genome.jp/kegg-bin/show_pathway?ko04145

#my ($anno,$dir)=@ARGV;
#my $anno;#="/Work/data/ms/kobas2.0-20110214/scripts/chayi.annotate";
#print $anno;
#my $annoString="";
#my $outdir;#="/Work/data/ms/mscal";

my ($outdir,$forname,$geneinten)=@ARGV;
#print $geneinten."\n";
#exit;
my %geneint;
if($geneinten ne "none"){
	$geneinten=~s/#$//;
	$geneinten=~s/@/\|/g;
	my @array=split"#",$geneinten;
	pop @array;
	
	foreach (@array){
		my @temp=split":";
		$geneint{$temp[0]}=$temp[1];
		#print "2\t".$_."\n";
	}
}
$outdir=~s/\/$//;
#$outdir=~s/\//@/;
my $lldir="src";
my $anno="$outdir/$forname";
my $out="$outdir/$forname"."$lldir";
	#print $out;
if(-e $out){
	my @file=grep "*",$out;
	unlink $_ foreach (@file) || die "Existing file, Please check if $_ read-only\n";
}else{
	mkdir ("$out")|| die "Could not make the source dir $out\n";
}

my %query;
my %pathway2query;
my %pathway2gene;
my %pathway;
my %pathwayname;
my $count;
my %ko2gene;
my $allcount;
my %pvalue;
my %sample;
my %sample2;
my %gene2path;
open IN,$anno.".annotate";
while (<IN>){
	next unless(/\/\/\/\//);
	while(<IN>){
		if(/Query:.*?\t(.*)\n/){
			my $temp=$1;
			
			while(<IN>){
				last if(/\/\/\/\//);
				if(/Genes\/KOs:\t(.*?)\t/){
					$ko2gene{$temp}.=", ".$1;
					
					#last;
				}
				if(/KEGG\sPATHWAY\t(.*?)\n/){
					$gene2path{$1}.=", ".$temp;
				}
			}
		}
		
	}
}
		
close IN;

open IN,$anno.".identify";
my $tag=0;
my $tag1=0;
while (<IN>){
	next unless(/Term/);
	while(<IN>){
		last if (!/\S+/);
		my @part=split"\t";
		$pathway{$part[2]}++;
		$pathwayname{$part[2]}=$part[0];
		if($part[3]=~/(\d+)\s\/\s(\d+)/ ){
			if($tag==0){
				$tag=1;
				$count=$2;
			}
			
			$sample{$part[2]}=$1;
		}
		if($part[4]=~/(\d+)\s\/\s(\d+)/ ){
			if($tag1==0){
				$tag1=1;
				$allcount=$2;
			}
			$sample2{$part[2]}=$1;
		}
		$pvalue{$part[2]}=$part[5];
		$pathway2query{$part[2]}=$part[7];
	}
}
		
close IN;

open LOG,">>ms_system.log";
print LOG "Prepare for download the enrich kegg html\n";
print "Prepare for download the enrich kegg html\n";

if(!$count || !$allcount){
	exit;
}
my $one="</head><body><center><table><caption style='font-weight: 900;'".
	">1. $forname Summary</caption><tr><th>#</th><th>Pathway</th><th>Sample ($count)</th>".
	"<th>Sample2 ($allcount)</th><th>Pvalue</th><th>Pathway ID</th></tr>";
my $cal=0;
foreach (sort {$pvalue{$a}<=>$pvalue{$b}} keys %pvalue){
	$cal++;
	#print $pathwayname{$_}."\t".$sample{$_}."\t".$sample{$_}."\t".$sample2{$_}."\t";
	$one.="\n<tr><td>$cal</td><td><a href='#gene$cal' title='click to view genes' ".
		"onclick='javascript: colorRow(document.getElementsByTagName(\"table\")[1].rows[$cal]);".
		"'>$pathwayname{$_}</a></td><td>$sample{$_}</td><td>$sample2{$_}</td><td>$pvalue{$_}</td><td>$_</td></tr>";
}

$one.="\n</table><table><caption style='font-weight: 900;'>2. $forname Details</caption><tr><th>#</th>".
	"<th>Pathway</th><th>Proteins</th></tr>";
$cal=0;
my $all=scalar(keys %pathway2query);
foreach (sort {$pvalue{$a}<=>$pvalue{$b}} keys %pvalue){
	#my $t=$pathway2query{$_};
	my $t=$gene2path{$_};
	#$t=~ s/\|/, /g;
	my $a=$_;
	##change to map,not refer
	$a=~s/\D+/map/;
	$cal++;
	&get_links($a,$t,"yellow","black",$cal,$all);
	
	$one.="\n<tr><td>$cal</td><td><a name='gene$cal' href='./$forname"."$lldir/$a.html' title='click to view map' target='_blank'>$pathwayname{$_}</a></td><td>$t</td>";	
	#$one.="\n<tr><td>$cal</td><td><a name='gene$cal' href='$out/$a.html' title='click to view map' target='_blank'>$pathwayname{$_}</a></td><td>$t</td>";
}
$one.="</table><center>\n<script type='text/javascript'>showPer(document.getElementsByTagName('table')[0]);diffColor([document.getElementsByTagName('table')[0], document.getElementsByTagName('table')[1]]);</script></body></html>";






#open IN,">$outdir/gene2ko.txt";
#print IN "GeneName\tKEGG_ID;Pathway_ID\n";
#foreach (sort keys %query){
#	print IN "$_\t$query{$_}\n";
#}
#close IN;
 
#get_links();
 
# ===================
# creates link to colored img/html
# ===================
sub get_links{
 	my ($map,$query,$bgcolor,$fgcolor,$ca,$al)=@_;
	
	my @querylist=split", ",$query;
	shift @querylist;
	my $str="http://www.genome.jp/kegg-bin/mark_pathway_www?\@$map/default%3dpink";
	my %ko2gene1;
	#print @querylist;
	#print "\n";
	#print "1\t".$_."\t".$ko2gene{$_}."\n" foreach (keys %ko2gene);
	foreach (@querylist){
		my $q=$_;
		my $ko=$ko2gene{$q};
		$ko=~s/,\s//g;		
		#print $ko."\t".$q."\n";
		#if(!exists $ko2gene{$q}){print $q."aaaaaaaaaaa\n";next;}
		
		
		#print "$q"."\t".$inten."\taaa\n";
		my $inten="";
		if(exists $geneint{$q}){
			$inten=$geneint{$q};
			if($inten>=1){
				$bgcolor="red";
			}else{
				$bgcolor="green";
			}
		}
		
		$ko2gene1{$ko}.=", ".$q.":".$inten;
		if($str=~/$ko%09(.*?),$fgcolor/){
			if($1 eq $bgcolor){
				next;
			}else{
				#print $str."\n";
				$str=~ s/$ko%09(.*?),$fgcolor/$ko%09yellow,$fgcolor/;
				print $ko."\n";
				
			}
			
		}else{
			$str.="/$ko%09$bgcolor,$fgcolor";
		}
	}
	#print $str;
	my $ua = LWP::UserAgent->new();
	my $response = $ua->request(POST $str);
	print LOG "Download the map html file";
	if($response->is_success){
		open OUT,"> $out/$map.html";
		print "Downloading map:$map........\($ca/$al\)\n";
		my $cont=$response->content();
		if($cont=~ s/<img\ssrc="(\/tmp.*\.png?)/<img src=".\/$map.png/){
			my $imgpath="http://www.genome.jp".$1;
			mirror($imgpath,"$out/$map.png");
			
		}
		my $ti="http:\/\/www.genome.jp";
		#my $tt1="onmouseover='javascript: showInfo(\"<ul><li style=\"color: #f00;\">Protein<ul><li>";
		foreach (keys %ko2gene1){
			my $temp1=$_;
			my $temp2=$ko2gene1{$_};
			$cont=~s/(title=".*?)$_(.*?")/$1 $temp1: $temp2 $2/gm;
			
		}
		$cont=~s/href="\//href="$ti\//gm;
		$cont=~s/url\s=\s"/url="$ti/gm;
		$cont=~s/window.open\('/window.open\('$ti/gm;
		$cont=~s/form.action='/form.action='$ti/gm;

		my $js=<<javascript;
<script type="text/javascript">
function showInfo(info) {
	obj = document.getElementById("result");
	obj.innerHTML = "<div style='cursor: pointer; position: absolute; right: 5px; color: #000;' onclick='javascript: document.getElementById(\\"result\\").style.display = \\"none\\";' title='close'>X</div>" + info;
	obj.style.top = document.body.scrollTop;
	obj.style.left = document.body.scrollLeft;
	obj.style.display = "";
}
javascript
		#$cont=~s/(<script language="JavaScript">)/$1$js/;
		print OUT $cont;
		
			
		
		print OUT $js;
		close OUT;
	}else{
		print "no";
	}
#my $img_link=$serv->color_pathway_by_elements('path:bsu00010', $obj_list, $fg_list, $bg_list);
#mirror($img_link,"/Work/data/ms/mscal/bin/yes1.png");
#print $serv->get_ko_by_gene('hsa:718', 1, 10)->[0];


# print "--------------------\n";
 #print "IMG_link:\n$img_link\n";  # URL of the generated image
# print "HTML_link:\n$html_link\n"; # URL of the generated html
# print "--------------------\n";
}
 
# ================
# these subroutines are needed for KEGG interaction
# ================



my $html=<<HTML;
<html>
<head>
<meta http-equiv="content-type" content="text/html; charset=utf-8">
<title>$forname</title>
<style type="text/css">
body {background-color: #fff;}
table {background-color: #000; border-collapse: collapse; border: solid #000 1px; margin: 0 0 50px 0;}
tr {background-color: #fff;}
th, td {border: solid #000 1px;}
</style>
<script type="text/javascript">
<!--
function reSize2() {
	try {
		parent.document.getElementsByTagName("iframe")[0].style.height = document.body.scrollHeight + 10;
		parent.parent.document.getElementsByTagName("iframe")[0].style.height = parent.document.body.scrollHeight;
	} catch(e) {}
}

var preRow = null;
var preColor = null;
function colorRow(trObj) {
	if (preRow != null) {
		preRow.style.backgroundColor = preColor;
	}
	preRow = trObj;
	preColor = trObj.style.backgroundColor;
	trObj.style.backgroundColor = "#ff0";
}

function diffColor(tables) {
	var color = ["#fff", "#bbf"];
	for (var i = 0; i < tables.length; i++) {
		var trObj = tables[i].getElementsByTagName("tr");
		for (var j = 1; j < trObj.length; j++) {
			trObj[j].style.backgroundColor = color[j % color.length];
		}
	}
}

function showPer(tableObj) {
	trObj = tableObj.getElementsByTagName("tr");
	if (trObj.length < 2) {
		return;
	}
	var sum1 = trObj[0].cells[2].innerHTML.replace(/^.*\\\(([\\d]+)\\\).*\$/, "\$1");
	var sum2 = 0;
	if (trObj[0].cells.length > 4) {
		sum2 = trObj[0].cells[3].innerHTML.replace(/^.*\\\(([\\d]+)\\\).*\$/, "\$1");
	}
	trObj[0].cells[2].innerHTML = "Proteins with pathway annotation (" + sum1 + ")";
	if (trObj[0].cells.length > 4) {
		trObj[0].cells[3].innerHTML = "All Proteins with pathway annotation (" + sum2 + ")";
	}
	for (var i = 1; i < trObj.length; i++) {
		trObj[i].cells[2].innerHTML += " (" + (Math.round(trObj[i].cells[2].innerHTML * 10000 / sum1) / 100) + "%)";
		if (trObj[0].cells.length > 4) {
			trObj[i].cells[3].innerHTML += " (" + (Math.round(trObj[i].cells[3].innerHTML * 10000 / sum2) / 100) + "%)";
		}
	}
}

window.onload = function() {
	setTimeout("reSize2()", 1);
}
//-->
</script>
HTML

my $output="$outdir/$forname"."_output.html";
open OUT,">$output";
print OUT $html.$one;
close OUT;

print "Pathway Summary done!\n";
close LOG;
