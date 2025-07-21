parser grammar C2105067Parser;

options {
	tokenVocab = C2105067Lexer;
}

@parser::header {
    #pragma once
    #include <iostream>
    #include <fstream>
    #include <string>
    #include <vector>
    #include <cstdlib>      
    #include <algorithm> 
    #include "antlr4-runtime.h"
    #include "C2105067Lexer.h"
    #include "hash.hpp"
    #include "symbolInfo.hpp"
    #include "SymbolTable.hpp"
    #include "ScopeTable.hpp"
    extern std::ofstream parserLogFile; 
    extern std::ofstream errorFile;      
    extern std::ofstream lexLogFile;     
    extern int syntaxErrorCount;       
    extern int semanticErrorCount;      
    extern int bucketsize;            
    extern SymbolTable symboltable;
	extern string globalprogram;
}

@parser::members {
    void writeIntoparserLogFile(const std::string message) {
        if (!parserLogFile.is_open()) {
            parserLogFile.open("log.txt", std::ios::app);
            if (!parserLogFile) {
                std::cerr << "Error opening log.txt" << std::endl;
                return;
            }
        }
        parserLogFile << message << std::endl;
        parserLogFile.flush();            
    }

    void writeIntoErrorFile(const std::string message) {
        if (!errorFile.is_open()) {
            errorFile.open("error.txt", std::ios::app);
            if (!errorFile) {
                std::cerr << "Error opening error.txt" << std::endl;
                return;
            }
        }
        errorFile << message << std::endl; 
        errorFile.flush();                 
        semanticErrorCount++;
    }

    // Helper function to check if a type is numeric (int or float)
bool isNumericType(const std::string& type) {
    return type == "INT" || type == "FLOAT";
}

// Helper function to check if a type is integer
bool isIntegerType(const std::string& type) {
    return type == "INT";
}

std::string checkCompatibility(const std::string& type1, const std::string& type2, const std::string& op, int line,bool print=true) {
    if (type1 == "unknown" || type2 == "unknown") return "unknown";

        if (op == "++" || op == "--") {
        if (!isNumericType(type1)) {
            if(print) writeIntoErrorFile("Line# " + std::to_string(line) + ": Error: Increment/decrement operator applies only to numeric types. Found " + type1 + ".");
            return "ERROR";
        }
        return type1;
    } else if (op == "!") { 
        if (!isIntegerType(type1)) {
            if(print) writeIntoErrorFile("Line# " + std::to_string(line) + ": Error: Logical NOT operator applies only to integer types. Found " + type1 + ".");
            return "ERROR";
        }
        return "INT";
    } else if (op == "+" && type2.empty()) {
        if (!isNumericType(type1)) {
           if(print) writeIntoErrorFile("Line# " + std::to_string(line) + ": Error: Unary plus operator applies only to numeric types. Found " + type1 + ".");
            return "ERROR";
        }
        return type1;
    } else if (op == "-" && type2.empty()) { 
        if (!isNumericType(type1)) {
            if(print) writeIntoErrorFile("Line# " + std::to_string(line) + ": Error: Unary minus operator applies only to numeric types. Found " + type1 + ".");
            return "ERROR";
        }
        return type1;
    }

    if (op == "=") {
        if (type1 == type2) return type1;
        if (type1 == "FLOAT" && type2 == "INT") {
           //if(print) writeIntoErrorFile("Error at line " + std::to_string(line) + ": Type Mismatch\n");
            return type1;
        }
        if (type1 == "INT" && type2 == "FLOAT") {
            if(print) writeIntoErrorFile("Error at line# " + std::to_string(line) + ": Type Mismatch\n");
           //if(print) writeIntoparserLogFile("Error at Line# " + std::to_string(line) + ": argument mismatch in function func\n");
            return "ERROR"; // Disallow
        }
        //void function
        if(print) writeIntoErrorFile("Error at line# " + std::to_string(line) + ": for(=) sign Void function in expression\n");
        return "ERROR";
    } else if (op == "%") {
        if (!isIntegerType(type1) || !isIntegerType(type2)) {
            if(print) writeIntoErrorFile("Line# " + std::to_string(line) + ": Error: Operands of modulus operator must be integers. Found " + type1 + " and " + type2 + ".");
            return "ERROR";
        }
        return "INT";
    } else if (op == "+" || op == "-" || op == "*" || op == "/") {

        if (type2.empty()) {
            if(print)  writeIntoErrorFile("Line# " + std::to_string(line) + ": Internal Error: Binary operator '" + op + "' called without a second operand.");
            return "ERROR";
        }
        if (!isNumericType(type1) || !isNumericType(type2)) {
           // writeIntoErrorFile("Line# " + std::to_string(line) + ": Error: Invalid types for arithmetic operation '" + op + "': " + type1 + " and " + type2 + ".");
            return "ERROR";
        }
        if (type1 == "FLOAT" || type2 == "FLOAT") return "FLOAT";
        return "INT"; // Otherwise, result is INT
    } else if (op == "<" || op == "<=" || op == ">" || op == ">=" || op == "==" || op == "!=") {
        if (!isNumericType(type1) || !isNumericType(type2)) {
           if(print) writeIntoErrorFile("Line# " + std::to_string(line) + ": Error: Invalid types for relational operation '" + op + "': " + type1 + " and " + type2 + ".");
            return "ERROR";
        }
        return "INT"; // Result of relational ops is typically a boolean (represented as INT)
    } else if (op == "&&" || op == "||") { // Logical operators
         if (!isIntegerType(type1) || !isIntegerType(type2)) {
           if(print) writeIntoErrorFile("Line# " + std::to_string(line) + ": Error: Invalid types for logical operation '" + op + "': " + type1 + " and " + type2 + ".");
            return "ERROR";
        }
        return "INT"; // Result is INT (boolean)
    }
    
    return "ERROR";
}   
}

start:
	program {
    };

program:
	u = unit+
	{
        writeIntoparserLogFile("Line " +std:: to_string($u.stop->getLine()) + " : start : program\n");
        symboltable.PrintAllScopeTables(parserLogFile);
    };

