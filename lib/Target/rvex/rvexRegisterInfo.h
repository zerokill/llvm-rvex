//===- rvexRegisterInfo.h - rvex Register Information Impl --*- C++ -*-===//
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
// This file contains the rvex implementation of the TargetRegisterInfo class.
//
//===----------------------------------------------------------------------===//

#ifndef rvexREGISTERINFO_H
#define rvexREGISTERINFO_H

#include "llvm/Target/TargetRegisterInfo.h"

#define GET_REGINFO_HEADER
#include "rvexGenRegisterInfo.inc"

namespace llvm {

class TargetInstrInfo;
class Type;

struct rvexRegisterInfo : public rvexGenRegisterInfo {

  const TargetInstrInfo &TII;

  rvexRegisterInfo(const TargetInstrInfo &tii);

  /// Code Generation virtual methods...
  virtual const uint16_t *getCalleeSavedRegs(const MachineFunction *MF = 0)
                                                                         const;

  virtual BitVector getReservedRegs(const MachineFunction &MF) const;

  virtual void eliminateCallFramePseudoInstr(MachineFunction &MF,
                                             MachineBasicBlock &MBB,
                                             MachineBasicBlock::iterator I)
                                                                         const;

  virtual void eliminateFrameIndex(MachineBasicBlock::iterator II,
                                   int SPAdj, RegScavenger *RS = NULL) const;

  // Debug information queries.
  virtual unsigned getFrameRegister(const MachineFunction &MF) const;

  // Exception handling queries.
  unsigned getEHExceptionRegister() const;
  unsigned getEHHandlerRegister() const;

  /// own methods

  //[Dest] = [Src] + Offset
  void addOffset(MachineBasicBlock &MBB, MachineBasicBlock::iterator I,
                 DebugLoc DL, unsigned Dest, unsigned Src, int Offset) const;
};

} // end namespace llvm

#endif

