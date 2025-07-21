#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <filesystem>
#include <memory>

#include "antlr4-runtime.h"
#include "C2105067Lexer.h"
#include "C2105067Parser.h"
#include "symbolInfo.hpp"
#include "ScopeTable.hpp"
#include "SymbolTable.hpp"

struct TokenInfo {
    int line;
    int col;
    std::string type;
    std::string text;
};

using namespace antlr4;
using namespace std;
namespace fs = std::filesystem; 

ofstream parserLogFile;
ofstream errorFile;
ofstream lexLogFile;

int syntaxErrorCount = 0;
int semanticErrorCount = 0;

int bucketsize = 7;
SymbolTable symboltable(bucketsize);
string globalprogram="";

class CustomErrorListener : public BaseErrorListener {
public:
    virtual void syntaxError(Recognizer *recognizer, Token *offendingSymbol, size_t line,
                             size_t charPositionInLine, const string &msg, exception_ptr e) override {
        // if (errorFile.is_open()) {
        //     errorFile << "Line# " << line << ", Col# " << charPositionInLine
        //               << ": Syntax Error: " << msg << " at token '"
        //               << offendingSymbol->getText() << "'" << endl;
        //     errorFile.flush();
        // } else {
        //     cerr << "Error logging parser syntax error: errorFile is not open." << endl;
        // }
        syntaxErrorCount++;
    }
};

class CustomLexerErrorListener : public BaseErrorListener {
public:
    virtual void syntaxError(Recognizer *recognizer, Token *offendingSymbol, size_t line,
                             size_t charPositionInLine, const string &msg, exception_ptr e) override {
        std::string tokenText = (offendingSymbol != nullptr) ? offendingSymbol->getText() : "";
        
        // if (errorFile.is_open()) {
        //     errorFile << "Line# " << line << ", Col# " << charPositionInLine
        //               << ": Lexical Error: " << msg << " at '"
        //               << tokenText << "'" << endl;
        //     errorFile.flush();
        // } else {
        //     cerr << "Error logging lexical error: errorFile is not open." << endl;
        // }
        syntaxErrorCount++;
    }
};

int main(int argc, const char* argv[]) {
    if (argc < 2) {
        cerr << "Usage: " << argv[0] << " <input_file>" << endl;
        return 1;
    }

    ifstream inputFile(argv[1]);
    if (!inputFile.is_open()) {
        cerr << "Error opening input file: " << argv[1] << endl;
        return 1;
    }

    string outputDirectory = "output/";
    string parserLogFileName = outputDirectory + "parserLog.txt";
    string errorFileName = outputDirectory + "errorLog.txt";
    string lexLogFileName = outputDirectory + "lexerLog.txt";

    try {
        if (!fs::exists(outputDirectory)) {
            fs::create_directories(outputDirectory);
        }
    } catch (const fs::filesystem_error& e) {
        cerr << "Error creating output directory: " << e.what() << endl;
        return 1;
    }

    parserLogFile.open(parserLogFileName);
    if (!parserLogFile.is_open()) {
        cerr << "Error opening parser log file: " << parserLogFileName << endl;
        return 1;
    }

    errorFile.open(errorFileName);
    if (!errorFile.is_open()) {
        cerr << "Error opening error log file: " << errorFileName << endl;
        return 1;
    }

    lexLogFile.open(lexLogFileName);
    if (!lexLogFile.is_open()) {
        cerr << "Error opening lexer log file: " << lexLogFileName << endl;
        return 1;
    }
   
    ANTLRInputStream input(inputFile);
    C2105067Lexer lexer(&input);

    CustomLexerErrorListener lexerErrorListener;
    lexer.removeErrorListeners();
    lexer.addErrorListener(&lexerErrorListener);

    CommonTokenStream tokens(&lexer);

    lexLogFile << "Lexical Analysis Output:" << endl;
    lexLogFile << "------------------------" << endl;
    tokens.fill();
    std::vector<antlr4::Token*> allTokens = tokens.getTokens();

    for (size_t i = 0; i < allTokens.size(); ++i) {
        antlr4::Token* token = allTokens[i];
        lexLogFile << "Line " << token->getLine()
                   << ": Token <" << lexer.getVocabulary().getSymbolicName(token->getType())
                   << "> Text '" << token->getText() << "'" << endl;
    }
    lexLogFile << "------------------------" << endl << endl;
    tokens.reset();

    C2105067Parser parser(&tokens);

    CustomErrorListener parserErrorListener;
    parser.removeErrorListeners();
    parser.addErrorListener(&parserErrorListener);

    parser.start();

    inputFile.clear();
    inputFile.seekg(0, ios::beg);
    string lineContent;
    int totalLines = 0;
    while (getline(inputFile, lineContent)) {
        totalLines++;
    }

   // int totalErrors = syntaxErrorCount + semanticErrorCount;
    parserLogFile << "Total lines: " << totalLines << endl;
    parserLogFile << "Total errors: " << semanticErrorCount << endl;

    inputFile.close();
    parserLogFile.close();
    errorFile.close();
    lexLogFile.close();

    cout << "Parsing completed" << endl;
    //cout << "Total Syntax Errors: " << syntaxErrorCount << endl;
    cout << "Total Semantic Errors: " << semanticErrorCount << endl;
    return 0;
}