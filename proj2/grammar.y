%{   


//Eli Friedman and Daniel Nestor


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
%type  <tptr>  TypeDeclBrackets_rec TypeField ArrayDeclBrackets_rec VariableDecBody RArgType VArgType preType ValBody VarExprs AssignmentStatement preTermWithOr preTermFactor

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

ClassBody :  LBRACEnum Decls MethodDecl MethodDecl RBRACEnum 
			{ $$ = MakeTree( BodyOp, MakeTree(BodyOp, $2, $3), $4); }
          |
		    LBRACEnum MethodDecl RBRACEnum 
			{ $$ = MakeTree( BodyOp, NullExp(), $2); }
	
		  |	LBRACEnum RBRACEnum 
			{ $$ = MakeTree( BodyOp, NullExp(), NullExp()); }
	      |		
			LBRACEnum DeclsWithMethodDecl_rec MethodDecl RBRACEnum 
		  	{ $$ = MakeTree( BodyOp, $2, $3); } 
		  |		
			LBRACEnum DeclsWithMethodDecl_rec DeclsWithMethodDecl RBRACEnum 
		  	{ $$ = MakeTree( BodyOp, $2, $3); }
		  |
		    LBRACEnum Decls MethodDecl RBRACEnum 
		    { $$ = MakeTree( BodyOp, $2, $3); }
		  |
		    LBRACEnum Decls RBRACEnum 
			{ $$ = MakeTree( BodyOp, $2, NullExp()); }
		  
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
					|/* DeclsWithMethodDecl 
					   { $$ = MakeTree( BodyOp, $1, NullExp()); }
					| */ MethodDecl_rec MethodDecl
					   { $$ = MakeTree( BodyOp, $1, $2); }
					;
			
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

FieldDecl : 	      Type {x = $1;} VariableDecBody SEMInum
	                { $$ = MakeTree( DeclOp, NullExp(), $3); }
					;

VariableDecBody: VariableDeclId EQUALnum VariableInitializer
				  { $$ = MakeTree( DeclOp, NullExp(), MakeTree(CommaOp, $1, MakeTree(CommaOp, x, $3) ) ) ;}
				| VariableDeclId
				  { $$ = MakeTree( DeclOp, NullExp(), MakeTree(CommaOp, $1, MakeTree(CommaOp, x, NullExp() ) ) ) ;}
				| VariableDecBody COMMAnum VariableDeclId EQUALnum VariableInitializer
				  { $$ = MakeTree( DeclOp, $1, MakeTree(CommaOp, $3, MakeTree(CommaOp, x, $5 ) ) ) ;}
				| VariableDecBody COMMAnum VariableDeclId
				  { $$ = MakeTree( DeclOp, $1, MakeTree(CommaOp, $3, MakeTree(CommaOp, x, NullExp() ) ) ); }
				;
				
VariableDeclId :    IDnum ArrayDeclBrackets_rec
					{ $$ = MakeLeaf(IDNode, $1); }
				|	IDnum 
				  	{ $$ = MakeLeaf(IDNode, $1); }
				;

ArrayDeclBrackets_rec : LBRACnum RBRACnum
						{ $$ = MakeTree( IndexOp, NullExp(), NullExp() ); }
					  |  ArrayDeclBrackets_rec LBRACnum RBRACnum
					    { $$ = MakeTree( IndexOp, NullExp(), $1 ); }
					  ;
				  
VariableInitializer   : Expression
					//  ??	{ $$ = MakeLeaf(EXPRNode, $1); }
					  | ArrayInitializer
					  | ArrayCreationExpression
					  ;
				  
ArrayInitializer      :  LBRACEnum ArrayInitializer_head RBRACEnum
						 {$$ = $2;}
					  ;

ArrayInitializer_head : VariableInitializer_rec
						{ $$ = MakeTree(ArrayTypeOp, $1, x); }
					  ;

VariableInitializer_rec : | VariableInitializer_rec COMMAnum VariableInitializer
						  { $$ = MakeTree( CommaOp, $1, $3 ); }
						|  VariableInitializer
						  { $$ = MakeTree( CommaOp, NullExp(), $1 ); }
						
						;
						
ArrayCreationExpression : INTnum ArrayCreationBrackets_rec
						  { $$ = MakeTree( ArrayTypeOp, $2, MakeLeaf(INTEGERTNode, 0) ); }

ArrayCreationBrackets_rec : LBRACnum Expression RBRACnum
						    { $$ = MakeTree( BoundOp, NullExp(), $2 ); }
						  | ArrayCreationBrackets_rec LBRACnum Expression RBRACnum
						    { $$ = MakeTree( BoundOp, $1, $3 ); }
						  ;

MethodDecl : METHODnum Type {typeForMethodDecl = $2;} IDnum LPARENnum FormalParameterList RPARENnum Block
			 { $$ = MakeTree( MethodOp, MakeTree(HeadOp, MakeLeaf(IDNode, $4), $6 ), $8); }
		   |   METHODnum VOIDnum IDnum LPARENnum FormalParameterList RPARENnum Block
		     { $$ = MakeTree( MethodOp, MakeTree(HeadOp, MakeLeaf(IDNode, $3), $5 ), $7); }
		  |
            METHODnum Type {typeForMethodDecl = $2;} IDnum LPARENnum RPARENnum Block
		     { $$ = MakeTree(MethodOp, MakeTree(HeadOp, MakeLeaf(IDNode, $4), NullExp() ), $7 ); }
		   | METHODnum VOIDnum IDnum LPARENnum RPARENnum Block
		     { $$ = MakeTree(MethodOp, MakeTree(HeadOp, MakeLeaf(IDNode, $3), NullExp() ), $6 ); }
            ;
			
FormalParameterList :  FormalParameterList_rec 
						{ $$ = MakeTree(SpecOp, $1 , typeForMethodDecl ); }
                    ;
					
FormalParameterList_rec : INTnum RArgType
						  { $$ = $2;}
						| VALnum INTnum VArgType
						  { $$ = $3; }
						| FormalParameterList_rec SEMInum INTnum RArgType
					      { $$ = MkRightC($4, $1); }
						| FormalParameterList_rec SEMInum VALnum INTnum VArgType
						  { $$ = MkRightC($5, $1); }
						;

RArgType : IDnum
           { $$ = MakeTree(RArgTypeOp, MakeTree(CommaOp, MakeLeaf(IDNode, $1), MakeLeaf(INTEGERTNode, 0) ), NullExp()  ) ;}
		   | RArgType COMMAnum IDnum
		     { $$ = MakeTree(RArgTypeOp, MakeTree(CommaOp, MakeLeaf(IDNode, $3), MakeLeaf(INTEGERTNode, 0) ), $1  )  ;}
	      ;
		  
VArgType : IDnum
           { $$ = MakeTree(RArgTypeOp, MakeTree(CommaOp, MakeLeaf(IDNode, $1), MakeLeaf(INTEGERTNode, 0) ), NullExp()  )  ;}
		   | VArgType COMMAnum IDnum
		     { $$ = MakeTree(RArgTypeOp, MakeTree(CommaOp, MakeLeaf(IDNode, $3), MakeLeaf(INTEGERTNode, 0) ), $1  )  ;}
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
	 
preType : INTnum 
	   { $$ = MakeTree(TypeIdOp, MakeLeaf(INTEGERTNode, 0) , NullExp() ); }
	 | IDnum
       { $$ = MakeTree(TypeIdOp, MakeLeaf(IDNode, $1) , NullExp() ); }
     ;
	 
Type : preType 
       { $$ = MakeTree(TypeIdOp, $1 , NullExp() ); }
	 |  preType TypeDeclBrackets_rec
	    { $$ = MakeTree(TypeIdOp, $1 , $2 ); }
	 | Type DOTnum preType TypeDeclBrackets_rec
	   { tree t = MakeTree(TypeIdOp, $3 , $4 ); $$ = MkRightC(t, $1); }
	   ;
	 
TypeDeclBrackets_rec : LBRACnum RBRACnum
						{ $$ = MakeTree( IndexOp, NullExp(), NullExp() ); }
					  |  TypeDeclBrackets_rec LBRACnum RBRACnum
					    { $$ = MakeTree( IndexOp, NullExp(), $1 ); }
					  ;
					 
TypeField : //epsilon
            { $$ = NullExp(); }
		  | DOTnum Type
		    { $$ = MakeTree(FieldOp, $2, NullExp()); }
		  ;
	 
StatementList : LBRACEnum Statement_rec RBRACEnum
				{$$ = $2;}
			  ;
		  
Statement_rec : Statement 
			    { $$ = MakeTree(StmtOp, NullExp(), $1); }
			  | Statement_rec Statement
			    { $$ = MakeTree(StmtOp, $1, $2); }
			  ;
			  
Statement: //epsilon 
             {$$ = NullExp();}
		   | ReturnStatement SEMInum
		   | MethodCallStatement SEMInum
		   | AssignmentStatement SEMInum
		   | WhileStatement SEMInum
		   | IfStatement SEMInum
		 ;

IfStatement: IFnum Expression StatementList{$$ = MakeTree(IfElseOp,NullExp(),$3);}
			| IFnum Expression StatementList ELSEnum IfStatement{$$ = MakeTree(IfElseOp,$5,MakeTree(CommaOp, $2,$3));}
			| IFnum Expression StatementList ELSEnum StatementList{$$ = MakeTree(IfElseOp,NullExp(),MakeTree(CommaOp, $2,$3));}


;

AssignmentStatement: Variable ASSGNnum Expression{$$ = MakeTree(AssignOp,MakeTree(AssignOp,NullExp(),$1),$3);}
                   ;		 

ReturnStatement : RETURNnum 
				  { $$ = MakeTree(ReturnOp, NullExp(), NullExp() ); }
				| RETURNnum Expression
		          { $$ = MakeTree(ReturnOp, $2, NullExp() ); }
				;
				
WhileStatement : WHILEnum LPARENnum Expression RPARENnum StatementList
				 { $$ = MakeTree(LoopOp, $3, $5); }
               ;
			
Expression : SimpleExpression //{$$ = $1; }
 | SimpleExpression Comp_op SimpleExpression
    { MkLeftC($1, $2); $$ = MkRightC($3, $2); }
  ;
   
Comp_op : LTnum { $$ = MakeTree(LTOp, NullExp(), NullExp() ); }
		| LEnum { $$ = MakeTree(LEOp, NullExp(), NullExp() ); }
		| EQnum { $$ = MakeTree(EQOp, NullExp(), NullExp() ); }
		| NEnum { $$ = MakeTree(NEOp, NullExp(), NullExp() ); }
		| GEnum { $$ = MakeTree(GEOp, NullExp(), NullExp() ); }
		| GTnum { $$ = MakeTree(GTOp, NullExp(), NullExp() ); }
         ;

SimpleExpression :   preTerm Term
                   { $$ = MakeTree(AddOp, NullExp(), $2); }
				 | preTerm Term preTermWithOr Term
				   //{ $$ = MakeTree(AddOp, $4, $2); }
				    { MkLeftC($2, $3); $$ = MkRightC($4, $3);}
				 | preTerm Term Term_rec
                   { $$ = MakeTree(AddOp, $3, $2); }
				 ;

preTerm : //epsilon
       | PLUSnum | MINUSnum
	   ;
	   
Term_rec :  preTermWithOr Term
		//   { $$ = MakeTree(AddOp, NullExp(), $2); }
		   { $$ = MkRightC($2, $1);}
		 | preTermWithOr Term Term_rec
           { $$ = MakeTree(AddOp, $3, $2); }
		 ;

preTermWithOr : PLUSnum 
                { $$ = MakeTree(AddOp, NullExp(), NullExp()); }
			  | MINUSnum 
			    { $$ = MakeTree(SubOp, NullExp(), NullExp()); }
			  | ORnum  
			    { $$ = MakeTree(OrOp, NullExp(), NullExp()); }
	          ;
			  
Term : Factor
       { $$ = MakeTree(UnaryNegOp, $1, NullExp() ); }
     | Factor preTermFactor Factor
       { MkLeftC($1, $2); $$ = MkRightC($3, $2);}
	  | Factor preTermFactor Term
       { $$ = MakeTree(UnaryNegOp, $1, $3 ); }
	 ;
	 
preTermFactor : //TIMESnum | DIVIDEnum | ANDnum
			  //  { $$ = MakeTree(UnaryNegOp, $1, NullExp() ); }
			  |	TIMESnum 
                { $$ = MakeTree(AddOp, NullExp(), NullExp()); }
			  | DIVIDEnum 
			    { $$ = MakeTree(SubOp, NullExp(), NullExp()); }
			  | ANDnum  
			    { $$ = MakeTree(OrOp, NullExp(), NullExp()); }
	          ;
              ;
			  
Factor : UnsignedConstant //{$$ = $1;}
       | Variable
	   | MethodCallStatement
	   | LPARENnum Expression RPARENnum
	   | NOTnum Factor
       ;

UnsignedConstant: ICONSTnum
				  { $$ = MakeLeaf(NUMNode, $1 ); }
				| SCONSTnum
				  { $$ = MakeLeaf(STRINGNode, $1 ); }
				  ;
		  
Variable : IDnum ValBody
           { $$ = MakeTree(VarOp, MakeLeaf(IDNode, $1 ), $2 ); }
		 | IDnum 
		   { $$ = MakeTree(VarOp, MakeLeaf(IDNode, $1 ), NullExp() ); }
		  ;


ValBody : LBRACnum VarExprs RBRACnum
          { $$ = MakeTree(SelectOp, $2, NullExp() ); } 
		| DOTnum IDnum
		  { $$ = MakeTree(SelectOp, MakeTree(FieldOp, MakeLeaf(IDNode, $2 ) , NullExp() ) , NullExp() ); }
		| ValBody LBRACnum VarExprs RBRACnum
          { tree t = MakeTree(SelectOp, $3, NullExp() ); $$ = MkRightC(t, $1) ; }
		| ValBody DOTnum IDnum
		  { tree t = MakeTree(SelectOp, MakeTree(FieldOp, MakeLeaf(IDNode, $3 ) , NullExp() ), NullExp() ); $$ = MkRightC(t, $1); }
		;

VarExprs : Expression
            { $$ = MakeTree(IndexOp, $1, NullExp() ); } 
		  | VarExprs COMMAnum Expression
		    { tree t = MakeTree(IndexOp, $3, NullExp() ); $$ = MkRightC(t, $1) ; }
;

//method call statement
MethodCallStatement: Variable LPARENnum RPARENnum
                     { $$ = MakeTree(RoutineCallOp, $1, NullExp() ) ;}
				   | Variable LPARENnum Expression_rec2 RPARENnum
				     {$$ = MakeTree(RoutineCallOp,$1,$3);} 
                   ;

Expression_rec2: Expression COMMAnum Expression_rec2
                 {$$ = MakeTree(CommaOp,$1,$3);}
               | Expression
			     {$$ = MakeTree(CommaOp,$1,NullExp());}
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

