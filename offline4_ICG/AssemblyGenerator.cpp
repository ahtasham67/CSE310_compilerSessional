#include "AssemblyGenerator.hpp"
#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <stack>
#include "SymbolTable.hpp"
extern SymbolTable symboltable;

std::ofstream asmFile;
std::stack<std::string> labelStack;
std::vector<std::string> mainFunctionCode;
std::vector<std::string> otherFunctionsCode;
std::vector<std::string> forIncrementCode;
std::vector<std::string> forConditionCode;
std::vector<std::string> whileConditionCode;
int stackOffset = 0;
int labelCounter = 1;
bool inFunction = false;
std::string currentFunction;
int paramCount = 0;
bool asmInitialized = false;
bool collectingMainCode = false;
bool collectingOtherFuncCode = false;
bool collectingForIncrement = false;
bool collectingForCondition = false;
bool collectingWhileCondition = false;

// Track if the last expression pushed a value onto the stack
bool lastExpressionPushedValue = false;

void initializeAssembly()
{
    if (!asmInitialized)
    {
        if (!asmFile.is_open())
        {
            asmFile.open("output.asm", std::ios::out);
            if (!asmFile)
            {
                std::cerr << "Error opening output.asm" << std::endl;
                return;
            }
        }

        asmFile << ".MODEL SMALL\n";
        asmFile << ".STACK 100H\n\n";
        asmFile << ".DATA\n";
        asmFile << "    newline DB 0DH, 0AH, '$'\n";
        asmFile << "    number DB '00000$'\n";

        labelCounter = 1;
        stackOffset = 0;
        inFunction = false;
        asmInitialized = true;
    }
}
void writeToAsmFile(const std::string &code)
{
    if (collectingForIncrement)
        forIncrementCode.push_back(code);
    else if (collectingForCondition)
        forConditionCode.push_back(code);
    else if (collectingWhileCondition)
        whileConditionCode.push_back(code);
    else if (collectingMainCode)
        mainFunctionCode.push_back(code);
    else if (collectingOtherFuncCode)
        otherFunctionsCode.push_back(code);
    else
    {
        if (!asmFile.is_open())
        {
            asmFile.open("output.asm", std::ios::out);
            if (!asmFile)
            {
                std::cerr << "Error opening output.asm" << std::endl;
                return;
            }
        }
        asmFile << code << std::endl;
        asmFile.flush();
    }
}
std::string generateLabel()
{
    return "L" + std::to_string(labelCounter++);
}
void generateDataSection()
{
    writeToAsmFile("\n;     Global variables");
    std::vector<SymbolInfo *> globalVars = symboltable.getAllGlobalVariables();
    for (SymbolInfo *sym : globalVars)
    {
        if (sym->getIsArray())
        {
            std::string arrayName = sym->getName();
            std::string arrayType = sym->getElementType();
            int arraySize = sym->getArraySize();
            writeToAsmFile("    " + arrayName + " DW " + std::to_string(arraySize) + " DUP(0)  ; " + arrayType + " array[" + std::to_string(arraySize) + "]");
        }
        else
        {
            std::string varName = sym->getName();
            std::string varType = sym->getType();
            writeToAsmFile("    " + varName + " DW ?  ; " + varType + " variable");
        }
    }
}
void generateCodeSectionStart()
{
    writeToAsmFile("\n.CODE");
    writeToAsmFile("MAIN PROC");
    writeToAsmFile("    MOV AX, @DATA");
    writeToAsmFile("    MOV DS, AX");
    writeToAsmFile("");
    for (const auto &line : mainFunctionCode)
        writeToAsmFile(line);
}
void generateOtherFunctions()
{
    for (const auto &line : otherFunctionsCode)
        writeToAsmFile(line);
}

