%{
#include <stdio.h>
#include "proj2.h"
#include "proj3.h"

	
extern tree ptype;
extern tree mtype;
int yydebug=1;
%}

//%union
//{
//  int intg;
//  tree tptr;
//} 



%token ANDnum			257
%token ASSGNnum			258
%token DECLARATIONSnum		259
%token DOTnum			260
%token ENDDECLARATIONSnum	261
%token EQUALnum			262
%token GTnum			263
%token <intg> IDnum		264
%token INTnum			265
%token LBRACnum			266
%token LPARENnum		267
%token METHODnum		268
%token NEnum			269
%token ORnum			270
%token PROGRAMnum		271
%token RBRACnum			272
%token RPARENnum		273
%token SEMInum			274
%token VALnum			275
%token WHILEnum			276
%token CLASSnum			277
%token COMMAnum			278
%token DIVIDEnum		279
%token ELSEnum			280
%token EQnum			281
%token GEnum			282
%token <intg> ICONSTnum		283
%token IFnum			284
%token LBRACEnum		285
%token LEnum			286
%token LTnum			287
%token MINUSnum			288
%token NOTnum			289
%token PLUSnum			290
%token RBRACEnum		291
%token RETURNnum		292
%token <intg> SCONSTnum		293
%token TIMESnum			294
%token VOIDnum			295
%token EOFnum			0

%type <tptr> startsym 
%type  <tptr> ClassDecl
%type  <tptr> ClassBody
%type  <tptr> Decls
%type  <tptr> MethodDecl
%type  <tptr> FieldDecl
%type  <tptr> Type
%type  <tptr> VariableDeclId
%type  <tptr> VariableInitializer
%type  <tptr> VariableInitializerSub
%type  <tptr> Expression
%type  <tptr> SupExpression
%type  <tptr> ArrayInitializer
%type  <tptr> ArrayCreationExpression
%type  <tptr> FormalParameterList
%type  <tptr> Block
%type  <tptr> StatementList
%type  <tptr> Statement
%type  <tptr> AssignmentStatement
%type  <tptr> MethodCallStatement
%type  <tptr> ReturnStatement
%type  <tptr> IfStatement
%type  <tptr> WhileStatement
%type  <tptr> Variable
%type  <tptr> SimpleExpression
%type  <tptr> Term
%type  <tptr> Factor
%type  <tptr> UnsignedConstant


%type  <tptr> VIDExpr
%type  <tptr> RIDExpr

%type  <tptr> PreType
%type  <tptr> Brackets
%type  <tptr> Statements
%type  <tptr> Exprs
%type  <tptr> IfSuffix
%type  <tptr> ElseIfStatement
%type  <tptr> NegPosSign
%type  <tptr> OpOnTerms
%type  <tptr> Ops
%type  <tptr> MethodDeclBody
%type  <tptr> FieldDeclBody
%type  <tptr> FieldDeclBodySub
//%type  <tptr> VariableDeclIdSub
%type  <tptr> FormalParameterListSub
%type  <tptr> VarExprs
%type  <tptr> TermBody
%type  <tptr> ValBody



%%

startsym
			: 	PROGRAMnum IDnum SEMInum ClassDecl	 
				{
					$$ = MakeTree (ProgramOp, $4, MakeLeaf (IDNode, $2));
					treeptr = $$;
					

				}
;

ClassDecl
			:	CLASSnum IDnum ClassBody 
				{
					$$ = MakeTree (ClassOp, NullExp (), MakeTree (ClassDefOp, $3, MakeLeaf(IDNode, $2)));
				}
			|	ClassDecl CLASSnum IDnum ClassBody  
				{
					$$ = MakeTree (ClassOp, $1, MakeTree (ClassDefOp, $4, MakeLeaf(IDNode, $3)));
				}
;

ClassBody
			:	LBRACEnum Decls RBRACEnum 
				{
					//$$ = MakeTree (BodyOp, $2, NullExp ());
					$$ = $2;

				}
			| 	LBRACEnum MethodDecl RBRACEnum
				{
					//$$ = MakeTree (BodyOp, NullExp (), $2);
					$$ = $2;

				}
			| 	LBRACEnum Decls MethodDecl RBRACEnum
				{
					//$$ = MakeTree (BodyOp, $2, $3);
					$$ = MkLeftC ($2, $3);
				}
			| 	LBRACEnum RBRACEnum
				{

					$$ = NullExp ();
				}
