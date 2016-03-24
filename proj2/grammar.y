%{
#include  "proj2.h"
#include  <stdio.h>

  tree x;
  tree typeForMethodDecl;

  tree type_record, type_method, argtype, bractemp;/* globals used to store treenode pointers */

%}

%token <intg>  PROGRAMnum IDnum SEMInum CLASSnum  DECLARATIONSnum  ENDDECLARATIONSnum
%token <intg>  COMMAnum EQUALnum LBRACEnum RBRACEnum LBRACnum RBRACnum LPARENnum RPARENnum VOIDnum
%token <intg>  INTnum METHODnum VALnum DOTnum ASSGNnum RETURNnum IFnum ELSEnum WHILEnum
%token <intg>  LTnum LEnum EQnum NEnum GEnum GTnum PLUSnum MINUSnum ORnum TIMESnum DIVIDEnum ANDnum
%token <intg>  NOTnum ICONSTnum SCONSTnum

%type  <tptr>  Program ClassDecl_rec ClassDecl ClassBody MethodDecl_z1 MethodDecl_rec Decls
%type  <tptr>  FieldDecl_rec FieldDecl Tail FieldDecl_body VariableDeclId Bracket_rec1 Bracket_rec2
%type  <tptr>  VariableInitializer ArrayInitializer ArrayInitializer_body  ArrayCreationExpression
%type  <tptr>  ArrayCreationExpression_tail MethodDecl FormalParameterList_z1 FormalParameterList
%type  <tptr>  FormalParameterList_rec IDENTIFIER_rec Block Type Type_front 
%type  <tptr>  StatementList Statement_rec Statement AssignmentStatement MethodCallStatement
%type  <tptr>  MethodCallStatement_tail Expression_rec ReturnStatement IfStatement If_rec WhileStatement
%type  <tptr>  Expression Comp_op SimpleExpression Term Factor Expression_rec2
%type  <tptr>  UnsignedConstant Variable Variable_tail Variable_rec Variable_1 VariableDeclId_rec VariableInitializer_rec ArrayInitializer_head DeclsWithMethodDecl_rec DeclsWithMethodDecl ArrayCreationBrackets_rec Term_rec


%%/* yacc specification*/
Program          :      PROGRAMnum IDnum SEMInum ClassDecl_rec
                        {  
                          /* $$ = MakeTree(ProgramOp, $4, NullExp());  */
                          $$ = MakeTree(ProgramOp, $4, MakeLeaf(IDNode, $2)); 
                          printtree($$, 0);
                        }
                 ;

ClassDecl_rec    :      ClassDecl                       /* 1 or More of ClassDecl */
                          {  $$ = MakeTree(ClassOp, NullExp(), $1); } 
                 |      ClassDecl_rec ClassDecl
			            {  $$ = MakeTree(ClassOp, $1, $2); }
                 ;

ClassDecl : CLASSnum IDnum ClassBody 
		   	{ $$ = MakeTree(ClassDefOp, $3, MakeLeaf(IDNode, $2) ); }
			;

ClassBody :  LBRACEnum RBRACEnum 
			{ $$ = MakeTree( BodyOp, NullExp(), NullExp()); }
	      |		
			LBRACEnum DeclsWithMethodDecl_rec MethodDecl RBRACEnum 
		  	{ $$ = MakeTree( BodyOp, $2, $3); }
		  |
		    LBRACEnum Decls MethodDecl RBRACEnum 
		    { $$ = MakeTree( BodyOp, $2, $3); }
		  |
		    LBRACEnum Decls RBRACEnum 
			{ $$ = MakeTree( BodyOp, $2, NullExp()); }
		  |
		    LBRACEnum MethodDecl RBRACEnum 
			{ $$ = MakeTree( BodyOp, NullExp(), $2); }
		  |  
		    LBRACEnum MethodDecl_rec MethodDecl RBRACEnum 
			{ $$ = MakeTree( BodyOp, NullExp(), $2); }
		  ;
		  
DeclsWithMethodDecl_rec : DeclsWithMethodDecl
						|
					//	  DeclsWithMethodDecl MethodDecl
					//	  { $$ = MakeTree( BodyOp, $1, $2); }
					//	|
						  DeclsWithMethodDecl MethodDecl_rec MethodDecl
						  { MkLeftC($1, $2); $$ = MakeTree( BodyOp, $2, $3); }
						;
						
DeclsWithMethodDecl      : Decls MethodDecl
						   { $$ = MakeTree( BodyOp, $1, $2); }
				         ;