unit:
	var_declaration {
         std::string funcdef = _input->getTokenSource()->getInputStream()->getText(
    antlr4::misc::Interval($var_declaration.start->getStartIndex(), $var_declaration.stop->getStopIndex()));

	writeIntoparserLogFile("Line " + std::to_string($var_declaration.start->getLine()) + ": unit : var_declaration\n\n" + funcdef + "\n");

bool check=false;
if(globalprogram=="") check=true;
  globalprogram += funcdef + "\n";
if(check){
 writeIntoparserLogFile("Line " + std::to_string($var_declaration.start->getLine()) + ":program : unit\n\n" + globalprogram + "\n");
}
else{
	writeIntoparserLogFile("Line " + std::to_string($var_declaration.start->getLine()) + ": program : program unit\n\n" + globalprogram + "\n");
}
 
 }
	| func_declaration { 
        //writeIntoparserLogFile("Line " + std::to_string($func_declaration.start->getLine()) + ": unit : func_declaration\n\n" + _func_declaration->getText() + "\n");

    std::string funcdec = _input->getTokenSource()->getInputStream()->getText(
    antlr4::misc::Interval($func_declaration.start->getStartIndex(), $func_declaration.stop->getStopIndex()));
writeIntoparserLogFile("Line " + std::to_string($func_declaration.start->getLine()) +
                       ": unit : func_declaration\n\n" + funcdec + "\n");

	 bool check=false;
    if(globalprogram=="") check=true;
    globalprogram +=funcdec + "\n";
    if(check){
         writeIntoparserLogFile("Line " + std::to_string($func_declaration.start->getLine()) + ":program : unit\n\n" + globalprogram + "\n");
    }
    else{
	    writeIntoparserLogFile("Line " + std::to_string($func_declaration.start->getLine()) + ": program : program unit\n\n" + globalprogram + "\n");
    }

 }
	| func_definition { 

std::string funcdef = _input->getTokenSource()->getInputStream()->getText(
    antlr4::misc::Interval($func_definition.start->getStartIndex(), $func_definition.stop->getStopIndex())
);

writeIntoparserLogFile("Line " + std::to_string($func_definition.stop->getLine()) +
                       ": unit : func_definition\n\n" + funcdef + "\n");

	 bool check=false;
	 if(globalprogram=="") check=true;
  globalprogram +=funcdef + "\n";
if(check){
 writeIntoparserLogFile("Line " + std::to_string($func_definition.start->getLine()) + ":program : unit\n\n" + globalprogram + "\n");
}
else{
	writeIntoparserLogFile("Line " + std::to_string($func_definition.stop->getLine()) + ": program : program unit\n\n" + globalprogram + "\n");
}
	 };

// --- Function Declarations --- Defines a function's signature without its body.
func_declaration:
	type_specifier rType = ID LPAREN pList = parameter_list RPAREN SEMICOLON {
        
        std::string funcdef = _input->getTokenSource()->getInputStream()->getText(
    antlr4::misc::Interval($type_specifier.start->getStartIndex(), $SEMICOLON->getStopIndex())
);

        writeIntoparserLogFile("Line " + std::to_string($type_specifier.start->getLine()) + ": func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON\n\n" + funcdef + "\n");

        std::string funcName = $rType.text;
        std::string returnType = $type_specifier.type;
        std::vector<std::string> paramTypes = $pList.types;

        SymbolInfo* existingSymbol = symboltable.LookUp(funcName); // Look up in all scopes

        if (existingSymbol) {
            if (existingSymbol->getIsFunction()) {
                if (existingSymbol->getReturnType() != returnType) {
                    writeIntoErrorFile("Error at line " + std::to_string($rType.line) + ": Return type mismatch with function declaration in function " + funcName + " \n\n");
                     writeIntoparserLogFile("Error at line " + std::to_string($rType.line) + ": Return type mismatch with function declaration in function " + funcName + " \n\n");
                }
                else if(existingSymbol->getParamTypes() != paramTypes){

                }
            } else {
                writeIntoErrorFile("Error at line " + std::to_string($rType.line) + ": Multiple declaration of " + funcName + "\n");
                writeIntoparserLogFile("Error at line " + std::to_string($rType.line) + ": Multiple declaration of " + funcName + "\n");
            }
        } else {
            symboltable.Insert(funcName, "FUNCTION", true, returnType, paramTypes, $rType.line, parserLogFile);
        }
    }
	// Alternative: Function declaration with no parameters
	| type_specifier rType = ID LPAREN RPAREN SEMICOLON {

        std::string funcdec = _input->getTokenSource()->getInputStream()->getText(
    antlr4::misc::Interval($type_specifier.start->getStartIndex(), $SEMICOLON->getStopIndex()));


        writeIntoparserLogFile("Line " + std::to_string($type_specifier.start->getLine()) + ": func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON\n\n"+ funcdec +"\n");
        std::string funcName = $rType.text;
        std::string returnType = $type_specifier.type;
        std::vector<std::string> paramTypes = {};

        SymbolInfo* existingSymbol = symboltable.LookUp(funcName);
        if (existingSymbol) {
            if (existingSymbol->getIsFunction()) {
                if (existingSymbol->getReturnType() != returnType || !existingSymbol->getParamTypes().empty()) {
                    writeIntoErrorFile("Line# " + std::to_string($rType.line) + ": Error: Function redeclaration '" + funcName + "' with inconsistent signature (expected no parameters).");
                }
            } else {
                writeIntoErrorFile("Error at line " + std::to_string($rType.line) + ": Multiple declaration of " + funcName + "\n");
                writeIntoparserLogFile("Error at line " + std::to_string($rType.line) + ": Multiple declaration of " + funcName + "\n");
            }
        } else {
            symboltable.Insert(funcName, "FUNCTION", true, returnType, paramTypes, $rType.line, parserLogFile);
        }
    };