;

Decls
			:	DECLARATIONSnum FieldDecl ENDDECLARATIONSnum
				{
					$$ = $2;
					//printf ("test ---------------------\n");
				}
			|	DECLARATIONSnum ENDDECLARATIONSnum
				{
					$$ = MakeTree (BodyOp, NullExp (), NullExp ());
					//printf ("test ---------------------\n");
					//$$ = NullExp ();
				}
;

FieldDecl
			:	FieldDeclBody
				{
					//$$ = $1;
					$$ = MakeTree (BodyOp, NullExp (), $1);
				}
			|	FieldDecl FieldDeclBody
				{
					$$ = MakeTree (BodyOp, $1, $2 );
					//printf ("test ---------------------\n");
				}
;

FieldDeclBody   
			:	Type 
				{
					ptype = $1;
				}
				FieldDeclBodySub SEMInum
				{
					
					$$ = $3;
				}
;


FieldDeclBodySub
			:	VariableDeclId EQUALnum VariableInitializer
				{
					tree tmp = MakeTree (CommaOp, $1, MakeTree (CommaOp, ptype, $3));
					$$ = MakeTree (DeclOp, NullExp (), tmp);
				}	
			|	VariableDeclId 
				{
					tree tmp = MakeTree (CommaOp, $1, MakeTree (CommaOp, ptype, NullExp ()));
					$$ = MakeTree (DeclOp, NullExp (), tmp);
				}
			|	FieldDeclBodySub COMMAnum VariableDeclId EQUALnum VariableInitializer
				{
					tree tmp = MakeTree (CommaOp, $3, MakeTree (CommaOp, ptype, $5));
					$$ = MakeTree (DeclOp, $1, tmp);
				}
			|	FieldDeclBodySub COMMAnum VariableDeclId
				{
					tree tmp = MakeTree (CommaOp, $3, MakeTree (CommaOp, ptype, NullExp ()));
					$$ = MakeTree (DeclOp, $1, tmp);
				}
;




VariableDeclId
			:	IDnum 
				{
					$$ = MakeLeaf (IDNode, $1);
				}
			|	IDnum Brackets 
				{
					$$ = MakeLeaf (IDNode, $1);
				}
;


//VariableDeclIdSub
//			:	LBRACnum RBRACnum
//				{
//					$$ = NullExp ();
//				}
//			|	VariableDeclIdSub LBRACnum RBRACnum
//				{
//					$$ = $1;
//				}
//;




VariableInitializer
			:	Expression
				{
					$$ = $1;
				}
			|	ArrayInitializer
				{
					$$ = $1;
				}
			|	ArrayCreationExpression
				{
					$$ = $1;
				}
;


ArrayInitializer
			:	LBRACEnum VariableInitializerSub RBRACEnum
				{
					$$ = MakeTree (ArrayTypeOp, $2, ptype);
				}
;

VariableInitializerSub
			:	VariableInitializer
				{
					$$ = MakeTree (CommaOp, NullExp (), $1); 
				}
			|	VariableInitializerSub COMMAnum VariableInitializer
				{
					$$ = MakeTree (CommaOp, $1, $3);
				}
;

 
ArrayCreationExpression
			:	INTnum SupExpression
				{
					$$ = MakeTree (ArrayTypeOp, $2, MakeLeaf(INTEGERTNode, INTnum)); 
				}
;


SupExpression
			:	LBRACnum Expression RBRACnum
				{
					$$ = MakeTree (BoundOp, NullExp (), $2); 
				}
			|	SupExpression LBRACnum Expression RBRACnum
				{
					$$ = MakeTree (BoundOp, $1, $3); 
				}
;


MethodDecl
			:	MethodDeclBody
				{
					//printf ("debug-----------------------------\n");
					//$$ = $1;
					$$ = MakeTree (BodyOp, NullExp (), $1);

				}
			|	MethodDecl MethodDeclBody
				{
					$$ = MakeTree (BodyOp, $1, $2);

				}
;

