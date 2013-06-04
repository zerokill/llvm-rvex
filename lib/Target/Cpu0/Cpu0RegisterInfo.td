//===-- Cpu0RegisterInfo.td - Cpu0 Register defs -----------*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
//  Declarations that describe the CPU0 register file
//===----------------------------------------------------------------------===//


// We have banks of 16 registers each.
class Cpu0Reg<string n> : Register<n> {
  field bits<7> Num;
  let Namespace = "Cpu0";
}

// Cpu0 CPU Registers
class Cpu0GPRReg<bits<7> num, string n> : Cpu0Reg<n> {
  let Num = num;
}

//===----------------------------------------------------------------------===//
//  Registers
//===----------------------------------------------------------------------===//

let Namespace = "Cpu0" in {
  // General Purpose Registers
  def R0 : Cpu0GPRReg< 0, "r0.0">, DwarfRegNum<[0]>;
  def R1 : Cpu0GPRReg< 1, "r0.1">, DwarfRegNum<[1]>;
  def R2 : Cpu0GPRReg< 2, "r0.2">, DwarfRegNum<[2]>;
  def R3 : Cpu0GPRReg< 3, "r0.3">, DwarfRegNum<[3]>;
  def R4 : Cpu0GPRReg< 4, "r0.4">, DwarfRegNum<[4]>;
  def R5 : Cpu0GPRReg< 5, "r0.5">, DwarfRegNum<[5]>;
  def R6 : Cpu0GPRReg< 6, "r0.6">, DwarfRegNum<[6]>;
  def R7 : Cpu0GPRReg< 7, "r0.7">, DwarfRegNum<[7]>;
  def R8 : Cpu0GPRReg< 8, "r0.8">, DwarfRegNum<[8]>;
  def R9 : Cpu0GPRReg< 9, "r0.9">, DwarfRegNum<[9]>;
  def R10 : Cpu0GPRReg< 10, "r0.10">, DwarfRegNum<[10]>;
  def R11 : Cpu0GPRReg< 11, "r0.11">, DwarfRegNum<[11]>;
  def R12 : Cpu0GPRReg< 12, "r0.12">, DwarfRegNum<[12]>;
  def R13 : Cpu0GPRReg< 13, "r0.13">, DwarfRegNum<[13]>;
  def R14 : Cpu0GPRReg< 14, "r0.14">, DwarfRegNum<[14]>;
  def R15 : Cpu0GPRReg< 15, "r0.15">, DwarfRegNum<[15]>;
  def R16 : Cpu0GPRReg< 16, "r0.16">, DwarfRegNum<[16]>;
  def R17 : Cpu0GPRReg< 17, "r0.17">, DwarfRegNum<[17]>;
  def R18 : Cpu0GPRReg< 18, "r0.18">, DwarfRegNum<[18]>;
  def R19 : Cpu0GPRReg< 19, "r0.19">, DwarfRegNum<[19]>;
  def R20 : Cpu0GPRReg< 20, "r0.20">, DwarfRegNum<[20]>;
  def R21 : Cpu0GPRReg< 21, "r0.21">, DwarfRegNum<[21]>;
  def R22 : Cpu0GPRReg< 22, "r0.22">, DwarfRegNum<[22]>;
  def R23 : Cpu0GPRReg< 23, "r0.23">, DwarfRegNum<[23]>;
  def R24 : Cpu0GPRReg< 24, "r0.24">, DwarfRegNum<[24]>;
  def R25 : Cpu0GPRReg< 25, "r0.25">, DwarfRegNum<[25]>;
  def R26 : Cpu0GPRReg< 26, "r0.26">, DwarfRegNum<[26]>;
  def R27 : Cpu0GPRReg< 27, "r0.27">, DwarfRegNum<[27]>;
  def R28 : Cpu0GPRReg< 28, "r0.28">, DwarfRegNum<[28]>;
  def R29 : Cpu0GPRReg< 29, "r0.29">, DwarfRegNum<[29]>;
  def R30 : Cpu0GPRReg< 30, "r0.30">, DwarfRegNum<[30]>;
  def R31 : Cpu0GPRReg< 31, "r0.31">, DwarfRegNum<[31]>;
  def R32 : Cpu0GPRReg< 32, "r0.32">, DwarfRegNum<[32]>;
  def R33 : Cpu0GPRReg< 33, "r0.33">, DwarfRegNum<[33]>;
  def R34 : Cpu0GPRReg< 34, "r0.34">, DwarfRegNum<[34]>;
  def R35 : Cpu0GPRReg< 35, "r0.35">, DwarfRegNum<[35]>;
  def R36 : Cpu0GPRReg< 36, "r0.36">, DwarfRegNum<[36]>;
  def R37 : Cpu0GPRReg< 37, "r0.37">, DwarfRegNum<[37]>;
  def R38 : Cpu0GPRReg< 38, "r0.38">, DwarfRegNum<[38]>;
  def R39 : Cpu0GPRReg< 39, "r0.39">, DwarfRegNum<[39]>;
  def R40 : Cpu0GPRReg< 40, "r0.40">, DwarfRegNum<[40]>;
  def R41 : Cpu0GPRReg< 41, "r0.41">, DwarfRegNum<[41]>;
  def R42 : Cpu0GPRReg< 42, "r0.42">, DwarfRegNum<[42]>;
  def R43 : Cpu0GPRReg< 43, "r0.43">, DwarfRegNum<[43]>;
  def R44 : Cpu0GPRReg< 44, "r0.44">, DwarfRegNum<[44]>;
  def R45 : Cpu0GPRReg< 45, "r0.45">, DwarfRegNum<[45]>;
  def R46 : Cpu0GPRReg< 46, "r0.46">, DwarfRegNum<[46]>;
  def R47 : Cpu0GPRReg< 47, "r0.47">, DwarfRegNum<[47]>;
  def R48 : Cpu0GPRReg< 48, "r0.48">, DwarfRegNum<[48]>;
  def R49 : Cpu0GPRReg< 49, "r0.49">, DwarfRegNum<[49]>;
  def R50 : Cpu0GPRReg< 50, "r0.50">, DwarfRegNum<[50]>;
  def R51 : Cpu0GPRReg< 51, "r0.51">, DwarfRegNum<[51]>;
  def R52 : Cpu0GPRReg< 52, "r0.52">, DwarfRegNum<[52]>;
  def R53 : Cpu0GPRReg< 53, "r0.53">, DwarfRegNum<[53]>;
  def R54 : Cpu0GPRReg< 54, "r0.54">, DwarfRegNum<[54]>;
  def R55 : Cpu0GPRReg< 55, "r0.55">, DwarfRegNum<[55]>;
  def R56 : Cpu0GPRReg< 56, "r0.56">, DwarfRegNum<[56]>;
  def R57 : Cpu0GPRReg< 57, "r0.57">, DwarfRegNum<[57]>;
  def R58 : Cpu0GPRReg< 58, "r0.58">, DwarfRegNum<[58]>;
  def R59 : Cpu0GPRReg< 59, "r0.59">, DwarfRegNum<[59]>;
  def R60 : Cpu0GPRReg< 60, "r0.60">, DwarfRegNum<[60]>;
  def R61 : Cpu0GPRReg< 61, "r0.61">, DwarfRegNum<[61]>;
  def R62 : Cpu0GPRReg< 62, "r0.62">, DwarfRegNum<[62]>;
  def R63 : Cpu0GPRReg< 63, "r0.63">, DwarfRegNum<[63]>;

  def LR   : Cpu0GPRReg< 64, "l0.0">,   DwarfRegNum<[64]>;
  def PC   : Cpu0GPRReg< 65, "PC">,   DwarfRegNum<[65]>;




  // Hi/Lo registers
  def HI   : Register<"HI">, DwarfRegNum<[18]>;
  def LO   : Register<"LO">, DwarfRegNum<[19]>;
}

//===----------------------------------------------------------------------===//
// Register Classes
//===----------------------------------------------------------------------===//

def CPURegs : RegisterClass<"Cpu0", [i32], 32, 
  (add
    (sequence "R%u", 0, 63),

    LR, PC
  )>;

// Hi/Lo Registers
def HILO : RegisterClass<"Cpu0", [i32], 32, (add HI, LO)>;