func_definition:
    type_specifier rType = ID LPAREN pList = parameter_list RPAREN
    {
        std::string funcName = $rType.text;
        std::string returnType = $type_specifier.type;
        std::vector<std::string> paramTypes = $pList.types;
        std::vector<std::string> paramNames = $pList.names;
        int funcIdentifierLine = $rType.line;

int missingIdx = -1;
for(int i=0; i < $pList.names.size(); i++){
    if ($pList.names[i] == "")  missingIdx = i+1;
}
//if(missingIdx > -1) writeIntoErrorFile("Error at line "+ std::to_string(funcIdentifierLine)+": " +std::to_string(missingIdx) +"th parameter's name not given in function definition of "+ funcName +"\n");
        SymbolInfo* existingSymbol = symboltable.LookUp(funcName);
        if (existingSymbol) {
            if (existingSymbol->getIsFunction()) {
                bool signatureMismatch = false;

                // return type consistency
                if (existingSymbol->getReturnType() != returnType) {
                    writeIntoErrorFile("Error at line " + std::to_string(funcIdentifierLine) + ": Return type mismatch with function declaration in function " + funcName + "\n\n");
                    writeIntoparserLogFile("Error at line " + std::to_string(funcIdentifierLine) + ": Return type mismatch with function declaration in function " + funcName +"\n\n");
                    signatureMismatch = true;
                }

                // parameter count consistency
                if (existingSymbol->getParamTypes().size() != paramTypes.size()) {
                   writeIntoErrorFile("Error at line " + std::to_string(funcIdentifierLine) + ": Total number of arguments mismatch with declaration in function " + funcName + "\n\n");
                    writeIntoparserLogFile("Error at line " + std::to_string(funcIdentifierLine) + ": Total number of arguments mismatch with declaration in function " + funcName + "\n\n");
                     signatureMismatch = true;
                } else {
                    // Checking individual parameter types only if count matches
                    for (size_t i = 0; i < paramTypes.size(); ++i) {
                        if (existingSymbol->getParamTypes()[i] != paramTypes[i]) {
                            writeIntoErrorFile("Error at line " + std::to_string(funcIdentifierLine) + ": Function '" + funcName + "' redeclared with inconsistent type for parameter " + std::to_string(i+1) + ". Expected '" + existingSymbol->getParamTypes()[i] + "', got '" + paramTypes[i] + "'.\n");
                            writeIntoparserLogFile("Error at line " + std::to_string(funcIdentifierLine) + ": Function '" + funcName + "' redeclared with inconsistent type for parameter " + std::to_string(i+1) + ". Expected '" + existingSymbol->getParamTypes()[i] + "', got '" + paramTypes[i] + "'.\n");
                            signatureMismatch = true;
                        }
                    }
                }
            } else {
                // Name conflict with a non-function symbol
                writeIntoErrorFile("Error at line " + std::to_string($rType.line) + ": Redeclaration of " + funcName + "\n\n");
                writeIntoparserLogFile("Error at line " + std::to_string($rType.line) + ": Redeclaration of " + funcName + "\n\n");
            }
        } else {
            // if New function declaration/definition
            symboltable.Insert(funcName, "FUNCTION", true, returnType, paramTypes, funcIdentifierLine, parserLogFile);
        }
    }
    cStat = compound_statement[$pList.names, $pList.types,returnType] {
        std::string funcdef = _input->getTokenSource()->getInputStream()->getText(
            antlr4::misc::Interval($type_specifier.start->getStartIndex(), $cStat.stop->getStopIndex()));
        writeIntoparserLogFile("Line " + std::to_string($cStat.endLine) + ": func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement\n\n" + funcdef + "\n");
    }

    // Function definition with no parameters
    | type_specifier rType = ID LPAREN RPAREN
    {
        std::string funcName = $rType.text;
        std::string returnType = $type_specifier.type;
        int funcIdentifierLine = $rType.line;

        SymbolInfo* existingSymbol = symboltable.LookUp(funcName);
        if (existingSymbol) {
            if (existingSymbol->getIsFunction()) {
                // for redeclaration consistency (no params expected this time)
                bool signatureMismatch = false;
                if (existingSymbol->getReturnType() != returnType) {
                    writeIntoErrorFile("Error at line " + std::to_string(funcIdentifierLine) + ": Return type mismatch with function declaration in function " + funcName + "\n\n");
                    writeIntoparserLogFile("Error at line " + std::to_string(funcIdentifierLine) + ": Return type mismatch with function declaration in function " + funcName + "\n\n");
                    signatureMismatch = true;
                }
                if (!existingSymbol->getParamTypes().empty()) { // If it had parameters before but now has none
                     writeIntoErrorFile("Error at line " + std::to_string(funcIdentifierLine) + ": Function '" + funcName + "' redeclared with inconsistent number of arguments. Expected 0, got " + std::to_string(existingSymbol->getParamTypes().size()) + " (from previous declaration).\n");
                     writeIntoparserLogFile("Error at line " + std::to_string(funcIdentifierLine) + ": Function '" + funcName + "' redeclared with inconsistent number of arguments. Expected 0, got " + std::to_string(existingSymbol->getParamTypes().size()) + " (from previous declaration).\n");
                     signatureMismatch = true;
                }
            } else {
                // Name conflict with a nonfunction symbol
                writeIntoErrorFile("Error at line " + std::to_string($rType.line) + ": Redeclaration of " + funcName + "\n\n");
                writeIntoparserLogFile("Error at line " + std::to_string($rType.line) + ": Redeclaration of " + funcName + "\n\n");
            }
        } else {
            symboltable.Insert(funcName, "FUNCTION", true, returnType, {}, funcIdentifierLine, parserLogFile);
        }
    }
    cStat = compound_statement[ std:: vector<std::string>(), std:: vector<std::string>(),returnType ]
    {
        std::string funcdef = _input->getTokenSource()->getInputStream()->getText(
            antlr4::misc::Interval($type_specifier.start->getStartIndex(), $cStat.stop->getStopIndex()));

        writeIntoparserLogFile("Line " + std::to_string($cStat.endLine) + ": func_definition : type_specifier ID LPAREN RPAREN compound_statement\n\n" + funcdef + "\n");
    };


parameter_list
    returns[std::vector<std::string> types, std::vector<std::string> names, std::vector<int> lines]: // Add 'std::vector<int> lines'
    pd = parameter_declaration {
        $types.push_back($pd.type);
        $names.push_back($pd.name);
        $lines.push_back($pd.line); 
 
        std::string funcdef = _input->getTokenSource()->getInputStream()->getText(
    antlr4::misc::Interval($parameter_declaration.start->getStartIndex(), $parameter_declaration.stop->getStopIndex()));
        writeIntoparserLogFile("Line " + std::to_string($pd.start->getLine()) + ": parameter_list : type_specifier ID\n\n" + funcdef + "\n");
    } (
        COMMA pd2 = parameter_declaration {
        $types.push_back($pd2.type);
        $names.push_back($pd2.name);
        $lines.push_back($pd2.line);

          std::string funcdef = _input->getTokenSource()->getInputStream()->getText(
    antlr4::misc::Interval($pd.start->getStartIndex(), $pd2.stop->getStopIndex()));
        writeIntoparserLogFile("Line " + std::to_string($pd2.start->getLine()) + ": parameter_list : parameter_list COMMA type_specifier ID\n\n" + funcdef + "\n");
    }
    )*;

parameter_declaration
    returns[std::string type, std::string name, int line]:
    t = type_specifier pID = ID {
        $type = $t.type;
        $name = $pID.text;
        $line = $pID.line;
    }
    | t = type_specifier invalid = . {
        $type = $t.type;
        $name = "";
        $line = $invalid->getLine();
        writeIntoErrorFile("Error at line " + std::to_string($line) + " syntax error,expecting RPAREN or COMMA.\n");
        writeIntoparserLogFile("Error at line " + std::to_string($line) + " syntax error,expecting RPAREN or COMMA.\n");
    };
 compound_statement[std::vector<std::string> paramNames, std::vector<std::string> paramTypes, std :: string returnType]
    returns [int endLine] :
    LCURL {
            symboltable.EnterScope();

            if(paramNames.size() != 0) {
                for (size_t i = 0; i < paramNames.size(); i++) {
                    SymbolInfo* existingSym = symboltable.LookUpInCurrentScope(paramNames[i]);
                    if (existingSym) {
                        writeIntoErrorFile("Error at line " + std::to_string($LCURL.line) + ": Multiple declaration of " + paramNames[i] + " in parameter\n");
                        writeIntoparserLogFile("Error at line " + std::to_string($LCURL.line) + ": Multiple declaration of " + paramNames[i] + " in parameter\n");
                    } else {
                        symboltable.Insert(paramNames[i], paramTypes[i], $LCURL.line, parserLogFile);
                    }
                }
            }
    } statements RCURL {
        std::string funcdef = _input->getTokenSource()->getInputStream()->getText(
                antlr4::misc::Interval($LCURL->getStartIndex(), $RCURL->getStopIndex()));

        writeIntoparserLogFile("Line " + std::to_string($RCURL.line) + ": compound_statement : LCURL statements RCURL\n\n" + funcdef + "\n");
        symboltable.PrintAllScopeTables(parserLogFile);
        symboltable.ExitScope();
        $endLine = $RCURL.line;
        //cout<<returnType<<endl;
        if($statements.returnSome && returnType=="VOID"){
            writeIntoErrorFile("Error at line " + to_string($RCURL->getLine()) + ": Cannot return value from function with void return type\n");
            }
    }
    |LCURL {
            symboltable.EnterScope();

            if(paramNames.size() != 0) {
                for (size_t i = 0; i < paramNames.size(); i++) {
                    SymbolInfo* existingSym = symboltable.LookUpInCurrentScope(paramNames[i]);
                    if (existingSym) {
                        writeIntoErrorFile("Error at line " + std::to_string($LCURL.line) + ": Multiple declaration of " + paramNames[i] + " in parameter\n");
                        writeIntoparserLogFile("Error at line " + std::to_string($LCURL.line) + ": Multiple declaration of " + paramNames[i] + " in parameter\n");
                    } else {
                        symboltable.Insert(paramNames[i], paramTypes[i], $LCURL.line, parserLogFile);
                    }
                }
            }
    } RCURL {
        std::string funcdef = _input->getTokenSource()->getInputStream()->getText(
                antlr4::misc::Interval($LCURL->getStartIndex(), $RCURL->getStopIndex()));

        writeIntoparserLogFile("Line " + std::to_string($RCURL.line) + ": compound_statement : LCURL statements RCURL\n\n" + funcdef + "\n");
        symboltable.PrintAllScopeTables(parserLogFile);
        symboltable.ExitScope();
        $endLine = $RCURL.line;
        //cout<<returnType<<endl;
    };
