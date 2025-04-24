#include<iostream>
using namespace std;

#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <functional>
#include <unordered_map>
#include <sstream>
#include "hash.hpp"

using namespace std;



void calculateHash(const vector<string>& inputs,int type, const string& hashFuncName, int total_number_of_buckets) {
    int collisions = 0;
    unordered_map<int, int> bucket_count;
    for (const string& input : inputs) {
        int hashValue;
        if (type == 0) {
            hashValue = hashFunc::getSDBMHash(input,total_number_of_buckets) ;
        } else if (type == 1) {
            hashValue = hashFunc::getDJB2Hash(input) % total_number_of_buckets;
        } else {
            hashValue = hashFunc::getFNV1aHash(input) % total_number_of_buckets;
        }

        bucket_count[hashValue]++;
        if (bucket_count[hashValue] > 1) {
            collisions++;
        }
    }
    
    cout << hashFuncName << "," << collisions << "," << total_number_of_buckets << "," << static_cast<double>(collisions) / total_number_of_buckets << "\n";
}


int main() {
    string input_filename = "input.txt";
    string output_filename = "Report.csv";

    freopen(input_filename.c_str(), "r", stdin);
    freopen(output_filename.c_str(), "w", stdout);

    int total_number_of_buckets;
    cin >> total_number_of_buckets;
    cin.ignore();

    vector<string> inputs;
    string choice, line;

    while (getline(cin, line)) {
        if (line.empty()) continue;

        stringstream ss(line);
        ss >> choice;
        if (choice == "I") {
            string name;
            ss >> name;
            inputs.push_back(name);
        }
    }

    cout << "HashFunction,Collisions,BucketSize,CollisionRatio\n";

    calculateHash(inputs, 0, "SDBM", total_number_of_buckets);
    calculateHash(inputs, 1, "DJB2", total_number_of_buckets);
    calculateHash(inputs, 2, "FNV-1a", total_number_of_buckets);

    return 0;
}