void generateMainEnd()
{
    writeToAsmFile("\n    ; Clean up main function stack frame");
    writeToAsmFile("    MOV SP, BP");
    writeToAsmFile("    POP BP");
    writeToAsmFile("    ; Program termination");
    writeToAsmFile("    MOV AH, 4CH");
    writeToAsmFile("    INT 21H");
    writeToAsmFile("MAIN ENDP");
}
void generatePrintFunction()
{
    writeToAsmFile("\n; Print functions");
    writeToAsmFile("NEW_LINE PROC");
    writeToAsmFile("    PUSH AX");
    writeToAsmFile("    PUSH DX");
    writeToAsmFile("    MOV AH,2");
    writeToAsmFile("    MOV DL,0DH");
    writeToAsmFile("    INT 21H");
    writeToAsmFile("    MOV AH,2");
    writeToAsmFile("    MOV DL,0AH");
    writeToAsmFile("    INT 21H");
    writeToAsmFile("    POP DX");
    writeToAsmFile("    POP AX");
    writeToAsmFile("    RET");
    writeToAsmFile("NEW_LINE ENDP");
    writeToAsmFile("");
    writeToAsmFile("PRINT_OUTPUT PROC  ;print what is in ax");
    writeToAsmFile("    PUSH AX");
    writeToAsmFile("    PUSH BX");
    writeToAsmFile("    PUSH CX");
    writeToAsmFile("    PUSH DX");
    writeToAsmFile("    PUSH SI");
    writeToAsmFile("    LEA SI,NUMBER");
    writeToAsmFile("    MOV BX,10");
    writeToAsmFile("    ADD SI,4");
    writeToAsmFile("    CMP AX,0");
    writeToAsmFile("    JNS PRINT");
    writeToAsmFile("    JMP NEGATE");
    writeToAsmFile("    PRINT:");
    writeToAsmFile("    XOR DX,DX");
    writeToAsmFile("    DIV BX");
    writeToAsmFile("    MOV [SI],DL");
    writeToAsmFile("    ADD [SI],'0'");
    writeToAsmFile("    DEC SI");
    writeToAsmFile("    CMP AX,0");
    writeToAsmFile("    JNE PRINT");
    writeToAsmFile("    INC SI");
    writeToAsmFile("    LEA DX,SI");
    writeToAsmFile("    MOV AH,9");
    writeToAsmFile("    INT 21H");
    writeToAsmFile("    POP SI");
    writeToAsmFile("    POP DX");
    writeToAsmFile("    POP CX");
    writeToAsmFile("    POP BX");
    writeToAsmFile("    POP AX");
    writeToAsmFile("    RET");
    writeToAsmFile("    NEGATE:");
    writeToAsmFile("    PUSH AX");
    writeToAsmFile("    MOV AH,2");
    writeToAsmFile("    MOV DL,'-'");
    writeToAsmFile("    INT 21H");
    writeToAsmFile("    POP AX");
    writeToAsmFile("    NEG AX");
    writeToAsmFile("    JMP PRINT");
    writeToAsmFile("PRINT_OUTPUT ENDP");
}
void functionStart(const std::string &funcName)
{
    if (funcName == "main")
    {
        collectingMainCode = true;
        writeToAsmFile("    ; Main function code");
        writeToAsmFile("    PUSH BP");
        writeToAsmFile("    MOV BP, SP");
        stackOffset = 0;
        inFunction = true;
        currentFunction = funcName;
        paramCount = 0;
    }
    else
    {
        collectingOtherFuncCode = true;
        writeToAsmFile("\n; Function: " + funcName);
        writeToAsmFile(funcName + " PROC");
        writeToAsmFile("    PUSH BP");
        writeToAsmFile("    MOV BP, SP");
        stackOffset = 0;
        inFunction = true;
        currentFunction = funcName;
        paramCount = 0;
    }
}

