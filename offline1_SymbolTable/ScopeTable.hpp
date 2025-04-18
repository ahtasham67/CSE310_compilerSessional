#ifndef SCOPETABLE_HPP
#define SCOPETABLE_HPP

#include "hash.hpp"
#include "symbolInfo.hpp"

#include <iostream>
#include <string>
using namespace std;

/*Thisclassimplementsahashtable. You may need an array for the pointers
of SymbolInfo type and a hash function. The hash function will determine the corre-
sponding bucket number an object of the SymbolInfo class will go into.*/

/*• Insert: Insert the symbol into the current scope table if already not inserted. This
method will return a boolean value indicating whether the scope table insertion to
the symbol table is successful.
• Look Up: Search the hash table for a particular symbol. This method will return a
SymbolInfo type pointer corresponding to the looked up symbol.
• Delete: Delete an entry from the current scope table. This method will return a
boolean value indicating whether the deletion is successful.
• Print: Print the scope table in the console.
• Constructor: You have to write a constructor method that takes as input an integer
n and allocates n buckets in the corresponding hash table.
• Destructor: You also have to write a destructor method to deallocate memory.*/
class ScopeTable
{
private:
    int num_buckets, childCnt;
    string tableID;
    SymbolInfo **hashTable;

public:
    ScopeTable *parent_scope;

    ScopeTable(int n, ScopeTable *parent_scope = NULL)
    {
        this->childCnt = 0;
        if (parent_scope == NULL)
        {
            this->tableID = 1;
        }
        else
        {
            this->tableID = parent_scope->tableID + "." + to_string(++parent_scope->childCnt);
        }
        this->parent_scope = parent_scope;
        num_buckets = n;
        hashTable = new SymbolInfo *[num_buckets];

        for (int i = 0; i < num_buckets; i++)
        {
            hashTable[i] = NULL;
        }
    }

    ~ScopeTable()
    {
        for (int i = 0; i < num_buckets; i++)
        {
            if (hashTable[i] != NULL)
                delete hashTable[i];
        }
        delete hashTable;
        cout << "destructor called for id= " << tableID << " " << endl;
        if (parent_scope != NULL)
            delete parent_scope;
    }

    int getHashIndex(string name)
    {
        uint64_t hash = hashFunc ::getSDBMHash(name);
        int index = hash % num_buckets;
        return index;
    }

    int getIndxInChain(string name)
    {
        int atIndex = -1;
        int index = getHashIndex(name);
        SymbolInfo *curr = hashTable[index];
        int i = 0;
        while (curr != NULL)
        {
            if (curr->getName() == name)
            {
                atIndex = i;
                return atIndex;
            }
            curr = curr->nextPtr;
            i++;
        }
        return atIndex;
    }

    string getTableID()
    {
        return tableID;
    }
    int getChildcnt()
    {
        return childCnt;
    }
    void incrementChildCnt()
    {
        childCnt++;
    }

    SymbolInfo *LookUp(string name)
    {
        int indx = getIndxInChain(name);
        SymbolInfo *curr = hashTable[indx];

        int indxInChain = 0;
        while (curr != NULL)
        {
            if (curr->getName() == name)
            {
                cout << name << " found at position " << indxInChain + 1 << "of scopetable " << tableID << endl;
                return curr;
            }
            curr = curr->nextPtr;
            indxInChain++;
        }
        return NULL;
    }

    bool insert(string name, string type)
    {
        SymbolInfo *foundentry = LookUp(name);
        if (foundentry == NULL)
        {
            int indx = getHashIndex(name);
            SymbolInfo *newSymbol = new SymbolInfo(name, type, NULL);
            SymbolInfo *curr = hashTable[indx];
            int indexInChain = 0;
            if (curr == NULL)
            {
                hashTable[indx] = newSymbol;
            }
            else
            {
                indexInChain = 1;
                while (curr->nextPtr != NULL)
                {
                    curr = curr->nextPtr;
                    indexInChain++;
                }
                curr->nextPtr = newSymbol;
            }
            cout << name << " inserted at position " << indx + 1 << " in " << indexInChain + 1 << " of scopeTable " << tableID << endl;
            return true;
        }
        else
            return false;
    }

    bool remove(string name, string type)
    {
        SymbolInfo *entry = LookUp(name);
        if (entry != NULL)
        {
            int indx = getHashIndex(name);
            SymbolInfo *curr = hashTable[indx];
            SymbolInfo *temp; // node to be deleted
            int indexInChain = 0;
            if (curr == entry)
            {
                hashTable[indx] = curr->nextPtr;
                temp = curr;
            }
            else
            {
                indexInChain = 1;
                while (curr->nextPtr != entry)
                {
                    curr = curr->nextPtr;
                    indexInChain++;
                }
                temp = curr->nextPtr;
                curr->nextPtr = curr->nextPtr->nextPtr;
            }
            temp->nextPtr = NULL;
            delete temp;
            cout << name << " deleted from position " << indx + 1 << " at " << indexInChain + 1 << " of the scopetable of id " << tableID << endl;
            return true;
        }
        else
            return false;
    }

    void Print()
    {
        cout << endl;
        cout << "ScopeTable# " << tableID << endl;
        for (int i = 0; i < num_buckets; i++)
        {
            cout << "\t";
            cout << i + 1;
            SymbolInfo *curr = hashTable[i];
            while (curr != NULL)
            {
                cout << "-->" << "(" << curr->getName() << "," << curr->getType() << ")" << endl;
                curr = curr->nextPtr;
            }
            cout << endl;
        }
    }
};

#endif // SCOPETABLE_HPP