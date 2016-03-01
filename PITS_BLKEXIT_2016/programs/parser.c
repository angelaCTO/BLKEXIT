//////////////////////////////////////////////////////////////////////////////
//// PARSER.C                                                               //
//////////////////////////////////////////////////////////////////////////////

#include <unistd.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.h"


/* CHECK ATOI : int (exit status)
 * Checks that read in config spec matches the appropriate integer type required
 */
int check_atoi(int check, char* msg) {
	if(check < 0) {
		fprintf(stderr, "ERROR (parser.c : check_atoi): %s\n", msg);
		return(EXIT_ERR);
	} else { return(EXIT_OK); }
}	


/* PARSE INPUT : int (exit status)
 * Parses inputs configuration file, setting column infos into buffer to be 
 * read into blkexit routine for generating records that match the required 
 * record specifications
 */
int parse_input(char *str, int i, char *types[BUFFLEN], int limits[BUFFLEN], int precisions[BUFFLEN]) {
       	int  limit, precision;
        char *type = strtok(str, " ");          

	if      (strcmp(type, "COUNTER") == 0)  { 
                types[i] = "COUNTER";
        	limits[i] = 0; 
                precisions[i] = 0;
    	}
    	else if (strcmp(type, "INTEGER") == 0)  { 
		types[i] = "INTEGER";
        	limits[i] = 0; 
                precisions[i] = 0;
    	}
	else if (strcmp(type, "DECIMAL") == 0)  { 
		types[i] = "DECIMAL"; 
                limit = atoi(strtok(NULL, " ")); 
       		check_atoi(limit, "Input Parsing Error (DECIMAL)");
        	limits[i] = limit; 
                precision = atoi(strtok(NULL, " ")); 
       		check_atoi(precision, "Input Parsing Error (DECIMAL)");
        	precisions[i] = precision; 
    	}
	else if (strcmp(type, "VARCHAR") == 0)  { 
                types[i] = "VARCHAR";
                limit = atoi(strtok(NULL, " ")); 
       		check_atoi(limit, "Input Parsing Error (VARCHAR)");
        	limits[i] = limit; 
		precisions[i] = 0;
	}
	else if (strcmp(type, "CHAR") == 0) {
                types[i] = "CHAR";
                limit = atoi(strtok(NULL, " ")); 
       		check_atoi(limit, "Input Parsing Error (CHAR)");
        	limits[i] = limit; 
		precisions[i] = 0;
	}
	else if (strcmp(type, "DATE") == 0) { 
		types[i] = "DATE"; 
        	limits[i] = 0; 
		precisions[i] = 0;
    	}
	else if (strcmp(type, "PHONE") == 0) { 
		types[i] = "PHONE"; 
        	limits[i] = 0; 
		precisions[i] = 0;
    	}
	else { 
	        printf("%s\n", "ERROR(parser.c): Parsing Invalid Type");
	        printf("ERROR: Line %s Col %d\n", str, i);
       	        return (EXIT_ERR);
	}
	return (EXIT_OK);
} 


/* READ_SPECS : int (numcols)
 * Reads external configuration file for custom test setup, 
 * parses column specifications and appends into types buffer (global)
 * Returns number of columns to be generated for new test setup
 */
int read_specs(char *cfg_path, int col, char *types[BUFFLEN], int limits[BUFFLEN], int precisions[BUFFLEN]) {
	FILE *fp;
	if ((fp = fopen(cfg_path, "r")) == NULL) {
		printf("FILE: %s: %s\n", "ERROR(parser.c): Reading File", cfg_path);
		exit(EXIT_ERR);
	}
        
	char line[LINEBUF];
	while(fgets(line, LINEBUF, fp) != NULL) { 
            strtok(line, "\n");         
            if (line[col] != '\n' && line[col] != '#') {
                parse_input(line, col, types, limits, precisions);
                col++;
            } 	
	}
  
	fclose(fp);
        return(col);
}


/* READ_ROWS : int (numrows)
 * Reads in NUMROWS spec from external configurations file for BLKEXIT routine 
 */
long long int read_rows(char *cfg_path) {
	FILE *fp;
	if ((fp = fopen(cfg_path, "r")) == NULL) {
		printf("FILE: %s: %s\n", "ERROR(parser.c): Reading File", cfg_path);
		exit(EXIT_ERR);
	}
   
    int i = 0;
	char line[LINEBUF];
	while(fgets(line, LINEBUF, fp) != NULL) { 
        strtok(line, "\n");         
        if (line[i] != '\n' && line[i] != '#') {
		    char *spec = strtok(line, " ");
		    if (strcmp(spec, "ROWS") == 0) { 
                return(atoi(strtok(NULL, " ")));
    		}
        }
        i++; 	
	}
    return 0;
}