MethodDecl_rec :       MethodDecl 
					   { $$ = MakeTree( BodyOp, NullExp(), $1); }
					|  MethodDecl_rec MethodDecl
					   { $$ = MakeTree( BodyOp, $1, $2); }
			
Decls :    DECLARATIONSnum ENDDECLARATIONSnum
		  { $$ = MakeTree( BodyOp, NullExp(), NullExp()); }
		|
		  DECLARATIONSnum FieldDecl_rec FieldDecl ENDDECLARATIONSnum
		  { $$ = MakeTree( BodyOp, $2, $3); }
		|
		  DECLARATIONSnum FieldDecl ENDDECLARATIONSnum
		  { $$ = MakeTree( BodyOp, NullExp(), $2); }
		 ;

FieldDecl_rec :      FieldDecl
					{ $$ = MakeTree(BodyOp, NullExp(), $1); }
				|    FieldDecl_rec FieldDecl
				    { $$ = MakeTree( BodyOp, $1, $2); }
				;
			
FieldDecl : 	    Type  {x = $1;} VariableDeclId_rec Variable_1 SEMInum
					{  $$ = MakeTree( DeclOp, $3, $4); }
				|   Type {x = $1;} Variable_1 SEMInum
				    { $$ = MakeTree( DeclOp, NullExp(), $3); }
			     ;
			
VariableDeclId_rec :      Variable_1
					     { $$ = MakeTree( DeclOp, NullExp(), $1); }
					   | VariableDeclId_rec COMMAnum Variable_1
					     { $$ = MakeTree( DeclOp, $1, $3); }
				       ;
						 
Variable_1      :      VariableDeclId
					   {  $$ = MakeTree( CommaOp, $1, MakeTree(CommaOp, x, NullExp()) ); }
				|      VariableDeclId EQnum VariableInitializer
					   { $$ = MakeTree( CommaOp, $1, MakeTree(CommaOp, x, $3) ); }
					
VariableDeclId :    IDnum 
					{ $$ = MakeLeaf(IDNode, $1); }
				|   IDnum ArrayDeclBrackets_rec
					{ $$ = MakeLeaf(IDNode, $1); }
				;

ArrayDeclBrackets_rec : LBRACnum RBRACnum
					  | LBRACnum RBRACnum ArrayDeclBrackets_rec
					  ;
				  
VariableInitializer   : Expression
					//  ??	{ $$ = MakeLeaf(EXPRNode, $1); }
					  | ArrayInitializer
					  | ArrayCreationExpression
					  ;
				  
ArrayInitializer      :  LBRACEnum ArrayInitializer_head RBRACEnum
					  ;

ArrayInitializer_head : VariableInitializer_rec
						{ $$ = MakeTree(ArrayTypeOp, $1, x); }
					  ;

VariableInitializer_rec : VariableInitializer
						  { $$ = MakeTree( CommaOp, NullExp(), $1 ); }
						| VariableInitializer_rec COMMAnum VariableInitializer
						  { $$ = MakeTree( CommaOp, $1, $3 ); }
						;
						
ArrayCreationExpression : INTnum ArrayCreationBrackets_rec
						  { $$ = MakeTree( ArrayTypeOp, $2, MakeLeaf(INTEGERTNode, 0/****** what to put here ****/) ); }

ArrayCreationBrackets_rec : LBRACnum Expression RBRACnum
						    { $$ = MakeTree( BoundOp, NullExp(), $2 ); }
						  | ArrayCreationBrackets_rec LBRACnum Expression RBRACnum
						    { $$ = MakeTree( BoundOp, $1, $3 ); }
						  ;

MethodDecl : /*** why is this giving error?? METHODnum Type {typeForMethodDecl = $2;} IDnum LPARENnum FormalParameterList RPARENnum Block
			 { $$ = MakeTree( MethodOp, MakeTree(HeadOp, MakeLeaf(IDNode, $4), $6 ), $8); }
		   |  ***/ METHODnum VOIDnum IDnum LPARENnum FormalParameterList RPARENnum Block
		     { $$ = MakeTree( MethodOp, MakeTree(HeadOp, MakeLeaf(IDNode, $3), $5 ), $7); }
		   | METHODnum Type {typeForMethodDecl = $2;} IDnum LPARENnum RPARENnum Block
		     { $$ = MakeTree(MethodOp, MakeTree(HeadOp, MakeLeaf(IDNode, $4), NullExp() ),NullExp() /**********************$7*/ ); }
		   | METHODnum VOIDnum IDnum LPARENnum RPARENnum Block
		     { $$ = MakeTree(MethodOp, MakeTree(HeadOp, MakeLeaf(IDNode, $3), NullExp() ), $6 ); }
            ;
			