var_declaration:
    t = type_specifier dl = declaration_list[ $t.type ] sm = SEMICOLON {
        std::string typeText;
        if ($t.type == "INT") typeText = "int";
        else if ($t.type == "FLOAT") typeText = "float";
        else if ($t.type == "VOID") typeText = "void";

        if(typeText == "void"){
             writeIntoparserLogFile(
            "Error at line " + std::to_string(_localctx->getStart()->getLine()) +
            ": Variable type cannot be void \n\n");
             writeIntoErrorFile(
            "Error at line " + std::to_string(_localctx->getStart()->getLine()) +
            ": Variable type cannot be void \n\n");
        }
        std::string fullDeclarationText = typeText + " " + $dl.fullText + $sm->getText();

        writeIntoparserLogFile(
            "Line " + std::to_string(_localctx->getStart()->getLine()) +
            ": var_declaration : type_specifier declaration_list SEMICOLON\n\n" +
            fullDeclarationText + "\n"
        );
    }
    | t = type_specifier de = declaration_list_err sm = SEMICOLON {
        writeIntoparserLogFile("Line " + std::to_string($t.start->getLine()) + ": var_declaration : type_specifier declaration_list_err SEMICOLON");
        writeIntoErrorFile(
            std::string("Line# ") + std::to_string($sm->getLine()) +
            " with error: " + $de.error_name +
            " - Syntax error at variable declaration."
        );
        syntaxErrorCount++;
    };

declaration_list_err
    returns[std::string error_name]:
    {
        $error_name = "Malformed declaration list";
    };

type_specifier
    returns[std::string type]:
    INT {
        writeIntoparserLogFile("Line " + std::to_string($INT.line) + ": type_specifier : INT\n\n" + $INT.text + "\n");
        $type = "INT";
    }
    | FLOAT {
        writeIntoparserLogFile("Line " + std::to_string($FLOAT.line) + ": type_specifier : FLOAT\n\n"+ $FLOAT.text + "\n");
        $type = "FLOAT";
    }
    | VOID {
        writeIntoparserLogFile("Line " + std::to_string($VOID.line) + ": type_specifier : VOID\n\n"+ $VOID.text + "\n");
        $type = "VOID";
    };

declaration_list[std::string baseType]
    returns[std::vector<std::string> declaredNames, std::string fullText]:
    firstDecl = declaration_item[$baseType] {
        $declaredNames.push_back($firstDecl.name);
        $fullText = $firstDecl.text;
        writeIntoparserLogFile("Line " + std::to_string($firstDecl.line) + ": declaration_list : " + $firstDecl.rule_match_text + "\n\n" + $fullText + "\n");
    }
    ( COMMA nextDecl = declaration_item[$baseType] {
        $declaredNames.push_back($nextDecl.name);
        $fullText += ", " + $nextDecl.text; // Added a space for better readability
        writeIntoparserLogFile("Line " + std::to_string($nextDecl.line) + ": declaration_list : declaration_list COMMA " + $nextDecl.rule_match_text + "\n\n" + $fullText + "\n");
    }
        )*
;

declaration_item[std::string baseType]
    returns[std::string name, std::string text, int line, std::string rule_match_text]: // Added rule_match_text
    varID = ID {
        $name = $varID.text;
        $text = $varID.text;
        $line = $varID.line;
        $rule_match_text = "ID";

        SymbolInfo* existingSym = symboltable.LookUpInCurrentScope($name);
        if (existingSym) {
             writeIntoparserLogFile("Error at line " + std::to_string($line) + ": Multiple declaration of " + $name + "\n");
            writeIntoErrorFile("Error at line " + std::to_string($line) + ": Multiple declaration of " + $name + "\n");
        } else {
            symboltable.Insert($name, baseType, $line, parserLogFile);
        }
    }
    | arrayID = ID LTHIRD size = CONST_INT RTHIRD {
        $name = $arrayID.text;
        $text = $arrayID.text + "[" + $size.text + "]";
        $line = $arrayID.line;
        $rule_match_text = "ID LTHIRD CONST_INT RTHIRD";

        int arraySize = 0;
        try {
            arraySize = std::stoi($size.text);
        } catch (const std::out_of_range& oor) {
            writeIntoErrorFile("Line# " + std::to_string($size.line) + ": Error: Array size constant is too large or invalid: " + $size.text + ".");
            arraySize = 1;
        } catch (const std::invalid_argument& ia) {
            writeIntoErrorFile("Line# " + std::to_string($size.line) + ": Error: Invalid array size constant: " + $size.text + ".");
            arraySize = 1;
        }

        if (arraySize <= 0) {
            writeIntoErrorFile("Line# " + std::to_string($size.line) + ": Error: Array size must be a positive integer. Found " + std::to_string(arraySize) + ".");
            arraySize = 1;
        }

        SymbolInfo* existingSym = symboltable.LookUpInCurrentScope($name);
        if (existingSym) {
            writeIntoparserLogFile("Error at line " + std::to_string($line) + ": Multiple declaration of " + $name + "\n");
            writeIntoErrorFile("Error at line " + std::to_string($line) + ": Multiple declaration of " + $name + "\n");
        } else {
            symboltable.Insert($name, baseType, true, arraySize, $line, parserLogFile);
        }
    }
    | statements {
        writeIntoErrorFile("Error a line " + to_string($statements.line) + " syntax error" + "\n");
    }

;

