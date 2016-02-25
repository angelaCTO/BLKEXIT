#!/usr/bin/perl

###############################################################################
## GET_INST_SPACE.PL                                                         ##
###############################################################################

use strict;
use warnings;

if($#ARGV != 3) {
	print "USAGE: [SYSTEM] [USER] [PASSWORD] [INSTANCE]\n";
	exit 1;
}
my $sys  = $ARGV[0];
my $usr  = $ARGV[1];
my $pwd  = $ARGV[2];
my $i    = $ARGV[3];



my $export_report = "../../reports/space/test/merge/space_${i}.rpt";
my $export_output = "../../outputs/space/test/merge/space_${i}.txt";
my $get_space     = "../../scripts/space/test/merge/space_${i}.bteq";

#if (-e $export_report){qx(/bin/rm $export_report); }
#if (-e $export_output){qx(/bin/rm $export_output); }
#if (-e $get_space)    {qx(/bin/rm $get_space);     }

open (SPACE, '>', $get_space) or die("Could not open $get_space");
print SPACE ".LOGON $sys/$usr,$pwd;\n";
print SPACE ".SET TITLEDASHES OFF;\n";
print SPACE ".width 2048;\n";
print SPACE ".EXPORT RESET;\n";
print SPACE ".EXPORT REPORT FILE=$export_report;\n\n";
print SPACE "SELECT DatabaseName,\n";
print SPACE "SUM(CurrentPerm)/NULLIFZERO (SUM(MaxPerm)) * 100 ";
print SPACE "(FORMAT 'zz9.9999%') AS Percentage_Used\n";
print SPACE "FROM DBC.DiskSpace\n";
print SPACE "WHERE DatabaseName = 'Scribble_${i}'\n";
print SPACE "GROUP BY DatabaseName;\n\n";
print SPACE ".EXPORT RESET;\n";
print SPACE ".LOGOFF;\n.QUIT;\n";
close(SPACE);

qx(/usr/bin/bteq < $get_space > $export_output);
exit(0);
