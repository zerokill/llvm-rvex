//===-- rvexTargetMachine.h - Define TargetMachine for rvex --*- C++ --===//
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
//
// This file declares the rvex specific subclass of TargetMachine.
//
//===----------------------------------------------------------------------===//

#ifndef rvexTARGETMACHINE_H
#define rvexTARGETMACHINE_H

#include "rvexInstrInfo.h"
#include "rvexISelLowering.h"
#include "rvexFrameLowering.h"
#include "rvexSelectionDAGInfo.h"
#include "rvexSubtarget.h"
#include "llvm/Target/TargetMachine.h"
#include "llvm/DataLayout.h"
#include "llvm/Target/TargetFrameLowering.h"

namespace llvm {

class rvexTargetMachine : public LLVMTargetMachine {
  const DataLayout DL; // Calculates type size & alignment
  rvexSubtarget Subtarget;
  rvexInstrInfo InstrInfo;
  rvexTargetLowering TLInfo;
  rvexSelectionDAGInfo TSInfo;
  rvexFrameLowering FrameLowering;
	const InstrItineraryData *InstrItins;

public:
  rvexTargetMachine(const Target &T, StringRef TT, StringRef CPU,
                      StringRef FS, TargetOptions Options, Reloc::Model RM,
                      CodeModel::Model CM, CodeGenOpt::Level OL);

  virtual const rvexSubtarget *getSubtargetImpl() const {
    return &Subtarget;
  }

  virtual const rvexInstrInfo *getInstrInfo() const {
    return &InstrInfo;
  }

  virtual const rvexFrameLowering  *getFrameLowering() const {
    return &FrameLowering;
  }

  virtual const rvexRegisterInfo *getRegisterInfo() const {
    return &InstrInfo.getRegisterInfo();
  }

  virtual const rvexTargetLowering* getTargetLowering() const {
    return &TLInfo;
  }

  virtual const rvexSelectionDAGInfo* getSelectionDAGInfo() const {
    return &TSInfo;
  }

  virtual const DataLayout *getDataLayout() const {
    return &DL;
  }

  virtual const InstrItineraryData *getInstrItineraryData() const {
    return InstrItins;
  }

  // Pass Pipeline Configuration
  virtual TargetPassConfig *createPassConfig(PassManagerBase &PM);
};

} // end namespace llvm

#endif //rvexTARGETMACHINE_H