// A sequence of one or more statements.
statements returns [std::string text, int line, bool returnSome]:
    firstStat = statement {
        std::string firstStatText = _input->getTokenSource()->getInputStream()->getText(
            antlr4::misc::Interval($firstStat.start->getStartIndex(), $firstStat.stop->getStopIndex()));

        writeIntoparserLogFile("Line " + std::to_string($firstStat.start->getLine()) +
                               ": statements : statement\n\n" + firstStatText + "\n");

        $text = firstStatText; 
        $line = $firstStat.start->getLine();
        $returnSome = $statement.returnSome;
    }
    (tail = statements_tail[$text] {
        $text += " " + $tail.text;
    })?
;


statements_tail[std::string inheritedText] returns [std::string text, int line, bool returnSome]:
    nextStat = statement {
        std::string nextStatText = _input->getTokenSource()->getInputStream()->getText(
            antlr4::misc::Interval($nextStat.start->getStartIndex(), $nextStat.stop->getStopIndex()));

        $text = inheritedText + "\n" + nextStatText;
        $line = $nextStat.stop->getLine();
        writeIntoparserLogFile("Line " + std::to_string($line) +
                               ": statements : statements statement\n\n" + $text + "\n");
        $returnSome = $statement.returnSome;
    }
    (tail = statements_tail[$text] {
        $text = $tail.text;
    })?
;


statement returns [std::string text, int line, bool returnSome]:
    var_declaration {
         std::string nextStatText = _input->getTokenSource()->getInputStream()->getText(
            antlr4::misc::Interval($var_declaration.start->getStartIndex(), $var_declaration.stop->getStopIndex()));

        writeIntoparserLogFile("Line " + std::to_string($var_declaration.start->getLine()) + ": statement : var_declaration\n\n" + nextStatText + "\n");
        $text = nextStatText;
        $line = _localctx->getStart()->getLine();
        $returnSome=false;
    }
    | expression_statement {
          std::string nextStatText = _input->getTokenSource()->getInputStream()->getText(
            antlr4::misc::Interval($expression_statement.start->getStartIndex(), $expression_statement.stop->getStopIndex()));

        writeIntoparserLogFile("Line " + std::to_string($expression_statement.start->getLine()) + ": statement : expression_statement\n\n" + nextStatText + "\n");
        $text = nextStatText;
        $line = _localctx->getStart()->getLine();
        $returnSome=false;
    }
    | compound_statement[std::vector<std::string>(), std::vector<std::string>(),""]
 {
         std::string nextStatText = _input->getTokenSource()->getInputStream()->getText(
            antlr4::misc::Interval($compound_statement.start->getStartIndex(), $compound_statement.stop->getStopIndex()));

        writeIntoparserLogFile("Line " + std::to_string($compound_statement.stop->getLine()) + ": statement : compound_statement\n\n" + nextStatText + "\n");
        $text = _localctx->getText();
        $line = _localctx->getStart()->getLine();
        //$returnSome=false;
    }
    | FOR LPAREN expression_statement  expression_statement expression RPAREN body = statement {
         std::string firstStatText = _input->getTokenSource()->getInputStream()->getText(
            antlr4::misc::Interval($FOR->getStartIndex(), $body.stop->getStopIndex()));

        writeIntoparserLogFile("Line " + std::to_string($body.stop->getLine()) + ": statement : FOR LPAREN expression_statement expression RPAREN statement\n\n" + firstStatText + "\n");
        
        $text = _localctx->getText();
        $line = _localctx->getStart()->getLine();
        $returnSome=false;
      }
    | IF LPAREN cond = expression RPAREN thenStat = statement ELSE elseStat = statement {
          std::string Text = _input->getTokenSource()->getInputStream()->getText(
            antlr4::misc::Interval($IF->getStartIndex(), $elseStat.stop->getStopIndex()));

        writeIntoparserLogFile("Line " + std::to_string($elseStat.stop->getLine()) + ": statement : IF LPAREN expression RPAREN statement ELSE statement\n\n" + Text +"\n");
        if ($cond.type != "INT" && $cond.type != "unknown") {
            writeIntoErrorFile("Line# " + std::to_string($cond.stop->getLine()) + ": Error: Condition of if statement must be an integer. Found " + $cond.type + ".");
        }
        $text = _localctx->getText();
        $line = _localctx->getStart()->getLine();
        $returnSome=false;
      }
    | IF LPAREN cond = expression RPAREN thenStat = statement {
        writeIntoparserLogFile("Line " + std::to_string($IF.line) + ": statement : IF LPAREN expression RPAREN statement");
        if ($cond.type != "INT" && $cond.type != "unknown") {
            writeIntoErrorFile("Line# " + std::to_string($cond.start->getLine()) + ": Error: Condition of if statement must be an integer. Found " + $cond.type + ".");
        }
        $text = _localctx->getText();
        $line = _localctx->getStart()->getLine();
        $returnSome=false;
      }
    | WHILE LPAREN cond = expression RPAREN body = statement {
         std::string firstStatText = _input->getTokenSource()->getInputStream()->getText(
            antlr4::misc::Interval($WHILE->getStartIndex(), $body.stop->getStopIndex()));

        writeIntoparserLogFile("Line " + std::to_string($body.stop->getLine()) + ": statement : WHILE LPAREN expression RPAREN statement\n\n" + firstStatText + "\n");
        if ($cond.type != "INT" && $cond.type != "unknown") {
            writeIntoErrorFile("Line# " + std::to_string($cond.start->getLine()) + ": Error: Condition of while loop must be an integer. Found " + $cond.type + ".");
        }
        $text = _localctx->getText();
        $line = _localctx->getStart()->getLine();
        $returnSome=false;
      }
    | PRINTLN LPAREN printID = ID RPAREN SEMICOLON {
        writeIntoparserLogFile("Line " + std::to_string($PRINTLN.line) + ": statement : PRINTLN LPAREN ID RPAREN SEMICOLON");
        SymbolInfo* sym = symboltable.LookUp($printID.text);
        if (!sym) {
            writeIntoErrorFile("Line# " + std::to_string($printID.line) + ": Error: Undeclared identifier '" + $printID.text + "' in printf statement.");
            writeIntoparserLogFile("Line# " + std::to_string($printID.line) + ": Error: Undeclared identifier '" + $printID.text + "' in printf statement.");
        } else if (sym->getIsFunction()) {
            writeIntoErrorFile("Line# " + std::to_string($printID.line) + ": Error: Cannot print a function '" + $printID.text + "'.");
        } else if (sym->getIsArray()) {
            writeIntoErrorFile("Line# " + std::to_string($printID.line) + ": Error: Cannot print an array '" + $printID.text + "' directly. Use an index.");
        }
        $text = _localctx->getText();
        $line = _localctx->getStart()->getLine();
        $returnSome=false;
      }
    | RETURN expr = expression SEMICOLON {

                 std::string funcdef = _input->getTokenSource()->getInputStream()->getText(
                antlr4::misc::Interval($RETURN->getStartIndex(), $SEMICOLON->getStopIndex()));

        writeIntoparserLogFile("Line " + std::to_string($RETURN.line) + ": statement : RETURN expression SEMICOLON\n\n"+ funcdef +"\n");
        $text = _localctx->getText();
        $line = _localctx->getStart()->getLine();
        $returnSome=true;
      }
    | RETURN SEMICOLON {
        writeIntoparserLogFile("Line " + std::to_string($RETURN.line) + ": statement : RETURN SEMICOLON");
        $text = _localctx->getText();
        $line = _localctx->getStart()->getLine();
        $returnSome=false;
      };

