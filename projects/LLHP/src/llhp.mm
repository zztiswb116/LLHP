#include "llhp.hpp"
#include <dispatch/dispatch.h>
#include <iostream>
#include <memory>
LLHP* LLHP::singleton=nullptr;
static void* dummySELHandler(id self,SEL _cmd,...){
    string cacheKey;//Key for caching hashmap
    cacheKey.append(class_getName([self class]));
    cacheKey.append(sel_getName(_cmd));
    std::cout<<get<0>(LLHP::singleton->cachetable[cacheKey])<<std::endl;
    Function* func=get<1>(LLHP::singleton->cachetable[cacheKey]);
    Method meth=(class_getInstanceMethod([self class],_cmd)!=NULL) ? class_getInstanceMethod([self class],_cmd) : class_getClassMethod([self class],_cmd);
    vector<GenericValue> args;
    va_list ap;
    va_start(ap,_cmd);

    GenericValue arg1;//Push in self
    arg1.PointerVal=(__bridge void*)self;
    args.push_back(arg1);
    GenericValue arg2;//Push in SEL
    arg2.PointerVal=_cmd;
    args.push_back(arg2);

    for(unsigned int i=2;i<method_getNumberOfArguments(meth);i++){
        char type[OBJC_ARGUMENT_TYPE_STR_MAX_LENGTH] = {};
        method_getArgumentType(meth,i,type,OBJC_ARGUMENT_TYPE_STR_MAX_LENGTH);
        switch (type[0]){//Ugly hack.Need improvement for supporting struct
            case '@':{
                GenericValue Result;
                Result.PointerVal=va_arg(ap,void*);
                args.push_back(Result);
            }
            case 'i':{
                GenericValue Result;
                Result.IntVal=APInt(32,va_arg(ap,int),true);
                args.push_back(Result);
            }
            default:
                throw "Argument Type Unsupported:"+string(type);
        }
    }
    va_end(ap);
    GenericValue GV=LLHP::singleton->EE->runFunction(func,ArrayRef<GenericValue>(args));
    return (void*)GV.IntVal.getLimitedValue();
}
LLHP::LLHP(){
    InitializeNativeTarget();
    LLVMContext c;
    Module Mo(StringRef("LLHP"),c);
    EngineBuilder Engine(make_unique<Module>(StringRef("LLHP"),c));
    Engine.setEngineKind(EngineKind::Interpreter);
    Engine.setErrorStr(&err);
    EE=Engine.create();
    EE->runStaticConstructorsDestructors(false);
    LLHP::singleton=this;
}
void LLHP::LoadModule(unique_ptr< Module > Mo){
    Module* M=Mo.get();
    vector<string> ClassNameList;
    //Collect MethodInfo and push into cache
    for (auto GVI = M->global_begin(); GVI != M->global_end();
         GVI++) {        // Iterate GVs for ClassList
        GlobalVariable &GV = *GVI;
        if (GV.hasName()&&GV.getName().str().find("OBJC_CLASS_NAME_") != string::npos) {
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
                ->getAsCString();
                StringRef MethodSig =
                dyn_cast<ConstantDataArray>(GVMethodSig->getInitializer())
                ->getAsCString();
                Function *func =
                dyn_cast<Function>(CEBCIFunctionPointer->getOperand(0));
                cachetable[className+MethodName.str()]=make_tuple(MethodSig.str(),func);
                method_setImplementation(class_getClassMethod(objc_getClass(className.c_str()),sel_registerName(MethodName.str().c_str())),(IMP)dummySELHandler);
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
                ->getAsCString();
                StringRef MethodSig =
                dyn_cast<ConstantDataArray>(GVMethodSig->getInitializer())
                ->getAsCString();
                Function *func =
                dyn_cast<Function>(CEBCIFunctionPointer->getOperand(0));
                cachetable[className+MethodName.str()]=make_tuple(MethodSig.str(),func);
                method_setImplementation(class_getInstanceMethod(objc_getClass(className.c_str()),sel_registerName(MethodName.str().c_str())),(IMP)dummySELHandler);
            }
        }
    }
    //TODO: Map GVs to native address.
    //Including but not limited to StringConstants(a.k.a. ConstantArray) and declared GVs
    for (auto GVI = M->global_begin(); GVI != M->global_end();
         GVI++) {        // Iterate GVs for ClassList
        GlobalVariable &GV = *GVI;
        Type* GVType=GV.getType ();
        StringRef GVName=GV.getName();
        if(GVName.startswith("OBJC_SELECTOR_REFERENCES_")){
            Constant* cs=GV.getInitializer();
            if(ConstantExpr* exp=dyn_cast<ConstantExpr>(cs)){
                if(GlobalVariable* foo1= dyn_cast<GlobalVariable>(exp->getOperand (0))){
                    StringRef SELName=dyn_cast<ConstantDataArray>(foo1->getInitializer())->getAsCString();
                    void* SELFoo=(void*)sel_registerName(SELName.data());
                    errs()<<SELName<<" :"<<SELFoo<<"\n";
                    EE->addGlobalMapping(&GV,&SELFoo);
                }
            }

        }
        else if(!GV.hasInitializer ()){
            //Declared Variable
            if(GVName.startswith("OBJC_CLASS_$_")){
                size_t pos=GVName.find("OBJC_CLASS_$_");
                StringRef clsName=GVName.substr(pos+strlen("OBJC_CLASS_$_"));
                void* tmp=(__bridge void*)objc_getClass(clsName.data());
                errs()<<clsName<<" :"<<tmp<<"\n";
                EE->addGlobalMapping(&GV,tmp);

            }
            /*map<Type*,function<void *(GlobalVariable*)>>::iterator it = Handlers.find(GVType);
            if(it != Handlers.end())
            {
                function<void *(GlobalVariable*)> Handler = it->second;

            }*/

        }
    }
    EE->addModule(std::move(Mo));
    EE->runFunctionAsMain(EE->FindFunctionNamed("main"),vector<string >(),NULL);
}
