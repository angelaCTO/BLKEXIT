//////////////////////////////////////////////////////////////////////////////
//// PARSER.H                                                               //
//////////////////////////////////////////////////////////////////////////////
#define EXIT_OK	 	0
#define EXIT_ERR	1
#define LINEBUF		80
#define BUFFLEN     1000 

int check_atoi(int check, char* msg);
int parse_input(char *str, int i, char *types[BUFFLEN], int limits[BUFFLEN], int precisions[BUFFLEN]);
int read_specs(char *cfg_path, int col, char *types[BUFFLEN], int limits[BUFFLEN], int precisions[BUFFLEN]);
int read_rows(char *cfg_path);
