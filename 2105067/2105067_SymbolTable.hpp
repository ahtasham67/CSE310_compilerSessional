#ifndef SYMBOLTABLE
#define SYMBOLTABLE

#include "2105067_ScopeTable.hpp"

#include <iostream>
#include <string>

// SymbolTable: This class implements a list of scope tables. As a member variable, this
// class should have a pointer to an object of the ScopeTable class which indicates the
// current scope table. Also, you have to implement the following functionalities for this
// class:
// • Enter Scope: Create a new scope table and make it the current one. Also, make
// the previous “current” scope table as its parent_scope table.
// • Exit Scope: Remove the current scope table.
// • Insert: Insert a symbol in the current scopetable. This method will return a boolean
// value indicating whether the insertion is successful.
// • Remove: Remove a symbol from the current scope table. This method will return
// a boolean value indicating whether the removal is successful.

class SymbolTable
{
	ScopeTable *currentTable;
	int num_buckets;
	int type;

public:
	SymbolTable(int type, int n)
	{	
		this->num_buckets = n;
		this->type = type;
		//increment the table count
		ScopeTable::tableCount++;
		currentTable = new ScopeTable(type,num_buckets);
		cout << "\tScopeTable# " << currentTable->getTableID() << " created" << endl;
	}

	~SymbolTable()
	{
		// while (currentTable != NULL)
		// {
		// 	ScopeTable *temp = currentTable;
		// 	currentTable = currentTable->parent_scope;
		// 	delete temp;
		// 	temp = NULL;
		// }
		//cout<<"working here bosssssssssssssssssssss"<<endl;
		delete currentTable;
		currentTable = NULL;
	}

	ScopeTable *get_current_scopetable()
	{
		return currentTable;
	}

	void EnterScope()
	{
		if (currentTable != NULL)
			currentTable->incrementChildCnt();
			ScopeTable::tableCount++;
		currentTable = new ScopeTable(type, num_buckets, currentTable);
		//currentTable = newTable;
		cout << "\tScopeTable# " << currentTable->getTableID() << " created" << endl;
		// delete newTable;
		// newTable = NULL;
	}
	void ExitScope()
	{
		if (currentTable == NULL)
		{
			cout << "No scope table to exit" << endl;
			return;
		}

		if (currentTable->parent_scope == NULL)
		{
			cout << "\tScopeTable# " << currentTable->getTableID() << " cannot be removed (Global Scope)" << endl;
			return;
		}

		ScopeTable *temp = currentTable;
		int id = temp->getTableID();
		currentTable = currentTable->parent_scope;
		delete temp;
		cout << "\tScopeTable# " << id << " removed" << endl;
	}

	bool Insert(string name, string type)
	{
		if (currentTable == NULL)
		{
			// cout << "No scope table to insert" << endl;
			return false;
		}
		else
		{

			bool result = currentTable->insert(name, type);
			if (result)
			{
				// cout << "\t" << name << " inserted in current scope table" << endl;

				return true;
			}
			else{
				return false;
			}
		}
	}

	bool Remove(string name)
	{
		if (currentTable == NULL)
		{
			cout << "No scope table to remove" << endl;
			return false;
		}
		else
		{
			bool result = currentTable->remove(name);
			if (result)
			{
				//cout << "\t" << name << " removed from current scope table" << endl;
				
				return true;
			}
			else{
				//cout<<"Not found in the current ScopeTable"<<endl;
				return false;
			}
		}
	}

	// • Look Up: Search a symbol in the symbol table. First, search the current scope
	// table. If the symbol is not in the current one, then search its parent scope table
	// and so on. This method will return a pointer to the object of the SymbolInfo class
	// representing the looked up symbol.

	SymbolInfo* lookup(string name, bool print = false)
{
    ScopeTable* curr = currentTable;
    while (curr != NULL)
    {
        SymbolInfo* existing_entry = curr->LookUp(name, print);
        if (existing_entry != NULL)
        {
            return existing_entry;
        }
        curr = curr->parent_scope;
    }

    if (print)
        cout << "\t'" << name << "' not found in any of the ScopeTables" << endl;

    return NULL;
}

	// • Print Current Scope Table: Print the current scope table.
	// • Print All Scope Table: Print all the scope tables currently in the symbol table.
	void PrintCurrentScopeTable()
	{
		if (currentTable != NULL)
			currentTable->Print(1);
		else
			cout << "No scope table to print" << endl;
	}

	void PrintScopeRecursive(ScopeTable* scope, int level)
{
    if (scope == NULL)
        return;

		scope->Print(level);
    PrintScopeRecursive(scope->parent_scope, level + 1);
   
}

	

	void PrintAllScopeTables()
{
    if (currentTable != NULL)
    {
        PrintScopeRecursive(currentTable, 1);
    }
    else
    {
        cout << "No scope table to print" << endl;
    }
}

	void ExitAllScope(){
		while (currentTable -> parent_scope != NULL)
		{
			ExitScope();
		}
		delete currentTable;
		currentTable = NULL;
		//cout << "All scope tables exited" << endl;
		cout << "\tScopeTable# " << 1 << " removed" << endl;
	}
};

#endif