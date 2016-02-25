#!/usr/bin/perl

###############################################################################
## GET_DBC_SPACE.PL                                                          ##
###############################################################################

use strict;
use warnings;

if($#ARGV != 2) {
	print "USAGE: [SYSTEM] [USER] [PASSWORD]\n";
	exit (1);
}
my $sys  = $ARGV[0];
my $usr  = $ARGV[1];
my $pwd  = $ARGV[2];

my $export_report = "reports/space/${sys}_space.rpt";
my $export_output = "outputs/space/${sys}_space.txt";
my $get_space     = "scripts/space/${sys}_space.bteq";

#if (-e $export_report){ qx(/bin/rm $export_report); }
if (-e $get_space)     { qx(/bin/rm $get_space);     }

open (SPACE, '>', $get_space) or die("Could not open $get_space!");
print SPACE ".LOGON $sys/$usr,$pwd;\n";
print SPACE ".SET TITLEDASHES OFF;\n";
print SPACE ".width 2048;\n";
print SPACE ".EXPORT REPORT FILE = $export_report;\n\n";
print SPACE "SELECT SUM(CurrentPerm)(FORMAT 'zzzzzzzzzzzzzzz') AS CPerm,\n";
print SPACE "SUM(MaxPerm)(FORMAT 'zzzzzzzzzzzzzzz') AS MPerm,\n";
print SPACE "SUM(CurrentPerm)/SUM(MaxPerm)(FORMAT 'zz9.9999999999999999') AS UsedP\n";
print SPACE "FROM DBC.DiskSpace;\n";
print SPACE ".EXPORT RESET;\n";
print SPACE ".LOGOFF;\n.QUIT;\n";
close(SPACE);

qx(/usr/bin/bteq < $get_space > $export_output);
system("cat $export_report");
exit(0);

