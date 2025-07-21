lexer grammar C2105067Lexer;

@lexer::header {
    #pragma once
    #include <iostream>
    #include <fstream>
    #include <string>
    extern std::ofstream lexLogFile;
}

@lexer::members {
    void writeIntoLexLogFile(const std::string &message) {
        if (!lexLogFile.is_open()) {
            // Attempt to open the log file if it's not already open
            // This fallback is good, but ideally, main.cpp should open it first.
            lexLogFile.open("lexerLog.txt", std::ios::app);
            if (!lexLogFile) {
                // Log an error to standard error if file opening fails
                std::cerr << "Error opening lexerLog.txt" << std::endl;
                return; // Exit if file cannot be opened
            }
        }
        lexLogFile << message << std::endl;
        lexLogFile.flush();
    }
}
LINE_COMMENT
    : '//' ~[\r\n]* {
        writeIntoLexLogFile(
          "Line# " + std::to_string(getLine())
          + ": Token <SINGLE LINE COMMENT> Lexeme "
          + getText()
        );
    } -> skip
    ;

BLOCK_COMMENT
  : '/*' ( . | '\r' | '\n' )*? '*/' {
      { // Extra braces create a new scope for local variables
        std::string txt = getText();
        std::string content = "";
        // Extract content between '/*' and '*/'
        if (txt.size() >= 4) { // Ensure string is long enough to avoid out_of_range
            content = txt.substr(2, txt.size() - 4);
        }
        writeIntoLexLogFile(
          "Line# " + std::to_string(getLine())
          + ": Token <MULTI LINE COMMENT> Lexeme /*"
          + content + "*/"
        );
      }
    }
    -> skip 
  ;

STRING
    : '"' ( '\\' . | ~["\\\r\n] )* '"' { // Allows any character or an escaped character, but not newline
        writeIntoLexLogFile(
          "Line# " + std::to_string(getLine())
          + ": Token <STRING> Lexeme " + getText()
        );
    }
    ;

WS      : [ \t\f\r\n]+ -> skip ; 

IF       : 'if'      { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <IF> Lexeme " + getText()); };
ELSE     : 'else'    { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <ELSE> Lexeme " + getText()); };
FOR      : 'for'     { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <FOR> Lexeme " + getText()); };
WHILE    : 'while'   { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <WHILE> Lexeme " + getText()); };
PRINTLN  : 'printf' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <PRINTLN> Lexeme " + getText()); };
RETURN   : 'return'  { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <RETURN> Lexeme " + getText()); };
INT      : 'int'     { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <INT> Lexeme " + getText()); };
FLOAT    : 'float'   { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <FLOAT> Lexeme " + getText()); };
VOID     : 'void'    { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <VOID> Lexeme " + getText()); };


LPAREN   : '(' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <LPAREN> Lexeme " + getText()); };
RPAREN   : ')' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <RPAREN> Lexeme " + getText()); };
LCURL    : '{' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <LCURL> Lexeme " + getText()); };
RCURL    : '}' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <RCURL> Lexeme " + getText()); };
LTHIRD   : '[' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <LTHIRD> Lexeme " + getText()); };
RTHIRD   : ']' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <RTHIRD> Lexeme " + getText()); };
SEMICOLON: ';' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <SEMICOLON> Lexeme " + getText()); };
COMMA    : ',' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <COMMA> Lexeme " + getText()); };

ADDOP    : '+' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <ADDOP> Lexeme " + getText()); }; // Matches only '+'
SUBOP    : '-' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <SUBOP> Lexeme " + getText()); }; // Matches only '-'
MULOP    : [*/%] { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <MULOP> Lexeme " + getText()); };
INCOP    : '++' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <INCOP> Lexeme " + getText()); };
DECOP    : '--' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <DECOP> Lexeme " + getText()); };
NOT      : '!' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <NOT> Lexeme " + getText()); };
RELOP    : '<=' | '==' | '>=' | '>' | '<' | '!=' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <RELOP> Lexeme " + getText()); };
LOGICOP  : '&&' | '||' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <LOGICOP> Lexeme " + getText()); };
ASSIGNOP : '=' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <ASSIGNOP> Lexeme " + getText()); };
PLUS_EQUAL    :  '+'[ \t\r\n]*'=' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <PLUS_EQUAL> Lexeme " + getText()); };


ID         : [A-Za-z_] [A-Za-z0-9_]* { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <ID> Lexeme " + getText()); };
CONST_INT  : [0-9]+ { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <CONST_INT> Lexeme " + getText()); };
CONST_FLOAT
    : [0-9]+ ('.' [0-9]*)? ([Ee][+\-]? [0-9]+)? { // Matches 123.45e+6, 123., .45e-2, 123
        writeIntoLexLogFile(
          "Line# " + std::to_string(getLine())
          + ": Token <CONST_FLOAT> Lexeme " + getText()
        );
    }
    | '.' [0-9]+ { // Matches .123 (without leading digits)
        writeIntoLexLogFile(
          "Line# " + std::to_string(getLine())
          + ": Token <CONST_FLOAT> Lexeme " + getText()
        );
    }
    | [0-9]+ '.' { // Matches 123. (with trailing dot but no fractional part)
        writeIntoLexLogFile(
          "Line# " + std::to_string(getLine())
          + ": Token <CONST_FLOAT> Lexeme " + getText()
        );
    }
    ;

CONST_CHAR : '\'' ( ~('\''|'\\') | ESCAPE_SEQUENCE ) '\'' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <CONST_CHAR> Lexeme " + getText()); };

fragment ESCAPE_SEQUENCE
    : '\\' (
          'n'    
        | 't'    
        | 'r'    
        | '\\'   
        | '\''   
        | '"'    
        | '0'    
        | 'a'    
        | 'b'    
        | 'f'    
        | 'v'   
    );


SYMBOL: [@#$^&] { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <SYMBOL> Lexeme " + getText()); };
