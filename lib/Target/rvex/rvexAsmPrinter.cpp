//===-- rvexAsmPrinter.cpp - rvex LLVM assembly writer ----------------===//
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
// This file contains a printer that converts from our internal representation
// of machine-dependent LLVM code to GAS-format rvex assembly language.
//
//===----------------------------------------------------------------------===//

#define DEBUG_TYPE "asm-printer"
#include "rvex.h"
#include "rvexInstrInfo.h"
#include "rvexTargetMachine.h"
#include "rvexMachineFunctionInfo.h"
#include "llvm/CodeGen/AsmPrinter.h"
#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/MC/MCAsmInfo.h"
#include "llvm/MC/MCStreamer.h"
#include "llvm/MC/MCSymbol.h"
#include "llvm/Target/Mangler.h"
#include "llvm/ADT/SmallString.h"
#include "llvm/ADT/StringExtras.h"
#include "llvm/Support/TargetRegistry.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

namespace {
  class rvexAsmPrinter : public AsmPrinter {
  public:
    explicit rvexAsmPrinter(TargetMachine &TM, MCStreamer &Streamer)
      : AsmPrinter(TM, Streamer) {}

    virtual const char *getPassName() const {
      return "rvex Assembly Printer";
    }

    void printOperand(const MachineInstr *MI, int opNum, raw_ostream &OS);

    virtual void EmitInstruction(const MachineInstr *MI);

    void printInstruction(const MachineInstr *MI, raw_ostream &OS); //autogen'd.
    static const char *getRegisterName(unsigned RegNo); //autogen'd.

    //TODO: inlineasm support
    /*
    virtual bool PrintAsmOperand(const MachineInstr *MI, unsigned OpNo,
                                 unsigned AsmVariant, const char *ExtraCode,
                                 raw_ostream &O);
    virtual bool PrintAsmMemoryOperand(const MachineInstr *MI, unsigned OpNo,
                                       unsigned AsmVariant, const char *ExtraCode,
                                       raw_ostream &O);
    */
    void printMemOperand(const MachineInstr *MI, int opNum, raw_ostream &O);
    void printGBR(const MachineInstr *MI, unsigned OpNo, raw_ostream &OS);
    bool printBSN(const MachineInstr *MI, unsigned OpNo, raw_ostream &OS);
  };
} // end of anonymous namespace

#include "rvexGenAsmWriter.inc"

void rvexAsmPrinter::EmitInstruction(const MachineInstr *MI) {
  SmallString<128> Str;
  raw_svector_ostream OS(Str);

  if(MI->isBundle()) {
    std::vector<const MachineInstr*> BundleMIs;

    unsigned int IgnoreCount = 0;
    MachineBasicBlock::const_instr_iterator MII = MI;
    MachineBasicBlock::const_instr_iterator MBBe = MI->getParent()->instr_end();
    ++MII;
    while(MII != MBBe && MII->isInsideBundle()) {
      const MachineInstr *MInst = MII;
      if(MInst->getOpcode() == TargetOpcode::DBG_VALUE ||
         MInst->getOpcode() == TargetOpcode::IMPLICIT_DEF) {
        IgnoreCount++;
      } else {
        BundleMIs.push_back(MInst);
      }
      ++MII;
    }

    unsigned Size = BundleMIs.size();
    assert((Size+IgnoreCount) == MI->getBundleSize() && "Corrupt Bundle!");

    //OS << "\t{\n";
    for(unsigned Index = 0; Index < Size; ++Index) {
      const MachineInstr *BMI = BundleMIs[Index];
      OS << "\tc0";
      printInstruction(BMI, OS);
      OS << "\n";
    }
    OS << ";; ## end of bundle\n\n";

  } else {
    OS << "\tc0";
    printInstruction(MI, OS);
    OS << "\n";
    OS << ";; ## end of bundle\n\n";
  }

  OutStreamer.EmitRawText(OS.str());
}

