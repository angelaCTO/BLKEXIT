#!/usr/bin/perl

###############################################################################
#### Script for compiling BLKEXIT and SCP over to testing grounds (PIT11)    ##
#### (Note: Need to compile on PITS because necessary dependies required for ##
#### compilation on PITS)                                                    ##
###############################################################################

use strict;
use warnings;

## Compile SCRIBMOD
my $programs = "programs/blkexit.c programs/generator.c programs/parser.c programs/dictionary.c";
#qx(gcc -lm -lrt -fPIC -m32 -shared -Bstatic programs/blkexit.c programs/generator.c programs/parser.c programs/dictionary.c -o bin/BLKEXIT);

qx(gcc -lm -lrt -fPIC -m32 -shared -Bstatic $programs -o bin/BLKEXIT);


## OpenSSH to bypass password prompt
qx(sshpass -p "Guest2345" scp bin/BLKEXIT root\@pit11:/var/opt/teradata/PIT11_BLKEXIT_2016/bin);

exit(0);
