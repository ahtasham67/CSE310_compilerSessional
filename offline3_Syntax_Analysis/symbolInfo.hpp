#ifndef SYMBOLINFO_HEADER
#define SYMBOLINFO_HEADER

#pragma once
#include <iostream>
#include <string>
#include <vector> 
using namespace std;

class SymbolInfo
{
private:
    string name;
    string type; 

    bool isArray;
    int arraySize;     
    string elementType; 

    bool isFunction;
    string returnType;             
    vector<string> paramTypes;    
    int numParams;      

    int line;

public:
    SymbolInfo *nextPtr;

    SymbolInfo(string name, string type, int line, SymbolInfo *next = NULL)
    {
        this->name = name;
        this->type = type;
        this->line = line;
        this->nextPtr = next;

    
        this->isArray = false;
        this->arraySize = -1;
        this->elementType = "";

        this->isFunction = false;
        this->returnType = "";
        this->numParams = 0;
    }

    SymbolInfo(string name, string type, bool isArray, int arraySize, int line, SymbolInfo *next = NULL)
    {
        this->name = name;
        this->type = type; 
        this->line = line;
        this->nextPtr = next;

        this->isArray = isArray;
        this->arraySize = arraySize;
        this->elementType = type;

        this->isFunction = false;
        this->returnType = "";
        this->numParams = 0;
    }

    SymbolInfo(string name, string type, bool isFunction, string returnType, const vector<string>& paramTypes, int line, SymbolInfo *next = NULL)
    {
        this->name = name;
        this->type = type;
        this->line = line;
        this->nextPtr = next;

        this->isArray = false;
        this->arraySize = -1;
        this->elementType = "";

        this->isFunction = isFunction;
        this->returnType = returnType;
        this->paramTypes = paramTypes;
        this->numParams = paramTypes.size();
    }


    // --- Getters ---
    string getName() const { return name; }
    string getType() const { return type; } // This now refers to the overall kind (e.g., "INT", "FUNCTION")
    int getLine() const { return line; }

    bool getIsArray() const { return isArray; }
    int getArraySize() const { return arraySize; }
    string getElementType() const { return elementType; }

    bool getIsFunction() const { return isFunction; }
    string getReturnType() const { return returnType; }
    const vector<string>& getParamTypes() const { return paramTypes; }
    int getNumParams() const { return numParams; }

    // --- Setters (if needed, but constructor initialization is preferred) ---
    void setName(const string &name) { this->name = name; }
    void setType(const string &type) { this->type = type; }
    void setLine(int line) { this->line = line; }

    void setIsArray(bool isArray) { this->isArray = isArray; }
    void setArraySize(int size) { this->arraySize = size; }
    void setElementType(const string& elementType) { this->elementType = elementType; }

    void setIsFunction(bool isFunction) { this->isFunction = isFunction; }
    void setReturnType(const string &returnType) { this->returnType = returnType; }
    void setParamTypes(const vector<string>& types) { this->paramTypes = types; numParams = types.size(); }

    void print()
    {
        cout << "Name - " << name << ", Type - " << type;
        if (isArray) {
            cout << ", IsArray - true, ElementType - " << elementType << ", Size - " << arraySize;
        }
        if (isFunction) {
            cout << ", IsFunction - true, ReturnType - " << returnType << ", NumParams - " << numParams;
            cout << ", Params: [";
            for (size_t i = 0; i < paramTypes.size(); ++i) {
                cout << paramTypes[i] << (i == paramTypes.size() - 1 ? "" : ", ");
            }
            cout << "]";
        }
        cout << ", Declared at line " << line << endl;
    }
};

#endif