//===-- Cpu0BaseInfo.h - Top level definitions for Cpu0 ----*- C++ -*--===//
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
// This file contains small standalone helper functions and enum definitions for
// the Cpu0 target useful for the compiler back-end and the MC libraries.
// As such, it deliberately does not include references to LLVM core
// code gen types, passes, etc..
//
//===----------------------------------------------------------------------===//

#ifndef Cpu0BASEINFO_H
#define Cpu0BASEINFO_H

namespace llvm {

// Cpu0II - This namespace holds all of the target specific flags that /
//instruction info tracks.
//
namespace Cpu0II {
  // *** The code below must match Cpu0InstrFormat*.td *** //

    enum Cpu0Type {
      TypeIIAlu    = 0,
      TypeIILoad   = 1,
      TypeIIStore  = 2,
      TypeIIBranch = 3,
      TypeIIHiLo   = 4,
      TypeIIImul   = 5,
      TypeIIIdiv   = 6,
      TypeIIPseudo = 7,

    };

    enum {
    //===------------------------------------------------------------------===//
    // Instruction encodings.  These are the standard/most common forms for
    // Cpu0 instructions.
    //

    // Pseudo - This represents an instruction that is a pseudo instruction
    // or one that has not been implemented yet.  It is illegal to code generate
    // it, but tolerated for intermediate implementation stages.
    Pseudo   = 0,

    /// FrmR - This form is for instructions of the format R.
    FrmR  = 1,
    /// FrmI - This form is for instructions of the format I.
    FrmI  = 2,
    /// FrmJ - This form is for instructions of the format J.
    FrmJ  = 3,
    /// FrmOther - This form is for instructions that have no specific format.
    FrmOther = 4,

    FormMask = 15
  };

  // MCInstrDesc TSFlags
  // *** Must match Cpu0InstrFormat*.td ***
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

  /// getCpu0RegisterNumbering - Given the enum value for some register,
/// return the number that it corresponds to.
inline static unsigned getCpu0RegisterNumbering(unsigned RegEnum)
{
  switch (RegEnum) {
  case Cpu0::ZERO:
    return 0;
  case Cpu0::AT:
    return 1;
  case Cpu0::V0:
    return 2;
  case Cpu0::V1:
    return 3;
  case Cpu0::A0:
    return 4;
  case Cpu0::A1:
    return 5;
  case Cpu0::T9:
    return 6;
  case Cpu0::S0:
    return 7;
  case Cpu0::S1:
    return 8;
  case Cpu0::S2:
    return 9;
  case Cpu0::GP:
    return 10;
  case Cpu0::FP:
    return 11;
  case Cpu0::SW:
    return 12;
  case Cpu0::SP:
    return 13;
  case Cpu0::LR:
    return 14;
  case Cpu0::PC:
    return 15;
  default: llvm_unreachable("Unknown register number!");
  }
}

enum TOF {
  //===------------------------------------------------------------------===//
  // Cpu0 Specific MachineOperand flags.

  MO_NO_FLAG,

  /// MO_GOT16 - Represents the offset into the global offset table at which
  /// the address the relocation entry symbol resides during execution.
  MO_GOT16,
  MO_GOT,

  /// MO_GOT_CALL - Represents the offset into the global offset table at
  /// which the address of a call site relocation entry symbol resides
  /// during execution. This is different from the above since this flag
  /// can only be present in call instructions.
  MO_GOT_CALL,

  /// MO_GPREL - Represents the offset from the current gp value to be used
  /// for the relocatable object file being produced.
  MO_GPREL,

  /// MO_ABS_HI/LO - Represents the hi or low part of an absolute symbol
  /// address.
  MO_ABS_HI,
  MO_ABS_LO,

  /// MO_TLSGD - Represents the offset into the global offset table at which
  // the module ID and TSL block offset reside during execution (General
  // Dynamic TLS).
  MO_TLSGD,

  /// MO_TLSLDM - Represents the offset into the global offset table at which
  // the module ID and TSL block offset reside during execution (Local
  // Dynamic TLS).
  MO_TLSLDM,
  MO_DTPREL_HI,
  MO_DTPREL_LO,

  /// MO_GOTTPREL - Represents the offset from the thread pointer (Initial
  // Exec TLS).
  MO_GOTTPREL,

  /// MO_TPREL_HI/LO - Represents the hi and low part of the offset from
  // the thread pointer (Local Exec TLS).
  MO_TPREL_HI,
  MO_TPREL_LO,

  // N32/64 Flags.
  MO_GPOFF_HI,
  MO_GPOFF_LO,
  MO_GOT_DISP,
  MO_GOT_PAGE,
  MO_GOT_OFST
};

  // *** The code above must match Cpu0InstrFormat*.td *** //

} // End namespace Cpu0II.

} // End namespace llvm.

#endif
