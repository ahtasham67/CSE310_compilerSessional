#include <bits/stdc++.h>
using namespace std;

#include "SymbolTable.hpp"

int main()
{
    
    string input_filename = "input.txt";
    string output_filename = "output.txt";

    freopen(input_filename.c_str(), "r", stdin);
    freopen(output_filename.c_str(), "w", stdout);

    int total_number_of_buckets;
    cin >> total_number_of_buckets;
    cin.ignore(); // to ignore the newline character after the integer input
    SymbolTable *symbolTable = new SymbolTable(total_number_of_buckets);
    string choice, line;
    int commanCnt = 0;
    while (getline(cin, line))
    {
        if (line == "")
            continue;
        
        stringstream ss(line);
        commanCnt++;
        int argCnt = 0;

        
        cout<<"Cmd "<<commanCnt<<": "<<line<<endl;
        // take the first character
        ss >> choice;
        //For STRUCT or UNION, the format alternates between type and variable name.
        //Refer to the sample files for clarity.
        if (choice == "I")
{
    string args[100];
    int i = 0;
    while (ss >> args[i])
    {
        i++;
    }

    if (i < 2)
    {
        cout << "\tNumber of parameters mismatch for the command I" << endl;
        continue;
    }

    string name = args[0];
    string type = args[1];

    if (type == "FUNCTION")
    {
        if (i < 3)
        {
            cout << "\tNumber of parameters mismatch for FUNCTION type" << endl;
            continue;
        }

        string return_type = args[2];
        string func_type = "FUNCTION," + return_type + "<==(";

        for (int j = 3; j < i; j++)
        {
            func_type += args[j];
            if (j != i - 1)
                func_type += ",";
        }

        func_type += ")";
        symbolTable->Insert(name, func_type);
    }
    else if (type == "STRUCT" || type == "UNION")
    {
        if ((i - 2) % 2 != 0)
        {
            cout << "\tInvalid STRUCT/UNION declaration format for symbol '" << name << "'" << endl;
            continue;
        }

        string struct_type = type + ",{";
        for (int j = 2; j < i; j += 2)
        {
            struct_type += "(" + args[j] + "," + args[j + 1] + ")";
            if (j + 2 < i)
                struct_type += ",";
        }
        struct_type += "}";
        symbolTable->Insert(name, struct_type);
    }
    else
    {
        symbolTable->Insert(name, type);
    }
}

//         L: Stands for lookup which is followed by a string containing the symbol to be looked up in the
//          symbol table.
        if(choice == "L")
        {
            string name, extra;
            ss >> name;
            ss>> extra;
            if(extra != "")
            {
                cout<<"\tNumber of parameters mismatch for the command L"<<endl;
                continue;
            }
            SymbolInfo *entry = symbolTable->lookup(name);
        }
        //S: Stands for entering a new scope.
        if(choice == "S")
        {
            string extra;
            ss>>extra;
            if(extra != "")
            {
                cout<<"\tNumber of parameters mismatch for the command S"<<endl;
                continue;
            }
            symbolTable->EnterScope();
        }
        /*P: Stands for printing the symbol table which is followed by another code letter that is either ‘A’
        or ‘C’. If ‘A’ follows P, then you will print all the scope tables in the symbol table. On the
        other hand, if ‘C’ follows P, then you will print only the current scope table.*/
        if(choice == "P")
        {
            string extra;
            ss>>extra;
            if(extra == "A")
            {
                symbolTable->PrintAllScopeTables();
            }
            else if(extra == "C")
            {
                symbolTable->PrintCurrentScopeTable();
            }
            else
            {
                cout<<"\tInvalid command"<<endl;
                continue;
            }
        }
        //E: Stands for exiting the current scope. Note that you cannot exit the root scope table.
        if(choice == "E")
        {
            string extra;
            ss>>extra;
            if(extra != "")
            {
                cout<<"\tNumber of parameters mismatch for the command E"<<endl;
                continue;
            }
            symbolTable->ExitScope();
        }
        //Q: Stands for quitting. No code letter after ‘Q’ will be processed.
        if(choice == "Q")
        {
            string extra;
            ss>>extra;
            if(extra != "")
            {
                cout<<"\tNumber of parameters mismatch for the command Q"<<endl;
                continue;
            }
            break;
        }
        //D: Stands for deletion which is also followed by a string indicating the symbol to be deleted.
        if(choice == "D")
        {
            string name, extra;
            ss >> name;
            ss >> extra;
            if(extra == "")
            {
                cout<<"\tNumber of parameters mismatch for the command D"<<endl;
                continue;
            }
            bool result = symbolTable->Remove(name);
            if (result)
            {
                cout << "\t" << name << " removed from current scope table" << endl;
            }
            else
                cout << "\t" << name << " not found in current scope table" << endl;
        }
    }
}