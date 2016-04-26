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
		
		SetAttr(symbol_table_index, NAME_ATTR, IntVal(nd));
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
	//if the node to the right is an id Replace it
	
		
		if(NodeKind(LeftChild(nd2)) == 200){
		//printf("LeftChildHit\n");
		//replace the Id Node
		
		//declare the symbol table indexes
		symbol_table_index = InsertEntry(LeftChild(nd2));
		
		SetAttr(symbol_table_index, NAME_ATTR, IntVal(nd));
		SetAttr(symbol_table_index, NEST_ATTR, nestLevel);
		
		free( LeftChild(nd2) ); // unlink IDNode
		SetRightChild(nd2, MakeLeaf( STNode, symbol_table_index) );
		
		
		//only make a right recursive call
		traverseTree(RightChild(nd2));
		
		return 0;
		
	}	
	
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