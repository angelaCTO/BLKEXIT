INPUT_ALL.CFG README
-------------------------------------------------------------------------------

CONTENTS
	1. ABOUT
	2. SUPPORTED TYPES 
	3. USEAGE 
	4. CUSTOMIZATION (OPTIONAL)


1. ABOUT
	The input_all.cfg is a configuration file for the user to input the 
        desired data types for their testing database. The types read from this
        file will be used to generate (canned) test data "on-the-fly" to be 
        used with INMOD which will generate the specified number of record to 
        be passed into the DBS. This method of data population will significantly
        reduce the memory requirement for running field tests on TD systems as 
        it requires no external source of data to be used for processing (eg. 
        flatfiles, exported data source, etc)

2. SUPPORTED TYPES
	The following lists the currently supported data types
         
        ------------------------------------------------------------------------
        | Type Name | Data Type | Useage      | Description                    |
        ----------------------------------------------------------------------
        | COUNTER   | Integer   | COUNTER     | Record counter. Increments w/  |
        |           | (INT32)   |             | each record generated. 0 ... N |   
        ------------------------------------------------------------------------
        | INTEGER   | Integer   | INTEGER     | Generates a random integer in  |
        |           | (INT32)   |             | the range 0 ... RAND_MAX       |
        |           |           |             | (ex. 343223)                   |
        -----------------------------------------------------------------------
        | DECIMAL   | Float     | DECIMAL s p | Generates a random decimal of  |
        |           |           | DECIMAL 5 2 | size s with precision to p     | 
        |           |           | DECIMAL 8 0 | decimal places. Note, at the   |
        |           |           |             | current time, formmating only  |
        |           |           |             | supports up to 30 characters   |   
        |           |           |             | so please input for s, s <= 27 | 
        |           |           |             | (ex. 123.45, 12345678.00)      |
        ------------------------------------------------------------------------
        | CHAR      | Char      | CHAR s      | Generates a randomized ascii   |
        |           |           | CHAR 50     | string containing s characters |
        |           |           |             | (ex. asmd73@#$2asd34 ... 34@#$)|
        ------------------------------------------------------------------------
        | VARCHAR   | Varchar   | VARCHAR s   | Generates a randomized sentence|
        |           |           | VARCHAR 100 | containing a string of words of|
        |           |           |             | pulled from an English Dict. of|
        |           |           |             | max character length s         |
        |           |           |             | (ex. epson character ... prune)|
        ------------------------------------------------------------------------
        | DATE      | Char      | DATE        | Generates a random date  string|
        |           |           |             | of form YYYY-MM-DD             |
        |           |           |             | (ex. 2016-01-15)               |
        ------------------------------------------------------------------------
        | PHONE     | Char      | PHONE       | Generates a random phone string|
        |           |           |             | of form ##-###-###-####        |
        |           |           |             | (ex. 12-345-678-9102)          |
        ------------------------------------------------------------------------
  
        
3. USEAGE
        The configuration file to be used must be named input_all.cfg and must 
        be saved in the cfgs directory of the current working enviroment. 
        Comments (using the '#' character to denote commented text) and blank
        lines will be ignored by the parser. There are currently 7 supported 
        data types (refer to section 2 for more details). Each type should be 
        listed on its own per new line and the columns generated for each table
        reading from the cfg will be generated according to the order types
        were specified in.
         
        Ex: (input_all.cfg)
        #######################################################################
        #### INPUT_ALL.CFG                                                   ##
        #### (FOR TEST SYSTEM 'FOO')                                         ##
        #######################################################################

        COUNTER
        DATE
        INTEGER
        CHAR 100
        DECIMAL 20 2
        VARCHAR 100
        
        ################################################################### EOF   

        This will generate the following table schema
        
        	COL0 (counter,      type: integer)
        	COL1 (date,         type: char)
        	COL2 (integer,      type: integer)
        	COL3 (char 10,      type: char(100))
        	COL4 (decimal 20 2, type: decimal)
        	COL5 (varchar 100,  type: varchar(100))            

4. CUSTOMIZATION (OPTIONAL)
        