void functionEnd()
{
    if (currentFunction == "main")
        collectingMainCode = false;//for main func
    else
    {
        std::string functionEndLabel = currentFunction + "_END";
        writeToAsmFile(functionEndLabel + ":");
        writeToAsmFile("    MOV SP, BP");
        writeToAsmFile("    POP BP");
        writeToAsmFile("    RET");
        writeToAsmFile(currentFunction + " ENDP\n");
        collectingOtherFuncCode = false;
    }
    inFunction = false;
}
void generateVariableDeclaration(const std::string &varName, const std::string &type)
{
    if (inFunction)
    {
        stackOffset -= 2;
        writeToAsmFile("    ; Variable " + varName + " at [BP" + std::to_string(stackOffset) + "]");
        writeToAsmFile("    SUB SP, 2");
        SymbolInfo *sym = symboltable.LookUp(varName);
        if (sym != nullptr)
            sym->setStackOffset(stackOffset);
    }
    else
    {
        SymbolInfo *sym = symboltable.LookUp(varName);
        if (sym != nullptr)
            sym->setIsGlobal(true);
    }
}
void generateArrayDeclaration(const std::string &varName, const std::string &type, int arraySize)
{
    if (inFunction)
    {
        stackOffset -= 2 * arraySize;
        writeToAsmFile("    ; Array " + varName + " at [BP" + std::to_string(stackOffset) + "] size " + std::to_string(arraySize));
        writeToAsmFile("    SUB SP, " + std::to_string(2 * arraySize));
        SymbolInfo *sym = symboltable.LookUp(varName);
        if (sym != nullptr)
            sym->setStackOffset(stackOffset);
    }
    else
    {
        SymbolInfo *sym = symboltable.LookUp(varName);
        if (sym != nullptr)
            sym->setIsGlobal(true);
    }
}

void generateParameterSetup(const std::vector<std::string> &paramNames)
{
    for (size_t i = 0; i < paramNames.size(); i++)
    {
        size_t reverseIndex = paramNames.size() - 1 - i;
        int offset = 4 + (reverseIndex * 2); // Parameters start at [BP+4]
        writeToAsmFile("    ; Parameter " + paramNames[i] + " at [BP+" + std::to_string(offset) + "]");
        SymbolInfo *sym = symboltable.LookUp(paramNames[i]);
        if (sym != nullptr)
            sym->setStackOffset(offset);
    }
}
void generateLoadConstant(const std::string &value)
{
    if (!inFunction)
        return;
    writeToAsmFile("    MOV AX, " + value + "  ; Load constant");
    writeToAsmFile("    PUSH AX");
}
void generateLoadVariable(const std::string &varName)
{
    if (!inFunction)
        return;

    SymbolInfo *sym = symboltable.LookUp(varName);
    if (sym != nullptr)
    {
        int offset = sym->getStackOffset();
        if (offset != 0) // Local variable or parameter
        {
            if (offset > 0)
                writeToAsmFile("    MOV AX, [BP+" + std::to_string(offset) + "]  ; Load " + varName);
            else
                writeToAsmFile("    MOV AX, [BP" + std::to_string(offset) + "]  ; Load " + varName);
        }
        else if (symboltable.isVariableGlobal(varName))
            writeToAsmFile("    MOV AX, [" + varName + "]  ; Load global " + varName);
        else
            writeToAsmFile("    MOV AX, [BP]  ; Load " + varName);
    }
    else
        writeToAsmFile("    MOV AX, [" + varName + "]  ; Load global " + varName);//
    writeToAsmFile("    PUSH AX");
}

void generateAssignment(const std::string &varName)
{
    if (!inFunction)
        return;
    writeToAsmFile("    POP AX  ;   Get value to assign");
    SymbolInfo *sym = symboltable.LookUp(varName);
    if (sym != nullptr)
    {
        int offset = sym->getStackOffset();
        if (offset != 0)
        {
            if (offset > 0)
                writeToAsmFile("    MOV [BP+" + std::to_string(offset) + "], AX  ; " + varName + " = AX");
            else
                writeToAsmFile("    MOV [BP" + std::to_string(offset) + "], AX  ; " + varName + " = AX");
        }
        else if (symboltable.isVariableGlobal(varName))
            writeToAsmFile("    MOV [" + varName + "], AX  ; Global assignment");
        else
            writeToAsmFile("    MOV [BP], AX  ; " + varName + " = AX");
    }
    else
        writeToAsmFile("    MOV [" + varName + "], AX  ; Global assignment");
    //chaining like a = b = 5;
    writeToAsmFile("    PUSH AX  ; Push assigned value for chained assignment");
}
void generateDirectAssignment(const std::string &varName, const std::string &value)//a=5
{
    if (!inFunction)
        return;
    SymbolInfo *sym = symboltable.LookUp(varName);
    if (sym != nullptr)
    {
        int offset = sym->getStackOffset();
        if (offset != 0)
        {
            if (offset > 0)
                writeToAsmFile("    MOV WORD PTR [BP+" + std::to_string(offset) + "], " + value + "  ; " + varName + " = " + value);
            else
                writeToAsmFile("    MOV WORD PTR [BP" + std::to_string(offset) + "], " + value + "  ; " + varName + " = " + value);
        }
        else if (symboltable.isVariableGlobal(varName))
            writeToAsmFile("    MOV WORD PTR [" + varName + "], " + value + "  ; Global assignment");
        else
            writeToAsmFile("    MOV WORD PTR [BP], " + value + "  ; " + varName + " = " + value);
    }
    else
        writeToAsmFile("    MOV WORD PTR [" + varName + "], " + value + "  ; Global assignment");
}

