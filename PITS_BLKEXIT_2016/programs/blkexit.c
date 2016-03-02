///////////////////////////////////////////////////////////////////////////////
//// BLKEXIT.C                                                               //
//// Generates test records and sends filled data buffers to DBS             //
///////////////////////////////////////////////////////////////////////////////

#include <stdio.h>
#include <string.h>
#include <signal.h>
#include "generator.h"
#include "dictionary.h"
#include "parser.h"
#include "blkexit.h"


// ------------------------- LOCAL INITIALIZATION -------------------------- //
struct  tuple init_t;
inmdptr inmodptr;   
Int32   reccnt= 0;

// ------------------------- METHOD INITIALIZATION -------------------------- //

/* SIGHANDLER : void
 * Set EOF if signal received
 */
static volatile int stop = 0;
void SigHandler(int dummy) { 
    stop = 1; 
}


/* INIT : Exit Status 
 * Initializations, if any
 */
struct tuple Init() { 
    init_dict(import_dict, export_dict, dict_buff);

    // Invoke parser to read in numrows spec from cfg file: master.cfg
    Int32 rows = read_rows(master_path);
    printf("(INIT)-->ROWS: %lu\n", rows);

    struct tuple rt = {EM_OK, rows};

    return(rt); 
}


/* HOSTRESTART : Exit Status
 * Reset and start sending data
 */
Int32 HostRestart() { return(EM_OK); } 


/* CHECKPOINT : Exit Status
 * Save checkpoint in case roll back needed
 */
Int32 CheckPoint() { return(EM_OK); }


/* DBSRESTART : Exit Status 
 * Resets record counter to checkpoint
 */
Int32 DBSRestart() { return(EM_OK); }


/* CLEANUP : Exit Status 
 */ 
Int32 CleanUp() { return(EM_OK); }


/* INVALIDCODE : Exit Status
 * Dispatches error messages if invalid INMOD code returned 
 */
Int32 InvalidCode() { 
    fprintf(stderr, "**** Invalid code received by INMOD\n");
    return(EM_OK);
}


/* MAKERECORD : Exit Status
 * Generates records according to inputs defined in CFG 
 */
Int32 MakeRecord(Int32 cols, Int32 rows) {
    char *p;
	printf("RECCNT: %lu // ROWS: %lu\n", reccnt, rows);
    if (reccnt >= rows) { return(FILEOF); }
    p = inmodptr->Body;
 
    char str_data[BUFSIZ];
    memset(str_data, '\0', BUFSIZ);

    int i;
    for (i = 0; i < cols; i++) {
        memset(str_data, '\0', BUFSIZ);
		if (strcmp(types[i], "COUNTER") == 0) {
	    	memcpy(p, &reccnt, (Int32)sizeof(reccnt));
        	p += sizeof(reccnt);
		}
        else if (strcmp(types[i], "INTEGER") == 0) {
            Int32 intr = rand_int(randr(0,1));
	    	memcpy(p, &intr, (Int32)sizeof(intr));
            p += sizeof(intr);
		}
        else if (strcmp(types[i], "DECIMAL") == 0) {
            randl_deci(str_data, limits[i], precisions[i]);
            memcpy(p, str_data, strlen(str_data));
            p += strlen(str_data);
        }
        else if (strcmp(types[i], "CHAR") == 0) {
            rand_ascii(str_data, limits[i]);
            memcpy(p, str_data, strlen(str_data));
            p += strlen(str_data);
        }
        else if (strcmp(types[i], "VARCHAR") == 0) {
            gen_comment(str_data, limits[i], export_dict, dict_buff);
            Int16 str_len = (Int16)strlen(str_data);
            memcpy(p, &str_len, (Int16)sizeof(str_len));
            p += sizeof(str_len);
            memcpy(p, str_data, strlen(str_data));
            p += strlen(str_data);
        }
        else if (strcmp(types[i], "PHONE") == 0) {
            rand_phone(str_data);
            memcpy(p, str_data, strlen(str_data));
            p += strlen(str_data);
        }
        else if (strcmp(types[i], "DATE") == 0) {
            rand_date(str_data);
            memcpy(p, str_data, strlen(str_data));
            p += strlen(str_data);
        }
        else { 
			printf("ERROR(blkexit.c): Processing Found Invalid Type. Aborting.\n"); 
		}
       
    }

    inmodptr->ReturnCode = 0;
    inmodptr->Length = p - inmodptr->Body; 
    reccnt += 1;

    return(EM_OK);
}






/* BLKEXIT : Result Code
 * Begin processing, the main module which contains the checks for number of 
 * records generated and buffer filling. This module also sends the filled 
 * buffer to the DBS.
 */ 
#if defined WIN32
__declspec(dllexport) Int32 BLKEXIT(tblptr)
#elif defined I370
Int32 _dynamn(tblptr)
#else
Int32 BLKEXIT(tblptr)
#endif
char *tblptr;
{
    // Catch control signals to stop load
    signal(SIGINT, SigHandler);

    inmodptr = (struct inmod_struct *)tblptr;

    Int32 result;


    // Invoke parser to parse user cfg file: input_all.cfg
    Int32 cols = 0;
    cols = read_specs(inputs_path, cols, types, limits, precisions); 

    // Process the function passed to the INMOD
    switch (inmodptr->ReturnCode) {
        case 0:  init_t = Init();
                 if (init_t.result) break;
                 result = MakeRecord(cols, init_t.rows);
                 break;
        case 1:  result = MakeRecord(cols, init_t.rows);	
                 break;
        case 2:  result = HostRestart();
                 break;
        case 3:  result = CheckPoint();
                 break;
        case 4:  result = DBSRestart();
                 break;
        case 5:  result = CleanUp();
                 break;
        default: result = InvalidCode();
                 break;
    }
     
    /* TODO */
//    if (result == FILEOF || stop == 1) {
      if (result == FILEOF) {
        printf("INMOD: FILE = EOF! Done\n");
        inmodptr->Length = 0;
        result = EM_OK;
    }
 
    return(result);
}