MethodDeclBody
			:	METHODnum Type IDnum LPARENnum 
				{
					mtype = $2;
				}
				FormalParameterList RPARENnum Block
				{
					
					tree idnode = MakeLeaf (IDNode, $3);
					$$ = MakeTree (MethodOp, MakeTree (HeadOp, idnode, $6), $8);
				}
			|	METHODnum VOIDnum IDnum LPARENnum 
				{
					mtype = NullExp ();
				}
				FormalParameterList RPARENnum Block
				{
					tree idnode = MakeLeaf (IDNode, $3);
					
					$$ = MakeTree (MethodOp, MakeTree (HeadOp, idnode, $6), $8);


				}
			|	METHODnum Type IDnum LPARENnum  RPARENnum Block
				{
					mtype = $2;
					tree idnode = MakeLeaf (IDNode, $3);
					
					tree nullparalist = MakeTree (SpecOp, NullExp (), mtype);
					$$ = MakeTree (MethodOp, MakeTree (HeadOp, idnode, nullparalist), $6);
				}
			|	METHODnum VOIDnum IDnum LPARENnum RPARENnum Block
				{
					mtype = NullExp ();
			
					tree idnode = MakeLeaf (IDNode, $3);
					
					tree nullparalist = MakeTree (SpecOp, NullExp (), NullExp ());
					$$ = MakeTree (MethodOp, MakeTree (HeadOp, idnode, nullparalist), $6);
				}
;	



FormalParameterList
				:	FormalParameterListSub
					{
						$$ = MakeTree (SpecOp, $1, mtype); 
					}
;




FormalParameterListSub
			:	VALnum INTnum VIDExpr
				{
					$$ = $3; 
				}
			|	INTnum RIDExpr
				{
					$$ = $2; 
				}
			|	FormalParameterListSub SEMInum VALnum INTnum VIDExpr
				{
					$$ = MkRightC ($5, $1); 
				}
			|	FormalParameterListSub SEMInum INTnum RIDExpr
				{
					$$ = MkRightC ($4, $1); 
				}
;




VIDExpr
			:	IDnum
				{
					tree tleaf= MakeLeaf (IDNode, $1);
					tree intleaf = MakeLeaf (INTEGERTNode, INTnum);
					$$ = MakeTree (VArgTypeOp, MakeTree(CommaOp, tleaf, intleaf), NullExp ());
				}
			|	VIDExpr COMMAnum IDnum
				{
					tree tleaf= MakeLeaf (IDNode, $3);
					tree intleaf = MakeLeaf (INTEGERTNode, INTnum);
					$$ = MakeTree (VArgTypeOp, MakeTree(CommaOp, tleaf, intleaf), $1);
				}
;

RIDExpr
			:	IDnum
				{
					tree tleaf= MakeLeaf (IDNode, $1);
					tree intleaf = MakeLeaf (INTEGERTNode, INTnum);
					$$ = MakeTree (RArgTypeOp, MakeTree(CommaOp, tleaf, intleaf), NullExp ());
				}
			|	RIDExpr COMMAnum IDnum
				{
					tree tleaf= MakeLeaf (IDNode, $3);
					tree intleaf = MakeLeaf (INTEGERTNode, INTnum);
					$$ = MakeTree (RArgTypeOp, MakeTree(CommaOp, tleaf, intleaf), $1);
				}
;



Block
			:	Decls StatementList
				{
					$$ = MakeTree (BodyOp, $1, $2); 
				}
			|	StatementList
				{
					$$ = MakeTree (BodyOp, NullExp (), $1); 
				}
;


Type 
			:	PreType
				{
					//tree tmp = MakeTree (IndexOp, NullExp (), NullExp ());
					$$ = MakeTree (TypeIdOp, $1, NullExp ());
				}
			|	PreType Brackets
				{
					$$ = MakeTree (TypeIdOp, $1, $2);
				}
			|	Type DOTnum PreType Brackets 
				{
					//tree tmp = MakeTree (IndexOp, NullExp (), $1);
					tree tmp = MakeTree (TypeIdOp, $3, $4);
					$$ = MkRightC (tmp, $1);
				}
;

PreType
			:	IDnum
				{
					$$ = MakeLeaf (IDNode, $1);
				}
			|	INTnum
				{
					$$ = MakeLeaf (INTEGERTNode, INTnum);
				}
