#pragma once
#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <stack>
#include "SymbolTable.hpp"

extern std::ofstream asmFile;
extern SymbolTable symboltable;
extern std::stack<std::string> labelStack;
extern std::vector<std::string> mainFunctionCode;
extern std::vector<std::string> forIncrementCode;
extern std::vector<std::string> forConditionCode;
extern std::vector<std::string> whileConditionCode;
extern int stackOffset;
extern int labelCounter;
extern bool inFunction;
extern std::string currentFunction;
extern int paramCount;
extern bool asmInitialized;
extern bool collectingMainCode;
extern bool collectingForIncrement;
extern bool collectingForCondition;
extern bool collectingWhileCondition;
extern bool lastExpressionPushedValue;

// Type checking functions
bool isNumericType(const std::string &type);
bool isIntegerType(const std::string &type);
std::string checkCompatibility(const std::string &type1, const std::string &type2, const std::string &op, int line = -1, bool print = false);

// Assembly generation functions
void initializeAssembly();
void writeToAsmFile(const std::string &code);
std::string generateLabel();
void generateDataSection();
void generateCodeSectionStart();
void generateMainEnd();
void generatePrintFunction();
void functionStart(const std::string &funcName);
void functionEnd();
void generateVariableDeclaration(const std::string &varName, const std::string &type);
void generateArrayDeclaration(const std::string &varName, const std::string &type, int arraySize);
void generateParameterSetup(const std::vector<std::string> &paramNames);
void generateLoadConstant(const std::string &value);
void generateLoadVariable(const std::string &varName);
void generateAssignment(const std::string &varName);
void generateDirectAssignment(const std::string &varName, const std::string &value);
void generateArithmetic(const std::string &op);
void generateComparison(const std::string &op);
void generateFunctionCall(const std::string &funcName, int argCount);
void generateReturn();
void generateIfStart();
void generateElse();
void generateIfEnd();
void generateWhileStart();
void generateWhileCondition();
void generateWhileEnd();
void generateForStart();
void generateForEnd();
void finalizeAssembly();
void generateArrayElementAddress(const std::string &varName);
void generateLoadArrayElement(const std::string &varName);
void generateAssignmentToArray();
void generateArrayAssignmentWithIndex(const std::string &varName);
void generateLogicalAnd();
void generateIncrement(const std::string &varName);
void generateDecrement(const std::string &varName);
void generatePostDecrement(const std::string &varName);
void generateIncrementArray();
void generateDecrementArray();
void generateUnaryOperation(const std::string &op);
void generatePushReturnValue();
void generateExpressionStatementCleanup();
void generateConditionalExpressionCleanup();
void generateOtherFunctions();

// Optimization functions
void peepholeOptimize();
