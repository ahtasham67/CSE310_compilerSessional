%option noyywrap

%x CONST_CHAR_STATE
%x MULTI_LINE_COMMENT_STATE
%x SINGLE_COMMENT_STATE
%x STRING_STATE

%{
#include"bits/stdc++.h"
#include"symbolInfo.hpp"
#include"ScopeTable.hpp"
#include"SymbolTable.hpp"
using namespace std;

int globalLineCount=1;
int lineCount=0;
int errorCount=0;
int char_length;
int commentLine=0;
int stringLine=0;
int stringStartLine = 0;
int commentStartLine = 0;


string tokenout;
string logout;
ofstream tokenprint;
ofstream logprint;
string charLog;
string charToken;
string commentString;
string stringLog;
string stringToken;


int bucket_size = 7;
SymbolTable symbolTable(bucket_size);

string toUpper(string s){
    for(auto &c:s) c = toupper(c);
    return s;
}

%}
KEYWORD if|for|do|int|float|void|switch|default|else|while|break|char|double|return|case|continue|goto|long|short|static|unsigned
DIGIT [0-9]
LETTER [a-zA-Z]
ALPHANUM {DIGIT}|{LETTER}
EXPONENT [eE][+-]?{DIGIT}+
DECIMALFRACTION \.{DIGIT}
WHITESPACE [ \t\r\v\f]
CONSTCHAR "\\0"|"\\v"|"\\b"|"\\r"|"\\f"|"\\a"|"\\\'"|"\\\\"|"\\t"|"\\n"|"\\\""
NEWLINE "\n"|"\r\n"
BACKSLASH "\\"

%%
{KEYWORD} {
    tokenprint << "<" << toUpper(yytext) <<"> ";
    logprint << "Line no " <<globalLineCount<<": Token <"<<toUpper(yytext)<<"> Lexeme "<<yytext<<" found\n"<<endl;
}
{DIGIT}+ {
    tokenprint << "<CONST_INT, "<<yytext<<"> ";
    logprint << "Line no " <<globalLineCount<<": Token <"<<"CONST_INT"<<"> Lexeme "<<yytext<<" found\n"<<endl;
    bool inserted =  symbolTable.Insert(yytext, "CONST_INT", logprint);
    if(inserted) symbolTable.PrintAllScopeTables(logprint);

}
({DIGIT}+|{DIGIT}*{DECIMALFRACTION}){EXPONENT}? {
    tokenprint << "<CONST_FLOAT, "<<yytext<<"> ";
    logprint << "Line no " <<globalLineCount<<": Token <"<<"CONST_FLOAT"<<"> Lexeme "<<yytext<<" found\n"<<endl;
    bool inserted =  symbolTable.Insert(yytext, "CONST_FLOAT", logprint);
    if(inserted) symbolTable.PrintAllScopeTables(logprint);
}
{DIGIT}+{DECIMALFRACTION}+{DECIMALFRACTION}+{DECIMALFRACTION}* {
     errorCount++;
    logprint<<"Error at line no "<<globalLineCount<<": Too many decimal points "<<yytext<<"\n\n"<<endl;
}

({DIGIT}+|{DIGIT}*{DECIMALFRACTION}){EXPONENT}+{DECIMALFRACTION}+ {
    errorCount++;
    logprint<<"Error at line no "<<globalLineCount<<": Ill formed number "<<yytext<<"\n\n"<<endl;
}

