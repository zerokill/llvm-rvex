//===- rvexRegisterInfo.td - rvex Register defs --------*- tablegen -*-===//
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
//  Declarations that describe the rvex register file.
//
//  NOTE: SPRs are not mentioned in this definition. 
//===----------------------------------------------------------------------===//


class rvexReg<string n> : Register<n> {
  let Namespace = "T64";
}

class rvexBranchReg<string n> : Register<n> {
    let Namespace = "T64";
}

//===----------------------------------------------------------------------===//
// Define registers
//===----------------------------------------------------------------------===//

//General purpose registers
def R0 : rvexReg<"$r0.0">;      // always zero     
//def R1 : rvexReg<"$r0.1">;    // stackpointer
def R2 : rvexReg<"$r0.2">;
def R3 : rvexReg<"$r0.3">;
def R4 : rvexReg<"$r0.4">;
def R5 : rvexReg<"$r0.5">;
def R6 : rvexReg<"$r0.6">;
def R7 : rvexReg<"$r0.7">;
def R8 : rvexReg<"$r0.8">;
def R9 : rvexReg<"$r0.9">;
def R10 : rvexReg<"$r0.10">;
def R11 : rvexReg<"$r0.11">;
def R12 : rvexReg<"$r0.12">;
def R13 : rvexReg<"$r0.13">;
def R14 : rvexReg<"$r0.14">;
def R15 : rvexReg<"$r0.15">;
def R16 : rvexReg<"$r0.16">;
def R17 : rvexReg<"$r0.17">;
def R18 : rvexReg<"$r0.18">;
def R19 : rvexReg<"$r0.19">;
def R20 : rvexReg<"$r0.20">;
def R21 : rvexReg<"$r0.21">;
def R22 : rvexReg<"$r0.22">;
def R23 : rvexReg<"$r0.23">;
def R24 : rvexReg<"$r0.24">;
def R25 : rvexReg<"$r0.25">;
def R26 : rvexReg<"$r0.26">;
def R27 : rvexReg<"$r0.27">;
def R28 : rvexReg<"$r0.28">;
def R29 : rvexReg<"$r0.29">;
def R30 : rvexReg<"$r0.30">;
def R31 : rvexReg<"$r0.31">;
def R32 : rvexReg<"$r0.32">;
def R33 : rvexReg<"$r0.33">;
def R34 : rvexReg<"$r0.34">;
def R35 : rvexReg<"$r0.35">;
def R36 : rvexReg<"$r0.36">;
def R37 : rvexReg<"$r0.37">;
def R38 : rvexReg<"$r0.38">;
def R39 : rvexReg<"$r0.39">;
def R40 : rvexReg<"$r0.40">;
def R41 : rvexReg<"$r0.41">;
def R42 : rvexReg<"$r0.42">;
def R43 : rvexReg<"$r0.43">;
def R44 : rvexReg<"$r0.44">;
def R45 : rvexReg<"$r0.45">;
def R46 : rvexReg<"$r0.46">;
def R47 : rvexReg<"$r0.47">;
def R48 : rvexReg<"$r0.48">;
def R49 : rvexReg<"$r0.49">;
def R50 : rvexReg<"$r0.50">;
def R51 : rvexReg<"$r0.51">;
def R52 : rvexReg<"$r0.52">;
def R53 : rvexReg<"$r0.53">;
def R54 : rvexReg<"$r0.54">;
def R55 : rvexReg<"$r0.55">;
def R56 : rvexReg<"$r0.56">;
def R57 : rvexReg<"$r0.57">;
def R58 : rvexReg<"$r0.58">;
def R59 : rvexReg<"$r0.59">;
def R60 : rvexReg<"$r0.60">;
def R61 : rvexReg<"$r0.61">;
def R62 : rvexReg<"$r0.62">;
def R63 : rvexReg<"$r0.63">;
def R64 : rvexReg<"$r0.64">;

def B0 : rvexBranchReg<"$b0.0">;
def B1 : rvexBranchReg<"$b0.1">;
def B2 : rvexBranchReg<"$b0.2">;
def B3 : rvexBranchReg<"$b0.3">;
def B4 : rvexBranchReg<"$b0.4">;
def B5 : rvexBranchReg<"$b0.5">;
def B6 : rvexBranchReg<"$b0.6">;
def B7 : rvexBranchReg<"$b0.7">;


//Specially handled general purpose registers
// Moeten verwijdert worden
//def FramePointer : rvexReg<"$r0.65">;
def ThreadLocalData : rvexReg<"tp">;
def StackPointer : rvexReg<"$r0.1">;
def LinkRegister : rvexReg<"$l0.0">;

//General purpose registers for on-card networking
def SN : rvexReg<"sn">;
def IDN0 : rvexReg<"idn0">;
def IDN1 : rvexReg<"idn1">;
def UDN0 : rvexReg<"udn0">;
def UDN1 : rvexReg<"udn1">;
def UDN2 : rvexReg<"udn2">;
def UDN3 : rvexReg<"udn3">;

//Zero register
def Zero : rvexReg<"zero">;


//===----------------------------------------------------------------------===//
// Define RegisterClass
//===----------------------------------------------------------------------===//

def T64GPRF : RegisterClass<"T64", [i32], 32,
                            (add
                                 (sequence "R%u", 2, 64),
                            //     FramePointer,
                                 ThreadLocalData,
                                 StackPointer,
                                 LinkRegister,
                                 Zero
                            )>;




