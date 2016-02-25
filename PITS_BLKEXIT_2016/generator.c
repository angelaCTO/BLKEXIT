///////////////////////////////////////////////////////////////////////////////
//// GENERATOR.C							   ////
//// Data Generators					                   ////
//// gcc -lm dictionary.c generator.c -o generate                          ////
///////////////////////////////////////////////////////////////////////////////

#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>
#include <sys/utsname.h>
#include "generator.h"
#include "dictionary.h"

///////////////////////////////////////////////////////////////////////////////
////		   	Integer Operators			   	   ////
///////////////////////////////////////////////////////////////////////////////
/* RANDR : int 
 * Select random integer within range (inclusive)
 * Params:  range(min, max) 
 * Returns: a random integer
 */ 
int randr(int min, int max) {
	int range = (max - min) + 1;
	double scale = (double)rand() / RAND_MAX;
	return( range * scale + min );
}

// ull_max = 18446744073709551615 (20)
unsigned long long randrl(unsigned long long min, unsigned long long max) {
	unsigned long long range = (max - min) + 1;
	double scale = (double)rand() / RAND_MAX;
	return( range * scale + min );   
}


/* RAND_INT : int
 * Generates a random integer between the ranges of 0 and RAND_MAX
 * Params: is_pos - bool to indicate whether the generated float value should be
 *                  positive, else assumed either positive or negative
 * Returns: a random integer   
 */
int rand_int(int is_pos) {
	if (is_pos) { return (rand()); }
	return ( pow(-1, rand()) * (rand())); 
}


int count_digits(int n) {
   int c = 0;
    while (n!= 0) {
        n /= 10;
        c++;
    }
    return c;
}



///////////////////////////////////////////////////////////////////////////////
////		   	String Operators			   	   ////
///////////////////////////////////////////////////////////////////////////////

void upper(char *p) {
     for ( ; *p; ++p) *p = toupper(*p);
}


/* CONCAT : char* 
 * String concatenation
 * Params:  str1 - first string to concat 
            str2 - second string to concat to str1
 * Returns: concatenated string
 */
char* concat(char *str1, char *str2) {
	char *sentence = malloc(strlen(str1) + strlen(str2));
	strcpy(sentence, str1);
	strcat(sentence, str2);
	return sentence;
}


/* RAND_STRING : string
 * Generates a random string containing dictionary words of specified length
 * Params:
 * Return: 
 */
void rand_string(char* str, int num_strs, char *dict_path, char dict[][LINEBUF]) {
	if (num_strs < 1)  { return; }

	memset(str, '\0', BUFSIZ);

	// Read in the dictionary buffer
	int dict_lines =  count_lines(dict_path);
	read_dict(dict_path, dict);

	char *words[num_strs];

	int str_sum = 0, i = 0;
	while(i  < num_strs) {
		char *word = dict[rand() % dict_lines];
		word[strlen(word)-1] = '\0';
		words[i] = word;
		str_sum += strlen(words[i]);
		i++;
	}
	str_sum += num_strs; 

	for(i = 0; i < num_strs; i++) { strcat(str, words[i]); }
	str[strlen(str)+1] = '\0';
}


/* GEN_COMMENT : string
 * Randomly generate comments strings for filling col specifications
 * 
 * Ex. Useage, we have a table called Test with an attribute defined as
 *     Varchar(152), in such case, we would pass in 152 into the function
 *     inorder for the function to generate a string with a character 
 *     count as close as possible to the specification    
 */
void gen_comment(char *com, int max_len, char *dict_path, char dict[][LINEBUF]) {
	if (max_len < 1)  { return; }

	// Estimate number of words based on average length of english word
	int word_count = max_len/5;

	// Read in the dictionary buffer
	int dict_lines =  count_lines(dict_path);
	read_dict(dict_path, dict);

	unsigned int i, sum = 0, count = 0;
	
	char str[BUFSIZ];
	for( i = 0; i < word_count; i++ ) {
		// memset(str, '\0', BUFSIZ);

		rand_string(str, 1, dict_path, dict);
		strcat(str, " "); 

		sum += strlen(str);
		if ( sum > max_len )  { 
			sum -= strlen( str ) - 1;
			break; 
		}
		strcat(com, str);
		count++;
	}
	com[strlen(com)+1] = '\0';
}


/* PAD_STRING : void
 * Pads string with trailing characters, ie to help pad cell cap
 * Params:
 * Returns:
 */
void pad_string(char* buf, size_t buf_size, char* str, char* pad) {
      strncpy(buf, str, buf_size);
      size_t pad_size = buf_size - strlen(str);
      if (pad_size > 0) {
         size_t i = 0;
         while(i < (pad_size - 1)) {
            strncpy((buf + strlen(str) + i), pad, 1);
            i++;
         }
      }
      buf[buf_size-1] = '\0';
} 


/* RAND_ASCII : char*
 * Generates a string containing random selection of ascii characters of 
 * specified length
 * Params:
 * Returns:
 */
void rand_ascii(char *ascii, int str_len) {
	if (str_len < 1) { return; }

	int i = 0;
	while(i < str_len) {
		int c = rand() % (int)(sizeof(charset)-1);
		ascii[i] = charset[c];
		i++;		
	}
	ascii[str_len + 1] = '\0';
}



/* RAND_DATE 
 * Generates a random date (year 1900 - 2015) of format YYYY-MM-DD
 */
void rand_date(char *date) {
	int year  = randr(1900,2016);
	int month = randr(1,12); 
	int day   = randr(1,31);

        snprintf(date, 11, "%.4d-%.2d-%.2d", year, month, day);
}


/* RAND_PHONE
 * Generates random phone number of format ##-###-###-####
 */
void rand_phone(char *phone) {
	int c1 = randr(10,99);
	int c2 = randr(100,999);
	int c3 = randr(100,999); 
	int c4 = randr(1000,9999);

        snprintf(phone, 16, "%.2d-%.3d-%.3d-%.4d", c1, c2, c3, c4);
}


/* TEST DECIMAL
 * TD Fast_Load_TD15.pdf p59 
 */
void rand_deci(char *deci) {
    int d1 = randr(0,9999999); 
    int d2 = randr(0,99);   

    printf("d1: %d\n", d1);
    printf("d2: %d\n", d2);  

    snprintf(deci, (17+1), "%.7d.%.2d", d1, d2);
                            
}


void randl_deci(char *deci, int s, int p) {
    int c, i = 0, j = 0;;

    while (i < (s-p)) {
        c = rand() % (int)(sizeof(intset)-1);
        deci[i] = intset[c];
        i++;
    }   
 
    deci[i] = '.';
    i++;
    
    if (p > 0) {
        while(j < p) {
            c = rand() % (int)(sizeof(intset)-1);
            deci[i] = intset[c];
            j++; i++;
        }
    }
}




/* TEST TBR
int main(void) {
   srand(time(NULL));

   //printf("LLD: %lld\n", randrl(99999999999999,999999999999999));

   char dig[BUFSIZ];
   memset(dig, '\0', BUFSIZ);
   rand_deci(dig);
   printf("dig: %s\n", dig);
   printf("strlen(dig): %zu\n\n", strlen(dig));

   char dig[BUFSIZ];
   memset(dig, '\0', BUFSIZ);
   randl_deci(dig, 10, 5);
   printf("dig: %s\n", dig);
   printf("strlen(dig): %zu\n\n", strlen(dig));

   return 0;
}
*/
