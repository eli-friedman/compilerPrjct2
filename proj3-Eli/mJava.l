%{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include "proj2.h"
#include "y.tab.h" 




extern int yycolumn, yylength, yyline;
extern char * stringTable[500];
extern int idx;
extern int sid[500];
extern int marker[500];
extern YYSTYPE yylval;

char * convertToLowerCase (char * text);
void addNewString (char * text);
void addNewID (char * text);
int checkForSameString (char * text, int flag);
void displayStringTable ();
void ReportError (char * msg, int line, int column);
char * checkForEscape (char * old);

%}

/* regular definitions */

identifier  	  [a-zA-Z][a-zA-Z0-9]*
falseid	   	  [0-9][a-zA-Z0-9]*
delim        	  [ \t]
ws           	  {delim}+
newline      	  [\n]
integerconstant	  [0-9]+	
stringconstant	  '(\\.|[^'\n])*'
falsestring	  '(\\.|[^'\n])*\n
comments	  "/*"([^*\n]|\*+[^*/\n])*"*/"
falsecomments    "/*"([^*\n]|\*+[^*/\n])*\n
          
%%
&&		    {yycolumn = yycolumn + yyleng;  return (ANDnum);}
:= 		    {yycolumn = yycolumn + yyleng;  return (ASSGNnum);}
[dD][eE][cC][lL][aA][rR][aA][tT][iI][oO][nN][sS]	    {yycolumn = yycolumn + yyleng;  return (DECLARATIONSnum);}
\.	            {yycolumn = yycolumn + yyleng;  return (DOTnum);}
[eE][nN][dD][Dd][eE][cC][lL][aA][rR][Aa][tT][iI][oO][nN][sS]	    {yycolumn = yycolumn + yyleng;  return (ENDDECLARATIONSnum);}
= 		    {yycolumn = yycolumn + yyleng;  return (EQUALnum);}
\> 		    {yycolumn = yycolumn + yyleng;  return (GTnum);}
[iI][nN][tT]		    {yycolumn = yycolumn + yyleng;  return (INTnum);}
\[	    	    {yycolumn = yycolumn + yyleng; return (LBRACnum);}
\]	  	    {yycolumn = yycolumn + yyleng;  return (RBRACnum);}
\(		    {yycolumn = yycolumn + yyleng;  return (LPARENnum);}
\)		    {yycolumn = yycolumn + yyleng;  return (RPARENnum);}
[mM][eE][tT][Hh][Oo][Dd]		    {yycolumn = yycolumn + yyleng;  return (METHODnum);}
!=		    {yycolumn = yycolumn + yyleng;  return (NEnum);}
\|\|		    {yycolumn = yycolumn + yyleng;  return (ORnum);}
[Pp][rR][oO][gG][rR][aA][mM]		    {yycolumn = yycolumn + yyleng;  return (PROGRAMnum);}
;		    {yycolumn = yycolumn + yyleng;  return (SEMInum);}
[vV][aA][lL]		    {yycolumn = yycolumn + yyleng;  return (VALnum);}
[wW][hH][iI][lL][eE]		    {yycolumn = yycolumn + yyleng;  return (WHILEnum);}
[cC][lL][aA][sS][sS]		    {yycolumn = yycolumn + yyleng;  return (CLASSnum);}
,		    {yycolumn = yycolumn + yyleng;  return (COMMAnum);}
\/		    {yycolumn = yycolumn + yyleng;  return (DIVIDEnum);}
[eE][lL][sS][eE]		    {yycolumn = yycolumn + yyleng;  return (ELSEnum);}
==		    {yycolumn = yycolumn + yyleng;  return (EQnum);}
\>=		    {yycolumn = yycolumn + yyleng;  return (GEnum);}
{integerconstant}   {
    		    	yycolumn = yycolumn + yyleng; 
		     	yylval.intg = atoi (yytext);
		     	//printf ("%-6d%-8dICONSTnum           \n", yyline, yycolumn); 
		     	return (ICONSTnum);
		    }
[iI][fF] 		    {yycolumn = yycolumn + yyleng;  return (IFnum);}
\{		    {yycolumn = yycolumn + yyleng;  return (LBRACEnum);}
\<=		    {yycolumn = yycolumn + yyleng;  return (LEnum);}
\<		    {yycolumn = yycolumn + yyleng; return (LTnum);}
\-		    {yycolumn = yycolumn + yyleng;  return (MINUSnum);}
!		    {yycolumn = yycolumn + yyleng;  return (NOTnum);}
\+		    {yycolumn = yycolumn + yyleng;  return (PLUSnum);}
\}		    {yycolumn = yycolumn + yyleng; return (RBRACEnum);}
[rR][eE][tT][uU][rR][nN]		    {yycolumn = yycolumn + yyleng;  return (RETURNnum);}
{stringconstant}    {
    			char * trimmedString = checkForEscape (yytext);
                        int tmp = checkForSameString (trimmedString, 0);
    			yycolumn = yycolumn + yyleng;
			if (tmp  != -1)
			{
				//printf ("%-6d%-8dSCONSTnum             %d\n", yyline, yycolumn, sid[tmp]);
				yylval.intg = sid[tmp];
			}
			else
			{
				//printf ("%-6d%-8dSCONSTnum             %d\n", yyline, yycolumn, sid[idx]);
				yylval.intg = sid[idx];
				marker[idx] = 0;
				addNewString (trimmedString);
			}
			return (SCONSTnum);
		    }
{falsestring}	    {
    			char * msg = "Detect not ending strings";
			ReportError (msg, yyline, yycolumn);
			yyline ++;
			yycolumn = 0;
   		    }
