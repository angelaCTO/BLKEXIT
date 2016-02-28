///////////////////////////////////////////////////////////////////////////////
//// BLKEXIT.H                                                               //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////

#define DEBUG    0
#define EM_OK    0
#define EM_ERR   1
#define FILEOF   401
#define ROWSIZE  64000


//------------ Type Definitions  ------------//
typedef short        	Sht16;
typedef int          	Int16;
typedef long int        Int32;
typedef long long int   Int64;
typedef unsigned int 	UInt32;
typedef double       	Dub64;

typedef struct inmod_struct {
    Int32 ReturnCode;
    Int32 Length;
    char  Body[ROWSIZE];
} inmdtyp,*inmdptr;

struct tuple {
    Int32 result;
    Int32 rows;
};

//------------ File Paths ------------//
char *import_dict = "dictionary/wordsEn.dict";
char *export_dict = "dictionary/wordsEx.dict";
char *inputs_path = "cfgs/input_all.cfg";
char *master_path = "cfgs/master.cfg";



//------------ Buffer Declarations  ------------//
char  	dict_buff[BUFFLEN][LINEBUF];
char    *types[BUFFLEN];
Int32 	limits[BUFFLEN];
Int32 	precisions[BUFFLEN];


//------------ Method Declarations ------------//
struct tuple Init();
Int32 HostRestart();
Int32 CheckPoint();
Int32 DBSRestart();
Int32 InvalidCode();
Int32 MakeRecord(int cols, int numrows);
Int32 BLKEXIT(char *tblptr);
Int32 CleanUp();
