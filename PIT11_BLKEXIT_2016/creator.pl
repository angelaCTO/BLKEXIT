#!/usr/bin/perl

###############################################################################
#### CREATOR.PL                                                            ####
#### TODO                                                                  ####
####                                                                       ####
###############################################################################

## FLAG/IMPORTS ============================================================ ##
use strict;
use warnings;
use threads;

# TODO Load Imports

## FLAG/IMPORTS ============================================================ ##

###############################################################################
####                                                                       ####
####                      GLOBALS + FLAG + OPT DECLARATIONS                ####
####                                                                       ####
###############################################################################

## TODO ==================================================================== ##
my $verb  = 1; #TODO implement this into a flag opt '-v'
my $debug = 1; #TODO implement this into a flag opt '-d'
## ==================================================================== TODO ##

## GLOBALS (CFG) =========================================================== ##
my $cwd     = undef;
my $sys  	= undef; 	
my $usr  	= undef;
my $pwd  	= undef;
my $perm 	= undef;
my $inst 	= undef;
my $tbls 	= undef;
my $rows 	= undef;
my $fopt 	= undef;
my $fill    = undef;
my $err     = undef;
my $test    = undef;

# (OTHER):
my $sess = 1;

## ================================================================= GLOBALS ##



####=======================================================================####
####                                                                       ####
####                      BEGIN METHOD DEFINITONS                          ####
####                                                                       ####
####=======================================================================####

##===========================================================================##
## clean_up()                                                                ##
##                                                                           ##
## Description: Removes all scripts, reports and BTEQ output files generated ##
##              from previous runs                                           ##
## Params: none                                        	                     ##
## Return: none                                                              ##
##===========================================================================##
sub clean_up {
    if ($verb) { print "*** PREPPING DIRECTORIES\n"; }

    qx(find outputs ! -name '.*' ! -type d -exec rm -- {} +);
    qx(find scripts ! -name '.*' ! -type d -exec rm -- {} +);
    qx(find reports ! -name '.*' ! -type d -exec rm -- {} +);

    if ($verb) { print "*** PREPPING DIRECTORIES [DONE]\n"; }
}


##===========================================================================##
## clear_dbs()
##
##===========================================================================##
#TODO Modify so that script will just look for and delete all scribble insts
# ie no old instances from prior runs should exist
sub clear_dbs {
	if ($verb) { print "\n*** CLEARING DBS ON $sys\n"; }
	
	# my @clear_jobs = ();
	foreach my $i (0 .. $inst-1) {
		print "\tDELETING Scribble($i)\n"; 
		#push @clear_jobs, async { 
			qx(perl bteq/clear_scribble.pl $cwd $sys $usr $pwd $i);
		#};
	} 
	# $_->join for @clear_jobs;

=pod TODO: this implemetation occasionally leads to a resource deadlock, need to  resolve
	## Implement check to ensure all old instances have been properly cleared
	## Note to self: cannot delegate
	foreach my $i (0 .. $inst-1) { 
		print "\tNOW CHECKING FOR Scribble_${i}\n";
		my $check = 0;
		while ($check eq 0) {			
    		my $check_out = "outputs/clean/Scribble_${i}_check.out";
    		if (-e $check_out) { qx(rm $check_out); }  
	
			my $check_script = "scripts/clean/Scribble_${i}_check_script";
    		open(CHECK, '>', $check_script) or die("Couldn't open $check_script $!\n");
    		print CHECK "LOGON $sys/$usr,$pwd;";
		    #print CHECK ".EXPORT REPORT FILE=$check_out;\n"; 
			print CHECK "SELECT DatabaseName FROM DBC.DiskSpace\n";
			print CHECK "WHERE DatabaseName = 'Scribble_$i';\n";
			print CHECK "LOGOFF;\nQUIT;\n";
    		close(CHECK);

    		qx(/usr/bin/bteq < $check_script 2>$check_out);

    		open(CHECK, '<', $check_out) or die("Couldn't open $check_out $!\n");
    		my @lines = <CHECK>;
    		close(CHECK);

    		foreach my $line (@lines) {
        		if ($line =~ /Query completed\. No rows found\./) {
		    		print "\tScribble_$i SUCCESSFULLY REMOVED\n";
	   	    		$check = 1;	
					last;
	    		}
    		}
    		if ($check eq 0) {
        		print "\tScribble_${i} DELETION IN PROGRESS. SLEEP.\n";
        		sleep(1);
    		}
		}
	}
	print "\tCHECK COMPLETED.\n";
=cut
	
	if ($verb) { print "*** CLEARING DBS ON $sys [DONE]\n"; }
}


