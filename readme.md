# 🎯 CSE 310 Compiler Sessional

![Compiler](https://img.shields.io/badge/Compiler-Design-blue)
![Language](https://img.shields.io/badge/Language-C%2B%2B-red)
![Parser](https://img.shields.io/badge/Parser-ANTLR4-green)
![Lexer](https://img.shields.io/badge/Lexer-Flex-orange)
![Status](https://img.shields.io/badge/Status-Complete-brightgreen)

> **A comprehensive compiler implementation for a C-like language, built progressively through four offline assignments covering all major phases of compilation.**

---

## 📚 Table of Contents

- [🌟 Overview](#-overview)
- [🏗️ Project Structure](#️-project-structure)
- [📋 Offline Assignments](#-offline-assignments)
  - [Offline 1: Symbol Table](#offline-1-symbol-table)
  - [Offline 2: Lexical Analysis](#offline-2-lexical-analysis)
  - [Offline 3: Syntax Analysis](#offline-3-syntax-analysis)
  - [Offline 4: Intermediate Code Generation](#offline-4-intermediate-code-generation)
- [🚀 Quick Start](#-quick-start)
- [🔧 Technical Stack](#-technical-stack)
- [📊 Features](#-features)
- [📖 Documentation](#-documentation)

---

## 🌟 Overview

This repository contains the complete implementation of a compiler for a C-like programming language, developed as part of CSE 310 (Compiler Design) coursework. The project demonstrates the systematic construction of a compiler through four progressive phases:

```
Source Code → Lexical Analysis → Syntax Analysis → Semantic Analysis → Code Generation
```

Each offline assignment builds upon the previous one, ultimately creating a fully functional compiler capable of generating assembly code.

---

## 🏗️ Project Structure

```
CSE310_compilerSessional/
├── 📁 offline1_SymbolTable/          # Foundation: Symbol Table Implementation
├── 📁 offline2_Lexical_analysis/     # Phase 1: Tokenization and Lexical Analysis
├── 📁 offline3_Syntax_Analysis/      # Phase 2: Parsing and Semantic Analysis
├── 📁 offline4_ICG/                  # Phase 3: Intermediate Code Generation
└── 📄 README.md                      # This comprehensive guide
```

---

## 📋 Offline Assignments

### 🗃️ Offline 1: Symbol Table

> **Foundation Phase**: Implementing the core data structure for identifier management

<details>
<summary><strong>🎯 Objectives & Features</strong></summary>

#### 🎯 **Primary Objectives**
- Implement a **hierarchical symbol table** using hash tables with chaining
- Support **nested scopes** with proper scope management
- Handle **multiple data types** including variables, functions, structures, and unions
- Implement efficient **insertion, lookup, and deletion** operations

#### ✨ **Key Features**
- **Hash-based Storage**: Efficient symbol storage with collision handling
- **Scope Management**: Enter/exit scopes with automatic cleanup
- **Type Support**: Variables, functions, structures, unions, arrays
- **Conflict Resolution**: Proper handling of symbol redeclaration
- **Memory Management**: Automatic scope cleanup and memory deallocation

#### 🏛️ **Architecture**
```cpp
SymbolTable
├── ScopeTable (Hash Table with Chaining)
│   ├── SymbolInfo (Individual Symbol)
│   ├── Hash Function Implementation
│   └── Collision Resolution (Chaining)
└── Scope Stack Management
```

#### 📊 **Operations Supported**
- `I <name> <type>` - Insert symbol
- `L <name>` - Lookup symbol
- `D <name>` - Delete symbol
- `S` - Enter new scope
- `E` - Exit current scope
- `P A/C` - Print all/current scope tables

</details>

**📁 Key Files:**
- `SymbolTable.hpp` - Main symbol table implementation
- `ScopeTable.hpp` - Individual scope table with hash implementation
- `symbolInfo.hpp` - Symbol information storage
- `main.cpp` - Interactive symbol table testing
- `hash.hpp` - Hash function implementations

---

### 🔤 Offline 2: Lexical Analysis

> **Tokenization Phase**: Converting source code into meaningful tokens

<details>
<summary><strong>🎯 Objectives & Features</strong></summary>

#### 🎯 **Primary Objectives**
- Implement a **lexical analyzer** using Flex (Fast Lexical Analyzer)
- **Tokenize C-like source code** into meaningful units
- **Handle all token types**: keywords, operators, literals, identifiers
- **Error detection** for invalid tokens and lexical errors
- **Integration** with symbol table for identifier management

#### ✨ **Key Features**
- **Comprehensive Token Recognition**: Keywords, operators, literals, comments
- **String and Character Handling**: Proper escape sequence processing
- **Number Recognition**: Integer and floating-point literals
- **Comment Processing**: Single-line and multi-line comments
- **Error Recovery**: Graceful handling of lexical errors
- **Symbol Table Integration**: Automatic identifier insertion

#### 🔧 **Token Categories**
```
Keywords:     if, else, for, while, int, float, void, return, etc.
Operators:    +, -, *, /, %, ==, !=, <, >, <=, >=, &&, ||, !
Delimiters:   (, ), {, }, [, ], ;, ,
Literals:     integers, floats, characters, strings
Identifiers:  variable and function names
Comments:     // single-line, /* multi-line */
```

#### 📈 **Processing Flow**
```
Source Code → Lexical Analysis → Token Stream + Symbol Table Updates
```

</details>

**📁 Key Files:**
- `2105067.l` - Flex lexical analyzer specification
- `SymbolTable.hpp` - Enhanced symbol table for lexical analysis
- `run.sh` - Build and execution script
- `input*.txt` - Test input files
- `*_token.txt` - Generated token output files
- `*_log.txt` - Detailed analysis logs

---

### 🌳 Offline 3: Syntax Analysis

> **Parsing Phase**: Building parse trees and semantic analysis

<details>
<summary><strong>🎯 Objectives & Features</strong></summary>

#### 🎯 **Primary Objectives**
- Implement a **parser** using ANTLR4 (ANother Tool for Language Recognition)
- Build **Abstract Syntax Trees** for C-like programs
- Perform **semantic analysis** with type checking
- **Error detection and recovery** for syntax and semantic errors
- **Scope-aware parsing** with proper symbol management

#### ✨ **Key Features**
- **Grammar-based Parsing**: Complete C-like language grammar
- **Semantic Analysis**: Type checking, scope validation, function signatures
- **Error Reporting**: Detailed syntax and semantic error messages
- **Parse Tree Generation**: Complete derivation tracking
- **Symbol Table Integration**: Scope-aware symbol management
- **Function Analysis**: Parameter matching, return type validation

#### 🎯 **Grammar Productions**
```antlr
program         : unit+
unit           : var_declaration | func_declaration | func_definition
func_definition: type_specifier ID LPAREN parameter_list RPAREN compound_statement
compound_statement: LCURL statements RCURL
expression     : logic_expression | variable ASSIGNOP logic_expression
```

#### 🔍 **Semantic Checks**
- **Type Compatibility**: Assignment and operation type checking
- **Function Calls**: Parameter count and type validation
- **Array Access**: Index type and bounds checking
- **Variable Declaration**: Redeclaration and scope conflicts
- **Return Statements**: Type consistency with function signature

#### 📊 **Error Categories**
- **Syntax Errors**: Grammar rule violations
- **Semantic Errors**: Type mismatches, undeclared variables
- **Scope Errors**: Variable redeclaration, invalid access

</details>

**📁 Key Files:**
- `C2105067Parser.g4` - ANTLR4 parser grammar
- `C2105067Lexer.g4` - ANTLR4 lexer grammar
- `Ctester.cpp` - Main parser testing program
- `SymbolTable.hpp` - Enhanced symbol table with semantic support
- `run-script.sh` - Build and execution script
- `input*.txt` - Test C programs
- `log*.txt` - Parse trees and analysis logs
- `error*.txt` - Error detection outputs

---

### ⚙️ Offline 4: Intermediate Code Generation

> **Code Generation Phase**: Translating to assembly language

<details>
<summary><strong>🎯 Objectives & Features</strong></summary>

#### 🎯 **Primary Objectives**
- Generate **8086 assembly code** from parsed C-like programs
- Implement **code generation strategies** for expressions, control flow, and functions
- **Optimize code generation** with efficient register and memory usage
- **Runtime support** for function calls, parameter passing, and stack management
- **Complete compilation pipeline** from source to executable assembly

#### ✨ **Key Features**
- **Complete Code Generation**: Variables, expressions, control structures, functions
- **Stack Management**: Proper stack frame handling for function calls
- **Expression Evaluation**: Efficient code for arithmetic and logical expressions
- **Control Flow**: If-else, loops, function calls with proper branching
- **Memory Management**: Global variables, local variables, arrays
- **Function Support**: Parameter passing, return values, recursive calls

#### 🏗️ **Assembly Generation Components**
```cpp
AssemblyGenerator
├── Data Section Generation (Global Variables)
├── Code Section Generation
│   ├── Expression Evaluation
│   ├── Control Flow (If/For/While)
│   ├── Function Calls
│   └── Stack Management
└── Runtime Support (Print, I/O)
```

#### 🔧 **Code Generation Features**
- **Arithmetic Operations**: +, -, *, /, % with proper type handling
- **Logical Operations**: &&, ||, ! with short-circuit evaluation
- **Comparison Operations**: ==, !=, <, >, <=, >= with branching
- **Assignment Operations**: Direct and array element assignment
- **Function Calls**: Parameter setup, call/return mechanism
- **Control Structures**: Conditional execution and loops

#### 📈 **Compilation Pipeline**
```
C-like Source → Lexical Analysis → Syntax Analysis → Semantic Analysis → Assembly Code
```

#### 🎯 **Target Architecture**
- **8086 Assembly**: 16-bit x86 assembly language
- **Registers**: AX, BX, CX, DX for computations
- **Stack**: BP, SP for function call management
- **Memory**: Direct addressing for global variables

</details>

**📁 Key Files:**
- `C2105067Parser.g4` - Enhanced parser with code generation
- `C2105067Lexer.g4` - Lexer with assembly support
- `AssemblyGenerator.cpp/.hpp` - Core assembly generation engine
- `Ctester.cpp` - Main compiler driver
- `SymbolTable.hpp` - Symbol table with assembly metadata
- `run-script.sh` - Complete compilation script
- `test*.c` - Test C programs
- `output.asm` - Generated assembly code

---

## 🚀 Quick Start

### 📋 Prerequisites

```bash
# Required tools
- C++ Compiler (g++ recommended)
- ANTLR4 Runtime Library
- Flex (for lexical analysis)
- Make/CMake (for building)
```

### 🏃‍♂️ Running Each Phase

#### **Phase 1: Symbol Table**
```bash
cd offline1_SymbolTable
g++ -o main main.cpp
./main < input.txt > output.txt
```

#### **Phase 2: Lexical Analysis**
```bash
cd offline2_Lexical_analysis
chmod +x run.sh
./run.sh input1.txt
```

#### **Phase 3: Syntax Analysis**
```bash
cd offline3_Syntax_Analysis
chmod +x run-script.sh
./run-script.sh input1.txt
```

#### **Phase 4: Code Generation**
```bash
cd offline4_ICG
chmod +x run-script.sh
./run-script.sh test1_i.c
# Check output.asm for generated assembly
```

---

## 🔧 Technical Stack

| Component | Technology | Purpose |
|-----------|------------|---------|
| **Core Language** | C++ | Implementation language |
| **Parser Generator** | ANTLR4 | Syntax analysis and parsing |
| **Lexer Generator** | Flex | Lexical analysis and tokenization |
| **Data Structures** | Hash Tables, Stacks | Symbol tables and scope management |
| **Target Architecture** | 8086 Assembly | Code generation target |
| **Build System** | Shell Scripts, Make | Compilation and testing |

---

## 📊 Features

### 🎯 **Language Support**
- ✅ **Data Types**: `int`, `float`, `void`, arrays
- ✅ **Control Structures**: `if-else`, `for`, `while`
- ✅ **Functions**: Declaration, definition, calls, recursion
- ✅ **Operators**: Arithmetic, logical, relational, assignment
- ✅ **Scoping**: Block-level scope with proper nesting
- ✅ **Arrays**: Declaration, indexing, multi-dimensional support

### 🔍 **Analysis Capabilities**
- ✅ **Lexical Analysis**: Complete tokenization with error detection
- ✅ **Syntax Analysis**: Grammar-based parsing with error recovery
- ✅ **Semantic Analysis**: Type checking, scope validation
- ✅ **Symbol Management**: Hierarchical symbol tables
- ✅ **Error Reporting**: Detailed error messages with line numbers

### ⚙️ **Code Generation**
- ✅ **Assembly Output**: 8086 assembly code generation
- ✅ **Optimization**: Efficient register usage and stack management
- ✅ **Runtime Support**: Function calls, I/O operations
- ✅ **Memory Management**: Global and local variable handling

---

## 📖 Documentation

### 📚 **Detailed Documentation**
- Each offline folder contains specific documentation
- Grammar specifications in `.g4` files
- Test cases and expected outputs provided
- Error handling examples and edge cases

### 🧪 **Testing**
- Comprehensive test suites for each phase
- Input/output validation
- Error case testing
- Performance benchmarks

### 📈 **Learning Outcomes**
- **Compiler Theory**: Practical implementation of compilation phases
- **Language Design**: Understanding grammar and semantics
- **Code Generation**: Assembly language and target architecture
- **Software Engineering**: Large-scale project organization

---

## 🎖️ **Project Highlights**

### 🏆 **Technical Achievements**
- **Complete Compiler Pipeline**: From source code to assembly
- **Robust Error Handling**: Comprehensive error detection and recovery
- **Efficient Implementation**: Optimized data structures and algorithms
- **Modular Design**: Clean separation of compilation phases
- **Extensive Testing**: Thorough validation with diverse test cases

### 📊 **Statistics**
- **4 Major Phases** of compiler implementation
- **15+ Source Files** with comprehensive functionality
- **50+ Test Cases** covering various language features
- **1000+ Lines** of grammar specifications
- **Complete Assembly Generation** for 8086 architecture

---

<div align="center">

### 🎯 **Built with ❤️ for CSE 310 - Compiler Design**

**Student ID**: 2105067  
**Course**: CSE 310 - Compiler Design  
**Institution**: Bangladesh University of Engineering and Technology (BUET)
**Level-3 , Term-1**

---

*This project demonstrates the complete journey from source code to executable assembly, showcasing the intricate beauty of compiler design and implementation.*

</div>
