#!/usr/bin/perl

use warnings;
use strict;

###############################################################################
## MERGE TEST                                                                ##
##                                                                           ##
## LOOP(INF):                                                                ##
##     1. Create copies of each table to save as original                    ##
##     2. Merge 0-1, 0-1-2, 0-1-2-3, 0-1-2-3-...-n                           ##
##     3. Reloop, on every reloop merge the merged (lvl -> pvl) table        ## 
###############################################################################

=pod
if($#ARGV != 4) {
	print "USAGE: [SYSTEM] [USER] [PASSWORD] [#INSTANCES] [#TABLE]\n";
	exit(1);
}
my $sys   = $ARGV[0];
my $usr   = $ARGV[1];
my $pwd   = $ARGV[2];
my $insts = $ARGV[3];
my $tbls  = $ARGV[4];
=cut

my $sys   = "pit41";
my $usr   = "dbc";
my $pwd   = "dbc";
my $insts = 4;
my $tbls  = 10;




##===========================================================================##
## parse_space(instanceID)                                                   ##
##                                                                           ##
## Method Object: [HELPER]                                                   ##
## Description: Returns available space left in each instance (%)            ##
## Params: Int: Instance ID                                                  ##
## Return: Int: Used Space                                                   ##
##===========================================================================##
sub parse_space {
    my $inst = shift(@_);
    qx(perl get_inst_space.pl $sys $usr $pwd $inst);

    my $export_report = "../../reports/space/test/merge/space_${inst}.rpt";
    open (SPACE, '<', $export_report) or die("Could not open $export_report");
    my @lines = <SPACE>;
    close(SPACE);

    my @stats = split(/\s\s+/, $lines[$#lines]);
    foreach my $stat (0 .. $#stats) { $stats[$stat] =~ s/\s+//g; }

	my $percu = $stats[1]; chop($percu);

    if ($percu > 90) {
        print "OUT OF SPACE FOR INSTANCE(${inst})\n";
        exit(1);
    }
}


##===========================================================================##
## copy()                                                                    ##
##                                                                           ##
## Method Object: [HELPER]                                                   ##
## Description: Clones the existing tables in each instance                  ##
## Params: None                                                              ##
## Return: None                                                              ##
##===========================================================================##
sub copy {
	foreach my $copy (0 .. $tbls) {
    	my $export_output = "../../outputs/tests/merge/merge_copy-${copy}.txt";
    	my $merge_copy    = "../../scripts/tests/merge/merge_copy-${copy}.bteq";

    	open (COPY, '>', $merge_copy) or die("Could not open $merge_copy $!");
    	print COPY ".LOGON $sys/$usr,$pwd;\n";
    	foreach my $inst (0 .. $insts-1) {
        	foreach my $tbl (0 .. $tbls-1) {
        		print COPY "\nCREATE TABLE Scribble_${inst}.TestTable_${tbl}c${copy} AS\n";
            	print COPY "Scribble_${inst}.TestTable_${tbl} WITH DATA;\n";
        	}
    	}
    	print COPY ".LOGOFF;\n.QUIT;\n";
    	close(COPY);

    	qx(/usr/bin/bteq < $merge_copy > $export_output);
	}
} 



##===========================================================================##
## merge_tbls()                                                              ##
##                                                                           ##
## Method Object: [ESSENTIAL]                                                ##
## Description: Merges current list of tables for each instance. For each    ##
##              instance we'll make #table merge (lvl0) tables               ##
## Params: None                                                              ##
## Return: None                                                              ##
##===========================================================================##
sub merge_tbls {
	foreach my $merge (0 .. $tbls-1) {
    	foreach my $inst (0 .. $insts-1) {
        	my $export_output = "../../outputs/tests/merge/Scribble${inst}_merge0-${merge}.txt";
        	my $merge_tbls    = "../../scripts/tests/merge/Scribble${inst}_merge0-${merge}.bteq";

        	open (MERGE, '>', $merge_tbls) or die("Could not open $merge_tbls $!");
			print MERGE ".LOGON $sys/$usr,$pwd;\n";
        	print MERGE "CREATE TABLE Scribble_${inst}.MERGE_L0_M${merge} AS\n";
			print MERGE "Scribble_${inst}.TestTable_0 WITH DATA;\n";
        	foreach my $tbl (0 .. $tbls-1) {
	    		print MERGE "INSERT INTO Scribble_${inst}.MERGE_L0_M${merge}\n";
            	print MERGE "SELECT * FROM Scribble_${inst}.TestTable_${tbl};\n\n";
        	}
        	print MERGE ".LOGOFF;\n.QUIT;\n";
        	close(MERGE);
			qx(/usr/bin/bteq < $merge_tbls > $export_output);
    	} 
	}
}


##===========================================================================##
## merge_merge ()                                                            ##
##                                                                           ##
## Method Object: [ESSENTIAL]                                                ##
## Description: Iteratively merges all the merge (lvl_i) tables into another ##
##              merge table (lvl_j) for i,j > 0 and j = i-1                  ##
## Params: None                                                              ##
## Return: None                                                              ##
##===========================================================================##
sub merge_merge {
    my $lvl   = shift(@_);
    my $pvl   = $lvl - 1;

    foreach my $inst (0 .. $insts-1) {
    	space_check($inst);
        foreach my $merge (0 .. $tbls-1) { 
        	my $export_output = "../../outputs/tests/merge/Scribble${inst}_merge${lvl}-${merge}.txt";
            my $merge_merge   = "../../scripts/tests/merge/Scribble${inst}_merge${lvl}-${merge}.bteq";
            open (MERGE, '>', $merge_merge) or die("Could not open $merge_merge $!");
                print MERGE ".LOGON $sys/$usr,$pwd;\n";
                print MERGE "CREATE TABLE Scribble_${inst}.MERGE_L${lvl}_M${merge} AS\n";
           		print MERGE "Scribble_${inst}.MERGE_L${pvl}_M0 WITH DATA;\n";
                foreach my $tbl (0 .. $tbls-1) {
            		space_check($inst);
   	               	print MERGE "INSERT INTO Scribble_${inst}.MERGE_L${lvl}_M${merge}\n";
                    	print MERGE "SELECT * FROM Scribble_${inst}.MERGE_L${pvl}_M${tbl};\n\n";
                }
                print MERGE ".LOGOFF;\n.QUIT;\n";
                close(MERGE); 
                qx(/usr/bin/bteq < $merge_merge > $export_output);  
            }
    }
}


sub main {
	print "BEGINNING MERGE TEST\n";
    
    my $lvl = 1;
    while ($lvl < 10) {
    	# Generate the lvl0 merges
		merge_tbls(); 
		# Generate the lvl1 - lvln merges
		merge_merge($lvl); 
        $lvl += 1; 	
    }    
    
    print "END MERGE TEST\n";
}
main();