//====- rvexFrameLowering.cpp - rvex Frame Information -----*- C++ -*-====//
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
// This file contains the rvex implementation of TargetFrameLowering class.
//
//===----------------------------------------------------------------------===//

#include "rvexFrameLowering.h"
#include "rvexRegisterInfo.h"
#include "rvexInstrInfo.h"
#include "rvexMachineFunctionInfo.h"
#include "llvm/Function.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineModuleInfo.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/Target/TargetOptions.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Debug.h"

using namespace llvm;

void rvexFrameLowering::emitPrologue(MachineFunction &MF) const {
  MachineBasicBlock &MBB = MF.front();
  MachineFrameInfo *MFI = MF.getFrameInfo();
  const rvexInstrInfo &TII =
    *static_cast<const rvexInstrInfo*>(MF.getTarget().getInstrInfo());
  const rvexRegisterInfo &TRI =
    *static_cast<const rvexRegisterInfo*>(MF.getTarget().getRegisterInfo());

  MachineBasicBlock::iterator MBBI = MBB.begin();
  DebugLoc DL = MBBI != MBB.end() ? MBBI->getDebugLoc() : DebugLoc();

  // Get the number of bytes to allocate from the FrameInfo
  int maxCallFrameSize = (int) MFI->getMaxCallFrameSize();
  int NumBytes = (int) MFI->getStackSize();
  NumBytes += maxCallFrameSize;
  NumBytes += abs(getOffsetOfLocalArea());
  NumBytes = -((NumBytes + 7) & ~7); //round up to next double-word boundary

  //fp and lr slots at the bottom of the frame needed only if there are calls
  int StackOffset = (int) MFI->hasCalls() ?
                          MF.getInfo<rvexMachineFunctionInfo>()->
                            getArgAreaOffset() : 0;
  NumBytes += (-StackOffset);
  DEBUG(errs() << "NumBytes " << NumBytes << "\n");
  //storing lr
  //BuildMI(MBB, MBBI, DL, TII.get(T64::SW)).addReg(T64::StackPointer).addReg(T64::LinkRegister);
  //setting fp
  //BuildMI(MBB, MBBI, DL, TII.get(T64::MOVE), T64::FramePointer).addReg(T64::StackPointer);
  //setting sp
  TRI.addOffset(MBB, MBBI, DL, T64::StackPointer, T64::StackPointer, NumBytes);

  //temp register for addressing
  unsigned TmpReg = T64::R10; //R0-R29 caller saved, but R0-R9 may contain args

  //storing fp, if needed -- it's the same as the custom inserter of STORE_FP
  if(MFI->hasCalls()) {
    BuildMI(MBB, MBBI, DL, TII.get(T64::ADDI), TmpReg).addReg(T64::StackPointer)
                                                      .addImm(4);
    //BuildMI(MBB, MBBI, DL, TII.get(T64::SW)).addReg(TmpReg).addReg(T64::FramePointer);
  }
}

void rvexFrameLowering::emitEpilogue(MachineFunction &MF,
                                       MachineBasicBlock &MBB) const {
  MachineBasicBlock::iterator MBBI = MBB.getLastNonDebugInstr();
  const rvexInstrInfo &TII =
    *static_cast<const rvexInstrInfo*>(MF.getTarget().getInstrInfo());
  DebugLoc DL = MBBI->getDebugLoc();

  assert(MBBI->getOpcode() == T64::JRP &&
         "Can only put epilog before 'jrp' instruction!");

  //restore lr
  //BuildMI(MBB, MBBI, DL, TII.get(T64::LW)).addReg(T64::LinkRegister).addReg(T64::FramePointer);
  //restore sp
  //BuildMI(MBB, MBBI, DL, TII.get(T64::MOVE), T64::StackPointer).addReg(T64::FramePointer);
  //restore fp
  //BuildMI(MBB, MBBI, DL, TII.get(T64::ADDI), T64::FramePointer).addReg(T64::FramePointer).addImm(4);
  //BuildMI(MBB, MBBI, DL, TII.get(T64::LW)).addReg(T64::FramePointer).addReg(T64::FramePointer);
}

//Compute the exact address of dynamically allocated stack objects
void rvexFrameLowering::
processFunctionBeforeFrameFinalized(MachineFunction &MF) const {
  const TargetInstrInfo *TII = MF.getTarget().getInstrInfo();
	const rvexRegisterInfo *TRI = static_cast<const rvexRegisterInfo*>
                                             (MF.getTarget().getRegisterInfo());
  rvexMachineFunctionInfo *FuncInfo = MF.getInfo<rvexMachineFunctionInfo>();
  MachineFrameInfo *MFI = MF.getFrameInfo();

  bool hasCalls = MFI->hasCalls();
  unsigned Offset = FuncInfo->getArgAreaOffset() + MFI->getMaxCallFrameSize();

  for(MachineFunction::iterator I = MF.begin(), E = MF.end();
      I != E; ++I) {
    MachineBasicBlock &MBB = *I;
    for(MachineBasicBlock::iterator II = MBB.begin(), IE = MBB.end();
        II != IE; ++II) {
      MachineInstr *MI = &*II;
      if(MI->getOpcode() == T64::NEWSLOT_ADDR) {
        DebugLoc DL = MI->getDebugLoc();
        MachineBasicBlock::iterator MBBI(MI);

        unsigned Dest = MI->getOperand(0).getReg();
        unsigned Src = MI->getOperand(1).getReg();

        if(hasCalls) {
          TRI->addOffset(MBB, MBBI, DL, Dest, Src, Offset);
        } else {
          BuildMI(MBB, MBBI, DL, TII->get(T64::MOVE), Dest).addReg(Src);
        }
        ++II;
        MI->eraseFromParent();
				--II;
      }
		}
	}
}

