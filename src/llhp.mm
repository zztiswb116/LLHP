#include <llhp.hpp>
#include <dispatch/dispatch.h>
static dispatch_once_t once;
LLHP* LLHP::singleton=nullptr;
static void* dummySELHandler(id self,SEL _cmd,...){
        string cacheKey;//Key for caching hashmap
        cacheKey.append(class_getName([self class]));
        cacheKey.append(sel_getName(_cmd));
        Method meth=(class_getInstanceMethod([self class],_cmd)!=NULL) ? class_getInstanceMethod([self class],_cmd) : class_getClassMethod([self class],_cmd);
        va_list ap;
        va_start(ap,_cmd);

}
LLHP::LLHP(){
        dispatch_once(&once, ^ {std::string err;
                                EngineBuilder EB;
                                EB.setEngineKind(EngineKind::Interpreter);
                                EB.setErrorStr(&err);
                                this->EE=EB.create();
                                EE->runStaticConstructorsDestructors(false);
                                singleton=this;});

}
void LLHP::addModule(Module* M){
        //Collect MethodInfo and push into cache
        vector<string> ClassNameList;
        for (auto GVI = M->global_begin(); GVI != M->global_end();
             GVI++) {        // Iterate GVs for ClassList
                GlobalVariable &GV = *GVI;
                if (GV.getName().str().find("OBJC_CLASS_NAME_") != string::npos) {
                        ConstantDataSequential* CDA=dyn_cast<ConstantDataSequential>(GV.getInitializer());
                        if(CDA!=nullptr) {
                                if(CDA->isCString()) {
                                        ClassNameList.push_back(CDA->getAsCString ());
                                }
                                else if(CDA->isString ()) {
                                        ClassNameList.push_back(CDA->getAsString ());
                                }
                        }
                }

        }
        for(string className:ClassNameList) {
                string ClassMethodListGVName = "\01l_OBJC_$_CLASS_METHODS_";
                ClassMethodListGVName.append(className);
                string InstanceMethodListGVName = "\01l_OBJC_$_INSTANCE_METHODS_";
                InstanceMethodListGVName.append(className);
                GlobalVariable *ClassMethodListGV =
                        M->getGlobalVariable(ClassMethodListGVName, true);
                GlobalVariable *InstanceMethodListGV =
                        M->getGlobalVariable(StringRef(InstanceMethodListGVName), true);
                //vector<tuple<string /*SEL*/, string /*Method Signature*/,Function * /*IMP*/> > ClassMethodList;
                //vector<tuple<string /*SEL*/, string /*Method Signature*/,Function * /*IMP*/> > InstanceMethodList;
                if (ClassMethodListGV!=nullptr&&ClassMethodListGV->hasInitializer()) {
                        ConstantStruct *Init = reinterpret_cast<ConstantStruct *>(
                                ClassMethodListGV->getInitializer());
                        ConstantArray *objc_method_struct =
                                dyn_cast<ConstantArray>(Init->getOperand(2));
                        for (unsigned int idx = 0; idx < objc_method_struct->getNumOperands();
                             idx++) {
                                ConstantExpr *CEMethodName = dyn_cast<ConstantExpr>(
                                        dyn_cast<Constant>(objc_method_struct->getOperand(idx))
                                        ->getOperand(0));
                                ConstantExpr *CEMethodSignature = dyn_cast<ConstantExpr>(
                                        dyn_cast<Constant>(objc_method_struct->getOperand(idx))
                                        ->getOperand(1));
                                ConstantExpr *CEBCIFunctionPointer = dyn_cast<ConstantExpr>(
                                        dyn_cast<Constant>(objc_method_struct->getOperand(idx))
                                        ->getOperand(2));
                                GlobalVariable *GVMethodName =
                                        dyn_cast<GlobalVariable>(CEMethodName->getOperand(0));
                                GlobalVariable *GVMethodSig =
                                        dyn_cast<GlobalVariable>(CEMethodSignature->getOperand(0));
                                StringRef MethodName =
                                        dyn_cast<ConstantDataArray>(GVMethodName->getInitializer())
                                        ->getAsString();
                                StringRef MethodSig =
                                        dyn_cast<ConstantDataArray>(GVMethodSig->getInitializer())
                                        ->getAsString();
                                Function *IMP =
                                        dyn_cast<Function>(CEBCIFunctionPointer->getOperand(0));
                                cachetable[className+MethodName.str()]=make_tuple(MethodSig.str(),IMP);
                                        //ClassMethodList.push_back(
                                                //make_tuple(MethodName.str(), MethodSig.str(), IMP));

                        }
                }
                if (InstanceMethodListGV!=nullptr&&InstanceMethodListGV->hasInitializer()) {
                        ConstantStruct *Init = reinterpret_cast<ConstantStruct *>(
                                InstanceMethodListGV->getInitializer());
                        ConstantArray *objc_method_struct =
                                dyn_cast<ConstantArray>(Init->getOperand(2));
                        for (unsigned int idx = 0; idx < objc_method_struct->getNumOperands();
                             idx++) {
                                ConstantExpr *CEMethodName = dyn_cast<ConstantExpr>(
                                        dyn_cast<Constant>(objc_method_struct->getOperand(idx))
                                        ->getOperand(0));
                                ConstantExpr *CEMethodSignature = dyn_cast<ConstantExpr>(
                                        dyn_cast<Constant>(objc_method_struct->getOperand(idx))
                                        ->getOperand(1));
                                ConstantExpr *CEBCIFunctionPointer = dyn_cast<ConstantExpr>(
                                        dyn_cast<Constant>(objc_method_struct->getOperand(idx))
                                        ->getOperand(2));
                                GlobalVariable *GVMethodName =
                                        dyn_cast<GlobalVariable>(CEMethodName->getOperand(0));
                                GlobalVariable *GVMethodSig =
                                        dyn_cast<GlobalVariable>(CEMethodSignature->getOperand(0));
                                StringRef MethodName =
                                        dyn_cast<ConstantDataArray>(GVMethodName->getInitializer())
                                        ->getAsString();
                                StringRef MethodSig =
                                        dyn_cast<ConstantDataArray>(GVMethodSig->getInitializer())
                                        ->getAsString();
                                Function *IMP =
                                        dyn_cast<Function>(CEBCIFunctionPointer->getOperand(0));
                                //MethodCount--;
                                //InstanceMethodList.push_back(
                                        //make_tuple(MethodName.str(), MethodSig.str(), IMP));
                                cachetable[className+MethodName.str()]=make_tuple(MethodSig.str(),IMP);
                        }
                }
        }
        EE->addModule(unique_ptr<Module>(M));

}
void LLHP::apply(){


}
