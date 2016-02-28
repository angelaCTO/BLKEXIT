#!/usr/bin/perl
use warnings;
use strict;

###############################################################################
## CLEAN_SCRIBBLES							     ##
## Removes all Scribble* instances from system                               ##
## If [INSTANCES] = 'ALL' then all instances will be removed. In order to    ##
## specify 'ALL', must also input the total number of existing instances     ## 
###############################################################################

if($#ARGV != 5) {
	print "USAGE: [CWD] [SYSTEM] [USER] [PASSWORD] [INSTANCE] [#INSTANCES]\n";
	exit 1;
}
my $cwd  = $ARGV[0]
my $sys  = $ARGV[1];
my $usr  = $ARGV[2];
my $pwd  = $ARGV[3];
my $inst = $ARGV[4];
my $num  = $ARGV[5];


my $clean_script = "$cwd/scripts/clean_script";
my $clean_out    = "$cwd/outputs/clean_script.txt";

open(CLEAN, '>', $clean_script) or die("Couldn't open $clean_script $!\n");
print CLEAN "LOGON $sys/$usr,$pwd;\n";
if ($inst =~ /ALL/i) {
	foreach my $i (0 .. $num-1) {
		print CLEAN "DELETE DATABASE Scribble_${i};\n";
		print CLEAN "DROP DATABASE Scribble_${i};\n";
	}
}
else {
	print CLEAN "DELETE DATABASE Scribble_${inst};\n";
	print CLEAN "DROP DATABASE Scribble_${inst};\n";
}
print CLEAN "LOGOFF;\nQUIT;\n";
close(CLEAN);

system("/usr/bin/bteq < $clean_script > $clean_out");
#system("rm $clean_script");
