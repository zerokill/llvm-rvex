//===-- rvexISelDAGToDAG.cpp - A dag to dag inst selector for rvex ----===//
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
// This file defines an instruction selector for the rvex target.
//
//===----------------------------------------------------------------------===//

#include "rvexTargetMachine.h"
#include "llvm/Intrinsics.h"
#include "llvm/CodeGen/SelectionDAGISel.h"
#include "llvm/Support/Compiler.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

//===----------------------------------------------------------------------===//
// Instruction Selector Implementation
//===----------------------------------------------------------------------===//

//===--------------------------------------------------------------------===//
/// rvexDAGToDAGISel - rvex specific code to select rvex machine
/// instructions for SelectionDAG operations.
///
namespace {
class rvexDAGToDAGISel : public SelectionDAGISel {
  rvexTargetMachine& TM;
public:
  explicit rvexDAGToDAGISel(rvexTargetMachine &tm)
    : SelectionDAGISel(tm),
      TM(tm) {
  }

  SDNode *Select(SDNode *N);

  //Complex Pattern Selector
  bool SelectFI(SDValue N, SDValue &R1);

  virtual const char *getPassName() const {
    return "rvex DAG->DAG Pattern Instruction Selection";
  }
    bool SelectAddr(SDNode *Parent, SDValue Addr, SDValue &Base, SDValue &Offset);
  // Include the pieces autogenerated from the target description.
#include "rvexGenDAGISel.inc"

private:
  SDNode *getGlobalBaseReg();
};
}  // end anonymous namespace


SDNode *rvexDAGToDAGISel::Select(SDNode *N) {
  DebugLoc DL = N->getDebugLoc();
  if (N->isMachineOpcode())
    return NULL;   // Already selected.

  switch (N->getOpcode()) {
  default: break;

  case T64ISD::GLOBAL_BASE_REG:
    return getGlobalBaseReg();

  case ISD::MUL: {
    SDValue MulLHS = N->getOperand(0);
    SDValue MulRHS = N->getOperand(1);

    SDNode *Mul = CurDAG->getMachineNode(T64::MULLL_UU, DL, MVT::i32,
                                         MulLHS, MulRHS);
    Mul = CurDAG->getMachineNode(T64::MULHLSA_UU, DL, MVT::i32,
                                 SDValue(Mul, 0), MulLHS, MulRHS);
    return CurDAG->SelectNodeTo(N, T64::MULHLSA_UU, MVT::i32, SDValue(Mul, 0), MulRHS, MulLHS);
  }

  case ISD::MULHU:
  case ISD::MULHS: {
    SDValue MulLHS = N->getOperand(0);
    SDValue MulRHS = N->getOperand(1);

    unsigned OldOpcode = N->getOpcode();

    unsigned Opcode = OldOpcode == ISD::MULHU ? T64::MULHL_UU : T64::MULHL_SS;
    SDNode *Mul = CurDAG->getMachineNode(Opcode, DL, MVT::i32,
                                         MulLHS, MulRHS);

    Opcode = OldOpcode == ISD::MULHU ? T64::MULHLA_UU : T64::MULHLA_SS;
    Mul = CurDAG->getMachineNode(Opcode, DL, MVT::i32,
                                 SDValue(Mul, 0), MulRHS, MulLHS);

    Opcode = OldOpcode == ISD::MULHU ? T64::SHRI : T64::SRAI;
    Mul = CurDAG->getMachineNode(Opcode, DL, MVT::i32, SDValue(Mul, 0),
                                 CurDAG->getTargetConstant(16, MVT::i8));

    Opcode = OldOpcode == ISD::MULHU ? T64::MULHHA_UU : T64::MULHHA_SS;
    return CurDAG->SelectNodeTo(N, Opcode, MVT::i32,
                                SDValue(Mul, 0), MulLHS, MulRHS);
    }
  }

  return SelectCode(N);
}

/// ComplexPattern used on Cpu0InstrInfo
/// Used on Cpu0 Load/Store instructions
bool rvexDAGToDAGISel::SelectAddr(SDNode *Parent, SDValue Addr, SDValue &Base, SDValue &Offset) {
  EVT ValTy = Addr.getValueType();

  // If Parent is an unaligned f32 load or store, select a (base + index)
  // floating point load/store instruction (luxc1 or suxc1).
  const LSBaseSDNode* LS = 0;

  if (Parent && (LS = dyn_cast<LSBaseSDNode>(Parent))) {
    EVT VT = LS->getMemoryVT();

    if (VT.getSizeInBits() / 8 > LS->getAlignment()) {
      assert(TLI.allowsUnalignedMemoryAccesses(VT) &&
             "Unaligned loads/stores not supported for this type.");
      if (VT == MVT::f32)
        return false;
    }
  }

  // if Address is FI, get the TargetFrameIndex.
  if (FrameIndexSDNode *FIN = dyn_cast<FrameIndexSDNode>(Addr)) {
    Base   = CurDAG->getTargetFrameIndex(FIN->getIndex(), ValTy);
    Offset = CurDAG->getTargetConstant(0, ValTy);
    return true;
  }

  Base   = Addr;
  Offset = CurDAG->getTargetConstant(0, ValTy);
  return true;
}

bool rvexDAGToDAGISel::SelectFI(SDValue N, SDValue &R1) {
  if(FrameIndexSDNode *FIN = dyn_cast<FrameIndexSDNode>(N)) {
    R1 = CurDAG->getTargetFrameIndex(FIN->getIndex(), MVT::i32);
    return true;
  }
  return false;
}

SDNode *rvexDAGToDAGISel::getGlobalBaseReg() {
  unsigned GlobalBaseReg = TM.getInstrInfo()->getGlobalBaseReg(MF);
  return CurDAG->getRegister(GlobalBaseReg, TLI.getPointerTy()).getNode();
}

/// creatervexISelDag - This pass converts a legalized DAG into a
/// rvex-specific DAG, ready for instruction scheduling.
FunctionPass *llvm::creatervexISelDag(rvexTargetMachine &TM) {
  return new rvexDAGToDAGISel(TM);
}
