#!/usr/bin/perl

use warnings;
use strict;

###############################################################################
## CLEAR_SCRIBBLE.PL                                                         ##
##                                                                           ##
###############################################################################

if(($#ARGV != 4)) {
	print "USAGE: [CWD] [SYSTEM] [USER] [PASSWORD] [INSTANCE]\n";
	exit 1;
}
my $cwd  = $ARGV[0];
my $sys  = $ARGV[1];
my $usr  = $ARGV[2];
my $pwd  = $ARGV[3];
my $inst = $ARGV[4];

my $clear_script = "$cwd/scripts/clean/Scribble_${inst}_clear_script";
my $clear_out    = "$cwd/outputs/clean/Scribble_${inst}_clear_script";


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

#qx(/usr/bin/bteq < $clear_script 2>/dev/null);
qx(/usr/bin/bteq < $clear_script > $clear_out);