void generateArithmetic(const std::string &op)
{
    if (!inFunction)
        return;
    writeToAsmFile("    POP BX  ; Second operand");
    writeToAsmFile("    POP AX  ; First operand");
    if (op == "+")
        writeToAsmFile("    ADD AX, BX");
    else if (op == "-")
        writeToAsmFile("    SUB AX, BX");
    else if (op == "*")
        writeToAsmFile("    IMUL BX  ; AX = AX * BX");
    else if (op == "/")
    {
        writeToAsmFile("    CWD");
        writeToAsmFile("    IDIV BX");
    }
    else if (op == "%")
    {
        writeToAsmFile("    CWD ;   Convert AX to DX:AX for division");
        writeToAsmFile("    IDIV BX");
        writeToAsmFile("    MOV AX, DX");
    }
    writeToAsmFile("    PUSH AX  ;  Push result");
}
void generateComparison(const std::string &op)
{
    if (!inFunction)
        return;
    writeToAsmFile("    POP BX  ; Second operand");
    writeToAsmFile("    POP AX  ; First operand");
    writeToAsmFile("    CMP AX, BX");
    std::string trueLabel = generateLabel();
    std::string endLabel = generateLabel();
    if (op == "<")
        writeToAsmFile("    JL " + trueLabel);
    else if (op == "<=")
        writeToAsmFile("    JLE " + trueLabel);
    else if (op == ">")
        writeToAsmFile("    JG " + trueLabel);
    else if (op == ">=")
        writeToAsmFile("    JGE " + trueLabel);
    else if (op == "==")
        writeToAsmFile("    JE " + trueLabel);
    else if (op == "!=")
        writeToAsmFile("    JNE " + trueLabel);
    writeToAsmFile("    MOV AX, 0  ; False");
    writeToAsmFile("    JMP " + endLabel);
    writeToAsmFile(trueLabel + ":");
    writeToAsmFile("    MOV AX, 1  ; True");
    writeToAsmFile(endLabel + ":");
    writeToAsmFile("    PUSH AX");
}
void generateFunctionCall(const std::string &funcName, int argCount)
{
    if (!inFunction)
        return;
    writeToAsmFile("    ; Function call: " + funcName);
    if (funcName == "printf")
    {
        writeToAsmFile("    POP AX  ; Get value to print");
        writeToAsmFile("    CALL PRINT_OUTPUT");
        writeToAsmFile("    CALL NEW_LINE");
        lastExpressionPushedValue = false; // printf doesn't push return value
    }
    else
    {
        writeToAsmFile("    CALL " + funcName);
        if (argCount > 0)
            writeToAsmFile("    ADD SP, " + std::to_string(argCount * 2) + "  ; Clean up parameters");
        lastExpressionPushedValue = false; // set to true by generatePushReturnValue if needed
    }
}
void generatePushReturnValue()
{
    if (!inFunction)
        return;
    writeToAsmFile("    PUSH AX  ; Push return value onto stack");
    lastExpressionPushedValue = true;
}
void generateReturn()
{
    if (!inFunction)
        return;
    if (currentFunction == "main")
        writeToAsmFile("    POP AX  ; Return value"); // main e ret lage na
    else
    {
        writeToAsmFile("    POP AX  ; Return value");
        std::string functionEndLabel = currentFunction + "_END";
        writeToAsmFile("    JMP " + functionEndLabel + "  ; Jump to function end");
    }
}
void generateIfStart()
{
    if (!inFunction)
        return;
    writeToAsmFile("    POP AX  ; Condition value");
    writeToAsmFile("    CMP AX, 0");
    std::string elseLabel = generateLabel();
    writeToAsmFile("    JE " + elseLabel + "  ; Jump to else if false");
    labelStack.push(elseLabel);
}
void generateElse()
{
    if (!inFunction)
        return;
    std::string elseLabel = labelStack.top();
    labelStack.pop();
    std::string endLabel = generateLabel();
    writeToAsmFile("    JMP " + endLabel + "  ; Jump to end");
    writeToAsmFile(elseLabel + ":   ;else label");
    labelStack.push(endLabel);
}

