#!/usr/bin/perl

###############################################################################
### GEN_DICT                                                                 ##
### Generates a sample of words selected randomly from dictionary file       ##
###############################################################################

use strict;
use warnings;
use List::Util qw(shuffle);

if($#ARGV != 1) {
	print "USEAGE: [IMPORT DICT][EXPORT DICT]\n";
	exit -1;
}

my $imp_dict	= $ARGV[0];
my $exp_dict	= $ARGV[1];

#TODO 
my $rwd 	= "/var/opt/teradata/PIT11_BLKEXIT_2016";

chomp($imp_dict);
chomp($exp_dict);

my $in_dict     = "$rwd/$imp_dict";
my $out_dict    = "$rwd/$exp_dict";
my $sample      = 1000;

# Read in dictionary
open(DICT, '<', $in_dict) or die("Could not open $in_dict\n");
my @dict = <DICT>;
close(DICT);

# Generate sample
open(SAMP, '>', $out_dict) or die("Couldn't open $out_dict\n");
@dict = shuffle(@dict);
for my $i (0 .. $sample-1) {
	print SAMP $dict[$i]; 	
}
close(SAMP);
