///////////////////////////////////////////////////////////////////////////////
//// Initialize Dictionary Buffers                                           //
//// Generates random dictionary samples if DNE                              //
///////////////////////////////////////////////////////////////////////////////

#include <unistd.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "dictionary.h"

/* ------------------------------------------------------------------------- */
/* Counts the number of word (lines) in each dictionary (file)               */
/* ------------------------------------------------------------------------- */
int count_lines(char *file) {
        FILE *fp =  fopen(file, "r");
	if (fp == NULL) { 
		perror("Error: Reading/opening file for counting"); 
		return EXIT_ERR;
	}

	int ch = 0, lines = 0;
	while(!feof(fp)) {
  		ch = fgetc(fp);
  		if (ch == '\n') { lines++; }
	}

        fclose(fp);
	return lines;
}


/* ------------------------------------------------------------------------- */
/* Creates a sampled selection of words from dictionary                      */
/* ------------------------------------------------------------------------- */
void gen_sample_dict(char *import_dict, char *export_dict) {
	int buff_len = count_lines(import_dict);
        char com_buff[buff_len];
	char *script = "dictionary/genDict.pl";
        snprintf(com_buff, buff_len, "perl %s %s %s", script, import_dict, export_dict);
        printf("%s\n", com_buff);
	system(com_buff);	
}


/* ------------------------------------------------------------------------- */
/* Reads in randomly sampled dictionary into file                            */
/* ------------------------------------------------------------------------- */
void read_dict(char* dict_path, char dict[][LINEBUF]) {
	int dict_lines =  count_lines(dict_path);

	FILE *dict_fp =  fopen(dict_path, "r");
	if (dict_fp == NULL) { 
		perror("Error: Opening file for reading"); 
	}

	int i = 0;
	while(i < dict_lines && fgets(dict[i], sizeof(dict[0]), dict_fp)) {
		dict[i][strlen(dict[i])-1] = '\0';
		i++;
	}

	fclose(dict_fp);
}

/* ------------------------------------------------------------------------- */
/* Generates sample dictionary then reads exported dictionary into local buf */
/* ------------------------------------------------------------------------- */
void init_dict(char *import_dict, char *export_dict, char dict_buff[][LINEBUF]) {
	if (access(export_dict, F_OK) == -1) { 
		gen_sample_dict(import_dict, export_dict); 
	}
        read_dict(export_dict, dict_buff);
}


/*
// Test Driver (TBR)
int main(void) {
    char dict_buff[BUFFLEN][LINEBUF];
    init_dict(import_dict, export_dict, dict_buff);
    int i;
    for(i=0; i < BUFFLEN; i++) {
         printf("%s\n", dict_buff[i]); 
    }

    return 0;
}
*/