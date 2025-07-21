#ifndef SCOPETABLE_HPP
#define SCOPETABLE_HPP

#pragma once
#include "hash.hpp"
#include "symbolInfo.hpp"

#include <iostream>
#include <string>
#include <vector> // Make sure vector is included if SymbolInfo uses it
// #include "bits/stdc++.h" // Generally avoid this in headers, include specific ones.

using namespace std;

class ScopeTable
{
private:
    int num_buckets;
    int childCnt; // Renamed to childCnt for consistency (was childCount)
    string tableID;
    SymbolInfo **hashTable;
    int hashType; // 0 for SDBM, 1 for DJB2, 2 for FNV1a

public:
    ScopeTable *parent_scope;
    static string tableCount;  // This static variable is typically not used directly here; ScopeTable manages its own ID.
    static int collisionCount; // This static variable is better tracked in SymbolTable for overall stats.

    ScopeTable(int hashtype, int n, ScopeTable *parent_scope = NULL)
    {
        this->childCnt = 0;
        this->parent_scope = parent_scope;
        this->num_buckets = n;
        this->hashType = hashtype;

        hashTable = new SymbolInfo *[num_buckets];
        for (int i = 0; i < num_buckets; i++)
        {
            hashTable[i] = NULL;
        }

        if (parent_scope == NULL)
        {
            tableID = "1";
        }
        else
        {
            parent_scope->childCnt++;
            tableID = parent_scope->getTableID() + "." + to_string(parent_scope->childCnt);
        }
    }

    ~ScopeTable()
    {
        for (int i = 0; i < num_buckets; ++i)
        {
            SymbolInfo *current = hashTable[i];
            while (current != nullptr)
            {
                SymbolInfo *next = current->nextPtr;
                delete current;
                current = next;
            }
            hashTable[i] = nullptr;
        }
        delete[] hashTable;
    }

    string getTableID() const { return tableID; }
    int getChildCnt() const { return childCnt; }
    int getNumBuckets() const { return num_buckets; } // Add const

    // Method to get bucket head for assembly generator iteration
    SymbolInfo *getBucketHead(int index) const
    {
        if (index >= 0 && index < num_buckets)
        {
            return hashTable[index];
        }
        return nullptr;
    }

    void incrementChildCnt() { childCnt++; } // This is now done in the constructor

    int getHashIndex(string name)
    {
        if (hashType == 0)
            return hashFunc::getSDBMHash(name, num_buckets);
        else if (hashType == 1)
            return hashFunc::getDJB2Hash(name) % num_buckets;
        else
            return hashFunc::getFNV1aHash(name) % num_buckets;
    }

    int getIndxInChain(string name) // For internal use, good for diagnostics
    {
        int index = getHashIndex(name);
        SymbolInfo *curr = hashTable[index];
        int i = 0;
        while (curr != NULL)
        {
            if (curr->getName() == name)
            {
                return i;
            }
            curr = curr->nextPtr;
            i++;
        }
        return -1; // Not found
    }

    // Lookup method remains the same, it returns SymbolInfo*
    SymbolInfo *LookUp(string name, bool print = false)
    {
        int indx = getHashIndex(name);
        SymbolInfo *curr = hashTable[indx];
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

    // --- Modified insert methods to handle new SymbolInfo constructors ---
    bool insert(SymbolInfo *newSymbol)
    {
        string name = newSymbol->getName();
        SymbolInfo *foundentry = LookUp(name);
        if (foundentry == NULL)
        {
            int indx = getHashIndex(name);
            SymbolInfo *curr = hashTable[indx];
            int indexInChain = 0;

            if (curr == NULL)
            {
                hashTable[indx] = newSymbol;
            }
            else
            {
                indexInChain = 1; // It means it's not the first element
                while (curr->nextPtr != NULL)
                {
                    curr = curr->nextPtr;
                    indexInChain++;
                }
                curr->nextPtr = newSymbol;
                // ScopeTable::collisionCount++; // Removed from here, better tracked in SymbolTable
            }
            // Logging can be done by SymbolTable or caller
            return true;
        }
        else
        {
            delete newSymbol; // Clean up if not inserted
            return false;
        }
    }
    // --- End of modified insert methods ---

    bool remove(string name)
    {
        int indx = getHashIndex(name);
        SymbolInfo *curr = hashTable[indx];
        SymbolInfo *prev = NULL;

        while (curr != NULL)
        {
            if (curr->getName() == name)
            {
                if (prev == NULL)
                {
                    hashTable[indx] = curr->nextPtr;
                }
                else
                {
                    prev->nextPtr = curr->nextPtr;
                }
                curr->nextPtr = NULL;
                delete curr; // Free memory
                return true;
            }
            prev = curr;
            curr = curr->nextPtr;
        }
        return false;
    }

    // void Print(ofstream &out, int level = 0)
    // {
    //     out << "\tScopeTable # " << this->tableID << endl;
    //     for (int i = 0; i < num_buckets; i++)
    //     {
    //         if (hashTable[i] == NULL)
    //             continue;
    //         out << "\t" << i + 1 << " --> ";
    //         SymbolInfo *curr = hashTable[i];
    //         while (curr != NULL)
    //         {
    //             out << "< " << curr->getName();
    //             if (curr->getIsArray()) {
    //                 out << ", " << curr->getElementType() << "_ARRAY, Size=" << curr->getArraySize();
    //             } else if (curr->getIsFunction()) {
    //                 out << ", FUNCTION, Ret=" << curr->getReturnType() << ", Params=(";
    //                 const auto& params = curr->getParamTypes();
    //                 for(size_t j=0; j<params.size(); ++j) {
    //                     out << params[j] << (j == params.size() - 1 ? "" : ",");
    //                 }
    //                 out << ")";
    //             } else {
    //                 out << ", " << curr->getType();
    //             }
    //             out << " > ";
    //             curr = curr->nextPtr;
    //         }
    //         out << endl;
    //     }
    // }
    void Print(ofstream &out, int level = 0)
    {
        out << "\n\tScopeTable # " << this->tableID << endl;
        for (int i = 0; i < num_buckets; i++)
        {
            if (hashTable[i] == NULL)
                continue;
            out << "\t" << i + 1 << " --> ";
            SymbolInfo *curr = hashTable[i];
            while (curr != NULL)
            {
                out << "< " << curr->getName();
                // if (curr->getIsArray()) {
                //     out << ", " << curr->getElementType() << "_ARRAY, Size=" << curr->getArraySize();
                // } else if (curr->getIsFunction()) {
                //     out << ", FUNCTION, Ret=" << curr->getReturnType() << ", Params=(";
                //     const auto& params = curr->getParamTypes();
                //     for(size_t j=0; j<params.size(); ++j) {
                //         out << params[j] << (j == params.size() - 1 ? "" : ",");
                //     }
                //     out << ")";
                // } else {
                //     out << ", " << curr->getType();
                // }
                out << ", ID > ";
                curr = curr->nextPtr;
            }
            out << endl;
        }
    }
};
// Removed inline static variables from ScopeTable.hpp. They will be in .cpp or globally in main.cpp.
// inline string ScopeTable::tableCount = "1"; // Moved to .cpp or main.cpp
// inline int ScopeTable::collisionCount = 0; // Moved to .cpp or main.cpp
#endif