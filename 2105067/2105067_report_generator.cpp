#include <bits/stdc++.h>
using namespace std;

#include "2105067_SymbolTable.hpp"

int main(int argc, char *argv[]) {
    string output_filename = "2105067_Report.csv";
    ofstream report_file(output_filename);
    report_file << "HashFunction,Collisions,BucketSize,CollisionRatio\n";

    for (int i = 0; i < 3; i++) {
        string input_filename = "input.txt";
        ifstream input("input.txt");
        cin.rdbuf(input.rdbuf());


        int total_number_of_buckets;
        cin >> total_number_of_buckets;
        cin.ignore();

        // Redirect cout to null to suppress internal prints
        streambuf* orig_buf = cout.rdbuf();
#ifdef _WIN32
        ofstream null_stream("NUL");
#else
        ofstream null_stream("/dev/null");
#endif
        cout.rdbuf(null_stream.rdbuf());

        // Run SymbolTable for the current hash function
        SymbolTable* symbolTable = new SymbolTable(i, total_number_of_buckets);

        string line;
        while (getline(cin, line)) {
            if (line.empty()) continue;
            stringstream ss(line);
            string choice;
            ss >> choice;

            if (choice == "I") {
                string args[100];
                int j = 0;
                while (ss >> args[j]) j++;
                if (j < 2) continue;

                string name = args[0];
                string type = args[1];
                bool inserted;

                if (type == "FUNCTION") {
                    if (j < 3) continue;
                    string return_type = args[2];
                    string func_type = "FUNCTION," + return_type + "<==(";
                    for (int k = 3; k < j; k++) {
                        func_type += args[k];
                        if (k != j - 1) func_type += ",";
                    }
                    func_type += ")";
                    inserted = symbolTable->Insert(name, func_type);
                } else if (type == "STRUCT" || type == "UNION") {
                    if ((j - 2) % 2 != 0) continue;
                    string struct_type = type + ",{";
                    for (int k = 2; k < j; k += 2) {
                        struct_type += "(" + args[k] + "," + args[k + 1] + ")";
                        if (k + 2 < j) struct_type += ",";
                    }
                    struct_type += "}";
                    inserted = symbolTable->Insert(name, struct_type);
                } else {
                    inserted = symbolTable->Insert(name, type);
                }

            } else if (choice == "S") {
                symbolTable->EnterScope();
            } else if (choice == "E") {
                symbolTable->ExitScope();
            } else if (choice == "D") {
                string name;
                ss >> name;
                symbolTable->Remove(name);
            } else if (choice == "Q") {
                symbolTable->ExitAllScope();
                delete symbolTable;
                symbolTable = nullptr;
                break;
            }
        }

        // Restore cout for report writing
        cout.rdbuf(orig_buf);

        // Output collision stats to CSV
        double ratio = (double)ScopeTable::collisionCount /
                       (ScopeTable::tableCount * total_number_of_buckets);

        report_file << "HashNO-" << (i + 1) << ","
                    << ScopeTable::collisionCount << ","
                    << total_number_of_buckets << ","
                    << fixed << setprecision(4) << ratio << "\n";

        // Reset for next hash function run
         ScopeTable::collisionCount = 0;
         ScopeTable::tableCount = 0;
    }

    return 0;
}
