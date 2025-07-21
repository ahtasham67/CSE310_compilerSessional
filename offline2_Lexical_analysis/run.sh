#!/bin/bash

flex 2105067.l
g++ lex.yy.c -o main
./main input3.txt >> /dev/null