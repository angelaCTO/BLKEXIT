INPUTS CONTRAINTS README
-------------------------------------------------------------------------------

CONTENTS
	A. ABOUT
	B. TYPE CONSTRAINTS
	C. TESTING PROCESS
	D. INFO
	
A. ABOUT
	The SCRIBMOD(INMOD) loader functions by reading in user specified
	attribute types from the appropriate CFG file (cfgs/input_all.cfg).
	However, as discovered from testing, certain types are limited by
	certain constrains.The number of types that can be listed in the 
	input cfg have the following contraints, for nummber of columns, c.

B. TYPE CONSTRAINTS
		
	----------------------------------
	| TYPE    | CONSTRAINT           |
	----------------------------------
	| COUNTER | limited 0 <= c <= 11 |
	----------------------------------
	| INTEGER | limited 0 <= c <= 10 |
	----------------------------------
	| DECIMAL | limited 0 <= c <= 14 |
	----------------------------------
	| VARCHAR | limited 0 <= c <= 12 |
	----------------------------------
	| CHAR    | limited 0 <= c <= 10 |
	----------------------------------
	| VARCHAR | limited 0 <= c <= 12 |
	----------------------------------
	| DATE    | limited 0 <= c <= 10 |
	----------------------------------
	| PHONE   | limited 0 <= c <= 10 |
	----------------------------------

C. TESTING PROCESS
	I found myself discovering this intriguing, mysterious error 
	(ie. the loader would not except certain combinations of input types)
	when going testing randomized sets of input types. Some combinations
	would successfully pass the loader whilst others would fail. After some
	experimenation, I came across this type constraint which induces a 
	load fail if the number of some type T exceeds a certain limit. The
	constraints are documented here. Additionally, the loader will fail to
	load (using INMOD) if more than 13 attributes are listed.

D. INFO
	At this moment in time, we are not seeking explanation in regards to 
	this seemingly strange constraint; however, we suspect it is due to
	a Teradata idiosyncracy. We anticipate an investigation will be due
	in soon time, but due current time limitations, we will accept the
	constraint as is (in order to push to alpha). If you inquire more info
	regarding this constraint requirement, please consult the TUU team for
	a more informative explanation (as we have reasons to believe it may
	be due to a Teradata configuration unknownst to us at the moment).
