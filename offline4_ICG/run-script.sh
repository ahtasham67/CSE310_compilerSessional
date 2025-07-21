#!/bin/zsh
set -e

if [ -z "$1" ]; then
  echo "Usage: ./run-script.sh <input-file>"
  exit 1
fi

INPUT_FILE="$1"

ANTLR_JAR="/usr/local/Cellar/antlr/4.13.2/antlr-4.13.2-complete.jar"
ANTLR_CP=".:$ANTLR_JAR"

java -Xmx500M -cp "$ANTLR_CP" org.antlr.v4.Tool -Dlanguage=Cpp C2105067Lexer.g4
java -Xmx500M -cp "$ANTLR_CP" org.antlr.v4.Tool -Dlanguage=Cpp C2105067Parser.g4

arch -x86_64 g++ -std=c++17 -w -I/usr/local/Cellar/antlr4-cpp-runtime/4.13.2/include/antlr4-runtime -c C2105067Lexer.cpp C2105067Parser.cpp AssemblyGenerator.cpp Ctester.cpp

arch -x86_64 g++ -std=c++17 -w C2105067Lexer.o C2105067Parser.o AssemblyGenerator.o Ctester.o -L/usr/local/Cellar/antlr4-cpp-runtime/4.13.2/lib -lantlr4-runtime -o Ctester.out -pthread
arch -x86_64 ./Ctester.out "$INPUT_FILE"
