#!/usr/bin/perl

###############################################################################
#### Script for compiling BLKEXIT and SCP over to testing grounds (PIT11)    ##
#### (Note: Need to compile on PITS because necessary dependies required for ##
#### compilation on PITS)                                                    ##
###############################################################################

use strict;
use warnings;

## Compile SCRIBMOD
qx(gcc -lm -lrt -fPIC -m32 -shared -Bstatic blkexit.c generator.c parser.c dictionary.c -o BLKEXIT);

## OpenSSH to bypass password prompt
qx(sshpass -p "Guest2345" scp BLKEXIT root\@pit11:/var/opt/teradata/PIT11_BLKEXIT_2016);

exit(0);
