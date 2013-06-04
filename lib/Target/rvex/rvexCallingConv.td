//===-- rvexCallingConv.td - Calling Conventions for rvex --*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
// This describes the calling conventions for rvex architecture.
//===----------------------------------------------------------------------===//

/// CCIfSubtarget - Match if the current subtarget has a feature F.
class CCIfSubtarget<string F, CCAction A>:
  CCIf<!strconcat("State.getTarget().getSubtarget<rvexSubtarget>().", F), A>;

def CSR_O32 : CalleeSavedRegs<(add LR, 
									(sequence "R%u", 57, 63))>;