expression_statement:
    SEMICOLON { writeIntoparserLogFile("Line " + std::to_string($SEMICOLON.line) + ": expression_statement : SEMICOLON");
        }
    | expression SEMICOLON { writeIntoparserLogFile("Line " + std::to_string($expression.start->getLine()) + ": expression_statement : expression SEMICOLON\n\n" + _localctx->getText()+ "\n");
        };

variable
	returns[std::string type, bool isArrayAccess]:
	varID = ID {
        writeIntoparserLogFile("Line " + std::to_string($varID.line) + ": variable : ID");
        SymbolInfo* sym = symboltable.LookUp($varID.text);
        std::string errorMessage = ""; 
        bool hasError = false; 

        // undeclared variable
        if (!sym) {
            //symboltable.PrintAllScopeTables(parserLogFile);
            errorMessage = "Error at line " + std::to_string($varID.line) + ": Undeclared variable " + $varID.text + "\n";
            $type = "unknown";
            $isArrayAccess = false;
            hasError = true;
            writeIntoErrorFile("Error at line " + std::to_string($varID.line) + ": Undeclared variable " + $varID.text + "\n");
        }
        // if function identifier used as a variable
        else if (sym->getIsFunction()) {
            errorMessage = "Error at line " + std::to_string($varID.line) + ": Function identifier '" + $varID.text + "' used as a variable.";
            $type = "unknown";
            $isArrayAccess = false;
            hasError = true;
            writeIntoErrorFile("Line# " + std::to_string($varID.line) + ": Error: Function identifier '" + $varID.text + "' used as a variable.");
        }
        // if array used without an index
        else if (sym->getIsArray()) {
                                        
            errorMessage = "Error at line " + std::to_string($varID.line) + ": Type mismatch, " + $varID.text + " is an array\n";
            $type = sym->getElementType(); 
            $isArrayAccess = true;
            hasError = true;
            writeIntoErrorFile("Error at line " + std::to_string($varID.line) + ": Type mismatch, " + $varID.text + " is an array\n");
        }
        // ok
        else {
            $type = sym->getType();
            $isArrayAccess = false;
        }
        if (hasError) {
            writeIntoparserLogFile("\n" + errorMessage + "\n" + _localctx->getText() + "\n");
        } else {
            writeIntoparserLogFile("\n" + _localctx->getText() + "\n");
        }
    }
	| arrayID = ID LTHIRD index = expression RTHIRD {
        SymbolInfo* sym = symboltable.LookUp($arrayID.text); 

        if (!sym) {
            writeIntoErrorFile("Line# " + std::to_string($arrayID.line) + ": Error: Undeclared array '" + $arrayID.text + "'.");
            $type = "unknown";
            $isArrayAccess = true;
        } else if (!sym->getIsArray()) {
            writeIntoErrorFile("Error at line " + std::to_string($arrayID.line) + ": " + $arrayID.text + " not an array\n\n");
            writeIntoparserLogFile("Error at line " + std::to_string($arrayID.line) + ": " + $arrayID.text + " not an array\n\n" + _localctx->getText() + "\n");
            $type = "unknown";
            $isArrayAccess = false; // It's not an array, so it's not an array access

        } else if (!isIntegerType($index.type)) {
            // Array index must be an integer
            writeIntoErrorFile("Error at line "+std::to_string($index.start->getLine())+ ": Expression inside third brackets not an integer\n\n");
            writeIntoparserLogFile("Line " + std::to_string($arrayID.line) + ": variable : ID LTHIRD expression RTHIRD\n\n"); //but there is error now
            writeIntoparserLogFile("Error at line "+std::to_string($index.start->getLine())+ ": Expression inside third brackets not an integer\n\n"+ _localctx->getText() + "\n");  
            
            $type = "unknown"; // Type becomes unknown due to error
            $isArrayAccess = true;
        }
        else{
            writeIntoparserLogFile("Line " + std::to_string($arrayID.line) + ": variable : ID LTHIRD expression RTHIRD\n\n" + _localctx->getText() + "\n");
        }
        // Determining here the actual type of the array element if valid
        if ($type != "unknown" && sym && sym->getIsArray() && isIntegerType($index.type)) {
            $type = sym->getElementType();
        } else {
            $type = "unknown"; 
        }
        $isArrayAccess = true;
     };

expression
	returns[std::string type]:
    left = variable ASSIGNOP right = logic_expression {
        writeIntoparserLogFile("Line " + std::to_string($left.start->getLine()) + ": expression : variable ASSIGNOP logic_expression");

        std::string finalExpressionText = _localctx->getText();
        std::string determinedType = "unknown";
        std::string specificErrorMessage = "";
        bool hasSpecificErrorFromThisRule = false; 

        if ($right.type == "ERROR") {
            determinedType = "ERROR";
        }
        else if ($left.type == "unknown" || $right.type == "unknown") {
            determinedType = "unknown";
        } else {
            SymbolInfo* leftVarSym = symboltable.LookUp($left.start->getText());
            if (leftVarSym && leftVarSym->getIsArray() && !$left.isArrayAccess) {
                specificErrorMessage = "Line# " + std::to_string($left.start->getLine()) + ": Error: Cannot assign directly to array variable '" + $left.start->getText() + "'. An index is required.";
                hasSpecificErrorFromThisRule = true;
                determinedType = "ERROR";
                writeIntoErrorFile(specificErrorMessage);
            } else {
                determinedType = checkCompatibility($left.type, $right.type, "=", ($ASSIGNOP != nullptr ? $ASSIGNOP.line : -1));
                if (determinedType == "ERROR") {
                    specificErrorMessage = "Error at line " + std::to_string($left.start->getLine()) + ": Type Mismatch";
                    hasSpecificErrorFromThisRule = true;
                }
            }
        }

        if (determinedType == "ERROR" && hasSpecificErrorFromThisRule) {
            writeIntoparserLogFile("\n" + specificErrorMessage + "\n" + finalExpressionText + "\n");
            $type = "ERROR";
        } else if (determinedType == "ERROR") {
           writeIntoparserLogFile("\n" + finalExpressionText + "\n");
            $type = "ERROR";
        } else {
            writeIntoparserLogFile("\n" + finalExpressionText + "\n");
            $type = determinedType;
        }
    }
    | left = variable ASSIGNOP term PLUS_EQUAL term {
            writeIntoErrorFile("Error at line " + std::to_string($PLUS_EQUAL->getLine()) +": syntax error : += after assignment operator\n\n");
            writeIntoparserLogFile("Error at line " + std::to_string($PLUS_EQUAL->getLine()) +": syntax error : += after assignment operator\n\n"+_localctx->getText()+"\n");
            $type = "ERROR";
    }
	| logic_expression { writeIntoparserLogFile("Line " + std::to_string($logic_expression.start->getLine()) + ": expression : logic_expression\n\n"+ _localctx->getText()+"\n"); $type = $logic_expression.type; 
		};

