#!/usr/bin/perl

###############################################################################
## GET_RECORD.PL                                                             ##
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
my $inst = $ARGV[3];


my $export_report = "reports/table_${inst}.rpt";
my $get_space     = "scripts/table_${inst}.bteq";

if (-e $get_space){ qx(/bin/rm $get_space); }
open (SPACE, '>', $get_space) or die("Could not open $get_space!");

print SPACE ".LOGON $sys/$usr,$pwd;\n";
print SPACE ".SET TITLEDASHES OFF;\n";
print SPACE ".width 2048;\n";
print SPACE ".EXPORT REPORT FILE = $export_report;\n\n";
print SPACE "SELECT databasename, tablename,\n";
print SPACE "SUM (currentperm)/1024**4 AS CURRENT_TB\n";
print SPACE "FROM dbc.allspace\n"; 
print SPACE "WHERE tablename <> 'All'\n";
print SPACE "AND databasename = 'Scribble_${inst}'\n";
print SPACE "GROUP BY 1,2\n";
print SPACE "ORDER BY 1,2;\n\n";
print SPACE ".EXPORT RESET;\n";
print SPACE ".LOGOFF;\n.QUIT;\n";
close(SPACE);


qx(/usr/bin/bteq < $get_space);
exit(0);
