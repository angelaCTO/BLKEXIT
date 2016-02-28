#!/usr/bin/perl

use warnings;
use strict;

###############################################################################
## CREATE_SCRIBBLE.PL                                                        ##
##                                                                           ##
##                                                                           ##
###############################################################################

#TODO "Couldn't open ../scripts/create/Scribble_0_create.bteq No such file or directory"
#warning doesnt affect load ... need to debug later

if($#ARGV != 5) {
	print "USAGE: [CWD] [SYSTEM] [USER] [PASSWORD] [INSTANCE] [PERM]\n";
	exit (1);
}
my $cwd  = $ARGV[0];
my $sys  = $ARGV[1];
my $usr  = $ARGV[2];
my $pwd  = $ARGV[3];
my $inst = $ARGV[4];
my $perm = $ARGV[5];

my $create_script = "$cwd/scripts/create/Scribble_${inst}_create.bteq";

my $create_user = <<"EOT";
LOGON $sys/$usr,$pwd;
CREATE USER Scribble_$inst
AS PERM = $perm,
PASSWORD = scribble;
GRANT ALL ON Scribble_$inst to Scribble_$inst WITH GRANT OPTION;
GRANT SELECT ON DBC.SW_EVENT_LOG TO Scribble_$inst WITH GRANT OPTION;
GRANT ALL ON Sysadmin TO Scribble_$inst;
LOGOFF;
QUIT;
EOT

if (-e $create_script) { qx(rm $create_script); }
open(CREATE, '>', $create_script) or die("Couldn't open $create_script $!\n");
print CREATE $create_user; 
close(CREATE);

qx(/usr/bin/bteq < $create_script 2>/dev/null);
#qx(/usr/bin/bteq < $create_script);

exit(0);