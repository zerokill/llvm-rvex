//===- rvexCallingConv.td - Calling Conventions rvex ---*- tablegen -*-===//
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
// This describes the calling conventions for the rvex architecture.
//
//===----------------------------------------------------------------------===//

// rvex return-value convention.
def RetCC_rvex : CallingConv<[
  //Pass return value in registers if it fits them.
  CCAssignToReg<[R3, R4, R5, R6, R7, R8, R9, R10]>
]>;

// rvex Calling convention.
def CC_rvex : CallingConv<[
  //Assign SRet ptr to R0.
  CCIfSRet<CCAssignToReg<[R0]>>,

  //Arguments get passed in registers if there is space. Bigger values my need
  //padding, and are to be passed entirely in register or on stack. Arguments
  //passed on stack are to be stored according to ABI size and alignment.
  //However, types are already legalized at this point, i.e. the type of every
  //argument is i32, except for byval arguments. Therefore the calling
  //convention need to be realized via a custom function.
  CCCustom<"CC_rvex_Assign">
]>;

