#!/usr/bin/perl

use strict;
use warnings;

###############################################################################
####                                                                         ##
#### SUBMIT_BLKEXIT:							                             ## 
####    Dev script for compiling BLKEXIT using different execution paths     ##
####    Use OPENSSH to SCP exe binary to testing grounts (e.g PIT11) for     ##
####    quick transfer and immediate development                             ##
####                                                                         ##
#### NOTES: 								                                 ##
####	Compile BLKEXIT on PITS for execution on PIT11/15.10+ TD release     ##
####	because execution env (PIT11/15.10+TD) lack required dependencies    ##
####    dependencies                                                         ##
####    TODO: Further action required to implement more stringent security   ##
####          checks on release to obfuscate login credentials when using    ##
####          OpenSSH                                                        ##
####                                                                         ##
#### USEAGE:                                                                 ## 
####   1. Note to change execution path, modify "master_path" variable to    ##
####      point to appropriate configuration file on your execution system   ##
####      (ie not PITS)                                                      ##
####   2. Prompt requests naming                                             ##
####   3. Named executable will then be compiled into binary then SCP        ## 
####      transfered to designated testing grounds.                          ##
####   4. Done!                                                              ##
####                                                                         ##
###############################################################################

my $t0 = localtime();
print "\nBEGIN *************************** $t0\n";
print "SUBMITTING INMOD FOR COMPILATION\n";

print "\nPLEASE SPECIFY NAME FOR EXE: ";
my $blkex = <STDIN>; chomp($blkex);
if (-e $blkex) { qx(rm $blkex); }

=pod TODO LATER
print "SPECIFY TARGET LOGON CREDENTIALS\n";
print "\tUSER_NAME: "; my $usr = <STDIN>; chomp($usr);
print "\tPASSWORD: ";  my $pwd = <STDIN>; chomp($pwd);
print "\tSYSTEM: ";    my $sys = <STDIN>; chomp($sys);
print "SPECIFY TARGET PATH (ABSOLUTE)\n";
print "\tPATH: ";      my $pth = <STDIN>; chomp($pth);

my $programs = "programs/blkexit.c programs/generator.c programs/parser.c programs/dictionary.c";
qx(gcc -lm -lrt -fPIC -m32 -shared -Bstatic $programs -o $blkex);
qx(sshpass -p $pwd scp $blkex $usr\@$sys:$pth);
=cut

my $programs = "programs/blkexit.c programs/generator.c programs/parser.c programs/dictionary.c";
qx(gcc -lm -lrt -fPIC -m32 -shared -Bstatic $programs -o bin/$blkex);
qx(sshpass -p "Guest2345" scp bin/$blkex root\@pit11:/var/opt/teradata/PIT11_BLKEXIT_2016/bin);

my $tn = localtime();
print "\nSUBMITTED INMOD COMPILED AS $blkex\n";
print "DONE **************************** $tn\n\n";

exit(0);
