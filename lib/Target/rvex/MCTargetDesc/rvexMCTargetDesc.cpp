//===-- rvexMCTargetDesc.cpp - rvex Target Descriptions ------*- C++ -*-===//
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
// This file provides rvex specific target descriptions.
//
//===----------------------------------------------------------------------===//

#include "rvexMCTargetDesc.h"
#include "rvexMCAsmInfo.h"
#include "llvm/MC/MCCodeGenInfo.h"
#include "llvm/MC/MCInstrInfo.h"
#include "llvm/MC/MCRegisterInfo.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/Support/TargetRegistry.h"

#define GET_INSTRINFO_MC_DESC
#include "rvexGenInstrInfo.inc"

#define GET_SUBTARGETINFO_MC_DESC
#include "rvexGenSubtargetInfo.inc"

#define GET_REGINFO_MC_DESC
#include "rvexGenRegisterInfo.inc"

using namespace llvm;

static MCInstrInfo *creatervexMCInstrInfo() {
  MCInstrInfo *X = new MCInstrInfo();
  InitrvexMCInstrInfo(X);
  return X;
}

static MCRegisterInfo *creatervexMCRegisterInfo(StringRef TT) {
  MCRegisterInfo *X = new MCRegisterInfo();
  InitrvexMCRegisterInfo(X, T64::R51); //TODO: is that right?
  return X;
}

static MCSubtargetInfo *creatervexMCSubtargetInfo(StringRef TT, StringRef CPU,
                                                    StringRef FS) {
  MCSubtargetInfo *X = new MCSubtargetInfo();
  InitrvexMCSubtargetInfo(X, TT, CPU, FS);
  return X;
}

static MCCodeGenInfo *creatervexMCCodeGenInfo(StringRef TT, Reloc::Model RM,
                                                CodeModel::Model CM,
                                                CodeGenOpt::Level OL) {
  MCCodeGenInfo *X = new MCCodeGenInfo();
  X->InitMCCodeGenInfo(RM, CM, OL);
  return X;
}

extern "C" void LLVMInitializervexTargetMC() {
  // Register the MC asm info.
  RegisterMCAsmInfo<rvexELFMCAsmInfo> X(ThervexTarget);

  // Register the MC codegen info.
  TargetRegistry::RegisterMCCodeGenInfo(ThervexTarget,
                                        creatervexMCCodeGenInfo);

  // Register the MC instruction info.
  TargetRegistry::RegisterMCInstrInfo(ThervexTarget, creatervexMCInstrInfo);

  // Register the MC register info.
  TargetRegistry::RegisterMCRegInfo(ThervexTarget, creatervexMCRegisterInfo);

  // Register the MC subtarget info.
  TargetRegistry::RegisterMCSubtargetInfo(ThervexTarget,
                                          creatervexMCSubtargetInfo);
}
