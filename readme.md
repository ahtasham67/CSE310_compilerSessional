# 🎯 CSE 310 Compiler Sessional

![Compiler](https://img.shields.io/badge/Compiler-Design-blue)
![Language](https://img.shields.io/badge/Language-C%2B%2B-red)
![Parser](https://img.shields.io/badge/Parser-ANTLR4-green)
![Status](https://img.shields.io/badge/Status-Complete-brightgreen)

> **A complete compiler implementation for a C-like language through four progressive phases: Symbol Table → Lexical Analysis → Syntax Analysis → Code Generation.**

---

## 🌟 Overview

A complete compiler implementation for C-like language developed for CSE 310 coursework:

```
Source Code → Lexical Analysis → Syntax Analysis → Semantic Analysis → Assembly Code
```
## 🔧 Technical Stack

| Component | Technology | Purpose |
|-----------|------------|---------|
| **Core Language** | C++ | Implementation language |
| **Parser Generator** | ANTLR4 | Syntax analysis and parsing |
| **Lexer Generator** | Flex | Lexical analysis and tokenization |
| **Data Structures** | Hash Tables, Stacks | Symbol tables and scope management |
| **Target Architecture** | 8086 Assembly | Code generation target |
| **Build System** | Shell Scripts, Make | Compilation and testing |

## 🏗️ Project Structure

```
CSE310_compilerSessional/
├── offline1_SymbolTable/          # Symbol Table with Hash Tables
├── offline2_Lexical_analysis/     # Tokenization using Flex
├── offline3_Syntax_Analysis/      # Parsing with ANTLR4 + Semantic Analysis  
└── offline4_ICG/                  # Assembly Code Generation (8086)
```

---

## 📋 Offline Assignments

### 🗃️ **Offline 1: Symbol Table**
Hierarchical symbol table using hash tables with chaining for efficient symbol management.

**Key Features:**
- Hash-based storage with collision handling
- Nested scope management  
- Support for variables, functions, structures, unions
- Operations: Insert, Lookup, Delete, Scope Enter/Exit

**Files:** `SymbolTable.hpp`, `ScopeTable.hpp`, `symbolInfo.hpp`, `main.cpp`

---

### 🔤 **Offline 2: Lexical Analysis**  
Tokenization using Flex to convert source code into meaningful tokens.

**Key Features:**
- Complete token recognition (keywords, operators, literals)
- String and comment processing
- Error detection and recovery
- Symbol table integration

**Files:** `2105067.l`, `run.sh`, test files with `*_token.txt` and `*_log.txt` outputs

---

### 🌳 **Offline 3: Syntax Analysis**
Grammar-based parsing using ANTLR4 with semantic analysis and type checking.

**Key Features:**
- Complete C-like language grammar
- Semantic analysis with type checking
- Parse tree generation with error reporting
- Function signature validation

**Files:** `C2105067Parser.g4`, `C2105067Lexer.g4`, `Ctester.cpp`, `run-script.sh`

---

### ⚙️ **Offline 4: Code Generation**
8086 assembly code generation with complete compilation pipeline.

**Key Features:**
- Expression evaluation and control flow
- Function calls with stack management
- Memory management for variables and arrays
- Complete runtime support

**Files:** `AssemblyGenerator.cpp/.hpp`, enhanced parser files, `output.asm`

---

## 🚀 Quick Start

### **Running Each Phase:**

```bash
# Phase 1: Symbol Table
cd offline1_SymbolTable && g++ -o main main.cpp && ./main < input.txt

# Phase 2: Lexical Analysis  
cd offline2_Lexical_analysis && ./run.sh input1.txt

# Phase 3: Syntax Analysis
cd offline3_Syntax_Analysis && ./run-script.sh input1.txt

# Phase 4: Code Generation
cd offline4_ICG && ./run-script.sh test1_i.c
```

## � Language Features Supported

✅ **Data Types:** `int`, `float`, `void`, arrays  
✅ **Control Flow:** `if-else`, `for`, `while`  
✅ **Functions:** Declaration, definition, calls, recursion  
✅ **Operators:** Arithmetic, logical, relational, assignment  
✅ **Scoping:** Block-level scope with proper nesting  
✅ **Error Detection:** Lexical, syntax, and semantic errors  

---

<div align="center">

**🎯 CSE 310 - Compiler Design**  
**Student ID:** 2105067 | **BUET** | **Level-3, Term-1**

*Complete compiler implementation from source code to 8086 assembly*

</div>
