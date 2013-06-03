//===-- Cpu0MCAsmInfo.cpp - Cpu0 asm properties -----------------------===//
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
// This file contains the declarations of the Cpu0MCAsmInfo properties.
//
//===----------------------------------------------------------------------===//

#include "Cpu0MCAsmInfo.h"
#include "llvm/ADT/Triple.h"

using namespace llvm;

Cpu0ELFMCAsmInfo::Cpu0ELFMCAsmInfo(const Target &T, StringRef TT) {
  //Only members with inappropriate default values are listed here.

  MaxInstLength = 10;

  Data32bitsDirective = "\t.word\t";
  Data64bitsDirective = 0;
  ZeroDirective = "\t.skip\t";

  GlobalDirective = "\t.global\t";
  ExternDirective = "\t.globl\t";

  SupportsDebugInformation = true;
  
  UsesELFSectionDirectiveForBSS = true;
}

