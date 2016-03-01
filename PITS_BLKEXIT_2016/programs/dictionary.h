#define EXIT_OK	 	0
#define EXIT_ERR	1
#define EM_OK 		0
#define EM_ERR 		1
#define LINEBUF		80
#define BUFFLEN     	1000 
#define SAMPLE      	1000

int count_lines(char *file);
void gen_sample_dict(char *import_dict, char *export_dict);
void read_dict(char* dict_path, char dict[][LINEBUF]);
void init_dict(char *import_dict, char *export_dict, char dict_buff[][LINEBUF]);