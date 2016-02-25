#!/usr/bin/perl

use warnings;
use strict;

if(($#ARGV != 4)) {
	print "USAGE: [SYSTEM] [USER] [PASSWORD] [INSTANCE]\n";
	exit 1;
}
my $sys  = $ARGV[0];
my $usr  = $ARGV[1];
my $pwd  = $ARGV[2];
my $inst = $ARGV[3];
my $perm = $ARGV[4];

my $check_script = "scripts/clean/Scribble_${inst}_check_script";
my $clear_check = <<"EOT";
LOGON $sys/$usr,$pwd;
SELECT DatabaseName
FROM DBC.DiskSpace
WHERE DatabaseName = 'Scribble_$inst';
LOGOFF;
QUIT;
EOT

