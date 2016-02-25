#!/usr/bin/perl

use warnings;
use strict;

if(($#ARGV != 3)) {
	print "USAGE: [SYSTEM] [USER] [PASSWORD] [INSTANCE]\n";
	exit 1;
}
my $sys  = $ARGV[0];
my $usr  = $ARGV[1];
my $pwd  = $ARGV[2];
my $inst = $ARGV[3];


my $clear_script = "../scripts/clean/Scribble_${inst}_clear_script";
my $clear_user = <<"EOT";
LOGON $sys/$usr,$pwd;
DELETE DATABASE Scribble_$inst;
DROP DATABASE Scribble_$inst;
LOGOFF;
QUIT;
EOT

open(CLEAR, '>', $clear_script) or die("Couldn't open $clear_script $!\n");
print CLEAR $clear_user; 
close(CLEAR);
qx(/usr/bin/bteq < $clear_script);
