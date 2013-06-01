//===-- rvexBaseInfo.h - Top level definitions for rvex ----*- C++ -*--===//
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
// This file contains small standalone helper functions and enum definitions for
// the rvex target useful for the compiler back-end and the MC libraries.
// As such, it deliberately does not include references to LLVM core
// code gen types, passes, etc..
//
//===----------------------------------------------------------------------===//

#ifndef rvexBASEINFO_H
#define rvexBASEINFO_H

namespace llvm {

// rvexII - This namespace holds all of the target specific flags that /
//instruction info tracks.
//
namespace rvexII {
  // *** The code below must match rvexInstrFormat*.td *** //

  // Insn types. -- see rvexSchedule.td bundle-approach
  // *** Must match HexagonInstrFormat*.td ***
  enum rvexType {
    TypePSEUDO = 0,
    TypeArS    = 1,
    TypeArL    = 2,
    TypeBmS    = 3,
    TypeBmL    = 4,
    TypeCtr    = 5,
    TypeMeS    = 6,
    TypeMeL    = 7,
    TypeIll    = 8,
    TypeNull   = 15 //not a valid type
  };



  // MCInstrDesc TSFlags
  // *** Must match rvexInstrFormat*.td ***
  enum {
    // This 4-bit field describes the insn type.
    TypePos  = 0,
    TypeMask = 0xf,

    // Solo instructions.
    SoloPos  = 4,
    SoloMask = 0x1,

    // Long instructions. -- only for X bundles
    LongPos = 5,
    LongMask = 0x1
  };

  // *** The code above must match rvexInstrFormat*.td *** //

} // End namespace rvexII.

} // End namespace llvm.

#endif
