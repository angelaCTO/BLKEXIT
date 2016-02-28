#!/usr/bin/perl

###############################################################################
## DROP_tbls.PL                                                              ##
###############################################################################

use strict;
use warnings;

if($#ARGV != 5) {
	print "USAGE: [CWD] [SYSTEM] [USER] [PASSWORD] [INSTANCE] [TABLE]\n";
	exit(1);
}
my $cwd  = $ARGV[0];
my $sys  = $ARGV[1];
my $usr  = $ARGV[2];
my $pwd  = $ARGV[3];
my $inst = $ARGV[4];
my $tbl  = $ARGV[5];


$drop_script	= "$cwd/scripts/drop/Scribble_${inst}-drop_tbl${i}-${tbl}.bteq";
$drop_out 		= "$cwd/outputs/drop/Scribble_${inst}-drop_tbl${i}-${tbl}.out";

open (DROP, '>', $drop_script) or die("Could not open $drop_script!");
print DROP ".LOGON $sys/$usr,$pwd;\n";
print DROP "DROP Scribble_${inst}.TestTable_${tbl};\n";
print DROP ".LOGOFF;\n.QUIT;\n";
close(DROP);

qx(/usr/bin/bteq < $drop_script> $drop_out);
exit(0);

