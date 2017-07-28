#ifndef libLLHP_h
#define libLLHP_h
#include <objc/runtime.h>
#include "llvm/ExecutionEngine/ExecutionEngine.h"
#include "llvm/ExecutionEngine/Interpreter.h"
#include "llvm/IR/Module.h"
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
using namespace llvm;
using namespace std;
class LLHP
{
public:
    ~LLHP();
    LLHP();
    void apply();
    void addModule(Module* M);
    ExecutionEngine* EE;
protected:
    static LLHP* singleton;
    map<string,tuple<string /*Method Signature*/,Function * /*IMP*/>> cachetable;//HashMap caching (CLASS+SEL):Function* for fast query, used by dummySELHandler

};

#endif