FormalParameterList :  FormalParameterList_rec 
                    ;
					
/**ask proffesor****/FormalParameterList_rec : INTnum IDENTIFIER_rec
						  { $$ = MakeTree(SpecOp, $2 , typeForMethodDecl ); }
						| VALnum INTnum IDENTIFIER_rec
						  { $$ = MakeTree(SpecOp, $3 , typeForMethodDecl ); }
						| FormalParameterList_rec SEMInum INTnum IDENTIFIER_rec
					  //  { $$ = MakeTree(SpecOp, MakeTree(RArgTypeOp, MakeTree() ) , typeForMethodDecl ); }
						| FormalParameterList_rec SEMInum VALnum INTnum IDENTIFIER_rec
					    ;
						
IDENTIFIER_rec : IDnum 
				 { $$ = MakeTree(CommaOp, MakeLeaf(IDNode, $1), MakeLeaf(INTEGERTNode, 0) ); }
			   | IDENTIFIER_rec COMMAnum IDnum
			//     {  }
			   ;
			   
Block: Decls StatementList 
       {$$ = MakeTree(BodyOp, $1, $2);}
     | StatementList
	   {$$ = MakeTree(BodyOp, NullExp(), $1);}
     ;
	 
Type : INTnum 
	   { $$ = MakeTree(TypeIdOp, MakeLeaf(INTEGERTNode, 0) , NullExp() ); }
     ;
	 
StatementList : LBRACEnum Statement_rec RBRACEnum
				{$$ = NullExp();}
			  ;
		  
Statement_rec : Statement
			    { $$ = MakeTree(StmtOp, NullExp(), $1); }
			  | Statement_rec Statement
			    { $$ = MakeTree(StmtOp, $1, $2); }
			  ;
			  
Statement: //epsilon 
           {$$ = NullExp();}
		   | ReturnStatement
		   //| WhileStatement
		 ;
		 
ReturnStatement : RETURNnum 
				  { $$ = MakeTree(ReturnOp, NullExp(), NullExp() ); }
				| RETURNnum Expression
		          { $$ = MakeTree(ReturnOp, $2, NullExp() ); }
				;
				
WhileStatement : WHILEnum Expression StatementList
				 { $$ = MakeTree(LoopOp, $2, $3); }
               ;
			
Expression : SimpleExpression {$$ = $1;}
 | SimpleExpression Comp_op SimpleExpression
    { MkLeftC($1, $2); $$ = MkRightC($3, $2); }
  ;
   
Comp_op : LTnum { $$ = MakeTree(LTOp, NullExp(), NullExp() ); }
		| LEnum { $$ = MakeTree(LTOp, NullExp(), NullExp() ); }
		| EQnum { $$ = MakeTree(LTOp, NullExp(), NullExp() ); }
		| NEnum { $$ = MakeTree(LTOp, NullExp(), NullExp() ); }
		| GEnum { $$ = MakeTree(LTOp, NullExp(), NullExp() ); }
		| GTnum { $$ = MakeTree(LTOp, NullExp(), NullExp() ); }
         ;

SimpleExpression : preTerm Term Term_rec
                   { $$ = MakeTree(AddOp, $3, $2); }
				 |  preTerm Term
                   { $$ = MakeTree(AddOp, NullExp(), $2); }
				 ;

preTerm : //epsilon
       | PLUSnum | MINUSnum
	   ;
	   
Term_rec :  preTermWithOr Term
		   { $$ = MakeTree(AddOp, NullExp(), $2); }
		 | preTermWithOr Term Term_rec
           { $$ = MakeTree(AddOp, $3, $2); }
		 ;

preTermWithOr : PLUSnum | MINUSnum | ORnum
	          ;
			  
Term : Factor
       { $$ = MakeTree(UnaryNegOp, $1, NullExp() ); }
     | Factor preTermFactor Term
       { $$ = MakeTree(UnaryNegOp, $1, $3 ); }
	 ;
	 
preTermFactor : TIMESnum | DIVIDEnum | ANDnum
              ;
			  
Factor : UnsignedConstant;

UnsignedConstant: ICONSTnum
				  { $$ = MakeLeaf(NUMNode, $1 ); }
				 ;
%%

int yycolumn, yyline;

FILE *treelst;

main()
{
  treelst = stdout;
  yyparse();
}

yyerror(char *str)
{
  printf("yyerror: %s at line %d\n", str, yyline);
}

#include "lex.yy.c"