({LETTER}|"_")({ALPHANUM}|"_")* {
    tokenprint << "<ID, "<<yytext<<"> ";
    logprint << "Line no " <<globalLineCount<<": Token <"<<"ID"<<"> Lexeme "<<yytext<<" found\n"<<endl;
    bool inserted =  symbolTable.Insert(yytext, "ID", logprint);
    if(inserted) symbolTable.PrintAllScopeTables(logprint);
}
{DIGIT}+({LETTER}|"_")({ALPHANUM}|"_")* {
    errorCount++;
    logprint<<"Error at line no "<<globalLineCount<<": Invalid prefix on ID or invalid suffix on Number "<<yytext<<"\n"<<endl;
}
{DIGIT}*{DECIMALFRACTION}+{DECIMALFRACTION}+ {
    errorCount++;
    logprint<<"Error at line no "<<globalLineCount<<": Too many decimal points "<<yytext<<"\n"<<endl;
}
"+"|"-" {
    tokenprint<<"<ADDOP, "<<yytext<<"> ";
    logprint<<"Line no "<< globalLineCount <<": Token " <<"<ADDOP>"<<" Lexeme "<<yytext<<" found\n"<<endl;
}
"*"|"/"|"%"  {
    tokenprint<<"<MULOP, "<<yytext<<"> ";
    logprint<<"Line no "<< globalLineCount <<": Token " <<"<MULOP>"<<" Lexeme "<<yytext<<" found\n"<<endl;
}
"++"|"--"  {
    tokenprint<<"<INCOP, "<<yytext<<"> ";
    logprint<<"Line no "<< globalLineCount <<": Token " <<"<INCOP>"<<" Lexeme "<<yytext<<" found\n"<<endl;
}
"<"|"<="|">"|">="|"=="|"!="  {
    tokenprint<<"<RELOP, "<<yytext<<"> ";
    logprint<<"Line no "<< globalLineCount <<": Token " <<"<RELOP>"<<" Lexeme "<<yytext<<" found\n"<<endl;
}
"="  {
    tokenprint<<"<ASSIGNOP, "<<yytext<<"> ";
    logprint<<"Line no "<< globalLineCount <<": Token " <<"<ASSIGNOP>"<<" Lexeme "<<yytext<<" found\n"<<endl;
}
"&&"|"||"  {
    tokenprint<<"<LOGICOP, "<<yytext<<"> ";
    logprint<<"Line no "<< globalLineCount <<": Token " <<"<LOGICOP>"<<" Lexeme "<<yytext<<" found\n"<<endl;
}
"!"  {
    tokenprint<<"<NOT, "<<yytext<<"> ";
    logprint<<"Line no "<< globalLineCount <<": Token " <<"<NOT>"<<" Lexeme "<<yytext<<" found\n"<<endl;
}
"("  {
    tokenprint<<"<LPAREN, "<<yytext<<"> ";
    logprint<<"Line no "<< globalLineCount <<": Token " <<"<LPAREN>"<<" Lexeme "<<yytext<<" found\n"<<endl;
}
")"  {
    tokenprint<<"<RPAREN, "<<yytext<<"> ";
    logprint<<"Line no "<< globalLineCount <<": Token " <<"<RPAREN>"<<" Lexeme "<<yytext<<" found\n"<<endl;
}
"{"  {
    tokenprint<<"<LCURL, "<<yytext<<"> ";
    logprint<<"Line no "<< globalLineCount <<": Token " <<"<LCURL>"<<" Lexeme "<<yytext<<" found\n"<<endl;
    symbolTable.EnterScope();
}
"}"  {
    tokenprint<<"<RCURL, "<<yytext<<"> ";
    logprint<<"Line no "<< globalLineCount <<": Token " <<"<RCURL>"<<" Lexeme "<<yytext<<" found\n"<<endl;
    symbolTable.ExitScope();
}
"["  {
    tokenprint<<"<LTHIRD, "<<yytext<<"> ";
    logprint<<"Line no "<< globalLineCount <<": Token " <<"<LTHIRD>"<<" Lexeme "<<yytext<<" found\n"<<endl;
}
"]"  {
    tokenprint<<"<RTHIRD, "<<yytext<<"> ";
    logprint<<"Line no "<< globalLineCount <<": Token " <<"<RTHIRD>"<<" Lexeme "<<yytext<<" found\n"<<endl;
}
","  {
    tokenprint<<"<COMMA, "<<yytext<<"> ";
    logprint<<"Line no "<< globalLineCount <<": Token " <<"<COMMA>"<<" Lexeme "<<yytext<<" found\n"<<endl;
}
";"  {
    tokenprint<<"<SEMICOLON, "<<yytext<<"> ";
    logprint<<"Line no "<< globalLineCount <<": Token " <<"<SEMICOLON>"<<" Lexeme "<<yytext<<" found\n"<<endl;
}

