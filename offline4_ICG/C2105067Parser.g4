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
    #include <map>
    #include <stack>
    #include <sstream>
    #include "antlr4-runtime.h"
    #include "C2105067Lexer.h"
    #include "hash.hpp"
    #include "symbolInfo.hpp"
    #include "SymbolTable.hpp"
    #include "ScopeTable.hpp"
    #include "AssemblyGenerator.hpp"
    extern SymbolTable symboltable;
}

@parser::members {
}

start:
	{
        initializeAssembly();
    }
    program {
        generateDataSection();
        generateCodeSectionStart();
        generateMainEnd();
        generateOtherFunctions();
        finalizeAssembly();
    };
program:
	unit+;

unit:
	var_declaration
	| func_declaration
	| func_definition;

func_declaration:
	type_specifier rType = ID LPAREN pList = parameter_list RPAREN SEMICOLON {
        std::string funcName = $rType.text;
        std::string returnType = $type_specifier.type;
        std::vector<std::string> paramTypes = $pList.types;

        SymbolInfo* existingSymbol = symboltable.LookUp(funcName);
        if (!existingSymbol) {
            symboltable.Insert(funcName, "FUNCTION", true, returnType, paramTypes, $rType.line);
        }
    }
	| type_specifier rType = ID LPAREN RPAREN SEMICOLON {
        std::string funcName = $rType.text;
        std::string returnType = $type_specifier.type;
        std::vector<std::string> paramTypes = {};

        SymbolInfo* existingSymbol = symboltable.LookUp(funcName);
        if (!existingSymbol) {
            symboltable.Insert(funcName, "FUNCTION", true, returnType, paramTypes, $rType.line);
        }
    };
func_definition:
    type_specifier rType = ID LPAREN pList = parameter_list RPAREN
    {
        std::string funcName = $rType.text;
        std::string returnType = $type_specifier.type;
        std::vector<std::string> paramTypes = $pList.types;
        int funcIdentifierLine = $rType.line;

        SymbolInfo* existingSymbol = symboltable.LookUp(funcName);
        if (!existingSymbol) {
            symboltable.Insert(funcName, "FUNCTION", true, returnType, paramTypes, funcIdentifierLine);
        }
        
        functionStart(funcName);
    }
    cStat = compound_statement[$pList.names, $pList.types, returnType]

    // Function definition with no parameters
    | type_specifier rType = ID LPAREN RPAREN
    {
        std::string funcName = $rType.text;
        std::string returnType = $type_specifier.type;
        int funcIdentifierLine = $rType.line;

        SymbolInfo* existingSymbol = symboltable.LookUp(funcName);
        if (!existingSymbol) {
            symboltable.Insert(funcName, "FUNCTION", true, returnType, {}, funcIdentifierLine);
        }
        functionStart(funcName);
    }
    cStat = compound_statement[std::vector<std::string>(), std::vector<std::string>(), returnType];


