#ifndef libLLHP_h
#define libLLHP_h
##include <objc/runtime.h>
#include "llvm/ExecutionEngine/ExecutionEngine.h"
#include "llvm/ExecutionEngine/Interpreter.h"
#include "llvm/IR/Module.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/TargetSelect.h"
#include "llvm/ExecutionEngine/GenericValue.h"
#include "llvm-c/Core.h"
using namespace llvm;
using namespace std;
class LLHP
{
public:
    ~LLHP();
    LLHP(char* IRPath);
    ExecutionEngine* EE;
    static LLHP* instance;
};

#endif
