#ifndef libLLHP_h
#define libLLHP_h
#include <objc/runtime.h>
#include "llvm/ExecutionEngine/ExecutionEngine.h"
#include "llvm/IR/Module.h"
#include "llvm/ExecutionEngine/Interpreter.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/TargetSelect.h"
#include "llvm/ExecutionEngine/GenericValue.h"
#include "llvm-c/Core.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/IR/TypeBuilder.h"
#include "llvm/IR/Value.h"
#define OBJC_ARGUMENT_TYPE_STR_MAX_LENGTH 64
using namespace llvm;
using namespace std;
class LLHP
{
public:
    ~LLHP();
    LLHP();
    void LoadModule(unique_ptr< Module > Mo);
    ExecutionEngine* EE;
    static LLHP* singleton;
    map<Type*,function<void *(GlobalVariable*)>> Handlers;
    map<string,tuple<string /*Method Signature*/,Function * /*IMP*/>> cachetable;//HashMap caching (CLASS+SEL):Function* for fast query, used by dummySELHandler
    std::string err;

};

#endif
