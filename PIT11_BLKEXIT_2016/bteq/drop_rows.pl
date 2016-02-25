#!/usr/bin/perl

###############################################################################
## DROP_ROWS.PL                                                              ##
###############################################################################

use strict;
use warnings;

if($#ARGV != 5) {
	print "USAGE: [SYSTEM] [USER] [PASSWORD] [INSTANCE] [TABLE] [ROWS]\n";
	exit(1);
}
my $sys  = $ARGV[0];
my $usr  = $ARGV[1];
my $pwd  = $ARGV[2];
my $i    = $ARGV[3];
my $tbl  = $ARGV[4];
my $rows = $ARGV[5];

my $drop     = undef;
my $drop_out = undef;

if ($rows =~ /ALL/i) {
    $drop     = "scripts/drop/drop_tbl${i}-${tbl}-ALL.bteq";
    $drop_out = "outputs/drop/drop_tbl${i}-${tbl}-ALL.out";

    open (DROP, '>', $drop) or die("Could not open $drop!");
    print DROP ".LOGON $sys/$usr,$pwd;\n";
    print DROP "DROP TABLE Scribble_${i}.TestTable_${tbl};";
    print DROP "\n.LOGOFF;\n.QUIT;\n";
    close(DROP);
}
else {
    $drop     = "scripts/drop/drop_tbl${i}-${tbl}-${rows}.bteq";
    $drop_out = "outputs/drop/drop_tbl${i}-${tbl}-${rows}.out";

    open (DROP, '>', $drop) or die("Could not open $drop!");
    print DROP ".LOGON $sys/$usr,$pwd;\n";
    print DROP "DELETE FROM Scribble_${i}.TestTable_${tbl} WHERE col0 IN\n";
    print DROP "(SELECT * FROM (SELECT col0 FROM Scribble_${i}.TestTable_${tbl} SAMPLE $rows) dt);\n";
    print DROP ".LOGOFF;\n.QUIT;\n";
    close(DROP);
}

qx(/usr/bin/bteq < $drop > $drop_out);
exit(0);

