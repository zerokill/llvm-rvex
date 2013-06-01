//===- rvexRegisterInfo.cpp - rvex Register Information -----*- C++ -*-===//
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

#include "rvex.h"
#include "rvexRegisterInfo.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/RegisterScavenging.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Target/TargetInstrInfo.h"
#include "llvm/Type.h"
#include "llvm/ADT/BitVector.h"
#include "llvm/ADT/STLExtras.h"

#define GET_REGINFO_TARGET_DESC
#include "rvexGenRegisterInfo.inc"

using namespace llvm;

rvexRegisterInfo::rvexRegisterInfo(const TargetInstrInfo &tii)
  : rvexGenRegisterInfo(T64::LinkRegister), TII(tii) {
}

const uint16_t* rvexRegisterInfo::getCalleeSavedRegs(const MachineFunction *MF)
                                                                         const {
  //Although T64::FramePointer is officially callee saved, it's not listed
  //here, because of special handling in prologue/epilogue sections.

  static const uint16_t CalleeSavedRegs[] = {
    T64::R30, T64::R31, T64::R32, T64::R33, T64::R34, T64::R35,
    T64::R36, T64::R37, T64::R38, T64::R39, T64::R40, T64::R41,
    T64::R42, T64::R43, T64::R44, T64::R45, T64::R46, T64::R47,
    T64::R48, T64::R49, T64::R50, T64::R51, 0 };

  return CalleeSavedRegs;
}

BitVector rvexRegisterInfo::getReservedRegs(const MachineFunction &MF) const {
  BitVector Reserved(getNumRegs());
  Reserved.set(T64::R51); //Reserved for frame index elimination purposes
  //Reserved.set(T64::FramePointer);
  Reserved.set(T64::ThreadLocalData);
  Reserved.set(T64::StackPointer);
  Reserved.set(T64::LinkRegister);
  Reserved.set(T64::SN);
  Reserved.set(T64::IDN0);
  Reserved.set(T64::IDN1);
  Reserved.set(T64::UDN0);
  Reserved.set(T64::UDN1);
  Reserved.set(T64::UDN2);
  Reserved.set(T64::UDN3);
  Reserved.set(T64::Zero);
  return Reserved;
}

void rvexRegisterInfo::
eliminateCallFramePseudoInstr(MachineFunction &MF, MachineBasicBlock &MBB,
                              MachineBasicBlock::iterator I) const {
  //Call frame area is handled in prologue and epilogue. Pseudo instructions
  //are needed to make information about call frame sizes available.
  MBB.erase(I);
}

void
rvexRegisterInfo::eliminateFrameIndex(MachineBasicBlock::iterator II,
                                        int SPAdj, RegScavenger *RS) const {
  assert(SPAdj == 0 && "Unexpected");

  MachineInstr &MI = *II;
  MachineBasicBlock &MBB = *MI.getParent();
  MachineFunction *MF = MBB.getParent();
  DebugLoc DL = MI.getDebugLoc();

  int Opc = MI.getOpcode();

  unsigned DestReg = 0;
  MachineOperand *FrameIndexOp = 0;

  if(Opc == T64::MOVFI) {
    DestReg = MI.getOperand(0).getReg();
    FrameIndexOp = &MI.getOperand(1);
  } else if(Opc == T64::SW || Opc == T64::LW) {
    unsigned i = 0;
    while (!MI.getOperand(i).isFI()) {
      ++i;
      assert(i < MI.getNumOperands() && "Instr doesn't have FrameIndex operand!");
    }
    DestReg = T64::R51;
    FrameIndexOp = &MI.getOperand(i);
  }

  int Offset = MF->getFrameInfo()->getObjectOffset(FrameIndexOp->getIndex());

//  addOffset(MBB, II, DL, DestReg, T64::FramePointer, Offset);

  switch(Opc) {
    default: llvm_unreachable("FrameIndex in unexpected instruction!");
    case T64::MOVFI:
      MI.eraseFromParent();
      break;
    case T64::SW:
    case T64::LW:
     FrameIndexOp->ChangeToRegister(DestReg, false);
     break;
  }
}

unsigned rvexRegisterInfo::getFrameRegister(const MachineFunction &MF) const {
  //return T64::FramePointer;
    return 0;
}

unsigned rvexRegisterInfo::getEHExceptionRegister() const {
  llvm_unreachable("What is the exception register");
  return 0;
}

unsigned rvexRegisterInfo::getEHHandlerRegister() const {
  llvm_unreachable("What is the exception handler register");
  return 0;
}

// Hier gaat sowieso nog iets fout. Controleer hoe de offset berekent wordt en of dit klopt.
void rvexRegisterInfo::
addOffset(MachineBasicBlock &MBB, MachineBasicBlock::iterator I, DebugLoc DL,
          unsigned Dest, unsigned Src, int Offset) const {
  if(Offset >= -128 && Offset <= 127) {
    BuildMI(MBB, I, DL, TII.get(T64::ADDI), Dest).addReg(Src).
                                                  addImm(Offset);
  } else if(Offset >= -32768 && Offset <= 32767) {
    BuildMI(MBB, I, DL, TII.get(T64::ADDI), Dest).addReg(Src).
                                                   addImm(Offset);
  } else {
    unsigned OffHi = (unsigned) Offset >> 16U;
    BuildMI(MBB, I, DL, TII.get(T64::ADDI), Dest).addReg(Src).
                                                   addImm(Offset & ((1 << 16) - 1));
    BuildMI(MBB, I, DL, TII.get(T64::AULI), Dest).addReg(Dest).
                                                  addImm(OffHi);
  }
}