void generateIfEnd()
{
    if (!inFunction)
        return;
    std::string endLabel = labelStack.top();
    labelStack.pop();
    writeToAsmFile(endLabel + ":    ;endlabel from ifend");
}
void generateWhileStart()
{
    if (!inFunction)
        return;
    std::string conditionLabel = generateLabel();
    std::string loopLabel = generateLabel();
    std::string endLabel = generateLabel();
    writeToAsmFile("    JMP " + conditionLabel + "  ; Jump to condition check");
    writeToAsmFile(loopLabel + ":");
    //std::cout << loopLabel << std::endl;
    labelStack.push(endLabel);
    labelStack.push(conditionLabel);
    labelStack.push(loopLabel);
}

void generateWhileCondition()
{
    if (!inFunction)
        return;
}

void generateWhileEnd()
{
    if (!inFunction)
        return;

    std::string loopLabel = labelStack.top();
    labelStack.pop();
    std::string conditionLabel = labelStack.top();
    labelStack.pop();
    std::string endLabel = labelStack.top();
    labelStack.pop();
    writeToAsmFile("    JMP " + conditionLabel + "  ; Jump to condition check");
    writeToAsmFile(conditionLabel + ":");
    for (const auto &line : whileConditionCode)
        writeToAsmFile(line);
    // The condition evaluation result is now on the stack
    writeToAsmFile("    POP AX  ; Get condition result");
    writeToAsmFile("    CMP AX, 0");
    writeToAsmFile("    JNE " + loopLabel + "  ; Continue loop if true");
    writeToAsmFile(endLabel + ":");
}

void generateForStart()
{
    if (!inFunction)
        return;
    std::string conditionLabel = generateLabel();
    std::string loopLabel = generateLabel();
    std::string endLabel = generateLabel();
    writeToAsmFile("    POP AX  ; Consume initial condition result");
    writeToAsmFile("    JMP " + conditionLabel + "  ; Jump to condition check");
    writeToAsmFile(loopLabel + ":");
    labelStack.push(endLabel);
    labelStack.push(conditionLabel);
    labelStack.push(loopLabel);
}

void generateForEnd()
{
    if (!inFunction)
        return;
    std::string loopLabel = labelStack.top();
    labelStack.pop();
    std::string conditionLabel = labelStack.top();
    labelStack.pop();
    std::string endLabel = labelStack.top();
    labelStack.pop();
    for (const auto &line : forIncrementCode)
        writeToAsmFile(line);
    writeToAsmFile("    JMP " + conditionLabel + "  ; Jump to condition check");
    writeToAsmFile(conditionLabel + ":");
    for (const auto &line : forConditionCode)
        writeToAsmFile(line);
    writeToAsmFile("    POP AX  ; Get condition result");
    writeToAsmFile("    CMP AX, 0");
    writeToAsmFile("    JNE " + loopLabel + "  ; Continue loop if true");
    writeToAsmFile(endLabel + ":");
}

void finalizeAssembly()
{
    generatePrintFunction();
    writeToAsmFile("END MAIN");
    if (asmFile.is_open())
        asmFile.close();
    peepholeOptimize();
}

