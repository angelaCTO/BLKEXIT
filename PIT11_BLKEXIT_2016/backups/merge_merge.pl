#!/usr/bin/perl

use strict;
use warnings;

if($#ARGV != 5) {
	print "USAGE: [SYSTEM] [USER] [PASSWORD] [INSTANCES] [TABLE] [COPY]\n";
	exit(1);
}
my $sys   = $ARGV[0];
my $usr   = $ARGV[1];
my $pwd   = $ARGV[2];
my $inst  = $ARGV[3];
my $tbl   = $ARGV[4];
my $copy  = $ARGV[5];


my $export_output = "../../outputs/tests/merge/merge-merge_inst-${inst}_tbl-${tbl}.out";
my $merge_merge    = "../../scripts/tests/merge/merge-merge_inst-${inst}_tbl-${tbl}.bteq";


open (COPY, '>', $merge_copy) or die("Could not open $merge_copy $!");
print COPY ".LOGON $sys/$usr,$pwd;\n";
print COPY "CREATE TABLE Scribble_${inst}.TestTable_${tbl}c${copy} AS\n";
print COPY "Scribble_${inst}.TestTable_${tbl} WITH DATA;\n";
print COPY ".LOGOFF;\n.QUIT;\n";
close(COPY);

qx(/usr/bin/bteq < $merge_copy > $export_output);
exit(0);