// Handles logical AND (&&) and OR (||) operators.
logic_expression
	returns[std::string type]:
	left = rel_expression { 
        writeIntoparserLogFile("Line " + std::to_string($left.start->getLine()) + ": logic_expression : rel_expression\n\n"+_localctx->getText()+"\n"); $type = $left.type; 
		} (
		op = LOGICOP right = rel_expression {
        writeIntoparserLogFile("Line " + std::to_string($op.line) + ": logic_expression : rel_expression LOGICOP rel_expression\n\n" +_localctx->getText()+"\n" );
        if ($left.type == "unknown" || $right.type == "unknown") {
            $type = "unknown";
        } else {
            // Perform type compatibility check for logical operation
            std::string opText = ($op != nullptr) ? $op.text : "";
            int opLine = ($op != nullptr) ? $op.line : -1;
            std::string resultType = checkCompatibility($left.type, $right.type, opText, opLine,true);
            if (resultType == "ERROR") { $type = "ERROR"; }
            else { $type = "INT"; } // Result of logical ops is always boolean (INT)
        }
      }
	)*;

// Handles relational operators (<, <=, >, >=, ==, !=).
rel_expression
	returns[std::string type]:
	left = simple_expression { writeIntoparserLogFile("Line " + std::to_string($left.start->getLine()) + ": rel_expression : simple_expression\n\n"+_localctx->getText()+"\n"); $type = $left.type; 
		} (
		op = RELOP right = simple_expression {
            std::string funcdef = _input->getTokenSource()->getInputStream()->getText(
            antlr4::misc::Interval($left.start->getStartIndex(), $right.stop->getStopIndex()));

        writeIntoparserLogFile("Line " + std::to_string($op.line) + ": rel_expression : rel_expression RELOP simple_expression\n\n"+funcdef+"\n");
        
        if ($left.type == "unknown" || $right.type == "unknown") {
            $type = "unknown";
        } else {
            // Perform type compatibility check for relational operation
            std::string opText = ($op != nullptr) ? $op.text : "";
            int opLine = ($op != nullptr) ? $op.line : -1;
            std::string resultType = checkCompatibility($left.type, $right.type, opText, opLine,true);
            if (resultType == "ERROR") { $type = "ERROR"; }
            else { $type = "INT"; } // Result of relational ops is always boolean (INT)
        }
      }
	)*;

// Handles addition (+) and subtraction (-) operators.
simple_expression
	returns[std::string type]:
	left = term { writeIntoparserLogFile("Line " + std::to_string($left.start->getLine()) + ": simple_expression : term\n\n" + _localctx->getText() + "\n"); $type = $left.type; 
		} (
		op = (ADDOP | SUBOP) right = term {
        writeIntoparserLogFile("Line " + std::to_string($op.line) + ": simple_expression : simple_expression ADDOP term\n\n" + _localctx->getText()+"\n");
        if ($left.type == "unknown" || $right.type == "unknown") {
            $type = "unknown";
        } else {
            std::string opText = ($op != nullptr) ? $op.text : "";
            int opLine = ($op != nullptr) ? $op.line : -1;
            std::string resultType = checkCompatibility($left.type, $right.type, opText, opLine,true);
            if (resultType == "ERROR") { $type = "ERROR"; }
            else { $type = resultType; } // Result type depends on operands (e.g., INT + FLOAT = FLOAT)
        }
      }
	)*;

// Handles multiplication (*), division (/), and modulus (%) operators.
term
    returns[std::string type]:
    left = unary_expression {
        writeIntoparserLogFile("Line " + std::to_string($left.start->getLine()) + ": term : unary_expression\n\n" + _localctx->getText() + "\n");
        $type = $left.type;
    } (
        op = MULOP right = unary_expression {
            writeIntoparserLogFile("Line " + std::to_string($op.line) + ": term : term MULOP unary_expression\n\n"+ _localctx->getText() + "\n");
            std::string currentTermText = _localctx->getText();
            std::string determinedType = "unknown";
            bool hasSpecificModulusError = false;
            bool hasModulusByZeroError = false;

            if (($left.type == "VOID" && $left.isFcall) || ($right.type == "VOID" && $right.isFcall)) {
                writeIntoErrorFile("Error at line# " + std::to_string($op.line) + ": Void function used in expression\n");
                writeIntoparserLogFile("Error at line# " + std::to_string($op.line) + ": Void function used in expression\n" + currentTermText +"\n");
                $type = "ERROR";
            } 
            else {
                std::string opText = ($op != nullptr) ? $op.text : "";
                int opLine = ($op != nullptr) ? $op.line : -1;

                if (opText == "%" && ($left.type != "INT" || $right.type != "INT")) {
                    hasSpecificModulusError = true;
                    determinedType = "ERROR";
                } else if (opText == "%" && ($right.text == "0" || $right.text == "0.0")) {
                    hasModulusByZeroError = true;
                    determinedType = "ERROR";
                } else {
                    determinedType = checkCompatibility($left.type, $right.type, opText, opLine, true);
                }
            }
            if (hasSpecificModulusError) {
                writeIntoErrorFile("Error at line# " + std::to_string($op.line) + ": Non-integer operand on modulus operator.\n");
                writeIntoparserLogFile("Error at line# " + std::to_string($op.line) + ": Non-integer operand on modulus operator.\n");
                $type = "ERROR";
            } else if (hasModulusByZeroError) {
                writeIntoErrorFile("Error at line " + std::to_string($op.line) + ": Modulus by zero.\n");
                writeIntoparserLogFile("Error at line " + std::to_string($op.line) + ": Modulus by zero.\n" + _localctx->getText()+ "\n");
                $type = "ERROR";
            } else if (determinedType == "ERROR") {
                $type = "ERROR";
            } else {
                  $type = determinedType;
            }
            $left.type = $type;
        }
    )*;


// Handles unary operators (+, -, !, ++, --).
unary_expression
	returns[std::string type, bool isFcall]:
	op = (ADDOP | SUBOP | NOT)? expr = factor {
        
        if($op==nullptr){
        writeIntoparserLogFile("Line " + std::to_string($expr.start->getLine()) + ": unary_expression : factor\n\n" + _localctx->getText()+"\n");
        }
        else if($op!=nullptr && ($op.text =="-" || $op.text =="+")){
                    writeIntoparserLogFile("Line " + std::to_string($expr.start->getLine()) + ": unary_expression : ADDOP unary_expression\n\n" + _localctx->getText()+"\n");

         }
        else if($op!=nullptr && ($op.text =="!")){
                                writeIntoparserLogFile("Line " + std::to_string($expr.start->getLine()) + ": unary_expression : NOT unary_expression\n\n" + _localctx->getText()+"\n");

         }
        $type = $expr.type;
        $isFcall = $expr.isFcall;

        if ($op != nullptr) { // If an operator was present
            if ($expr.type == "unknown") {
                $type = "unknown";
            } else { 
                // Perform type compatibility check for unary operation
                std::string opText = ($op != nullptr) ? $op.text : "";
                int opLine = ($op != nullptr) ? $op.line : -1;
                std::string resultType = checkCompatibility($expr.type, "", opText, opLine,true); // Pass empty string for second operand
                if (resultType == "ERROR") { $type = "ERROR"; }
                else { $type = resultType; }
            }
        }
      }
    

	| var = variable INCOP { // Post-increment (e.g., `x++`)
        writeIntoparserLogFile("Line " + std::to_string($var.start->getLine()) + ": unary_expression : variable INCOP\n\n" + _localctx->getText()+"\n");
        if ($var.type == "unknown") {
            $type = "unknown";
        } else {
            std::string opText = ($INCOP != nullptr) ? $INCOP.text : "";
            int opLine = ($INCOP != nullptr) ? $INCOP.line : -1;
            $type = checkCompatibility($var.type, "", opText, opLine,true);
        }
      }
	| var = variable DECOP { // Post-decrement (e.g., `x--`)
        writeIntoparserLogFile("Line " + std::to_string($var.start->getLine()) + ": unary_expression : variable DECOP\n\n" + _localctx->getText()+"\n");
        if ($var.type == "unknown") {
            $type = "unknown";
        } else {
            std::string opText = ($DECOP != nullptr) ? $DECOP.text : "";
            int opLine = ($DECOP != nullptr) ? $DECOP.line : -1;
            $type = checkCompatibility($var.type, "", opText, opLine,true);
        }
      };

