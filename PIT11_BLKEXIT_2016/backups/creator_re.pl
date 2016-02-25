#!/usr/bin/perl

use strict;
use warnings;
use threads;
use threads::shared;

my $sys  = undef;
my $usr  = undef;
my $pwd  = undef;
my $inst = undef;
my $tbls = undef;
my $rows = undef;
my $fill = undef;
my $err  = undef;
my $test = undef;


## CLEAN_UP
## Cleans up all output and report files generated from previous test runs
## before new test env instantiation
sub clean_up {
=pod
    qx(rm outputs/*.txt);
    qx(rm scripts/*.bteq);
    qx(rm reports/*.rpt);
=cut
}


## PARSE_CFG
## Parse client configuration file to customize run creation for test
sub parse_cfg {
    #my $cfg_master = "cfgs/master.cfg";
    my $cfg_master = shift(@_);

    open(CFG, '<', $cfg_master) or die("Couldn't open $cfg_master $!\n");
    my @cfgs = <CFG>;
    my $col_counts = $#cfgs;
    close(CFG);

    foreach my $cfg (@cfgs) {
         next if $cfg =~ /^#|^$/;
         my ($spec, $val) = split(/\s+/, $cfg); 
         #print "SPEC: $spec, VAL: $val\n";
       
         if    ($spec =~ /SYSTEM/i)   { $sys  = $val; }
         elsif ($spec =~ /USERNAME/i) { $usr  = $val; }
         elsif ($spec =~ /PASSWORD/i) { $pwd  = $val; }
         elsif ($spec =~ /INSTANCES/i){ $inst = $val; }         
         elsif ($spec =~ /TABLES/i)   { $tbls = $val; }
         elsif ($spec =~ /ROWS/i)     { $rows = $val; }
         elsif ($spec =~ /FILL/i)     { $fill = $val; }
         elsif ($spec =~ /ERROR/i)    { $err  = $val; }
         elsif ($spec =~ /TEST/i)     { $test = $val; }
         else                         {             ; }
    }
}





## COMPUTE_10P 
## For use with drop calculations
sub compute_10p {
    use integer;  
    my $ten  = $rows/10;
    return $ten;
}


## PARSE_DBC_SPACE
## Retrieves availble DBC space to compute fill target
sub parse_dbc_space {
    qx(perl get_dbc_space.pl $sys $usr $pwd);

    my $export_report = "reports/space/${sys}_space.rpt";
    open (SPACE, '<', $export_report) or die("Could not open $export_report $!");
    my @lines = <SPACE>;
    close(SPACE);

    my @stats = split(/\s\s+/, $lines[$#lines]);
    foreach my $i (0 .. $#stats) { $stats[$i] =~ s/\s+//g; }

    chop($stats[2]); # Strip the %
    my $perc_used    = $stats[2];

    # For posterity
    # my $used_space   = sprintf("%.10g", $stats[0]);
    # my $max_space    = sprintf("%.10g", $stats[1]);
    # my $remain_space = sprintf("%.10g", $stats[3]);
    # return ($used_space, $max_space, $perc_used, $remain_space);
   
    return $perc_used;
}


## COMPUTE_ADJUSTED_FILL
## Compute adjusted fill target
sub compute_adjusted_fill {
    my $dbc_used = parse_dbc_space();
    print "***DBC USED($sys): $dbc_used\n";
    if ($inst < 1) { 
	print "ERROR: Must specify at least one instance. Please adjust input_all.cfg\n";
	exit 1;
    }
    my $adj = (($fill - $dbc_used) / $inst);
    print "***ADJUSTED FILL: $adj\n";
    
    return $adj;
}


## CREATE_DBS
## Creates the db instances for each scribble instance
sub create_dbs {
    print "\n***CREATING DBS ON $sys\n";
    print "***Please note that this stage may take a while to complete\n";
    print "***if existing DBS must be removed\n";
    my @jobs = ();
    for my $i (0 .. $inst-1) {
         print "Constructing Scribble($i):\n";
	     push @jobs, async { 
	     qx(perl clear_scribble.pl $sys $usr $pwd $i 1E9);
        };
    } $_->join for @jobs;
}


## PARSE_SPACE
## Gets Instance Space 
sub parse_space {
        my $i = shift(@_);
        qx(perl get_space.pl $sys $usr $pwd 1E9);

        my $export_report = "reports/space/space_${i}.rpt";
	open (SPACE, '<', $export_report) or die("Could not open $export_report $!");
	my @lines = <SPACE>;
	close(SPACE);

	my @stats = split(/\s\s+/, $lines[$#lines]);
	foreach my $i (0 .. $#stats) { $stats[$i] =~ s/\s+//g; }

	chop($stats[3]); # Strip the %
	my $perc_used    = $stats[3];


        return $perc_used;
}


## POPULATE
## Refer to docs for fill options
sub populate {
   my $exec = shift(@_);
   print "***BEGIN POPULATION\n";

   if ($inst < 1) {
       print "($inst) INSTANCES SPECIFIED. ABORTING LOAD\n";
       exit(1);
   }

    my $created = undef(); # Number of tables created to hit target
    my $dropped = undef(); # Number of rows created to hit target

    if ($fill =~ /STANDARD/i) {
         print "\n***STANDARD FILL\n";
	     my @jobs = ();
         foreach my $i (0 .. $inst-1) {
	        push @jobs, async {
                foreach my $tbl (0 .. $tbls-1) {
		            print "***CREATING TABLE $tbl FOR INSTANCE $i\n";
		            qx(perl blkexit_generator.pl $sys $usr $pwd $tbl $i $exec);
                }
            }; 
         } $_->join for @jobs;
     }
     else { 
         print "\n***FILL TARGET\n";
      
         # Run I(0) to determine necessary load capacity to hit target fill, 
         # the parallelize instance I(1) .. I(n) with found loading targets 
         print "\n\n***CREATING TABLES FOR TEST INSTANCE 0\n"; 
 
         my $i   = 0;
         my $go  = 1; 
         my $tbl = -1;

          while($go) {
              $tbl += 1;  

              print "\n\n***CREATING TABLE $tbl\n";  
              qx(perl blkexit_generator.pl $sys $usr $pwd $tbl $i $exec);
                
              print "***GETTING SPACE FOR INSTANCE $i\n";
              my $perc_used = parse_space($i); 

              # See if we've hit our target fill
              print "***CHECKING FOR TARGET\n";
              print "***USED v TARGET: $perc_used v $fill\n";
              print "***CHECKING FOR EXIT\n";

              if (($perc_used <= ($fill + $err)) && ($perc_used >= ($fill - $err))) {
                  print "TARGET REACHED (+/- $err) AT $perc_used %FILL\n";
		          $created = $tbl;
                  $dropped = 0;
                  $go = 0; last;
              }
              elsif ($perc_used < $fill - $err) {
                  print "***DID NOT QUALIFY FOR EXIT\n";
                  print "***CHECKED CONTINUATION NEXT TABLE\n";
              }
              elsif ($perc_used > $fill + $err) {
                  print "***DID NOT QUALIFY FOR CONTINUATION\n";
                  print "***EXCEEDED TARGET FOR TABLE $tbl\n";    
        
                  my @stats_     = ();
                  my $perc_used_ = undef;

                  my $um = $fill + $err;
                  my $lm = $fill - $err;
                  print "\n***TARGET MARGIN: $lm - $um\n";

                  my $cont  = 1; 
                  my $drops = 10; # Drops are set at 10% of table capacity

                  print "\n***BEGIN DELETING ON TABLE $tbl\n";
                  while ($cont) {
                      # Check fill capacity 
                	  my $perc_used_ = parse_space($i);  
                      printf("***PERC USED: %f\n", $perc_used_);

                      if ($drops < 0) {
                          print "***NO MORE DROPS FOR CURRENT TABLE.\n";
                          print "***CHECK IF TARGET OBTAINED\n";

                          # If the current fill still exceeds target, drop rows from prev table
                          # and drop the current emptied table
                          if ($perc_used_ > $um) {
                              qx(perl drop.pl $sys $usr $pwd $i $tbl ALL);
                              $drops = 10;
                              $tbl  -= 1;
                          }
                          else { 
                              print "***TARGET REACHED (+/- $err) AT $perc_used_ %FILL\n";
                              $created = 1 + $tbl;    # Save the number of tbls created 
                              $dropped = 10 - $drops; # Save the number of rows dropped
                              $cont = 0; $go = 0; 
                         }
		             }

                     # If fill capacity has hit target fill +/- margin error, we're done!
                     if ($perc_used_ <= ($fill + $err)) {
                         print "***TARGET REACHED (+/- $err) AT $perc_used_ %FILL\n";
                         $created = 1 + $tbl;    # Save the number of tbls created 
                         $dropped = 10 - $drops; # Save the number of rows dropped
                         $cont = 0; $go = 0; last;
                     }

                     # Otherwise, drop another 10% of the table until we've just fallen under max cap
	                 my $ten = compute_10p();
                     print "***DROPPING 10%: $ten ROWS\n";
                     qx(perl drop.pl $sys $usr $pwd $i $tbl $ten);
                     $drops -= 1;
                 }
             }
             else { ; } # Nothing to do here
         } 

         print "\n\nCREATED: $created\n";
         print "DROPPED: $dropped\n";
            
         # Now that we know how many tables we need to achieve target fill,
         # parallel the load on knowledge
         print "\n\nGENERATING INSTANCES 1 .. $inst\n";

         my @jobs = ();
         foreach my $i (1 .. $inst-1) {
             foreach my $tbl (0 .. $created-1) {
                 push @jobs, async {
                     print "GENERATING TABLE $tbl FOR INSTANCE $i\n";
                     qx(perl blkexit_generator.pl $sys $usr $pwd $tbl $i $exec);
                 };
              }
          } $_->join for @jobs;

          print "DROPPING ROWS TO HIT TARGET FILL\n\n";
          my $to_drop   = $created - 1;
          my $num_drops = $dropped * 10;
          qx(perl drop.pl $sys $usr $pwd $i $to_drop $num_drops);
    }  
}


#### RUN TESTS ############################################################


sub main {
    print "\n\n****BEGINNING SCRIBBLE ***********************************\n";     
    print "\nIf you would like to customize the test attributes for \n";
    print "this test run, please modify cfgs/input_all.cfg. For more \n";
    print "information regarding customization, please refer to docs.\n\n\n";

    print "Enter exec name: ";
    my $exec = <STDIN>; chomp($exec);
    print "Enter master cfg name: ";
    my $master = <STDIN>; chomp($master);
    print "\n";

    my $t0 = localtime();
    print "\n***START TIME: $t0\n";

    clean_up();
    #parse_cfg_submit($cfg);
    parse_cfg($master);
    create_dbs();
    populate($exec);

    my $tn = localtime();
    print "\n*** FINISH TIME: $tn\n";
    print "\n****EXITING SCRIBBLE ***********************************\n\n";     
    exit(0);
}

   
main();
