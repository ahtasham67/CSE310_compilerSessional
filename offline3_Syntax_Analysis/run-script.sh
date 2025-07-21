#!/bin/zsh
set -e

if [ -z "$1" ]; then
  echo "Usage: ./run-script.sh <input-file>"
  exit 1
fi

INPUT_FILE="$1"

ANTLR_JAR="$HOME/Downloads/antlr-4.13.2-complete.jar"
ANTLR_CP=".:$ANTLR_JAR"

#echo "[*] Generating C++ lexer and parser..."
java -Xmx500M -cp "$ANTLR_CP" org.antlr.v4.Tool -Dlanguage=Cpp C2105067Lexer.g4
java -Xmx500M -cp "$ANTLR_CP" org.antlr.v4.Tool -Dlanguage=Cpp C2105067Parser.g4

#echo "[*] Compiling..."
g++ -std=c++17 -w -I/usr/local/include/antlr4-runtime -c C2105067Lexer.cpp C2105067Parser.cpp Ctester.cpp

#echo "[*] Linking..."
g++ -std=c++17 -w C2105067Lexer.o C2105067Parser.o Ctester.o -L/usr/local/lib -lantlr4-runtime -o Ctester.out -pthread

#echo "[*] Running parser..."
LD_LIBRARY_PATH=/usr/local/lib ./Ctester.out "$INPUT_FILE"
