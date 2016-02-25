#!/usr/bin/perl

###############################################################################
## SET_ENV.PL                                                                ##
## Sets up the neceessary working directory and its sub directories needed   ## 
## to execute Scribble/RESCRIBE on target test system                        ##
## Testing Script, later to be packaged in RPM
###############################################################################

use warnings;
use strict;

## Set up parent directory
qx(mkdir SCRIBBLE);

## Set up sub directories
qx(cd SCRIBBLE);

# Pull the configuration files 
qx(mkdir cfgs);
qx(wget https://github.td.teradata.com/AT186043/BLKEXIT/blob/master/PIT11_BLKEXIT_2016/cfgs/cfg_readme.txt);
qx(wget https://github.td.teradata.com/AT186043/BLKEXIT/blob/master/PIT11_BLKEXIT_2016/cfgs/input_all.cfg);
qx(wget https://github.td.teradata.com/AT186043/BLKEXIT/blob/master/PIT11_BLKEXIT_2016/cfgs/master.cfg);

# Pull the dictionary files for data generation
qx(mkdir dictionary);     
qx(wget https://github.td.teradata.com/AT186043/BLKEXIT/blob/master/PIT11_BLKEXIT_2016/dictionary/wordsEn.dict);

qx(mkdir outputs);        # Saves run generated outputs (diagnostics purpose)
qx(mkdir scripts);        # Saves run generated scripts (diagonistics purpose)

# Pull the requisite execution scripts
qx(wget);
qx(wget);




