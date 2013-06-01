//===-- rvexTargetMachine.cpp - Define TargetMachine for rvex -*- C++ -===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
//                               rvex Backend
//
// Author: David Juhasz
// E-mail: juhda@caesar.elte.hu
// Institute: Dept. of Programming Languages and Compilers, ELTE IK, Hungary
//
// The research is supported by the European Union and co-financed by the
// European Social Fund (grant agreement no. TAMOP
// 4.2.1./B-09/1/KMR-2010-0003).
//
//===----------------------------------------------------------------------===//

#include "rvex.h"
#include "rvexTargetMachine.h"
#include "llvm/PassManager.h"
#include "llvm/CodeGen/Passes.h"
#include "llvm/Support/TargetRegistry.h"
using namespace llvm;

extern "C" void LLVMInitializervexTarget() {
  // Register the target.
  RegisterTargetMachine<rvexTargetMachine> X(ThervexTarget);
}

rvexTargetMachine::rvexTargetMachine(const Target &T, StringRef TT,
                                         StringRef CPU, StringRef FS,
                                         TargetOptions Options,
                                         Reloc::Model RM, CodeModel::Model CM,
                                         CodeGenOpt::Level OL)
  : LLVMTargetMachine(T, TT, CPU, FS, Options, RM, CM, OL),
    DL("e-p:32:32-i8:8-i16:16-i32:32-i64:64-f32:32-f64:64-a:0-S:64"),
    Subtarget(TT, CPU, FS),
    InstrInfo(), TLInfo(*this), TSInfo(*this),
    FrameLowering(),
    InstrItins(&Subtarget.getInstItineraryData()) {
}

namespace {
/// rvex Code Generator Pass Configuration Options.
class rvexPassConfig: public TargetPassConfig {
public:
  rvexPassConfig(rvexTargetMachine *TM, PassManagerBase &PM)
    : TargetPassConfig(TM, PM) {}

  rvexTargetMachine &getrvexTargetMachine() const {
    return getTM<rvexTargetMachine>();
  }

  virtual bool addInstSelector();
	virtual bool addPreEmitPass();
};
} // end namespace

TargetPassConfig *rvexTargetMachine::createPassConfig(PassManagerBase &PM) {
  return new rvexPassConfig(this, PM);
}

bool rvexPassConfig::addInstSelector() {
  addPass(creatervexISelDag(getrvexTargetMachine()));
  return false;
}

bool rvexPassConfig::addPreEmitPass() {
	if(static_cast<rvexTargetMachine*>(TM)->getSubtargetImpl()->isVLIWEnabled()) {
	  addPass(creatervexVLIWPacketizer());
	}
  return false;
}

