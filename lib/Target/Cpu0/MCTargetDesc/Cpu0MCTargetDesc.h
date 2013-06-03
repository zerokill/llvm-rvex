//===-- Cpu0MCTargetDesc.h - Cpu0 Target Descriptions -------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
//                               Cpu0 Backend
//
// Author: David Juhasz
// E-mail: juhda@caesar.elte.hu
// Institute: Dept. of Programming Languages and Compilers, ELTE IK, Hungary
//
// The research is supported by the European Union and co-financed by the
// European Social Fund (grant agreement no. TAMOP
// 4.2.1./B-09/1/KMR-2010-0003).
//
// This file provides Cpu0 specific target descriptions.
//
//===----------------------------------------------------------------------===//

#ifndef Cpu0MCTARGETDESC_H
#define Cpu0MCTARGETDESC_H

namespace llvm {
class MCSubtargetInfo;
class Target;
class StringRef;

extern Target TheCpu0Target;

} // End llvm namespace

// Defines symbolic names for Cpu0 registers.  This defines a mapping from
// register name to register number.
//
#define GET_REGINFO_ENUM
#include "Cpu0GenRegisterInfo.inc"

// Defines symbolic names for the Cpu0 instructions.
//
#define GET_INSTRINFO_ENUM
#include "Cpu0GenInstrInfo.inc"

#define GET_SUBTARGETINFO_ENUM
#include "Cpu0GenSubtargetInfo.inc"

#endif