##===========================================================================##
## parse_cfg("path/to/file")                                                 ##
##                                                                           ##
## Description: Parses user configuration file required for customizing run, ##
##              reading in cfgs as file variables                            ##
## Params: String : path to CFG file (located in dir: cfgs/)                 ##
## Return: none                                                              ##
##===========================================================================##
sub parse_cfg {
    my $cfg_master = shift(@_);
    open(CFG, '<', $cfg_master) or die("Couldn't open $cfg_master $!\n");
    my @cfgs = <CFG>;
    close(CFG);

    foreach my $cfg (@cfgs) {
         next if $cfg =~ /^#|^$/;
         my ($spec, $val) = split(/\s+/, $cfg); 

		 if    ($spec =~ /CWD/i      ) { $cwd  	= $val; }
         elsif ($spec =~ /SYSTEM/i   ) { $sys  	= $val; }
         elsif ($spec =~ /USERNAME/i ) { $usr  	= $val; }
         elsif ($spec =~ /PASSWORD/i ) { $pwd  	= $val; }
         elsif ($spec =~ /PERM/i     ) { $perm 	= $val; }		 
         elsif ($spec =~ /INSTANCES/i) { $inst 	= $val; }         
         elsif ($spec =~ /TABLES/i   ) { $tbls 	= $val; }
         elsif ($spec =~ /ROWS/i     ) { $rows 	= $val; }
         elsif ($spec =~ /FOPT/i     ) { $fopt  = $val; }
         elsif ($spec =~ /FILL/i     ) { $fill  = $val; }
         elsif ($spec =~ /ERROR/i    ) { $err   = $val; }
         elsif ($spec =~ /TEST/i     ) { $test  = $val; }
         else                          {              ; }
    }
}


