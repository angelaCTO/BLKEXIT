#!/usr/bin/perl

use warnings;
use strict;

if(($#ARGV != 5)) {
	print "USAGE: [CWD] [SYSTEM] [USER] [PASSWORD] [INSTANCE]\n";
	exit 1;
}
my $cwd  = $ARGV[0]
my $sys  = $ARGV[1];
my $usr  = $ARGV[2];
my $pwd  = $ARGV[3];
my $inst = $ARGV[4];
my $perm = $ARGV[5];

my $check_script = "$cwd/scripts/clean/Scribble_${inst}_check_script";
my $clear_check = <<"EOT";
LOGON $sys/$usr,$pwd;
SELECT DatabaseName
FROM DBC.DiskSpace
WHERE DatabaseName = 'Scribble_$inst';
LOGOFF;
QUIT;
EOT