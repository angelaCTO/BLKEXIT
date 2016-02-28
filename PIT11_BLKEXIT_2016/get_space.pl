#!/usr/bin/perl

###############################################################################
## GET_SPACE.PL                                                              ##
###############################################################################

use strict;
use warnings;

if($#ARGV != 4) {
	print "USAGE: [CWD] [SYSTEM] [USER] [PASSWORD] [INSTANCE]\n";
	exit 1;
}
my $cwd  = $ARGV[0];
my $sys  = $ARGV[1];
my $usr  = $ARGV[2];
my $pwd  = $ARGV[3];
my $i    = $ARGV[4];


my $export_report = "$cwd/reports/space/space_${i}.rpt";
my $export_output = "$cwd/outputs/space/space_${i}.txt";
my $get_space     = "$cwd/scripts/space/space_${i}.bteq";

if (-e $export_report){qx(/bin/rm $export_report);}
if (-e $get_space){ qx(/bin/rm $get_space);      }

open (SPACE, '>', $get_space) or die("Could not open $get_space!");
print SPACE ".LOGON $sys/$usr,$pwd;\n";
print SPACE ".SET TITLEDASHES OFF;\n";
print SPACE ".width 2048;\n";
print SPACE ".EXPORT REPORT FILE = $export_report;\n\n";
print SPACE "SELECT DatabaseName\n";
print SPACE ",SUM(CurrentPerm) / 1024**4 AS USEDSPACE_IN_TB\n";
print SPACE ",SUM(MaxPerm) / 1024**4 AS MAXSPACE_IN_TB\n";
print SPACE ",SUM(CurrentPerm)/NULLIFZERO (SUM(MaxPerm)) * 100 ";
print SPACE "(FORMAT 'zz9.9999%') AS Percentage_Used\n";
print SPACE ",MAXSPACE_IN_TB - USEDSPACE_IN_TB AS REMAININGSPACE_IN_TB\n";
print SPACE "FROM DBC.DiskSpace\n";
print SPACE "WHERE DatabaseName = 'Scribble_${i}'\n";
print SPACE "GROUP BY DatabaseName;\n\n";
print SPACE ".EXPORT RESET;\n";
print SPACE ".LOGOFF;\n.QUIT;\n";
close(SPACE);

qx(/usr/bin/bteq < $get_space > $export_output);
exit(0);