// --- Factor --- The most basic elements of an expression: variables, function calls, parenthesized
// expressions, and constants.
factor
    returns[std::string type, bool isFcall]:
    var = variable {
        writeIntoparserLogFile("Line " + std::to_string($var.start->getLine()) + ": factor : variable\n\n" + _localctx->getText() + "\n");
        $type = $var.type;
        $isFcall = false;
    }
    | fcall = function_call {
    $type = $fcall.type;
    $isFcall = true;
    writeIntoparserLogFile("Line " + std::to_string($fcall.start->getLine()) + ": factor : " + $fcall.synt + "\n\n" + _localctx->getText() + "\n");
}

    | LPAREN expr = expression RPAREN {
        writeIntoparserLogFile("Line " + std::to_string($LPAREN.line) + ": factor : LPAREN expression RPAREN\n\n" + _localctx->getText() + "\n");
        $type = $expr.type;
        $isFcall = false;
    }
    | iConst = CONST_INT {
        writeIntoparserLogFile("Line " + std::to_string($iConst.line) + ": factor : CONST_INT\n\n" + _localctx->getText() + "\n");
        $type = "INT";
        $isFcall = false;
    }
    | fConst = CONST_FLOAT {
        writeIntoparserLogFile("Line " + std::to_string($fConst.line) + ": factor : CONST_FLOAT\n\n" + _localctx->getText() + "\n");
        $type = "FLOAT";
        $isFcall = false;
    }
    | CONST_CHAR {
        writeIntoparserLogFile("Line " + std::to_string($CONST_CHAR.line) + ": factor : CONST_CHAR\n\n" + _localctx->getText() + "\n");
        $type = "CHAR";
        $isFcall = false;
    }
    | STRING {
        writeIntoparserLogFile("Line " + std::to_string($STRING.line) + ": factor : STRING");
        $type = "STRING";
        $isFcall = false;
    }
    |SYMBOL{
        writeIntoparserLogFile("Error at line " + std::to_string($SYMBOL.line) + ":Invalid  SYMBOL "+_localctx->getText()+"\n");
        writeIntoErrorFile("Error at line " + std::to_string($SYMBOL.line) + " Invalid SYMBOL \n");
        $type = "SYMBOL";
        $isFcall = false;
    };

function_call
	returns[std::string type, std::string fName, std::string synt]:
	funcID = ID LPAREN aList = argument_list RPAREN {
        //writeIntoparserLogFile("Line " + std::to_string($funcID.line) + ": function_call : ID LPAREN argument_list RPAREN");
        $fName = $funcID.text;
        $synt = "ID LPAREN argument_list RPAREN";
         if ($funcID.text == "printf" || $funcID.text == "scanf") {
            $type = "INT";
        }else{
        SymbolInfo* funcSym = symboltable.LookUp($funcID.text);
         if (!funcSym) {
            writeIntoErrorFile("Error at line " + std::to_string($funcID.line) + ": Error: Undeclared function " + $funcID.text + "\n\n");
            writeIntoparserLogFile("Error at line " + std::to_string($funcID.line) + ": Error: Undeclared function " + $funcID.text + "\n\n");
            $type = "unknown";
        } else if (!funcSym->getIsFunction()) {
            writeIntoErrorFile("Line# " + std::to_string($funcID.line) + ": Error: '" + $funcID.text + "' is not a function and cannot be called.");
            $type = "unknown";
        }

        if ($type != "unknown") { // Only proceed with type checking if function is found and is a function
            std::vector<std::string> expectedParamTypes = funcSym->getParamTypes();
            std::vector<std::string> actualArgTypes = $aList.types;
            int expArgNum=funcSym->getNumParams();

            if (expectedParamTypes.size() != actualArgTypes.size()) {
                writeIntoErrorFile("Error at Line# " + std::to_string($funcID.line)+" Total number of arguments mismatch with declaration in function " + $funcID.text+"\n");
                writeIntoparserLogFile("Error at Line# " + std::to_string($funcID.line)+" Total number of arguments mismatch with declaration in function " + $funcID.text+"\n");
                $type = "unknown";
            }

            size_t minSize = std::min(expectedParamTypes.size(), actualArgTypes.size());
            for (size_t i = 0; i < minSize; ++i) {
                if (checkCompatibility(expectedParamTypes[i], actualArgTypes[i], "=", $funcID.line,false) == "ERROR") { 
                    writeIntoErrorFile("Error at line " + std::to_string($funcID.line) + ": "+std::to_string(i+1)+"th argument mismatch in function " + $funcID.text +"\n\n");
                    writeIntoparserLogFile("Error at line " + std::to_string($funcID.line) + ": "+std::to_string(i+1)+"th argument mismatch in function " + $funcID.text +"\n\n");
                    $type = "ERROR"; // If any type mismatch, mark overall function call type as ERROR
                }
            }
            if ($type != "ERROR") { // If no type errors so far, assign the function's return type
                $type = funcSym->getReturnType();
            }
        }
        }
      };

argument_list
	returns[std::vector<std::string> types]:
	arguments { writeIntoparserLogFile("Line " + std::to_string($arguments.start->getLine()) + ": argument_list : arguments\n\n" + _localctx->getText()+ "\n"); $types = $arguments.types; 
		}
	|; //means no arguments foo()
arguments
	returns[std::vector<std::string> types]:
	logic_expression { 
        writeIntoparserLogFile("Line " + std::to_string($logic_expression.start->getLine()) + ": arguments : logic_expression\n\n" + _localctx->getText() + "\n"); 
        $types.push_back($logic_expression.type); 
		} (
		COMMA logic_expression { writeIntoparserLogFile("Line " + std::to_string($logic_expression.start->getLine()) + ": arguments : arguments COMMA logic_expression\n\n" + _localctx->getText() +"\n"); 
        $types.push_back($logic_expression.type); 
			}
	)*;