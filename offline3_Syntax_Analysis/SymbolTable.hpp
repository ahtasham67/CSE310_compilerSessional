#ifndef SYMBOLTABLE
#define SYMBOLTABLE

#pragma once
#include <iostream>
#include <string>
#include <vector> 

#include "ScopeTable.hpp"
#include "symbolInfo.hpp" 

class SymbolTable
{
    ScopeTable *currentTable;
    int num_buckets;
    int hashType; // Renamed 'type' to 'hashType' for clarity

public:
    SymbolTable(int n, int type = 0)
    {
        this->num_buckets = n;
        this->hashType = type;
        currentTable = new ScopeTable(hashType, num_buckets);
        cout << "\tScopeTable# " << currentTable->getTableID() << " created" << endl;
    }

    ~SymbolTable()
    {
        // This loop ensures all scopes are deleted from current down to global.
        while (currentTable != NULL)
        {
            ScopeTable *temp = currentTable;
            string id = temp->getTableID();
            currentTable = currentTable->parent_scope;
            delete temp;
            cout << "\tScopeTable# " << id << " removed" << endl;
        }
    }

    ScopeTable *get_current_scopetable() { return currentTable; }
    int getCurrentScopeID() { return currentTable->getTableID().length(); } // Returns length of ID string, may not be what you intend for ID.
                                                                           // If you want the integer ID, you might need to parse tableID or add a field to ScopeTable.

    void EnterScope()
    {
        ScopeTable *newScope = new ScopeTable(hashType, num_buckets, currentTable);
        currentTable = newScope;
        cout << "\tScopeTable# " << currentTable->getTableID() << " created" << endl;
    }

    void ExitScope()
    {
        if (currentTable == NULL)
        {
            // Already handled by destructor, but good for explicit calls
            return;
        }

        if (currentTable->getTableID() == "1") // Global scope
        {
            cout << "\tScopeTable# " << currentTable->getTableID() << " cannot be removed (Global Scope)" << endl;
            return;
        }

        ScopeTable *temp = currentTable;
        string id = temp->getTableID();
        currentTable = currentTable->parent_scope;
        delete temp; // This will call the destructor of ScopeTable and clean up its hash table.

        cout << "\tScopeTable# " << id << " removed" << endl;
    }

    // Overloaded Insert method for general symbols
    bool Insert(string name, string type, int line, ofstream &out)
    {
        if (currentTable == NULL) return false;
        SymbolInfo *newSym = new SymbolInfo(name, type, line);
        if (currentTable->insert(newSym)) {
            // out << "\tInserted " << name << " in ScopeTable# " << currentTable->getTableID() << endl;
            return true;
        } else {
            // Error handling for existing symbol in current scope
            SymbolInfo* existing = currentTable->LookUp(name);
            out << "\t< " << name << " : " << type << " > already exists in ScopeTable# "
                << currentTable->getTableID() << " at position "
                << currentTable->getHashIndex(name) + 1 << ", " // +1 for 1-based indexing
                << currentTable->getIndxInChain(name) + 1 << "\n"; // +1 for 1-based indexing
            // delete newSym; // Handled by ScopeTable::insert
            return false;
        }
    }

    // Overloaded Insert method for arrays
    bool Insert(string name, string baseType, bool isArray, int arraySize, int line, ofstream &out)
    {
        if (currentTable == NULL) return false;
        SymbolInfo *newSym = new SymbolInfo(name, baseType, isArray, arraySize, line);
        if (currentTable->insert(newSym)) {
            // out << "\tInserted array " << name << " in ScopeTable# " << currentTable->getTableID() << endl;
            return true;
        } else {
            // Error handling for existing symbol
            SymbolInfo* existing = currentTable->LookUp(name);
            out << "\t< " << name << " : ARRAY > already exists in ScopeTable# "
                << currentTable->getTableID() << " at position "
                << currentTable->getHashIndex(name) + 1 << ", "
                << currentTable->getIndxInChain(name) + 1 << "\n";
            return false;
        }
    }

    // Overloaded Insert method for functions
    bool Insert(string name, string type, bool isFunction, string returnType, const vector<string>& paramTypes, int line, ofstream &out)
    {
        if (currentTable == NULL) return false;
        SymbolInfo *newSym = new SymbolInfo(name, type, isFunction, returnType, paramTypes, line);
        if (currentTable->insert(newSym)) {
            // out << "\tInserted function " << name << " in ScopeTable# " << currentTable->getTableID() << endl;
            return true;
        } else {
            // Error handling for existing symbol
            SymbolInfo* existing = currentTable->LookUp(name);
            out << "\t< " << name << " : FUNCTION > already exists in ScopeTable# "
                << currentTable->getTableID() << " at position "
                << currentTable->getHashIndex(name) + 1 << ", "
                << currentTable->getIndxInChain(name) + 1 << "\n";
            return false;
        }
    }

    bool Remove(string name)
    {
        if (currentTable == NULL) return false;
        return currentTable->remove(name);
    }

    SymbolInfo *LookUp(string name, bool print = false)
    {
        ScopeTable *curr = currentTable;
        while (curr != NULL)
        {
            SymbolInfo *existing_entry = curr->LookUp(name, print);
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

    SymbolInfo *LookUpInCurrentScope(string name)
    {
        if (currentTable == NULL) return NULL;
        return currentTable->LookUp(name);
    }

    void PrintCurrentScopeTable(ofstream &out)
    {
        if (currentTable != NULL)
            currentTable->Print(out, 1);
        else
            out << "No scope table to print" << endl;
    }

    void PrintAllScopeTables(ofstream &out)
    {
        if (currentTable != NULL)
        {
            ScopeTable* temp = currentTable;
            vector<ScopeTable*> scopesToPrint;
            while(temp != NULL) {
                scopesToPrint.push_back(temp);
                temp = temp->parent_scope;
            }
            // Print from outermost (global) to innermost
            for (int i = scopesToPrint.size() - 1; i >= 0; --i) {
                scopesToPrint[i]->Print(out); // Level handled by ScopeTable::Print for now
            }
            out << endl;
        }
        else
        {
            out << "No scope table to print" << endl;
        }
    }
    // Changed ExitAllScope to only exit non-global scopes, as the global scope is removed by destructor
    // or when the program truly finishes.
    void ExitAllScope() {
        while (currentTable != NULL && currentTable->parent_scope != NULL) { // Stop before global scope
            ExitScope();
        }
    }
};

#endif