;

Brackets
			:	LBRACnum RBRACnum
				{
					$$ = MakeTree (IndexOp, NullExp (), NullExp ());
				}
				
			|	Brackets LBRACnum RBRACnum
				{
					$$ = MakeTree (IndexOp, NullExp (), $1);
				}
;

StatementList
			:	LBRACEnum Statements RBRACEnum
				{
					$$ = $2;
				}
;

Statements
			:	Statement
				{
					$$ = MakeTree (StmtOp, NullExp (), $1); 
				}
			|	Statements SEMInum Statement
				{
					if (IsNull ($3))
					{
						$$ = $1;
					}
					else
						$$ = MakeTree (StmtOp, $1, $3);
				}	
;


Statement
			:	AssignmentStatement
				{
					$$ = $1;
				}
			|	MethodCallStatement
				{
					$$ = $1;
				}
			|	ReturnStatement
				{
					$$ = $1;
				}
			|	IfStatement
				{
					$$ = $1;
				}
			|	WhileStatement
				{
					$$ = $1;
				}
			|
				{
					$$ = NullExp ();
				}
;


AssignmentStatement
			:	Variable ASSGNnum Expression
				{
					$$ = MakeTree (AssignOp, MakeTree (AssignOp, NullExp (), $1), $3);
				}
;


MethodCallStatement
			:	Variable LPARENnum RPARENnum
				{
					$$ = MakeTree (RoutineCallOp, $1, NullExp ()); 
				}
			|	Variable LPARENnum Exprs RPARENnum
				{
					$$ = MakeTree (RoutineCallOp, $1, $3); 
				}

Exprs
			:	Expression
				{
					$$ = MakeTree (CommaOp, $1, NullExp ()); 
				}
			|	Exprs COMMAnum Expression
				{
					tree tmp = MakeTree (CommaOp, $3, NullExp ());
					$$ = MkRightC (tmp, $1); 
				}
;


ReturnStatement
			:	RETURNnum 
				{
					$$ = MakeTree (ReturnOp, NullExp (), NullExp ()); 
				}
			|	RETURNnum Expression
				{
					$$ = MakeTree (ReturnOp, $2, NullExp ()); 
				}
;


IfStatement
			:	IFnum Expression StatementList IfSuffix
				{
					//tree tmp = MakeTree (CommaOp, $2, $3);
					//$$ = MakeTree (IfElseOp, $4, tmp); 

					tree tmp1 = MakeTree (CommaOp, $2, $3);
					tree tmp2 = MakeTree (IfElseOp, NullExp (), tmp1); 
					if (IsNull ($4))
					{
						$$ = tmp2;
					}
					else
					{
						$$ = MkLeftC (tmp2, $4);
					}
				}
;


IfSuffix	:	ElseIfStatement
				{
					$$ = $1;
				}
			|	ELSEnum StatementList
				{
					//tree tmp = MakeTree (CommaOp, NullExp (), $2);
					//$$ = MakeTree (IfElseOp, NullExp (), tmp);

					$$ = MakeTree (IfElseOp, NullExp (), $2);
				}
			|
				{
					$$ = NullExp ();
				}
;


ElseIfStatement
			:	ELSEnum IFnum Expression StatementList
				{	
					tree tmp = MakeTree (CommaOp, $3, $4);
					$$ = MakeTree (IfElseOp, NullExp (), tmp);
				}
			|	ElseIfStatement ELSEnum IFnum Expression StatementList
				{
					tree tmp1 = MakeTree (CommaOp, $4, $5);
					tree tmp2 = MakeTree (IfElseOp, NullExp (), tmp1);
					//$$ = MakeTree (IfElseOp, $1, tmp);

					$$ = MkLeftC ($1, tmp2);
				}
;


WhileStatement
			:	WHILEnum Expression StatementList
				{
					$$ = MakeTree (LoopOp, $2, $3);
				}
;