\n {
    globalLineCount++;
}
' {
    // Beginning of CONST CHAR
    char_length = 0;
    charLog = "'";
    charToken = "";
    BEGIN CONST_CHAR_STATE;
}

<CONST_CHAR_STATE>{
    ' {
        charLog += "'";

        if (char_length == 0) {
            errorCount++;
            logprint << "Error at line no " << globalLineCount << ": Empty character constant error " << charLog << "\n\n" << endl;
        } else if (char_length == 1) {
            tokenprint << "<CONST_CHAR, " << charToken << "> ";
            logprint << "Line no " << globalLineCount << ": Token <CONST_CHAR> Lexeme " << charLog << " found --> <CONST_CHAR, " << charToken << ">\n" << endl;
            bool inserted = symbolTable.Insert(charLog, "CONST_CHAR", logprint);
            if (inserted) symbolTable.PrintAllScopeTables(logprint);
        } else {
            errorCount++;
            logprint << "Error at line no " << globalLineCount << ": Multi character constant error " << charLog << "\n\n" << endl;
        }
        BEGIN INITIAL;
    }

    \\n {
        char_length++;
        charLog += "\\n";
        charToken += "\n";
    }

    \\t {
        char_length++;
        charLog += "\\t";
        charToken += "\t";
    }

    \\\\ {
        char_length++;
        charLog += "\\\\";
        charToken += "\\";
    }

    \\\'\' {
        char_length++;
        charLog += "\\'";
        charToken += "\'";
    }

    \\a {
        char_length++;
        charLog += "\\a";
        charToken += "\a";
    }

    \\f {
        char_length++;
        charLog += "\\f";
        charToken += "\f";
    }

    \\r {
        char_length++;
        charLog += "\\r";
        charToken += "\r";
    }

    \\b {
        char_length++;
        charLog += "\\b";
        charToken += "\b";
    }

    \\v {
        char_length++;
        charLog += "\\v";
        charToken += "\v";
    }

    \\0 {
        char_length++;
        charLog += "\\0";
        charToken += "\0";
    }

    \\\'\n {
        errorCount++;
        charLog += "\\'";
        logprint << "Error at line no " << globalLineCount << ": Unterminated character " << charLog << "\n\n" << endl;
        globalLineCount++;
        BEGIN INITIAL;
    }

    \\\' {
        charLog += "\\'";
        logprint << "Error at line no " << globalLineCount << ": Unterminated character " << charLog << "\n\n" << endl;
        BEGIN INITIAL;
    }

    \n {
        errorCount++;
        logprint << "Error at line no " << globalLineCount << ": Unterminated character " << charLog << "\n\n" << endl;
        globalLineCount++;
        BEGIN INITIAL;
    }

    . {
        char_length++;
        charLog += yytext[0];
        charToken += yytext[0];
    }
}


\/\* {
    commentString = "/*";
    commentLine = 0;
    commentStartLine = globalLineCount;
    BEGIN MULTI_LINE_COMMENT_STATE;
}

<MULTI_LINE_COMMENT_STATE>{
    \*\/ {
        commentString += "*/";
        int logLine = commentStartLine + commentLine; 
        logprint << "Line no " << logLine << ": Token <COMMENT> Lexeme " << commentString << " found\n" << endl;
        globalLineCount = logLine; 
        BEGIN INITIAL;
    }

    <<EOF>> {
        errorCount++;
        logprint << "Error at line no " << globalLineCount << ": Unterminated comment " << commentString << "\n" << endl;
        globalLineCount += commentLine;
        BEGIN INITIAL;
    }

    \n {
        commentString += "\n";
        commentLine++; 
    }

    \r {
        commentString += "\r";
    }

    . {
        commentString += yytext[0];
    }
}


