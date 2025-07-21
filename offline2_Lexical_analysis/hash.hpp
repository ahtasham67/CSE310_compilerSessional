#ifndef HASH_FUNC
#define HASH_FUNC

#include <iostream>
#include <string>
using namespace std;

class hashFunc
{
    public:
    
    static unsigned int getSDBMHash(const std::string& str, unsigned int num_buckets) {
    unsigned int hash = 0;
    for (char c : str) {
        hash = static_cast<unsigned char>(c) + (hash << 6) + (hash << 16) - hash;
    }
    return hash % num_buckets;
}

    //http://www.cse.yorku.ca/~oz/hash.html
    static uint64_t getDJB2Hash(string str)
    {
        uint64_t hash = 5381;
        for (char c : str)
        {
            hash = ((hash << 5) + hash) + c; 
        }
        return hash;
    }
    //https://en.wikipedia.org/wiki/Fowler–Noll–Vo_hash_function
    static uint64_t getFNV1aHash(string str)
    {
        const uint64_t FNV_OFFSET_BASIS = 14695981039346656037ULL;
        const uint64_t FNV_PRIME = 1099511628211ULL;

        uint64_t hash = FNV_OFFSET_BASIS;
        for (char c : str)
        {
            hash ^= static_cast<unsigned char>(c); // XOR with byte
            hash *= FNV_PRIME;                     // Multiply by prime
        }

        return hash;
    }
    
};

#endif


