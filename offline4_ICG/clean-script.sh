#!/bin/bash

shopt -s extglob

for file in !(*.sh|*.g4|Ctester.cpp|AssemblyGenerator.cpp|*.hpp|test_assembly.c|*.asm); do
    # Only delete if it's a regular file
    if [[ -f "$file" ]]; then
        rm -f "$file"
    fi
done

rm -rf output

