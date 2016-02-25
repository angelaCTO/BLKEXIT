MASTER.CFG README
-------------------------------------------------------------------------------

CONTENTS
	1. ABOUT
	2. REQUIRED INPUTS
	3. USAGE
	4. NOTES


A1. ABOUT
	The master.cfg is the master control configuration file for the user to input 
        their desired testing specifications for the test run. Program executes on the
        basis of these inputs therefore careful specification of inputs is critical

A2. REQUIRED INPUTS
        Ex: (master.cfg)
        #######################################################################
        #### MASTER.CFG                                                      ##
        #######################################################################	
	SYSTEM      pitABC
	USERNAME    abc
	PASSWORD    abc
	INSTANCES   10
	TABLES      10000	
	ROWS        10000
	FILL        50	
	ERROR       5    
	TEST        T1
  
	SYSTEM		- Name of the host system
	USERNAME    	- System username
	PASSWORD    	- System password
	INSTANCES  	- How many test databases to generate, data generation 
			  and tests on each instance will be processed in 
			  parallel. (For instance, if you only require one
			  testing database, then specify 1)
	TABLES		- How many tables to generate for each instance
	ROWS        	- How many rows to generate for each instance
	FILL		- There are two options for FILL:
				1. STANDARD: Standard option will simply 
				generate i number of Instances specified, with 
				each Instance_i containing t Tables with each 
				Table_t containing r Rows as specified.
				2. ###: Percentage fill option will fill each
				Instance_i up to the specified fill percent.
				(ex. specifying 50 as FILL will fill each 
				Instance_i up to 50% of its max capacity).
				(Notes):
					1. Please input whole integers. A 50%
					fill should be expressed as 50 not 0.50
					or 50%
					2. Please input a fill value such that
					0 <= FILL <= 100 
	ERROR		- Margin of Error. Expressed in terms of percentage in
			  similar format to FILL. A 5% margin of error should 
			  simply be expressed as 5 (not 0.05 or 5%)           
	TEST		- Name of test to be run on each instance after testing
			  DBSs have been created and populated                

A3. USAGE
	The master configuration file MUST be named master.cfg and MUST be saved 
	in the cfgs/ directory. Use '#' for commenting.

A4. NOTES  