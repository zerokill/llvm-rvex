//===- rvex.td - Describe the rvex Target Machine ------*- tablegen -*-===//
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
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// Target-independent interfaces which we are implementing
//===----------------------------------------------------------------------===//

include "llvm/Target/Target.td"

//===----------------------------------------------------------------------===//
// Register File, Calling Conv, Instruction Descriptions
//===----------------------------------------------------------------------===//

include "rvexSchedule.td"
include "rvexRegisterInfo.td"
include "rvexCallingConv.td"
include "rvexInstrInfo.td"

def rvexInstrInfo : InstrInfo;

//===----------------------------------------------------------------------===//
// Subtarget features.
//===----------------------------------------------------------------------===//

def FeatureVLIW : SubtargetFeature<"vliw", "IsVLIWEnabled", "true",
                                   "Enable VLIW scheduling">;

//===----------------------------------------------------------------------===//
// Tilera processors supported.
//===----------------------------------------------------------------------===//

class Proc<string Name, SchedMachineModel Model,
           list<SubtargetFeature> Features>
  : ProcessorModel<Name, Model, Features>;

def : Proc<"rvex", rvexModel, []>;
def : Proc<"rvex-vliw", rvexModel, [FeatureVLIW]>;

//===----------------------------------------------------------------------===//
// Declare the target which we are implementing
//===----------------------------------------------------------------------===//

def rvex : Target {
  // Pull in Instruction Info:
  let InstructionSet = rvexInstrInfo;
}

