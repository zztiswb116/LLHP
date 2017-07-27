#include <llhp.hpp>
#include <dispatch/dispatch.h>
static dispatch_once_t once;
LLHP* LLHP::singleton=nullptr;
static id dummySELHandler(id self,id _cmd,...){
        const char* clsName=class_getName([self class]);

}
LLHP::LLHP(char* Path){
        dispatch_once(&once, ^ {std::string err;
                                SMDiagnostic SMD;
                                LLVMContext context;
                                EngineBuilder EB(parseIRFile(Path,SMD,context));
                                EB.setEngineKind(EngineKind::Interpreter);
                                EB.setErrorStr(&err);
                                this->EE=EB.create();
                                EE->runStaticConstructorsDestructors(false);
                                singleton=this;});

}
LLHP::LLHP(){
        dispatch_once(&once, ^ {std::string err;
                                EngineBuilder EB();
                                EB.setEngineKind(EngineKind::Interpreter);
                                EB.setErrorStr(&err);
                                this->EE=EB.create();
                                EE->runStaticConstructorsDestructors(false);
                                singleton=this;});

}
