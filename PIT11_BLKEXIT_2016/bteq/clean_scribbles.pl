#!/usr/bin/perl
use warnings;
use strict;

###############################################################################
## CLEAN_SCRIBBLES							     ##
## Removes all Scribble* instances from system                               ##
## If [INSTANCES] = 'ALL' then all instances will be removed. In order to    ##
## specify 'ALL', must also input the total number of existing instances     ## 
###############################################################################

if($#ARGV < 3) {
	print "USAGE: [SYSTEM] [USER] [PASSWORD] [INSTANCE] [#INSTANCES]\n";
	exit 1;
}
my $sys  = $ARGV[0];
my $usr  = $ARGV[1];
my $pwd  = $ARGV[2];
my $inst = $ARGV[3];
my $num  = $ARGV[4];

my $clean_script = "../scripts/clean_script";
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

system("/usr/bin/bteq < $clean_script > ../outputs/clean_script.txt");
#system("rm $clean_script");