Expression
			:	SimpleExpression
				{
					$$ = $1; 
				}
			|	SimpleExpression LTnum SimpleExpression
				{
					$$ = MakeTree (LTOp, $1, $3); 
				}
			|	SimpleExpression LEnum SimpleExpression
				{
					$$ = MakeTree (LEOp, $1, $3);
				}
			|	SimpleExpression EQnum SimpleExpression
				{
					$$ = MakeTree (EQOp, $1, $3);
				}
			|	SimpleExpression NEnum SimpleExpression
				{
					$$ = MakeTree (NEOp, $1, $3);
				}
			|	SimpleExpression GEnum SimpleExpression
				{
					$$ = MakeTree (GEOp, $1, $3);
				}
			|	SimpleExpression GTnum SimpleExpression
				{
					$$ = MakeTree (GTOp, $1, $3);
				}
			
;



SimpleExpression
			:	NegPosSign Term OpOnTerms
				{
					MkLeftC ($2, $3);
					if (IsNull ($1))
					{
						$$ = $3;
					}
					else
					{
						$$ = MkLeftC ($3, $1);
					}

				}
			|	NegPosSign Term
				{
					if (IsNull ($1))
					{
						$$ = $2;
					}
					else
					{
						$$ = MkLeftC ($2, $1);
					}
				}
				
; 


NegPosSign	
			:	PLUSnum
				{
					$$ = NullExp ();
				}
			|	MINUSnum
				{
					$$ = MakeTree (UnaryNegOp, NullExp (), NullExp ()); 
				}
			|	
				{
					$$ = NullExp ();
				}
;


OpOnTerms
			:	Ops	Term
				{
					$$ = MkRightC ($2, $1);
				}
			|	OpOnTerms Ops Term
				{
					MkLeftC ($1, $2);
					$$ = MkRightC ($3, $2);
				}
;



Ops
			:	PLUSnum
				{
					$$ = MakeTree (AddOp, NullExp (), NullExp () );
				}
			|	MINUSnum
				{
					$$ = MakeTree (SubOp, NullExp (), NullExp () );
				}
			|	ORnum
				{
					$$ = MakeTree (OrOp, NullExp (), NullExp () );
				}
;


Term
			:	Factor TermBody
				{
					$$ = MkLeftC ($1, $2);
				}
			|	Factor
				{
					$$ = $1;
				}
;

TermBody
			:	TIMESnum Factor
				{
					$$ = MakeTree (MultOp, NullExp (), $2);
				}
			|	DIVIDEnum Factor
				{
					$$ = MakeTree (DivOp, NullExp (), $2);
				}
			|	ANDnum Factor
				{
					$$ = MakeTree (AndOp, NullExp (), $2);
				}
			|	TermBody TIMESnum Factor
				{
					$$ = MakeTree (MultOp, $1, $3);
				}
			|	TermBody DIVIDEnum Factor
				{			
					$$ = MakeTree (DivOp, $1, $3);
				}
			|	TermBody ANDnum Factor
				{
					$$ = MakeTree (AndOp, $1, $3 );
				}
;

Factor
			:	UnsignedConstant
				{
					$$ = $1;
				}
			|	Variable
				{
					$$ = $1;
				}
			|	MethodCallStatement
				{
					$$ = $1;
				}
			|	LPARENnum Expression RPARENnum
				{
					$$ = $2;
				}
			|	NOTnum Factor
				{
					$$ = $2;
				}
;

 
UnsignedConstant
			:	ICONSTnum
				{
					$$ = MakeLeaf (NUMNode, $1);
				}
			|	SCONSTnum
				{
					$$ = MakeLeaf (STRINGNode, $1);
				}
;


Variable
			:	IDnum ValBody
				{
					$$ = MakeTree (VarOp, MakeLeaf (IDNode, $1), $2);
				}
			|	IDnum
				{
					$$ = MakeTree (VarOp, MakeLeaf (IDNode, $1), NullExp ());
				}
;

ValBody
			:	LBRACnum VarExprs RBRACnum
				{
					$$ = MakeTree (SelectOp, $2, NullExp ()); 
				}
			|	DOTnum IDnum
				{
					tree tmp = MakeTree (FieldOp, MakeLeaf(IDNode, $2), NullExp ());
					$$ = MakeTree (SelectOp, tmp, NullExp ()); 
				}
			| 	ValBody LBRACnum VarExprs RBRACnum
				{
					tree tmp = MakeTree (SelectOp, $3, NullExp ()); 
					$$ = MkRightC (tmp, $1);
				}
			|	ValBody DOTnum IDnum
				{
					tree tmp1 = MakeTree (FieldOp, MakeLeaf(IDNode, $3), NullExp ());
					tree tmp2 = MakeTree (SelectOp, tmp1, NullExp ());
					$$ = MkRightC ( tmp2, $1);  
				}