void generateArrayElementAddress(const std::string &varName)
{
    if (!inFunction)
        return;
    writeToAsmFile("    ; Calculate array element address for " + varName);
    writeToAsmFile("    POP BX  ; Index");
    writeToAsmFile("    SHL BX, 1  ; Index * 2 (2 bytes per element)");

    SymbolInfo *sym = symboltable.LookUp(varName);
    if (sym != nullptr)
    {
        int offset = sym->getStackOffset();
        if (offset != 0) // Local array
        {
            if (offset == 0)
                writeToAsmFile("    LEA SI, [BP]");
            else
                writeToAsmFile("    LEA SI, [BP" + std::to_string(offset) + "]");
            writeToAsmFile("    ADD SI, BX  ;   Base address + offset");
        }
        else if (symboltable.isVariableGlobal(varName))
        {
            writeToAsmFile("    LEA SI, " + varName);
            writeToAsmFile("    ADD SI, BX  ; Base address + offset");
        }
        else
        {
            writeToAsmFile("    LEA SI, [BP]");
            writeToAsmFile("    ADD SI, BX  ; Base address + offset");
        }
    }
    else
    {
        writeToAsmFile("    LEA SI, " + varName);
        writeToAsmFile("    ADD SI, BX  ; Base address + offset");
    }
    writeToAsmFile("    PUSH SI  ; Push element address");
}
void generateLoadArrayElement(const std::string &varName)
{
    if (!inFunction)
        return;
    generateArrayElementAddress(varName);
    writeToAsmFile("    POP SI  ; Get element address");
    writeToAsmFile("    MOV AX, [SI]  ; Load element value");
    writeToAsmFile("    PUSH AX");
}
void generateAssignmentToArray()
{
    if (!inFunction)
        return;
    writeToAsmFile("    POP SI  ; Get element address");
    writeToAsmFile("    POP AX  ; Get value to assign");
    writeToAsmFile("    MOV [SI], AX  ; Store value to array element");
}

void generateArrayAssignmentWithIndex(const std::string &varName)
{
    if (!inFunction)
        return;
    // Stack has: [index BX, value AX] (bottom to top)
    writeToAsmFile("    POP AX  ; Get value to assign");
    writeToAsmFile("    POP BX  ; Get index");
    writeToAsmFile("    SHL BX, 1  ;    Index * 2");
    SymbolInfo *sym = symboltable.LookUp(varName);
    if (sym != nullptr)
    {
        int offset = sym->getStackOffset();
        if (offset != 0) // Local array
        {
            if (offset == 0)
                writeToAsmFile("    LEA SI, [BP]");
            else
                writeToAsmFile("    LEA SI, [BP" + std::to_string(offset) + "]");
            writeToAsmFile("    ADD SI, BX  ;   Base address + offset");
        }
        else if (symboltable.isVariableGlobal(varName))
        {
            writeToAsmFile("    LEA SI, " + varName);
            writeToAsmFile("    ADD SI, BX  ; Base address + offset");
        }
        else
        {
            writeToAsmFile("    LEA SI, [BP]");
            writeToAsmFile("    ADD SI, BX  ; Base address + offset");
        }
    }
    else
    {
        writeToAsmFile("    LEA SI, " + varName);
        writeToAsmFile("    ADD SI, BX  ; Base address + offset");
    }
    writeToAsmFile("    MOV [SI], AX  ; Store value to array element");
}
void generateLogicalAnd()
{
    if (!inFunction)
        return;
    writeToAsmFile("    POP BX  ; Right operand");
    writeToAsmFile("    POP AX  ; Left operand");
    writeToAsmFile("    CMP AX, 0");
    std::string shortCircuitLabel = generateLabel();
    std::string endLabel = generateLabel();
    writeToAsmFile("    JE " + shortCircuitLabel + "  ; Short circuit if left is false");
    writeToAsmFile("    CMP BX, 0");
    writeToAsmFile("    JE " + shortCircuitLabel + "  ; Result is false if right is false");
    writeToAsmFile("    MOV AX, 1  ;    Both true, result is true");
    writeToAsmFile("    JMP " + endLabel);
    writeToAsmFile(shortCircuitLabel + ":");
    writeToAsmFile("    MOV AX, 0  ;    Result is false");
    writeToAsmFile(endLabel + ":");
    writeToAsmFile("    PUSH AX");
}

