use strict;
use warnings;
use utf8;



my $qsub = "/share/work1/staff/mengfei/tools/qsub-sge.pl";


=head
&Cut_shell_qsub ("work_sh_dir/throw_sh.sh","CPU_NUMber", "Memory size", "all.q");
=cut 


sub Cut_shell_qsub {# Cut shell for qsub 1000 line one file
	my $shell = shift;
	my $cpu = shift;
	my $vf = shift;
	my $queue = shift;
	my $line = `less -S $shell |wc -l `;
	if ($line<=1000) {
		if ($hostname=~/login\.local|compute-0-0\.local/) {
			system "perl $qsub --queue $queue --maxproc $cpu --resource vf=$vf --independent --reqsub $shell";
		}
		else
		{
			system "ssh compute-0-0 perl $qsub --queue $queue --maxproc $cpu --resource vf=$vf --independent --reqsub $shell";
		}
	}
	if ($line>1000) {
		my @div=glob "$shell.div*";
		foreach (@div) {
			if (-e $_) {
				system "rm $_";
			}
		}
		@div=();
		my $div_index=1;
		my $line_num=0;
		open IN,"$shell" || die;
		while (<IN>) {
			chomp;
			open OUT,">>$shell.div.$div_index" || die;
			if ($line_num<1000) {
				print OUT "$_\n";
				$line_num++;
			}
			else {
				print OUT "$_\n";
				$div_index++;
				$line_num=0;
				close OUT;
			}
		}
		if ($line_num!=0) {
			close OUT;
		}
		@div=glob "$shell.div*";
		foreach my $div_file (@div) {
			if ($hostname=~/cluster/) {
				system "perl $qsub --queue $queue --maxproc $cpu --resource vf=$vf --independent --reqsub $div_file";
			}
			else
			{
				system "ssh compute-0-0 perl $qsub --queue $queue --maxproc $cpu --resource vf=$vf --independent --reqsub $div_file";
			}
		}
	}
}

sub Check_qsub_error {
	my $sh=shift;
	my @Check_file=glob "$sh*.qsub/*.Check";
	my @sh_file=glob "$sh*.qsub/*.sh";

	if ($#sh_file != $#Check_file) {
		print "Their Some Error Happend in $sh qsub, Please Check..\n";
		die;
	}
	else {
		print "$sh qsub is Done!\n";
	}
}