void rvexAsmPrinter::printOperand(const MachineInstr *MI, int opNum,
                                    raw_ostream &O) {
  const MachineOperand &MO = MI->getOperand(opNum);
  switch (MO.getType()) {
  default:
    llvm_unreachable("<unknown operand type>");
  case MachineOperand::MO_Register: {
    unsigned Reg = MO.getReg();
    assert(TargetRegisterInfo::isPhysicalRegister(Reg));
    O << getRegisterName(Reg);
    }
    break;
  case MachineOperand::MO_Immediate:
    O << (int) MO.getImm();
    break;
  case MachineOperand::MO_MachineBasicBlock:
    O << *MO.getMBB()->getSymbol();
    return;
  case MachineOperand::MO_GlobalAddress:
    O << *Mang->getSymbol(MO.getGlobal());
    break;
  case MachineOperand::MO_ExternalSymbol:
    O << *GetExternalSymbolSymbol(MO.getSymbolName());
    break;
  case MachineOperand::MO_ConstantPoolIndex:
    O << *GetCPISymbol(MO.getIndex());
    break;
  }
}


void rvexAsmPrinter::printGBR(const MachineInstr *MI, unsigned opNum,
                                raw_ostream &O) {
  std::string operand = "";
  const MachineOperand &MO = MI->getOperand(opNum);

  switch (MO.getType()) {
  default: llvm_unreachable("GBR operand is not a register!");
  case MachineOperand::MO_Register:
    assert(TargetRegisterInfo::isPhysicalRegister(MO.getReg()) &&
           "Operand is not a physical register!");
    operand = getRegisterName(MO.getReg());
    break;
  }

  O << "lnk " << operand << '\n';
  O << *MI->getParent()->getParent()->getPICBaseSymbol() << ":\n";
}

bool rvexAsmPrinter::printBSN(const MachineInstr *MI, unsigned opNum,
                                raw_ostream &O) {

  const MachineOperand &MO = MI->getOperand(opNum);
  switch(MO.getType()) {
  default: llvm_unreachable("picaddr operand is not addressable!");
  case MachineOperand::MO_GlobalAddress:
    O << *Mang->getSymbol(MO.getGlobal());
    break;
  case MachineOperand::MO_ExternalSymbol:
    O << *GetExternalSymbolSymbol(MO.getSymbolName());
    break;
  }

  O << '-' << *MI->getParent()->getParent()->getPICBaseSymbol();

  return true;
}

void rvexAsmPrinter::printMemOperand(const MachineInstr *MI, int opNum, raw_ostream &O) {
  // Load/Store memory operands -- imm($reg)
  // If PIC target the target is loaded as the
  // pattern ld $t9,%call24($gp)
  printOperand(MI, opNum+1, O);
  O << "(";
  printOperand(MI, opNum, O);
  O << ")";
}

//TODO: inlineasm support
/*
/// PrintAsmOperand - Print out an operand for an inline asm expression.
///
bool SparcAsmPrinter::PrintAsmOperand(const MachineInstr *MI, unsigned OpNo,
                                      unsigned AsmVariant,
                                      const char *ExtraCode,
                                      raw_ostream &O) {
  if (ExtraCode && ExtraCode[0]) {
    if (ExtraCode[1] != 0) return true; // Unknown modifier.

    switch (ExtraCode[0]) {
    default: return true;  // Unknown modifier.
    case 'r':
     break;
    }
  }

  printOperand(MI, OpNo, O);

  return false;
}

bool SparcAsmPrinter::PrintAsmMemoryOperand(const MachineInstr *MI,
                                            unsigned OpNo, unsigned AsmVariant,
                                            const char *ExtraCode,
                                            raw_ostream &O) {
  if (ExtraCode && ExtraCode[0])
    return true;  // Unknown modifier

  O << '[';
  printMemOperand(MI, OpNo, O);
  O << ']';

  return false;
}
*/

// Force static initialization.
extern "C" void LLVMInitializervexAsmPrinter() { 
  RegisterAsmPrinter<rvexAsmPrinter> X(ThervexTarget);
}

