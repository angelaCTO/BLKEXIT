#!/usr/bin/perl

use warnings;
use strict;

###############################################################################
## BLKEXIT_GENERATOR.PL                                                      ##
##                                                                           ##
## Generates fastload scripts for custom test schemes                        ##
## Params         														     ##
## Return:                                                                   ##
## Useage: ./blkexit_generator.pl SYS USR PWD SESS TBL_ID INST_ID EXEC       ##   
###############################################################################

### CHECK INPUTS 
if($#ARGV != 6) {
	print "USAGE: [SYSTEM] [USER] [PASSWORD] [SESSION] [TABLES] [INSTANCE] [EXEC]\n";
	exit 1;
}
my $sys  = $ARGV[0];
my $usr  = $ARGV[1];
my $pwd  = $ARGV[2];
my $sess = $ARGV[3];
my $i    = $ARGV[4]; #TODO Change $i -> $tbl
my $inst = $ARGV[5];
my $exec = $ARGV[6];


my $cfg_input = "cfgs/input_all.cfg";
my $exec_fld  = "scripts/fastload/Scribble_${inst}-TestTable_${i}";
my $exec_out  = "outputs/fastload/load_${i}.txt";


### READ IN USER CFG FROM FILE
open(CFG, '<', $cfg_input) or die("Couldn't open $cfg_input $!\n");
my @cfgs = <CFG>;
my $col_counts = $#cfgs;
close(CFG);


### BEGIN 
open(EXEC, '>', $exec_fld) or die("Couldn't open $exec_fld$!\n");


## SESSIONS
print EXEC "SESSIONS $sess;\n";

### LOGON
print EXEC "LOGON $sys/$usr,$pwd;\n";
print EXEC "\n";


### DROP EXISTING TABLES
print EXEC "DROP TABLE Scribble_${inst}.Error_${i}_1;\n";
print EXEC "DROP TABLE Scribble_${inst}.Error_${i}_2;\n";
print EXEC "DROP TABLE Scribble_${inst}.TestTable_${i};\n";
print EXEC "\n";


my @deci = ();
my $deci = undef;
my $c    = 0;


### CREATE THE TESTING TABLES FOR TEST USER
print EXEC "CREATE TABLE Scribble_${inst}.TestTable_${i}, Fallback\n";
print EXEC "(\n";
foreach my $cfg (@cfgs) {
    if ($cfg =~ /^#|^\s|^\n/) { $col_counts -= 1; next; };

    my ($type) = $cfg =~ /(\w+)/;
    if ($type =~ /INTEGER/) { 
        print EXEC "\tcol$c INTEGER";       
        if ($c < $col_counts) { print EXEC ",\n"; }
    } 
    elsif ($type =~ /COUNTER/) { 
        print EXEC "\tcol$c INTEGER";
        if ($c < $col_counts) { print EXEC ",\n"; }
    }
    elsif ($type =~ /DECIMAL/) { 
        my ($limit, $prec) = $cfg =~ /\w+\s+(\d+)\s+(\d+)/; 
	print EXEC "\tcol$c DECIMAL($limit, $prec) ";
        my $format = ('9' x ($limit - $prec)) . '.' . ('9' x 2);
        print EXEC "FORMAT '$format'\n";
        if ($c < $col_counts) { print EXEC ",\n"; }
        push(@deci, $c); $deci = $cfg; 
    }
    elsif ($type =~ /CHAR|VARCHAR/) { 
        my ($limit) = $cfg =~ /\w+\s+(\d+)/; 
        print EXEC "\tcol$c $type(${limit})";
        if ($c < $col_counts) { print EXEC ",\n"; }
    }
    elsif ($type =~ /PHONE/) { 
        print EXEC "\tcol$c CHAR(15)";
        if ($c < $col_counts) { print EXEC ",\n"; }
    }
    elsif ($type =~ /DATE/) { 
        print EXEC "\tcol$c CHAR(10)";
        if ($c < $col_counts) { print EXEC ",\n"; }
    }
    else {
        print "Oh No!\n";
        exit -1;
    }
    $c += 1;
}
print EXEC "\n);\n\n";

my $counts = $c; $c = 0;


### DEFINE
print EXEC "SET RECORD FORMATTED;\n";
print EXEC "DEFINE\n";
foreach my $cfg (@cfgs) {
    next if $cfg =~ /^#|^\s|^\n/;
    my ($type) = $cfg =~ /(\w+)/;
    if ($type =~ /INTEGER/) { 
        print EXEC "\tcol$c (INTEGER)";       
        if ($c < $col_counts) { print EXEC ",\n"; }
    } 
    elsif ($type =~ /COUNTER/) { 
	print EXEC "\tcol$c (INTEGER)";
        if ($c < $col_counts) { print EXEC ",\n"; }
    }
    elsif ($type =~ /DECIMAL/) { 
        my ($limit, $prec) = $cfg =~ /\w+\s+(\d+)\s+(\d+)/;
        $limit = $limit + 1;
	print EXEC "\tcol$c (CHAR($limit))";
        if ($c < $col_counts) { print EXEC ",\n"; }
    }
    elsif ($type =~ /CHAR|VARCHAR/) { 
        my ($limit) = $cfg =~ /\w+\s+(\d+)/; 
        print EXEC "\tcol$c (${type}(${limit}))";
        if ($c < $col_counts) { print EXEC ",\n"; }
    }
    elsif ($type =~ /PHONE/) { 
        print EXEC "\tcol$c (CHAR(15))";
        if ($c < $col_counts) { print EXEC ",\n"; }
    }
    elsif ($type =~ /DATE/) { 
        print EXEC "\tcol$c (CHAR(10))";
        if ($c < $col_counts) { print EXEC ",\n"; }
    }
    else {
        print "Oh No!\n";
        exit -1;
    }
    $c += 1; 
}
print EXEC "\nINMOD=bin/$exec;\n\n";


### DISPLAY ACTIVE DEFINITIONS FOR THE INMOD AND FIELD NAMES DEFINED
print EXEC "SHOW;\n";


### LOAD
print EXEC "BEGIN LOADING Scribble_${inst}.TestTable_${i}\n";
print EXEC "ErrorFiles Scribble_${inst}.Error_${i}_1, Scribble_${inst}.Error_${i}_2;\n\n";


### INSERT
print EXEC "INSERT INTO Scribble_${inst}.TestTable_${i}\n";
print EXEC "(\n";
foreach my $c (0 .. $counts-1) {
    print EXEC "\tcol${c}";
    if ($c < $col_counts) { print EXEC ",\n"; }
}
print EXEC "\n)\n";
print EXEC "VALUES\n";
print EXEC "(\n";
foreach my $c (0 .. $counts-1) {
    if ($c ~~ @deci) { 
        my ($limit, $prec) = $deci =~ /\w+\s+(\d+)\s+(\d+)/; 
	print EXEC "\t:col${c} (DECIMAL($limit,$prec))"; 
    }
    else { print EXEC "\t:col${c}"; }
    if ($c < $col_counts) { print EXEC ",\n"; }
}
print EXEC "\n);\n\n";


### LOGOFF 
print EXEC "END LOADING;\n";
print EXEC "LOGOFF;\n";
print EXEC "QUIT;\n";
close(EXEC);

### EXECUTE
system("/usr/bin/fastload < $exec_fld > $exec_out");

exit(0);
