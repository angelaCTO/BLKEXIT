#!/usr/bin/perl

use strict;
use warnings;

###############################################################################
## GEN_SWAPS.PL                                                              ##
##                                                                           ##
## Generates BTEQ script to swap column data in selected tables that         ##
## corespond to the same data definition (attribite type)                    ##       
###############################################################################

if($#ARGV != 6) {
	print "USAGE: [SYSTEM] [USER] [PASSWORD] [INSTANCE] [TABLE] [COL0] [COL1]\n";
	exit(1);
}
my $sys   = $ARGV[0];
my $usr   = $ARGV[1];
my $pwd   = $ARGV[2];
my $inst  = $ARGV[3];
my $tbl   = $ARGV[4];
my $col0  = $ARGV[5];
my $col1  = $ARGV[6];

#my $export_report = "../../reports/space/test/alter/space_${i}.rpt";
my $export_output = "../../outputs/space/test/alter/space_${i}.txt";
my $swap_test     = "../../scripts/space/test/alter/space_${i}.bteq";

#if (-e $export_report){qx(/bin/rm $export_report); }
#if (-e $export_output){qx(/bin/rm $export_output); }
#if (-e $swap_test)    {qx(/bin/rm $swap_test);     }

open (SWAP, '>', $swap_test) or die("Could not open $swap_test");
print SWAP ".LOGON $sys/$usr,$pwd;\n";

print SWAP "\nUPDATE Scribble_${inst}.TestTable_${tbl}\n";
print SWAP "SET col${col0}=col${col1},col${col1}=col${col0};\n";
print SWAP ".EXPORT RESET;\n";
print SWAP ".LOGOFF;\n.QUIT;\n";
close(SWAP);

qx(/usr/bin/bteq < $swap_test > $export_output);
exit(0);