;

VarExprs
			:	Expression
				{
					$$ = MakeTree (IndexOp, $1, NullExp ()); 
				}
			|	VarExprs COMMAnum Expression
				{
					tree tmp = MakeTree (IndexOp, $3, NullExp ());
					$$ = MkRightC (tmp, $1); 
				}
;


%%

extern int yyline;
FILE *treelst;


tree ptype = NULL;
tree mtype = NULL;
tree treeptr = NULL;

int symbol_table_index = 0;
int nestLevel = 0;

//traverse the tree using the standard traversal
int traverseTree(tree nd2){
//	printf("inside the tree traverser\n");
	
	
	
	
	
	
	//part where the symbol/string table is built
	printf("Value inserted into string table\n");
	OpenBlock();
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	//part where the syntax tree is augmented
	
	
	/*
	//check to see if both the right and left nodes are Id nodes. if they are delete, replace and return
	if(NodeKind(RightChild(nd2)) == 200 && NodeKind(LeftChild(nd2)) == 200){
		
		//declare the symbol table indexes
		symbol_table_index = InsertEntry(RightChild(nd2));
		
		free( RightChild(nd2) ); // unlink IDNode
		SetRightChild(nd2, MakeLeaf( STNode, symbol_table_index) );
		
		//declare the symbol table indexes
		symbol_table_index = InsertEntry(LeftChild(nd2));
		
		free( LeftChild(nd2) ); // unlink IDNode
		SetRightChild(nd2, MakeLeaf( STNode ,  symbol_table_index) );
		
		
		
		return 0;
	}*/
	
	
	//if the node to the right is an id Replace it
	if(NodeKind(RightChild(nd2)) == 200){
	
		//declare the symbol table indexes
		symbol_table_index = InsertEntry(RightChild(nd2));
		
		SetAttr(symbol_table_index, NAME_ATTR, IntVal(RightChild(nd2)));
		SetAttr(symbol_table_index, NEST_ATTR, nestLevel);
		
		//	printf("RightChildHit\n");
		//replace the Id Node
		free( RightChild(nd2) ); // unlink IDNode
		//printtree(nd2,0);
		SetRightChild(nd2, MakeLeaf( STNode, symbol_table_index) );
		//printtree(nd2,0);
		
		//only make a left recursive call
		traverseTree(LeftChild(nd2));
		
		return 0;
		
	}	
	//if the node to the left is an id Replace it
	if(NodeKind(LeftChild(nd2)) == 200){
		//printf("LeftChildHit\n");
		//replace the Id Node
		
		//declare the symbol table indexes
		symbol_table_index = InsertEntry(LeftChild(nd2));
		
		SetAttr(symbol_table_index, NAME_ATTR, IntVal(LeftChild(nd2)));
		SetAttr(symbol_table_index, NEST_ATTR, nestLevel);
		
		free( LeftChild(nd2) ); // unlink IDNode
		SetLeftChild(nd2, MakeLeaf( STNode, symbol_table_index) );
		
		
		//only make a right recursive call
		traverseTree(RightChild(nd2));
		
		return 0;
		
	}	
	
	//check if nodeKind is EXPRNode and NodeOp is ProgramOp
	
	
	//for a dummy node return immediately
		if(NodeKind(nd2) == 204){
		return 0;
		
	}
	
	// if neither of the child nodes are Ids
	//make recursive calls in both directions
	
	traverseTree(LeftChild(nd2));
	traverseTree(RightChild(nd2));
	
	
	CloseBlock();
	
	return 0;
}

int main()
{
	treelst = stdout;
	yyparse();
	STInit();
	//traverse tree method
	traverseTree(treeptr);
	STPrint();
	printtree (treeptr, 0);
	return 0;
}

void yyerror(char *str)
{
	printf("yyerror: %s at line %d\n", str, yyline);
}

//#include "lex.yy.c"
