#!/usr/bin/perl

###############################################################################
## DROP_tbls.PL                                                              ##
###############################################################################

use strict;
use warnings;

if($#ARGV != 4) {
	print "USAGE: [SYSTEM] [USER] [PASSWORD] [INSTANCE] [TABLE]\n";
	exit(1);
}
my $sys  = $ARGV[0];
my $usr  = $ARGV[1];
my $pwd  = $ARGV[2];
my $inst = $ARGV[3];
my $tbl  = $ARGV[4];


$drop_script	= "../scripts/drop/Scribble_${inst}-drop_tbl${i}-${tbl}.bteq";
$drop_out 		= "../outputs/drop/Scribble_${inst}-drop_tbl${i}-${tbl}.out";

open (DROP, '>', $drop_script) or die("Could not open $drop_script!");
print DROP ".LOGON $sys/$usr,$pwd;\n";
print DROP "DROP Scribble_${inst}.TestTable_${tbl};\n";
print DROP ".LOGOFF;\n.QUIT;\n";
close(DROP);

qx(/usr/bin/bteq < $drop_script> $drop_out);
exit(0);