\*		    {yycolumn = yycolumn + yyleng;  return (TIMESnum);}
[vV][oO][iI][dD]		    {yycolumn = yycolumn + yyleng; return (VOIDnum);}
EOF		    {yycolumn = yycolumn + yyleng;  return (EOFnum);}

{falseid}	    {
    			char msg[50] = {'\0'};
			strcat (msg, "Identifier ");
			strcat (msg, yytext);
			strcat (msg, " starts with a digit");
			ReportError (msg, yyline, yycolumn);
			yycolumn = yycolumn + yyleng;
    		    }
{identifier}	    {
			char * lowered = convertToLowerCase (yytext);
                        int tmp = checkForSameString (lowered, 1);
    			yycolumn = yycolumn + yyleng; 
			if (tmp  != -1)
			{
				//printf("%-6d%-8dIDnum                 %d \n", yyline, yycolumn, sid[tmp]); 
				yylval.intg = sid[tmp];
				
			}
			else
			{
				//printf("%-6d%-8dIDnum                 %d \n", yyline, yycolumn, sid[idx]); 
				yylval.intg = sid[idx];
				marker[idx] = 1;
				addNewID (lowered);
			}
			return (IDnum);	
		    }

{newline}           {yyline++; yycolumn=0;}
{ws}		    {yycolumn = yycolumn + yyleng;}
{comments}	    { yycolumn += yyleng;}
{falsecomments}     {
    			char * msg = "Detect not ending comments";
			ReportError (msg, yyline, yycolumn);
			yyline ++;
			yycolumn = 0;
    		    }	
%%


YYSTYPE yylval;
int yyline = 0;
int yycolumn = 0;

int idx = 0;
char * stringTable[500];
int sid[500] = {0};
int marker[500] = {-1};

//int main()
//{
//   int lexReturn;
//    printf ("Line  Column  Token                 Index_in_String\n");
//    do
//    {
//      lexReturn = yylex();
//       if (lexReturn == 0)
//       {
//	   printf ("%-6d%-8dEOFnum           \n", yyline, yycolumn); 	
//       }
//    } while (lexReturn != 0);
//    displayStringTable ();
//    return 0;
//}

/*convert ID to lower case*/
char * convertToLowerCase (char * text)
{
    int length = strlen (text);
    int i;
    char * loweredID = (char *)malloc (length * sizeof (char));
    for (i = 0; i < length; i ++)
    {
	loweredID[i] = tolower (text[i]);   
    }
    return loweredID;
}

/*add new string to string table*/
void addNewString (char * text)
{
    int i;
    char * newString = (char *) malloc ((strlen (text)-1) * sizeof (char));
    for (i = 0; i < strlen (text)-2; i ++)
    {
	newString[i] = text[i+1];
    }
    newString[i] = '\0';
    stringTable[idx] = newString;
    sid[idx+1] = sid[idx] + strlen (newString) + 1;
    idx ++;
}

/*add new ID into string table*/
void addNewID (char * text)
{
    int i;
    char * newString = (char *) malloc ((strlen (text)+1) * sizeof (char));
    for (i = 0; i < strlen (text); i ++)
    {
	newString[i] = text[i];
    }
    newString[i] = '\0';
    stringTable[idx] = newString;
    sid[idx+1] = sid[idx] + strlen (newString) + 1;
    idx ++;
}


/*check for escape symbol in a string*/
char * checkForEscape (char * old)
{
    char * trimmed = (char *)malloc ((strlen (old)+1) * sizeof (char));
    int i = 0, leng = 0;
    for (i = 0; i < strlen (old); i ++)
    {
	if (old[i] == '\\')
	{
	    if (old[i+1] == 'n')
	    {
		trimmed[leng++] = '\n';
		i = i + 1;
	    }
	    else if (old[i+1] == 't')
	    {
		trimmed[leng++] = '\t';
		i = i + 1;
	    }
	    else if (old[i+1] == '\'')
	    {
		trimmed[leng++] = '\'';
		i = i + 1;
	    }
	    else if (old[i+1] == '\\')
	    {
		trimmed[leng++] = '\\';
		i = i + 1;
	    }
	    else
	    {
		trimmed[leng++] = old[i];
	    }
	}
	else
	{
	    trimmed[leng++] = old[i];
	}
    }
    trimmed[leng] = '\0';
    //printf ("trimmed string : %s\n", trimmed);
    return trimmed;
}

/*check for same string in the string table*/
int checkForSameString (char * text, int flag)
{
    int i;
    for (i = 0; i < idx; i ++)
    {
		if (marker[i] == flag && strlen (text) == strlen (stringTable[i]) && strcmp (text, stringTable[i]) == 0)
		{
		    return i;
		}
		else
		{    
		}
    }
    return -1;
}


/*report error */
void ReportError (char * msg, int line, int column)
{
    printf ("Error Message: %s, at line %d column %d\n", msg, line, column);
}

/*display the contents in the string table*/
void displayStringTable ()
{
    int i = 0;
    printf ("\nString Table : ");
    for (i = 0; i < idx; i ++)
    {
	printf ("%s ", stringTable[i]);
    }
    printf ("\n");
}


int yywrap (void) 
{  
	return 1;
}