\" {
    stringLine = 0;
    stringStartLine = globalLineCount;
    stringLog = "\"";
    stringToken = "";
    BEGIN STRING_STATE;
}

<STRING_STATE>{
    \" {
        stringLog += "\"";
        stringToken += "";
        tokenprint << "<STRING, " << stringToken << "> ";
        logprint << "Line no " << (stringStartLine + stringLine)
                 << ": Token <STRING> Lexeme " << stringLog << " found --> <STRING, "
                 << stringToken << ">\n" << endl;
        globalLineCount = stringStartLine + stringLine; 
        BEGIN INITIAL;
    }

    \\\r\n {
        stringLog += "\\\r\n";
        stringLine++;
    }

    \\\n {
        stringLog += "\\\n";
        stringLine++;
    }

    \n {
        errorCount++;
        logprint << "Error at line no " << globalLineCount << ": Unterminated string " << stringLog << "\n" << endl;
        stringLine++;
        globalLineCount += stringLine;
        BEGIN INITIAL;
    }

    <<EOF>> {
        errorCount++;
        logprint << "Error at line no " << globalLineCount << ": Unterminated string " << stringLog << "\n" << endl;
        globalLineCount++;
        BEGIN INITIAL;
    }

    \\n {
        stringLog += "\\n";
        stringToken += "\n";
        globalLineCount++;
    }

    \\t {
        stringLog += "\\t";
        stringToken += "\t";
    }

    \\\\ {
        stringLog += "\\\\";
        stringToken += "\\";
    }

    \\\" {
        stringLog += "\\\"";
        stringToken += "\"";
    }

    \\a {
        stringLog += "\\a";
        stringToken += "\a";
    }

    \\f {
        stringLog += "\\f";
        stringToken += "\f";
    }

    \\r {
        stringLog += "\\r";
        stringToken += "\r";
    }

    \\b {
        stringLog += "\\b";
        stringToken += "\b";
    }

    \\v {
        stringLog += "\\v";
        stringToken += "\v";
    }

    \\0 {
        stringLog += "\\0";
        stringToken += "\0";
    }

    . {
        stringLog += yytext[0];
        stringToken += yytext[0];
    }
}

\/\/ {
    commentString = "//";
    commentLine = 0;
    stringStartLine = globalLineCount;
    BEGIN SINGLE_COMMENT_STATE;
}

<SINGLE_COMMENT_STATE>{
    \\\r\n {
        commentLine++;
        commentString += "\\\r\n";
    }

    \\\n {
        commentLine++;
        commentString += "\\\n";
    }

    \\ {
        commentString += "\\";
    }

    . {
        commentString += yytext[0];
    }

    [\r]?\n {
        int logLine = stringStartLine + commentLine;
        logprint << "Line no " << logLine << ": Token <COMMENT> Lexeme " << commentString << " found\n" << endl;
        globalLineCount = logLine + 1;
        BEGIN INITIAL;
    }

    <<EOF>> {
        errorCount++;
        logprint << "Error at line no " << (stringStartLine + commentLine)
                 << ": Unterminated Comment " << commentString << "\n" << endl;
        globalLineCount = stringStartLine + commentLine + 1;
        BEGIN INITIAL;
    }
}

{WHITESPACE}+ {}

. {
    errorCount++;
    logprint<<"Error at line no "<<globalLineCount<<": Unrecognized character "<<yytext<<"\n"<<endl;
}
%%

int main(int argc , char* argv[]){
    if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
    //FILE *fin = fopen ("input3.txt", "r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}

	tokenprint.open("tokentest.txt");
	logprint.open("logtest.txt");

    yyin = fin;
    yylex();
    fclose(yyin);

    //symbolTable.printAllScopeTable(logprint);
    symbolTable.PrintAllScopeTables(logprint);
	logprint<<"Total lines: "<<globalLineCount<<endl;
	logprint<<"Total errors: "<<errorCount<<endl;
    
	tokenprint.close();
	logprint.close();


	return 0;

}