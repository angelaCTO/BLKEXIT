#!/usr/bin/perl

###############################################################################
## GET_TABLE_SIZE.PL                                                         ##
###############################################################################

use strict;
use warnings;

if($#ARGV != 5) {
	print "USAGE: [CWD] [SYSTEM] [USER] [PASSWORD] [INSTANCE] [TABLE]\n";
	exit (1);
}
my $cwd  = $ARGV[0];
my $sys  = $ARGV[1];
my $usr  = $ARGV[2];
my $pwd  = $ARGV[3];
my $inst = $ARGV[4];
my $tbl  = $ARGV[5];

my $export_report = "$cwd/reports/space/Scribble${inst}_Tbl${tbl}.rpt";
my $export_output = "$cwd/outputs/space/Scribble${inst}_Tbl${tbl}.rpt";
my $get_tbl       = "$cwd/scripts/space/Scribble${inst}_Tbl${tbl}.bteq";

if (-e $export_report){ qx(/bin/rm $export_report); }
if (-e $export_output){ qx(/bin/rm $export_output); }
if (-e $get_tbl)      { qx(/bin/rm $get_tbl);       }

open (TBL, '>', $get_tbl) or die("Could not open $get_tbl!");
print TBL ".LOGON $sys/$usr,$pwd;\n";
print TBL ".SET TITLEDASHES OFF;\n";
print TBL ".width 2048;\n";
print TBL ".EXPORT REPORT FILE = $export_report;\n\n";
print TBL "SELECT DATABASENAME, TABLENAME, SUM(CURRENTPERM) ";
print TBL "(FORMAT 'zzzzzzzzzzz') AS Table_Size\n";
print TBL "FROM DBC.TABLESIZE\n";
print TBL "WHERE DATABASENAME = 'Scribble_${inst}'\n";
print TBL "AND TABLENAME = 'TestTable_${tbl}'\n";
print TBL "GROUP BY DATABASENAME, TABLENAME;\n";
print TBL ".EXPORT RESET;\n";
print TBL ".LOGOFF;\n.QUIT;\n";
close(TBL);

qx(/usr/bin/bteq < $get_tbl > $export_output);
system("cat $export_report");
exit(0);