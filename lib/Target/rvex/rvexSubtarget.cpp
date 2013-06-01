//===- rvexSubtarget.cpp - rvex Subtarget Information -----------------===//
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
// This file implements the rvex specific subclass of TargetSubtargetInfo.
//
//===----------------------------------------------------------------------===//

#include "rvexSubtarget.h"
#include "rvex.h"
#include "llvm/Support/TargetRegistry.h"

#define GET_SUBTARGETINFO_TARGET_DESC
#define GET_SUBTARGETINFO_CTOR
#include "rvexGenSubtargetInfo.inc"

using namespace llvm;

rvexSubtarget::rvexSubtarget(StringRef TT, StringRef CPU, StringRef FS)
    : rvexGenSubtargetInfo(TT, CPU, FS), CPUString(CPU.str()) {

  // Parse features string.
  ParseSubtargetFeatures(CPU, FS);

  // Initialize scheduling itinerary for the specified CPU
  InstrItins = getInstrItineraryForCPU(CPUString);
}

