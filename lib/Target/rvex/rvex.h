//===-- rvex.h - Top-level interface for rvex representation --*- C++ -===//
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
// This file contains the entry points for global functions defined in the LLVM
// rvex back-end.
//
//===----------------------------------------------------------------------===//

#ifndef TARGET_rvex_H
#define TARGET_rvex_H

#include "MCTargetDesc/rvexMCTargetDesc.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Target/TargetMachine.h"
#include <cassert>

namespace llvm {
  class FunctionPass;
  class rvexTargetMachine;
  class formatted_raw_ostream;

  FunctionPass *creatervexISelDag(rvexTargetMachine &TM);

  FunctionPass *creatervexVLIWPacketizer();

} // end namespace llvm;

#endif