parameter_list
    returns[std::vector<std::string> types, std::vector<std::string> names, std::vector<int> lines]:
    pd = parameter_declaration {
        $types.push_back($pd.type);
        $names.push_back($pd.name);
        $lines.push_back($pd.line); 
    } (
        COMMA pd2 = parameter_declaration {
        $types.push_back($pd2.type);
        $names.push_back($pd2.name);
        $lines.push_back($pd2.line);
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
    };
compound_statement[std::vector<std::string> paramNames, std::vector<std::string> paramTypes, std::string returnType]
    returns [int endLine] :
    LCURL {
            symboltable.EnterScope();
            if(paramNames.size() != 0) {
                for (size_t i = 0; i < paramNames.size(); i++) {
                    SymbolInfo* existingSym = symboltable.LookUpInCurrentScope(paramNames[i]);
                    if (!existingSym) {
                        symboltable.Insert(paramNames[i], paramTypes[i], $LCURL.line);
                    }
                }
                generateParameterSetup(paramNames);
            }
    } statements RCURL {
        symboltable.ExitScope();
        $endLine = $RCURL.line;
        if (inFunction && returnType != "") {
            functionEnd();
        }
    }
    |LCURL {
            symboltable.EnterScope();
            if(paramNames.size() != 0) {
                for (size_t i = 0; i < paramNames.size(); i++) {
                    SymbolInfo* existingSym = symboltable.LookUpInCurrentScope(paramNames[i]);
                    if (!existingSym) {
                        symboltable.Insert(paramNames[i], paramTypes[i], $LCURL.line);
                    }
                }
                generateParameterSetup(paramNames);
            }
    } RCURL {
        symboltable.ExitScope();
        $endLine = $RCURL.line;
        if (inFunction && returnType != "") {
            functionEnd();
        }
    };

var_declaration:
    t = type_specifier dl = declaration_list[ $t.type ] sm = SEMICOLON;

type_specifier
    returns[std::string type]:
    INT {
        $type = "INT";
    }
    | FLOAT {
        $type = "FLOAT";
    }
    | VOID {
        $type = "VOID";
    };

declaration_list[std::string baseType]
    returns[std::vector<std::string> declaredNames, std::string fullText]:
    firstDecl = declaration_item[$baseType] {
        $declaredNames.push_back($firstDecl.name);
        $fullText = $firstDecl.text;
    }
    ( COMMA nextDecl = declaration_item[$baseType] {
        $declaredNames.push_back($nextDecl.name);
        $fullText += ", " + $nextDecl.text;
    }
        )*;
declaration_item[std::string baseType]
    returns[std::string name, std::string text, int line, std::string rule_match_text]:
    varID = ID {
        $name = $varID.text;
        $text = $varID.text;
        $line = $varID.line;
        $rule_match_text = "ID";

        SymbolInfo* existingSym = symboltable.LookUpInCurrentScope($name);
        if (!existingSym) {
            symboltable.Insert($name, baseType, $line);
            generateVariableDeclaration($name, baseType);
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
            arraySize = 1;
        } catch (const std::invalid_argument& ia) {
            arraySize = 1;
        }
        if (arraySize <= 0) {
            arraySize = 1;
        }
        SymbolInfo* existingSym = symboltable.LookUpInCurrentScope($name);
        if (!existingSym) {
            symboltable.Insert($name, baseType, true, arraySize, $line);
            generateArrayDeclaration($name, baseType, arraySize);
        }
    }
    | statements {
        $name = "";
        $text = "";
        $line = $statements.line;
        $rule_match_text = "statements";
    };
statements returns [std::string text, int line, bool returnSome]:
    firstStat = statement {
        $text = _localctx->getText(); 
        $line = $firstStat.start->getLine();
        $returnSome = $statement.returnSome;
    }
    (tail = statements_tail[$text] {
        $text += " " + $tail.text;
    })?;

statements_tail[std::string inheritedText] returns [std::string text, int line, bool returnSome]:
    nextStat = statement {
        $text = inheritedText + "\n" + _localctx->getText();
        $line = $nextStat.stop->getLine();
        $returnSome = $statement.returnSome;
    }
    (tail = statements_tail[$text] {
        $text = $tail.text;
    })?;

statement returns [std::string text, int line, bool returnSome]:
    var_declaration {
        $text = _localctx->getText();
        $line = _localctx->getStart()->getLine();
        $returnSome=false;
    }
    | expression_statement {
        $text = _localctx->getText();
        $line = _localctx->getStart()->getLine();
        $returnSome=false;
    }
    | compound_statement[std::vector<std::string>(), std::vector<std::string>(),""] {
        $text = _localctx->getText();
        $line = _localctx->getStart()->getLine();
        $returnSome=false;
    }
    | FOR LPAREN init = expression_statement  
    {
        collectingForCondition = true;
        forConditionCode.clear();
    }
    forCondition = expression_statement 
    {
        collectingForCondition = false;
        collectingForIncrement = true;
        forIncrementCode.clear();
    }
    incr = expression 
    {
        collectingForIncrement = false;
        generateForStart();
    }
    RPAREN body = statement 
    { 
        generateForEnd(); 
        $text = _localctx->getText();
        $line = _localctx->getStart()->getLine();
        $returnSome=false;
    }
    | IF LPAREN cond = expression RPAREN 
    { 
        generateIfStart(); 
    }
    thenStat = statement ELSE 
    { 
        generateElse(); 
    }
    elseStat = statement 
    { 
        generateIfEnd(); 
        $text = _localctx->getText();
        $line = _localctx->getStart()->getLine();
        $returnSome=false;
    }
    | IF LPAREN cond = expression RPAREN 
    { 
        generateIfStart(); 
    }
    thenStat = statement 
    { 
        generateIfEnd(); 
        $text = _localctx->getText();
        $line = _localctx->getStart()->getLine();
        $returnSome=false;
    }
    | WHILE LPAREN 
    { 
        generateWhileStart(); 
        collectingWhileCondition = true;
        whileConditionCode.clear();
    }
    whileCondition = expression RPAREN 
    { 
        collectingWhileCondition = false;
        generateWhileCondition(); 
    }
    body = statement 
    { 
        generateWhileEnd(); 
        $text = _localctx->getText();
        $line = _localctx->getStart()->getLine();
        $returnSome = false;
    }

    | PRINTLN LPAREN printID = ID RPAREN SEMICOLON {
        SymbolInfo* sym = symboltable.LookUp($printID.text);
        $text = _localctx->getText();
        $line = _localctx->getStart()->getLine();
        $returnSome=false;
        std::string varName = $printID.text;
        generateLoadVariable(varName);
        generateFunctionCall("printf", 1);
    }
    | RETURN expr = expression SEMICOLON {
        $text = _localctx->getText();
        $line = _localctx->getStart()->getLine();
        $returnSome=true;
        generateReturn();
    }
    | RETURN SEMICOLON {
        $text = _localctx->getText();
        $line = _localctx->getStart()->getLine();
        $returnSome=false;
    };

expression_statement:
    SEMICOLON
    | expr = expression SEMICOLON {
        generateConditionalExpressionCleanup();
    };

variable
	returns[std::string type, bool isArrayAccess]:
	varID = ID {
        SymbolInfo* sym = symboltable.LookUp($varID.text);
        if (sym && !sym->getIsFunction()) {
            if (sym->getIsArray()) {
                $type = sym->getElementType(); 
                $isArrayAccess = true;
            } else {
                $type = sym->getType();
                $isArrayAccess = false;
            }
        } else {
            $type = "INT";  // Default type
            $isArrayAccess = false;
        }
    }
	| arrayID = ID LTHIRD index = expression RTHIRD {
        SymbolInfo* sym = symboltable.LookUp($arrayID.text); 

        if (sym && sym->getIsArray()) {
            $type = sym->getElementType();
            $isArrayAccess = true;
        } else {
            $type = "INT";
            $isArrayAccess = true;
        }
     };
expression
	returns[std::string type]:
    left = variable ASSIGNOP right = logic_expression {
        $type = $left.type;
        
        if ($left.isArrayAccess) {
            std::string varName = $left.start->getText();
            generateArrayAssignmentWithIndex(varName);
        } else {
            std::string varName = $left.start->getText();
            generateAssignment(varName);
        }
    }
	| logic_expression { 
        $type = $logic_expression.type; 
    };

// Handles logical AND (&&) and OR (||) operators.
logic_expression
	returns[std::string type]:
	left = rel_expression { 
        $type = $left.type; 
    } (
		op = LOGICOP right = rel_expression {
            $type = "INT"; 
            // Generate assembly for logical operators
            std::string opText = ($op != nullptr) ? $op.text : "";
            if (opText == "&&") {
                generateLogicalAnd();
            }
      }
	)*;

// Handles relational operators (<, <=, >, >=, ==, !=).
rel_expression
	returns[std::string type]:
	left = simple_expression { 
        $type = $left.type; 
    } (
		op = RELOP right = simple_expression {
            $type = "INT"; 
            std::string opText = ($op != nullptr) ? $op.text : "";
            generateComparison(opText);
      }
	)*;

// Handles addition (+) and subtraction (-) operators.
simple_expression
	returns[std::string type]:
	left = term { 
        $type = $left.type; 
    } (
		op = (ADDOP | SUBOP) right = term {
            $type = $left.type; 
            std::string opText = ($op != nullptr) ? $op.text : "";
            generateArithmetic(opText);
      }
	)*;

term
    returns[std::string type]:
    left = unary_expression {
        $type = $left.type;
    } (
        op = MULOP right = unary_expression {
            $type = $left.type;
            std::string opText = ($op != nullptr) ? $op.text : "";
            generateArithmetic(opText);
            $left.type = $type;
        }
    )*;
unary_expression
	returns[std::string type, bool isFcall]:
	op = (ADDOP | SUBOP | NOT)? expr = factor {
        $type = $expr.type;
        $isFcall = $expr.isFcall;

        if ($op != nullptr) { 
            $type = $expr.type; 
            std::string opText = ($op != nullptr) ? $op.text : "";
            generateUnaryOperation(opText);
        }
    }
	| var = variable INCOP { 
        $type = $var.type;
        
        if ($var.isArrayAccess) {
            std::string varName = $var.start->getText();
            generateArrayElementAddress(varName);
            generateIncrementArray();
        } else {
            std::string varName = $var.start->getText();
            generateIncrement(varName);
        }
    }
	| var = variable DECOP { 
        $type = $var.type;
        if ($var.isArrayAccess) {
            std::string varName = $var.start->getText();
            generateArrayElementAddress(varName);
            generateDecrementArray();
        } else {
            std::string varName = $var.start->getText();
            generatePostDecrement(varName);
        }
    };

factor
    returns[std::string type, bool isFcall]:
    var = variable {
        $type = $var.type;
        $isFcall = false;
        if ($var.isArrayAccess) {
            std::string varName = $var.start->getText();
            generateLoadArrayElement(varName);
        } else {
            std::string varName = $var.start->getText();
            generateLoadVariable(varName);
        }
    }
    | fcall = function_call {
        $type = $fcall.type;
        $isFcall = true;
    }
    | LPAREN expr = expression RPAREN {
        $type = $expr.type;
        $isFcall = false;
    }
    | iConst = CONST_INT {
        $type = "INT";
        $isFcall = false;
        std::string value = $iConst.text;
        generateLoadConstant(value);
    }
    | fConst = CONST_FLOAT {
        $type = "FLOAT";
        $isFcall = false;
        std::string value = $fConst.text;
        generateLoadConstant(value);
    }
    | CONST_CHAR {
        $type = "CHAR";
        $isFcall = false;
    }
    | STRING {
        $type = "STRING";
        $isFcall = false;
    }
    |SYMBOL{
        $type = "SYMBOL";
        $isFcall = false;
    };

function_call
	returns[std::string type, std::string fName, std::string synt]:
	funcID = ID LPAREN aList = argument_list RPAREN {
        $fName = $funcID.text;
        $synt = "ID LPAREN argument_list RPAREN";
        
        if ($funcID.text == "printf" || $funcID.text == "scanf") {
            $type = "INT";
        } else {
            SymbolInfo* funcSym = symboltable.LookUp($funcID.text);
            if (funcSym && funcSym->getIsFunction()) {
                $type = funcSym->getReturnType();
            } else {
                $type = "INT";  // Default type
            }
        }
        generateFunctionCall($funcID.text, $aList.types.size());
        
        // If function has return value, pushing it onto stack
        if ($type != "VOID") {
            generatePushReturnValue();
        }
    }
	| funcID = ID LPAREN RPAREN {
        $fName = $funcID.text;
        $synt = "ID LPAREN RPAREN";
        
        SymbolInfo* funcSym = symboltable.LookUp($funcID.text);
        if (funcSym && funcSym->getIsFunction()) {
            $type = funcSym->getReturnType();
        } else {
            $type = "INT";  // Default type
        }
        //function call (no arguments)
        generateFunctionCall($funcID.text, 0);
        // If function has return value, pushing it onto stack
        if ($type != "VOID") {
            generatePushReturnValue();
        }
    };
argument_list
	returns[std::vector<std::string> types]:
	arguments { 
        $types = $arguments.types; 
    }
	|;
arguments
	returns[std::vector<std::string> types]:
	logic_expression { 
        $types.push_back($logic_expression.type); 
    } (
		COMMA logic_expression { 
            $types.push_back($logic_expression.type); 
        }
	)*;
