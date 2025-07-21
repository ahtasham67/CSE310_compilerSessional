#ifndef SYMBOLINFO_HEADER
#define SYMBOLINFO_HEADER

#include <iostream>
#include <string>
using namespace std;

/* This class contains the information about a symbol faced within the source
code. In the first step, we will limit (highly recommended) ourselves to two member
variables. One is for the name of the symbol and the other is for the type of the symbol.
You can use C++ STL (string). These two member variables must be declared private
and you should write necessary getter and setter methods. This class will also contain
a pointer to an object of the SymbolInfo class as you need to implement a chaining
mechanism to resolve collisions in the hash table. Also keep in mind that you may have
to extend this class as we progress to develop our compiler.*/
class SymbolInfo
{
private:
    string name, type;

public:
    SymbolInfo *nextPtr;

    SymbolInfo(string name, string type, SymbolInfo *next = NULL)
    {
        this->name = name;
        this->type = type;
        this->nextPtr = next;
    }
    // // destructor
    // ~SymbolInfo()
    // {
    //     if (nextPtr != NULL)
    //         delete nextPtr;
    // }

    string getName()
    {
        return name;
    }

    void setName(string &name)
    {
        this->name = name;
    }

    string getType()
    {
        return type;
    }

    void setType(string &type)
    {
        this->type = type;
    }

    void print()
    {
        cout << "Name - " << name << endl;
        cout << "Type - " << type << endl;
    }
};

#endif