##===========================================================================##
## parse_dbc_space() : (Helper)                                              ##
##                                                                           ##
## Description: Parses system disksum statistics retrieved from DBC by       ## 
##              delegate BTEQ generating script                              ##
## Params: None                                                              ##
## Return: List : system current perm, max perm and total space useage (%)   ##
##===========================================================================##
sub parse_dbc_space {
    qx(perl bteq/get_dbc_space.pl $cwd $sys $usr $pwd);

    my $export_report = "reports/space/${sys}_space.rpt";
    open (SPACE, '<', $export_report) or die("Could not open $export_report $!");
    my @lines = <SPACE>;
    close(SPACE);

    my @stats = split(/\s+/, $lines[$#lines]);
	my $cperm = $stats[1]; chomp($cperm); #print "CPERM: $cperm\n";
	my $mperm = $stats[2]; chomp($mperm); #print "MPERM: $mperm\n";
	my $usedp = $stats[3]; chomp($usedp); #print "USEDP: $usedp\n";

	return ($cperm, $mperm, $usedp);
}

##===========================================================================##
## parse_table_size(instance, table) : (Helper)                              ##
##                                                                           ##
## Description: Parses table size using data retrieved from a delegate BTEQ  ##
##              generating script                                            ##
## Params: Int : Instance Number (its No. ID)                                ##
##         Int : Table Number (its No. ID)                                   ##
## Return: None                                                              ##
##===========================================================================##
sub parse_table_size {
	my $inst = shift(@_);
	my $tbl  = shift(@_);
	
	my $tbl_rpt = "reports/space/Scribble${inst}_Tbl${tbl}.rpt";
	if (-e $tbl_rpt) { qx(rm $tbl_rpt); }

	qx(perl bteq/get_table_size.pl $cwd $sys $usr $pwd 0 0);
	
	open(TBL, '<', $tbl_rpt) or die ("Couldn't open $tbl_rpt $!\n");
	my @lines = <TBL>;
	close(TBL);
	
	my @stats = split(/\s\s+/, $lines[$#lines]);
    #foreach my $i (0 .. $#stats) { $stats[$i] =~ s/\s+//g; }
	
	my $tbl_size = $stats[2]; chomp($tbl_size);
    return $tbl_size;
}


##===========================================================================##
## standard_fill(BLKEXIT)                                                    ##
##                                                                           ##
## Description: Populates each instances and its tables with SCRIBMOD        ##
##              generated data. This load option is straightforward. It will ##
##              generate exactly the number of instances, tables/instance    ##
##              and rows of data as specified in the configuration file      ##
## Params: Executabole : BLKEXIT                                             ##
## Return: None                                                              ##
##===========================================================================##
sub standard_fill {
    my $exec = shift(@_);
   
	my @jobs = ();
	for my $i (0 .. $inst-1) {
		push @jobs, async { 
			qx(perl bteq/create_scribble.pl $cwd $sys $usr $pwd $i $perm);
		};
	} $_->join for @jobs;


	@jobs = ();
    foreach my $i (0 .. $inst-1) {
		push @jobs, async {
			foreach my $tbl (0 .. $tbls-1) {
				if ($verb) { print "\tCREATING TABLE $tbl FOR INSTANCE $i\n"; }
				qx(perl blkexit_generator.pl $cwd $sys $usr $pwd $sess $tbl $i $exec);
			}
		}; 
	} $_->join for @jobs;
}




##===========================================================================##
## target_fill(BLKEXIT)                                                      ##
##                                                                           ##
## Description: Populates the system DBC using SCRIBMOD generated data up to ##
##              the specified fill percentage. In order to consider existing ##
##              space availability of the system, target_fill will only take ##
##              into regard the specified "rows" input, i.e., it will        ##
##              generate its own number of instances and tables it has       ##
##              computed to produce the closest fill possible                ##
## Params: Exec : BLKEXIT                                                    ##
## Return: None                                                              ##
##===========================================================================##
sub target_fill {
	my $exec = shift(@_);

	## Check that system has sufficient space for achieving fill
    print "\tENSURING SUFFICIENT SPACE FOR TEST ";
	my $dbc_used = parse_dbc_space();
	if ($dbc_used > $fill) {
		print "[FAIL]\n";
		print "!! INSUFFICIENT DBC SPACE\n";
		print "\tDBC USED(%): $dbc_used\n";
		print "\tFILL(%):     $fill\n";
		print "ENDING LOAD. ABORTING RUN.\n";
		exit(1);
	} else { print "[OK]\n"; }


	if ($verb) { 
		print "\tCOMPUTING SPACE STATISTICS AND TARGET DISTRIBUTION\n";
		print "\tNOTE: SEE HTBL_SUMMARY REPORT FOR DETAILS\n";
	}

	## Gather DBC diskspace statistics after generating one htbl 
	my @dbc_stats		= parse_dbc_space();	
	my $mperm     		= $dbc_stats[1];        
	my $usedp     		= $dbc_stats[2];

	## If after generating sample table, we have exceeded target
	## then load is complete (but this would be a strange case)
	if ($usedp > $fill) {
		print "!! TARGET REACHED AT $usedp FILL vs TARGET $fill\n"; 
		exit(0);
	}

	## Determine the approximate space useage (%) for tbl/dbc
	## by generating 1 htbl with x rows to gauge character of fill
	qx(perl bteq/create_scribble.pl $cwd $sys $usr $pwd 0 $perm);
	qx(perl blkexit_generator.pl $sys $usr $pwd $sess 0 0 $exec);

	## Determine bounds on acceptable target margin given err
	my $um = $fill + $err;
	my $lm = $fill - $err; 

    ## Gather table info to gauge its effect on diskspace usage and 
    ## hypothesize the number of instances and tables to generate to
    ## achieve target 
	my $htbl_size  	   	= parse_table_size(0, 0);  
	my $num_htbls      	= int((($mperm*(0.01*$fill))/$htbl_size) + 1);
	my $htbls_per_inst 	= int($perm/$htbl_size) - 1;           # -1 to pad
	my $num_insts      	= int($num_htbls/$htbls_per_inst) + 1; # +1 overflow
	my $htbl_drops      = ($num_insts*$htbls_per_inst) - $num_htbls;

	## Htbl Computation Summary
	my $htbl_summary = "reports/htbl_summary.rpt";
	open(HTBL, '>', $htbl_summary) or die("Couldn't open $htbl_summary $!");
	print HTBL "\nSUMMARY OF HTBL DATA (GENERATED FOR TARGET FILL): \n";
	print HTBL "TARGET MARGIN:                      $lm - $um\n";
	print HTBL "TARGET HTABLE SIZE:                 $htbl_size\n";
	print HTBL "DBC MAX PERM SPACE:                 $mperm\n";
	print HTBL "TOTAL TARGET TABLES TO GENERATE:    $num_htbls\n";
	print HTBL "TOTAL TABLES FITTED PER INSTANCE:   $htbls_per_inst\n";
	print HTBL "TOTAL TARGET INSTANCES TO GENERATE: $num_insts\n";
	print HTBL "TOTAL HTABLE DROPS (FROM LAST)      $htbl_drops\n";
	close(HTBL);

    print "\tBEGIN GENERATING INSTANCES\n";
    my @jobs = ();
    if ($num_insts > 1) {
		for my $i (1 .. $num_insts-1) {
			push @jobs, async {
				qx(perl bteq/create_scribble.pl $cwd $sys $usr $pwd $i $perm);
			}
		} $_->join for @jobs;
	}

	print "\tBEGIN LOADING TABLES\n";
	my @jobs_insts = ();
	foreach my $i (0 .. $num_insts-1) {
		push @jobs_insts, async {
			my @jobs_htbls = ();
			foreach my $htbli (0.. $htbls_per_inst-1) {
				push @jobs_htbls, async {
					if ($verb) { print "\tCREATING TABLE $htbli FOR INSTANCE $i\n"; }
					qx(perl blkexit_generator.pl $sys $usr $pwd $sess $htbli $i $exec);
				};
			} $_->join for @jobs_htbls;
		}; 
    } $_->join for @jobs_insts;
	print "\tLOADING COMPLETE\n";
	
	
	## Determine if we've hit the target
	my @post_stats = parse_dbc_space();
	my $check_fill = $post_stats[2];
	print "***CHECK FILLED AT $check_fill\n";

	## Drop the overflows
	my $drop_script	= "scripts/drop/drop_overflow.bteq";
	open (DROP, '>', $drop_script) or die("Could not open $drop_script!");
	print DROP ".LOGON $sys/$usr,$pwd;\n";
	foreach my $htbl (0 .. $htbl_drops-1) {
		print DROP "DROP Scribble_${inst}.TestTable_$htbl;\n"
	}
	close(DROP);

	my $drop_out = "outputs/drop/drop_overflow.out";
	qx(/usr/bin/bteq < $drop_script > $drop_out);
}




##===========================================================================##
## populate(BLKEXIT)   	                                                     ##
##                                                                           ##
## Description: Populates the system DBC using SCRIBMOD generated data       ##
##              according to the method defined in the configuration (either ##
##              'STANDARD' or 'TARGET'.                                      ##
## Params: Exec : BLKEXIT                                                    ##
## Return: None                                                              ##
##===========================================================================##
sub populate {
	my $exec = shift(@_);

	if ($verb) { print "\n*** LOAD ($exec) "; }   	

    if ($fopt =~ /STANDARD/i) { 
    	if ($verb) { print "[STANDARD]\n"; }
    	standard_fill($exec); 
    }
    if ($fopt =~ /TARGET/i) {
    	if ($verb) { print "[TARGET]\n"; } 
    	target_fill($exec);   
    }

    if ($verb) { print "*** LOADING ON $sys [DONE]\n"; }
}




##===========================================================================##
## main()                                                                    ##
##                                                                           ##
## Description: Driver                                                       ##
## Params: None                                                              ##
## Return: None                                                              ##
##===========================================================================##
sub main {
    my $t0 = localtime();
    print "\n\nBEGINNING SCRIBBLE ***************************************\n";  
	print "***START TIME: $t0\n\n";
   
    my $exec   = "BLKEXIT41";
    my $master = "cfgs/master_41.cfg";


	clean_up();
    parse_cfg($master);
	clear_dbs();
	populate($exec);
	
    my $t1 = localtime();
    print "\n***START TIME: $t0\n";
	print "***END TIME:   $t1\n";
    print "\nEXITING SCRIBBLE ***************************************\n\n";

	exit 0;
} main();