void generateIncrement(const std::string &varName)
{
    if (!inFunction)
        return;

    SymbolInfo *sym = symboltable.LookUp(varName);
    if (sym != nullptr)
    {
        int offset = sym->getStackOffset();
        if (offset != 0)
        {
            if (offset > 0)
                writeToAsmFile("    INC WORD PTR [BP+" + std::to_string(offset) + "]  ; Increment " + varName);
            else
                writeToAsmFile("    INC WORD PTR [BP" + std::to_string(offset) + "]  ; Increment " + varName);
        }
        else if (symboltable.isVariableGlobal(varName))
            writeToAsmFile("    INC WORD PTR [" + varName + "]  ; Increment global " + varName);
        else
            writeToAsmFile("    INC WORD PTR [BP]  ; Increment " + varName);
    }
    else
        writeToAsmFile("    INC WORD PTR [" + varName + "]  ; Increment global " + varName);
}
void generateDecrement(const std::string &varName)
{
    if (!inFunction)
        return;

    SymbolInfo *sym = symboltable.LookUp(varName);
    if (sym != nullptr)
    {
        int offset = sym->getStackOffset();
        if (offset != 0)
        {
            if (offset > 0)
                writeToAsmFile("    DEC WORD PTR [BP+" + std::to_string(offset) + "]  ; Decrement " + varName);
            else
                writeToAsmFile("    DEC WORD PTR [BP" + std::to_string(offset) + "]  ; Decrement " + varName);
        }
        else if (symboltable.isVariableGlobal(varName))
            writeToAsmFile("    DEC WORD PTR [" + varName + "]  ; Decrement global " + varName);
        else
            writeToAsmFile("    DEC WORD PTR [BP]  ; Decrement " + varName);
    }
    else
        writeToAsmFile("    DEC WORD PTR [" + varName + "]  ; Decrement global " + varName);
}

void generatePostDecrement(const std::string &varName)
{
    if (!inFunction)
        return;

    SymbolInfo *sym = symboltable.LookUp(varName);
    if (sym != nullptr)
    {
        int offset = sym->getStackOffset();
        if (offset != 0)
        {
            if (offset > 0)
            {
                writeToAsmFile("    MOV AX, [BP+" + std::to_string(offset) + "]  ; Load " + varName + " (post-decrement)");
                writeToAsmFile("    DEC WORD PTR [BP+" + std::to_string(offset) + "]  ; Decrement " + varName);
            }
            else
            {
                writeToAsmFile("    MOV AX, [BP" + std::to_string(offset) + "]  ; Load " + varName + " (post-decrement)");
                writeToAsmFile("    DEC WORD PTR [BP" + std::to_string(offset) + "]  ; Decrement " + varName);
            }
        }
        else if (symboltable.isVariableGlobal(varName))
        {
            writeToAsmFile("    MOV AX, [" + varName + "]  ; Load global " + varName + " (post-decrement)");
            writeToAsmFile("    DEC WORD PTR [" + varName + "]  ; Decrement global " + varName);
        }
        else
        {
            writeToAsmFile("    MOV AX, [BP]  ; Load " + varName + " (post-decrement)");
            writeToAsmFile("    DEC WORD PTR [BP]  ; Decrement " + varName);
        }
    }
    else
    {
        writeToAsmFile("    MOV AX, [" + varName + "]  ; Load global " + varName + " (post-decrement)");
        writeToAsmFile("    DEC WORD PTR [" + varName + "]  ; Decrement global " + varName);
    }
    writeToAsmFile("    PUSH AX  ; Push original value");
}

