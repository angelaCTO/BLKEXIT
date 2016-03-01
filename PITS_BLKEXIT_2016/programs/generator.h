///////////////////////////////////////////////////////////////////////////////
//// GENERATOR.H							     //
////									     //
///////////////////////////////////////////////////////////////////////////////
#define EXIT_OK	        0
#define EXIT_ERR	1
#define LINEBUF		80
#define BUFFLEN     	1000 

static char charset[] = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890 ";
static char intset[]  = "1234567890";


int count_digits(int n);
int     rand_int(int is_pos);
int     randr(int min, int max);
unsigned long long randrl(unsigned long long min, unsigned long long max);

void    rand_string(char *str, int str_len, char *dict_path, char dict[][LINEBUF]);
void    gen_comment(char *com, int max_len, char *dict_path, char dict[][LINEBUF]); // TODO Rename to rand_comment
void    rand_ascii(char *ascii, int str_len);
void    rand_phone(char *phone); 
void    rand_date(char *date);
void    rand_deci(char *deci);
void    randl_deci(char *deci, int s, int p);

char   *concat(char *str1, char *str2);
