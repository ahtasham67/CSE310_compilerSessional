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
    int tableID;
    SymbolInfo **hashTable;

public:
    ScopeTable *parent_scope;
    static int tableCount;

    ScopeTable(int n, ScopeTable *parent_scope = NULL)
    {
        this->childCnt = 0;
        this->tableID = tableCount;
        this->parent_scope = parent_scope;
        num_buckets = n;
        hashTable = new SymbolInfo *[num_buckets];
        // cout<<num_buckets<<endl;

        for (int i = 0; i < num_buckets; i++)
        {
            hashTable[i] = NULL;
        }
    }

    ~ScopeTable()
    {
        for (int i = 0; i < num_buckets; i++)
        {
            SymbolInfo *curr = hashTable[i];
            while (curr != nullptr)
            {
                SymbolInfo *temp = curr;
                curr = curr->nextPtr;
                delete temp;
            }
        }
        delete[] hashTable;
        // cout << "\tScopeTable# " << tableID << " deleted" << endl;
    }

    int getNumBuckets()
    {
        return num_buckets;
    }
    int getNumChild()
    {
        return childCnt;
    }

    int getHashIndex(string name)
    {
        uint64_t hash = hashFunc ::getSDBMHash(name, num_buckets);
        int index = hash % num_buckets;
        return index;
    }

    int getIndxInChain(string name)
    {
        int index = getHashIndex(name);
        SymbolInfo *curr = hashTable[index];
        int i = 0;
        // cout<<index<<endl;

        while (curr != NULL)
        {
            if (curr->getName() == name)
            {
                // cout << "Found at index " << i << " in the chain." << endl;
                return i;
            }
            curr = curr->nextPtr;
            i++;
        }

        // cout << "Symbol " << name << " not found in the chain." << endl;
        return -1;
    }

    int getTableID()
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

    SymbolInfo* LookUp(string name, bool print = false)
{
    int indx = getHashIndex(name);
    SymbolInfo* curr = hashTable[indx];
    int indxInChain = 0;

    while (curr != NULL)
    {
        if (curr->getName() == name)
        {
            if (print)
            {
                cout << "\t'" << name << "' found in ScopeTable# " << tableID
                     << " at position " << indx + 1
                     << ", " << indxInChain + 1 << endl;
            }
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
            // cout << name << " inserted at position " << indx + 1 << " in " << indexInChain + 1 << " of scopeTable " << getTableID() << endl;
            // cout<<"\tInserted in ScopeTable# "<<getTableID()<<" at position "<<indx+1<<", "<< indexInChain+1<<endl;
            return true;
        }
        else
            return false;
    }

    bool remove(string name)
    {
        int indx = getHashIndex(name);
        SymbolInfo *curr = hashTable[indx];
        SymbolInfo *prev = NULL;
        int indexInChain = 0;

        while (curr != NULL)
        {
            if (curr->getName() == name)
            {
                if (prev == NULL)
                {
                    // first element in chain
                    hashTable[indx] = curr->nextPtr;
                }
                else
                {
                    prev->nextPtr = curr->nextPtr;
                }

                curr->nextPtr = NULL;
                delete curr;

                return true;
            }
            prev = curr;
            curr = curr->nextPtr;
            indexInChain++;
        }

        // If not found
        // cout << "\t'" << name << "' not found in ScopeTable# " << tableID << endl;
        return false;
    }

    void Print(int level = 0)
    {
        string indent(level, '\t');
        cout << indent << "ScopeTable# " << this->tableID << endl;
        for (int i = 0; i < num_buckets; i++)
        {
            cout << indent << i + 1 << "--> ";
            SymbolInfo *curr = hashTable[i];
            while (curr != NULL)
            {
                cout << "<" << curr->getName() << "," << curr->getType();

                cout << "> ";
                curr = curr->nextPtr;
            }
            cout << endl;
        }
    }
};
int ScopeTable::tableCount = 0;
#endif // SCOPETABLE_HPP