void generateIncrementArray()
{
    if (!inFunction)
        return;
    writeToAsmFile("    POP SI  ; Get array element address");
    writeToAsmFile("    MOV AX, [SI]  ; Load current value (for post-increment)");
    writeToAsmFile("    INC WORD PTR [SI]  ; Increment array element");
    writeToAsmFile("    PUSH AX  ; Push original value");
}
void generateDecrementArray()
{
    if (!inFunction)
        return;
    writeToAsmFile("    POP SI  ; Get array element address");
    writeToAsmFile("    MOV AX, [SI]  ; Load current value (for post-decrement)");
    writeToAsmFile("    DEC WORD PTR [SI]  ; Decrement array element");
    writeToAsmFile("    PUSH AX  ; Push original value");
}
void generateUnaryOperation(const std::string &op)
{
    if (!inFunction)
        return;
    writeToAsmFile("    POP AX  ; Get operand");
    if (op == "-")
        writeToAsmFile("    NEG AX  ; Negate value");
    else if (op == "+")
    {
        // Unary plus - no operation needed
    }
    else if (op == "!")
    {
        writeToAsmFile("    CMP AX, 0");
        std::string trueLabel = generateLabel();
        std::string endLabel = generateLabel();
        writeToAsmFile("    JE " + trueLabel);
        writeToAsmFile("    MOV AX, 0  ; False");
        writeToAsmFile("    JMP " + endLabel);
        writeToAsmFile(trueLabel + ":");
        writeToAsmFile("    MOV AX, 1  ; True");
        writeToAsmFile(endLabel + ":");
    }
    writeToAsmFile("    PUSH AX  ; Push result");
}
void generateExpressionStatementCleanup()
{
    if (!inFunction)
        return;
    writeToAsmFile("    POP AX  ; Clean up unused expression result");
}
void generateConditionalExpressionCleanup()
{
    if (!inFunction)
        return;
    if (lastExpressionPushedValue)
    {
        writeToAsmFile("    POP AX  ; Clean up unused expression result");
        lastExpressionPushedValue = false;
    }
}
std::string trimLine(const std::string &str)
{
    size_t first = str.find_first_not_of(" \t");
    if (first == std::string::npos)
        return "";
    size_t last = str.find_last_not_of(" \t");
    return str.substr(first, (last - first + 1));
}
bool isLabel(const std::string &line)
{
    std::string trimmed = trimLine(line);
    return (trimmed.find(":") != std::string::npos &&
            trimmed.find("PROC") == std::string::npos &&
            trimmed.find("ENDP") == std::string::npos &&
            trimmed.find(";") == std::string::npos);
}
void peepholeOptimize()
{
    std::ifstream inputFile("output.asm");
    if (!inputFile.is_open())
    {
        std::cerr << "Error: Could not open output.asm for optimization" << std::endl;
        return;
    }

    std::vector<std::string> lines;
    std::string line;

    while (std::getline(inputFile, line))
    {
        lines.push_back(line);
    }
    inputFile.close();
    std::cout << "code.asm has " << lines.size() << " lines" << std::endl;
    std::vector<std::string> optimized;
    for (size_t i = 0; i < lines.size(); i++)
    {
        bool skipLine = false;
        std::string current = trimLine(lines[i]);
        if (!skipLine && i + 1 < lines.size())
        {
            std::string next = trimLine(lines[i + 1]);
            if ((current.find("PUSH AX") != std::string::npos && next.find("POP AX") != std::string::npos) ||
                (current.find("PUSH BX") != std::string::npos && next.find("POP BX") != std::string::npos))
            {
                //cout << "PUSH/POP pair: " << current << " and " << next << std::endl;
                i++;
                skipLine = true;
            }
        }
        if (!skipLine)
        {
            optimized.push_back(lines[i]);
        }
    }
    std::cout << "Optimized assembly has " << optimized.size() << " lines" << std::endl;
    std::cout << "Removed " << (lines.size() - optimized.size()) << " redundant lines" << std::endl;
    std::ofstream outputFile("optimized.asm");
    if (!outputFile.is_open())
    {
        std::cerr << "Error: Could not create optimized.asm" << std::endl;
        return;
    }
    for (size_t i = 0; i < optimized.size(); i++)
    {
        outputFile << optimized[i] << std::endl;
    }
    outputFile.close();
}
