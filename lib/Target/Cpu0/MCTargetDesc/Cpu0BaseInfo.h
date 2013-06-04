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
    case Cpu0::R0:
      return 0;
    case Cpu0::R1:
      return 1;
    case Cpu0::R2:
      return 2;
    case Cpu0::R3:
      return 3;
    case Cpu0::R4:
      return 4;
    case Cpu0::R5:
      return 5;
    case Cpu0::R6:
      return 6;
    case Cpu0::R7:
      return 7;
    case Cpu0::R8:
      return 8;
    case Cpu0::R9:
      return 9;
    case Cpu0::R10:
      return 10;
    case Cpu0::R11:
      return 11;
    case Cpu0::R12:
      return 12;
    case Cpu0::R13:
      return 13;
    case Cpu0::R14:
      return 14;
    case Cpu0::R15:
      return 15;
    case Cpu0::R16:
      return 16;
    case Cpu0::R17:
      return 17;
    case Cpu0::R18:
      return 18;
    case Cpu0::R19:
      return 19;
    case Cpu0::R20:
      return 20;
    case Cpu0::R21:
      return 21;
    case Cpu0::R22:
      return 22;
    case Cpu0::R23:
      return 23;
    case Cpu0::R24:
      return 24;
    case Cpu0::R25:
      return 25;
    case Cpu0::R26:
      return 26;
    case Cpu0::R27:
      return 27;
    case Cpu0::R28:
      return 28;
    case Cpu0::R29:
      return 29;
    case Cpu0::R30:
      return 30;
    case Cpu0::R31:
      return 31;
    case Cpu0::R32:
      return 32;
    case Cpu0::R33:
      return 33;
    case Cpu0::R34:
      return 34;
    case Cpu0::R35:
      return 35;
    case Cpu0::R36:
      return 36;
    case Cpu0::R37:
      return 37;
    case Cpu0::R38:
      return 38;
    case Cpu0::R39:
      return 39;
    case Cpu0::R40:
      return 40;
    case Cpu0::R41:
      return 41;
    case Cpu0::R42:
      return 42;
    case Cpu0::R43:
      return 43;
    case Cpu0::R44:
      return 44;
    case Cpu0::R45:
      return 45;
    case Cpu0::R46:
      return 46;
    case Cpu0::R47:
      return 47;
    case Cpu0::R48:
      return 48;
    case Cpu0::R49:
      return 49;
    case Cpu0::R50:
      return 50;
    case Cpu0::R51:
      return 51;
    case Cpu0::R52:
      return 52;
    case Cpu0::R53:
      return 53;
    case Cpu0::R54:
      return 54;
    case Cpu0::R55:
      return 55;
    case Cpu0::R56:
      return 56;
    case Cpu0::R57:
      return 57;
    case Cpu0::R58:
      return 58;
    case Cpu0::R59:
      return 59;
    case Cpu0::R60:
      return 60;
    case Cpu0::R61:
      return 61;
    case Cpu0::R62:
      return 62;
    case Cpu0::R63:
      return 63;
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
