#ifndef HASH_FUNC
#define HASH_FUNC

#include <iostream>
#include <string>
using namespace std;

class hashFunc
{
    public:
    static uint64_t getSDBMHash(string str)
    {
        unsigned int hash = 0;
        unsigned int i = 0;
        unsigned int len = str.length();

        for (i = 0; i < len; i++)
        {
            hash = (str[i]) + (hash << 6) + (hash << 16) - hash;
        }

        return hash;
    }
};

#endif