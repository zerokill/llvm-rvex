//===- rvexInstrInfo.td - Target Description for rvex Target ----------===//
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
// This file describes the rvex instructions in TableGen format.
//
//===----------------------------------------------------------------------===//

//TODO: use zero in patterns as optimization

//===----------------------------------------------------------------------===//
// Instruction format superclass
//===----------------------------------------------------------------------===//

include "rvexInstrFormats.td"

//===----------------------------------------------------------------------===//
// Instruction Pattern Stuff
//===----------------------------------------------------------------------===//

//
//  Operand type definitions
//

def brtarget : Operand<OtherVT>; //17-bit offset
def jmptarget : Operand<OtherVT>; //28-bit offset
def calltarget : Operand<iPTR>; //for tglobaladdr, texternalsym


def gbr : RegisterOperand<T64GPRF, "printGBR">;

def picaddr : Operand<i32> {
  let PrintMethod = "printBSN";
}

//
// Pattern fragments for operands
//

//immediate byte
def imm8 : PatLeaf<(imm), [{ return isInt<8>(N->getSExtValue()); }]>;
def imm32 : PatLeaf<(imm), [{ return isInt<32>(N->getSExtValue()); }]>;


def imm32_pos : PatLeaf<(imm32), [{ return ((N->getSExtValue())) > 0; }]>;
def imm32_neg : PatLeaf<(imm32), [{ return ((N->getSExtValue())) < 0; }]>;


//immediate half-word
def imm16 : PatLeaf<(imm), [{ return isInt<16>(N->getSExtValue()); }]>;

//immediate half-word which doesn't fit a byte
def imms16 : PatLeaf<(imm), [{
  int num = N->getSExtValue();
  return !isInt<8>(num) && isInt<16>(num);
}]>;



//immediate for denoting positions in registers
def regimm : PatLeaf<(imm), [{ return isInt<5>(N->getZExtValue()); }]>;

//immediate for logical values
def false : PatLeaf<(imm), [{ return N->getZExtValue() == 0; }]>;

def true : PatLeaf<(imm), [{ return N->getZExtValue() > 0; }]>;







//
// rvex Profiles and Nodes
//

def SDT_T64CallSeqStart : SDCallSeqStart<[SDTCisVT<0, i32>]>;
def SDT_T64CallSeqEnd : SDCallSeqEnd<[SDTCisVT<0, i32>,
                                      SDTCisVT<1, i32>]>;

def callseq_start : SDNode<"ISD::CALLSEQ_START", SDT_T64CallSeqStart,
                           [SDNPHasChain, SDNPOutGlue]>;
def callseq_end : SDNode<"ISD::CALLSEQ_END", SDT_T64CallSeqEnd,
                         [SDNPHasChain, SDNPOptInGlue, SDNPOutGlue]>;

def T64_fence : SDNode<"T64ISD::FENCE", SDTypeProfile<0, 0, []>,
                       [SDNPHasChain, SDNPInGlue, SDNPOutGlue]>;
def T64_mb : SDNode<"T64ISD::MEMBARRIER", SDTypeProfile<0, 0, []>,
                       [SDNPHasChain, SDNPInGlue, SDNPOutGlue]>;

def SDT_T64Call : SDTypeProfile<0, -1, [SDTCisVT<0, iPTR>]>;
def SDT_T64Return : SDTypeProfile<0, 1, [SDTCisVT<0, iPTR>]>;

def T64_jalr : SDNode<"T64ISD::JALR", SDT_T64Call,
                      [SDNPHasChain, SDNPOutGlue, SDNPOptInGlue, SDNPVariadic]>;
def T64_call : SDNode<"T64ISD::CALL", SDT_T64Call,
                      [SDNPHasChain, SDNPOutGlue, SDNPOptInGlue, SDNPVariadic]>;
def T64_piccall : SDNode<"T64ISD::PICCALL", SDT_T64Call,
                        [SDNPHasChain, SDNPOutGlue, SDNPOptInGlue, SDNPVariadic]>;

def T64_jrp : SDNode<"T64ISD::JRP", SDT_T64Return,
                     [SDNPHasChain, SDNPOptInGlue]>;

def SDT_T64nop : SDTypeProfile<0, 0, []>;

def T64_fnop : SDNode<"T64ISD::FNOP", SDT_T64nop, [SDNPHasChain]>;
def T64_nop : SDNode<"T64ISD::NOP", SDT_T64nop, [SDNPHasChain]>;

def T64_movelo : SDNode<"T64ISD::MOVELO", SDTIntUnaryOp>;
def T64_addhi : SDNode<"T64ISD::ADDHI", SDTIntBinOp>;
def T64_addlo_pic : SDNode<"T64ISD::ADDLO_PIC", SDTIntBinOp>;
def T64_addhi_pic : SDNode<"T64ISD::ADDHI_PIC", SDTIntBinOp>;
def T64_addli_got : SDNode<"T64ISD::ADDLI_GOT", SDTIntBinOp>;

def T64_bitx : SDNode<"T64ISD::BITX", SDTIntUnaryOp>;
def T64_crc32_32 : SDNode<"T64ISD::CRC32_32", SDTIntBinOp>;
def T64_crc32_8 : SDNode<"T64ISD::CRC32_8", SDTIntBinOp>;

def SDT_T64mm : SDTypeProfile<1, 4, [SDTCisVT<0, i32>,
                                     SDTCisVT<1, i32>, SDTCisVT<2, i32>,
                                     SDTCisVT<3, i32>, SDTCisVT<4, i32>]>;
def T64_mm : SDNode<"T64ISD::MM", SDT_T64mm>;

def SDT_T64stfp : SDTypeProfile<0, 0, []>;
def T64_stfp : SDNode<"T64ISD::STORE_FP", SDT_T64stfp,
                      [SDNPHasChain, SDNPMayStore]>;

def SDT_T64nsaddr : SDTypeProfile<1, 1, [SDTCisVT<0, iPTR>,
                                         SDTCisVT<1, iPTR>]>;
def T64_nsaddr : SDNode<"T64ISD::NEWSLOT_ADDR", SDT_T64nsaddr>;

//for multiply instructions
def SDT_T64Mul : SDTypeProfile<1, 2, [SDTCisVT<0, i32>,
                                      SDTCisVT<1, i32>, SDTCisVT<2, i32>]>;
def SDT_T64MulA : SDTypeProfile<1, 3, [SDTCisVT<0, i32>, SDTCisVT<1, i32>,
                                       SDTCisVT<2, i32>, SDTCisVT<3, i32>]>;

def T64_mulhh_ss : SDNode<"T64ISD::MULHH_SS", SDT_T64Mul>;
def T64_mulhh_su : SDNode<"T64ISD::MULHH_SU", SDT_T64Mul>;
def T64_mulhh_uu : SDNode<"T64ISD::MULHH_UU", SDT_T64Mul>;
def T64_mulhha_ss : SDNode<"T64ISD::MULHHA_SS", SDT_T64MulA>;
def T64_mulhha_su : SDNode<"T64ISD::MULHHA_SU", SDT_T64MulA>;
def T64_mulhha_uu : SDNode<"T64ISD::MULHHA_UU", SDT_T64MulA>;
def T64_mulhhsa_uu : SDNode<"T64ISD::MULHHSA_UU", SDT_T64MulA>;
def T64_mulhl_ss : SDNode<"T64ISD::MULHL_SS", SDT_T64Mul>;
def T64_mulhl_su : SDNode<"T64ISD::MULHL_SU", SDT_T64Mul>;
def T64_mulhl_us : SDNode<"T64ISD::MULHL_US", SDT_T64Mul>;
def T64_mulhl_uu : SDNode<"T64ISD::MULHL_UU", SDT_T64Mul>;
def T64_mulhla_ss : SDNode<"T64ISD::MULHLA_SS", SDT_T64MulA>;
def T64_mulhla_su : SDNode<"T64ISD::MULHLA_SU", SDT_T64MulA>;
def T64_mulhla_us : SDNode<"T64ISD::MULHLA_US", SDT_T64MulA>;
def T64_mulhla_uu : SDNode<"T64ISD::MULHLA_UU", SDT_T64MulA>;
def T64_mulhlsa_uu : SDNode<"T64ISD::MULHLSA_UU", SDT_T64MulA>;
def T64_mulll_ss : SDNode<"T64ISD::MULLL_SS", SDT_T64Mul>;
def T64_mulll_su : SDNode<"T64ISD::MULLL_SU", SDT_T64Mul>;
def T64_mulll_uu : SDNode<"T64ISD::MULLL_UU", SDT_T64Mul>;
def T64_mullla_ss : SDNode<"T64ISD::MULLLA_SS", SDT_T64MulA>;
def T64_mullla_su : SDNode<"T64ISD::MULLLA_SU", SDT_T64MulA>;
def T64_mullla_uu : SDNode<"T64ISD::MULLLA_UU", SDT_T64MulA>;
def T64_mulllsa_uu : SDNode<"T64ISD::MULLLSA_UU", SDT_T64MulA>;

class MulInstBmST64<string OpcStr, SDNode OpNode> :
                    InstBmST64<(outs T64GPRF:$Dest),
                               (ins T64GPRF:$SrcA, T64GPRF:$SrcB),
                               !strconcat(OpcStr," $Dest, $SrcA, $SrcB"),
                               [(set T64GPRF:$Dest, (OpNode T64GPRF:$SrcA, T64GPRF:$SrcB))]>;

class MulInstBmLT64<string OpcStr, SDNode OpNode> :
                    InstBmLT64<(outs T64GPRF:$Dest),
                               (ins T64GPRF:$SrcA, T64GPRF:$SrcB),
                               !strconcat(OpcStr," $Dest, $SrcA, $SrcB"),
                               [(set T64GPRF:$Dest, (OpNode T64GPRF:$SrcA, T64GPRF:$SrcB))]>;

class MulAInstBmST64<string OpcStr, SDNode OpNode> :
                     InstBmST64<(outs T64GPRF:$Dest),
                                (ins T64GPRF:$acc, T64GPRF:$SrcA, T64GPRF:$SrcB),
                                !strconcat(OpcStr, " $Dest, $SrcA, $SrcB"),
                                [(set T64GPRF:$Dest, (OpNode T64GPRF:$acc, T64GPRF:$SrcA, T64GPRF:$SrcB))],
                                "$acc = $Dest">;

class MulAInstBmLT64<string OpcStr, SDNode OpNode> :
                     InstBmLT64<(outs T64GPRF:$Dest),
                                (ins T64GPRF:$acc, T64GPRF:$SrcA, T64GPRF:$SrcB),
                                !strconcat(OpcStr, " $Dest, $SrcA, $SrcB"),
                                [(set T64GPRF:$Dest, (OpNode T64GPRF:$acc, T64GPRF:$SrcA, T64GPRF:$SrcB))],
                                "$acc = $Dest">;

//===----------------------------------------------------------------------===//
// Pseudo Instructions
//===----------------------------------------------------------------------===//

let Defs = [StackPointer], Uses = [StackPointer] in {

  def ADJCALLSTACKDOWN : PseudoT64<(outs), (ins i32imm:$amt),
                                   "!ADJCALLSTACKDOWN $amt",
                                   [(callseq_start timm:$amt)]>;

  def ADJCALLSTACKUP : PseudoT64<(outs), (ins i32imm:$amt1, i32imm:$amt2),
                                 "!ADJCALLSTACKUP $amt1",
                                 [(callseq_end timm:$amt1, timm:$amt2)]>;

}


//let Uses = [FramePointer] in
  def MOVFI : PseudoT64<(outs T64GPRF:$Dest),
                        (ins T64GPRF:$idx),
                        "",
                        [(set T64GPRF:$Dest, T64GPRF:$idx)]>;


let isCodeGenOnly = 1 in {

  def MOVELO : InstArLT64<(outs T64GPRF:$Dest),
                          (ins i32imm:$val),
                          "addli $Dest, zero, lo16($val)",
                          []>;

  def ADDHI : InstArLT64<(outs T64GPRF:$Dest),
                         (ins T64GPRF:$acc, i32imm:$val),
                         "auli $Dest, $acc, ha16($val)",
                         [],
                         "$acc = $Dest">;
 
  def ADDLO_PIC : InstArLT64<(outs T64GPRF:$Dest),
                             (ins T64GPRF:$acc, picaddr:$val),
                             "addli $Dest, $acc, lo16($val)",
                             []>;

  def ADDHI_PIC : InstArLT64<(outs T64GPRF:$Dest),
                             (ins T64GPRF:$acc, picaddr:$val),
                             "auli $Dest, $acc, ha16($val)",
                             [],
                             "$acc = $Dest">;

  def ADDLI_GOT : InstArLT64<(outs T64GPRF:$Dest),
                             (ins T64GPRF:$acc, i32imm:$val),
                             "addli $Dest, $acc, got($val)",
                             [],
                             "$acc = $Dest">;

}

let usesCustomInserter = 1 in {
  def SELECT : PseudoT64<(outs T64GPRF:$Dest),
                         (ins T64GPRF:$CC, T64GPRF:$SrcA, T64GPRF:$SrcB),
                         "",
                         [(set (i32 T64GPRF:$Dest), (select (i32 T64GPRF:$CC), T64GPRF:$SrcA, T64GPRF:$SrcB))]>;

  let Uses = [StackPointer] in
    def STORE_FP : PseudoT64<(outs), (ins), "",
                             [(T64_stfp)]>;
}

def NEWSLOT_ADDR : PseudoT64<(outs T64GPRF:$Dest),
                             (ins T64GPRF:$Src),
                             "",
                             [(set T64GPRF:$Dest, (T64_nsaddr T64GPRF:$Src))]>;

//===----------------------------------------------------------------------===//
// Non-instruction patterns for computing addresses
//===----------------------------------------------------------------------===//

def : Pat<(T64_movelo tglobaladdr:$addr), (MOVELO tglobaladdr:$addr)>;
def : Pat<(T64_addhi T64GPRF:$acc, tglobaladdr:$addr),
          (ADDHI T64GPRF:$acc, tglobaladdr:$addr)>;
def : Pat<(T64_addlo_pic T64GPRF:$acc, tglobaladdr:$addr),
          (ADDLO_PIC T64GPRF:$acc, tglobaladdr:$addr)>;
def : Pat<(T64_addhi_pic T64GPRF:$acc, tglobaladdr:$addr),
          (ADDHI_PIC T64GPRF:$acc, tglobaladdr:$addr)>;
def : Pat<(T64_addli_got T64GPRF:$acc, tglobaladdr:$addr),
          (ADDLI_GOT T64GPRF:$acc, tglobaladdr:$addr)>;

def : Pat<(T64_movelo tconstpool:$addr), (MOVELO tconstpool:$addr)>;
def : Pat<(T64_addhi T64GPRF:$acc, tconstpool:$addr),
          (ADDHI T64GPRF:$acc, tconstpool:$addr)>;
def : Pat<(T64_addlo_pic T64GPRF:$acc, tconstpool:$addr),
          (ADDLO_PIC T64GPRF:$acc, tconstpool:$addr)>;
def : Pat<(T64_addhi_pic T64GPRF:$acc, tconstpool:$addr),
          (ADDHI_PIC T64GPRF:$acc, tconstpool:$addr)>;

def : Pat<(T64_addlo_pic T64GPRF:$acc, texternalsym:$addr),
          (ADDLO_PIC T64GPRF:$acc, texternalsym:$addr)>;
def : Pat<(T64_addhi_pic T64GPRF:$acc, texternalsym:$addr),
          (ADDHI_PIC T64GPRF:$acc, texternalsym:$addr)>;

//===----------------------------------------------------------------------===//
// Instructions
//
// from Tilera Processor User Architecture Manual (UG101) REL. 2.2
//===----------------------------------------------------------------------===//

//
// NOOP instructions
//

def FNOP : InstArST64<(outs), (ins),
                      "fnop",
                      [(T64_fnop)]>;

def NOP : InstArST64<(outs), (ins),
                     "nop",
                     [(T64_nop)]>;

//
// Arithmetic Instructions (p.43.)
//

def ADD : InstArST64<(outs T64GPRF:$Dest),
                     (ins T64GPRF:$SrcA, T64GPRF:$SrcB),
                     "add $Dest = $SrcA, $SrcB",
                     [(set (i32 T64GPRF:$Dest), (add T64GPRF:$SrcA, T64GPRF:$SrcB))]>;

def ADDI : InstArST64<(outs T64GPRF:$Dest),
                      (ins T64GPRF:$SrcA, i32imm:$Imm32),
                      "add $Dest = $SrcA, $Imm32",
                      [(set (i32 T64GPRF:$Dest), (add T64GPRF:$SrcA, imm32:$Imm32))]>;                      


//writing to the static network needs to meet additional condition beyond that pattern.


//skip ADDS because it's only for TilePro

def AULI : InstArLT64<(outs T64GPRF:$Dest),
                      (ins T64GPRF:$SrcA, i32imm:$Imm16),
                      "auli $Dest, $SrcA, $Imm16",
                      [(set (i32 T64GPRF:$Dest), (add T64GPRF:$SrcA, (shl imm16:$Imm16, (i32 16))))]>;

def S1A : InstArST64<(outs T64GPRF:$Dest),
                     (ins T64GPRF:$SrcA, T64GPRF:$SrcB),
                     "s1a $Dest, $SrcA, $SrcB",
                     [(set (i32 T64GPRF:$Dest), (add (shl T64GPRF:$SrcA, (i32 1)), T64GPRF:$SrcB))]>;

def S2A : InstArST64<(outs T64GPRF:$Dest),
                     (ins T64GPRF:$SrcA, T64GPRF:$SrcB),
                     "s2a $Dest, $SrcA, $SrcB",
                     [(set (i32 T64GPRF:$Dest), (add (shl T64GPRF:$SrcA, (i32 2)), T64GPRF:$SrcB))]>;

def S3A : InstArST64<(outs T64GPRF:$Dest),
                     (ins T64GPRF:$SrcA, T64GPRF:$SrcB),
                     "s3a $Dest, $SrcA, $SrcB",
                     [(set (i32 T64GPRF:$Dest), (add (shl T64GPRF:$SrcA, (i32 3)), T64GPRF:$SrcB))]>;

def SUB : InstArST64<(outs T64GPRF:$Dest),
                     (ins T64GPRF:$SrcA, T64GPRF:$SrcB),
                     "sub $Dest, $SrcA, $SrcB",
                     [(set (i32 T64GPRF:$Dest), (sub T64GPRF:$SrcA, T64GPRF:$SrcB))]>;

//skip SUBS because it's only for TilePro


//
// Bit Manipulation Instructions (p.63.)
//

def BITX : InstBmST64<(outs T64GPRF:$Dest),
                      (ins T64GPRF:$SrcA),
                      "bitx $Dest, $SrcA",
                      [(set (i32 T64GPRF:$Dest), (T64_bitx T64GPRF:$SrcA))]>;

def BYTEX : InstBmST64<(outs T64GPRF:$Dest),
                       (ins T64GPRF:$SrcA),
                       "bytex $Dest, $SrcA",
                       [(set (i32 T64GPRF:$Dest), (bswap T64GPRF:$SrcA))]>;

def CLZ : InstBmST64<(outs T64GPRF:$Dest),
                     (ins T64GPRF:$SrcA),
                     "clz $Dest, $SrcA",
                     [(set (i32 T64GPRF:$Dest), (ctlz T64GPRF:$SrcA))]>;

def CRC32_32 : InstBmLT64<(outs T64GPRF:$Dest),
                          (ins T64GPRF:$SrcA, T64GPRF:$SrcB),
                          "crc32_32 $Dest, $SrcA, $SrcB",
                          [(set (i32 T64GPRF:$Dest), (T64_crc32_32 T64GPRF:$SrcA, T64GPRF:$SrcB))]>;

def CRC32_8 : InstBmLT64<(outs T64GPRF:$Dest),
                         (ins T64GPRF:$SrcA, T64GPRF:$SrcB),
                         "crc32_8 $Dest, $SrcA, $SrcB",
                         [(set (i32 T64GPRF:$Dest), (T64_crc32_8 T64GPRF:$SrcA, T64GPRF:$SrcB))]>;

def CTZ : InstBmST64<(outs T64GPRF:$Dest),
                     (ins T64GPRF:$SrcA),
                     "ctz $Dest, $SrcA",
                     [(set (i32 T64GPRF:$Dest), (cttz T64GPRF:$SrcA))]>;

//skip DWORD_ALIGN because it's only for TilePro

def PCNT : InstBmST64<(outs T64GPRF:$Dest),
                      (ins T64GPRF:$SrcA),
                      "pcnt $Dest, $SrcA",
                      [(set (i32 T64GPRF:$Dest), (ctpop (i32 T64GPRF:$SrcA)))]>;


//
// Compare Instructions (p.76.)
//

def SEQ : InstArST64<(outs T64GPRF:$Dest),
                     (ins T64GPRF:$SrcA, T64GPRF:$SrcB),
                     "seq $Dest, $SrcA, $SrcB",
                     [(set (i32 T64GPRF:$Dest), (seteq (i32 T64GPRF:$SrcA), T64GPRF:$SrcB))]>;

def SEQI : InstArST64<(outs T64GPRF:$Dest),
                      (ins T64GPRF:$SrcA, i32imm:$Imm8),
                      "seqi $Dest, $SrcA, $Imm8",
                      [(set (i32 T64GPRF:$Dest), (seteq (i32 T64GPRF:$SrcA), imm8:$Imm8))]>;

def SLT : InstArST64<(outs T64GPRF:$Dest),
                     (ins T64GPRF:$SrcA, T64GPRF:$SrcB),
                     "slt $Dest, $SrcA, $SrcB",
                     [(set (i32 T64GPRF:$Dest), (setlt (i32 T64GPRF:$SrcA), T64GPRF:$SrcB))]>;

def SLT_U : InstArST64<(outs T64GPRF:$Dest),
                       (ins T64GPRF:$SrcA, T64GPRF:$SrcB),
                       "slt_u $Dest, $SrcA, $SrcB",
                       [(set (i32 T64GPRF:$Dest), (setult (i32 T64GPRF:$SrcA), T64GPRF:$SrcB))]>;

def SLTE : InstArST64<(outs T64GPRF:$Dest),
                      (ins T64GPRF:$SrcA, T64GPRF:$SrcB),
                      "slte $Dest, $SrcA, $SrcB",
                      [(set (i32 T64GPRF:$Dest), (setle (i32 T64GPRF:$SrcA), T64GPRF:$SrcB))]>;

def SLTE_U : InstArST64<(outs T64GPRF:$Dest),
                        (ins T64GPRF:$SrcA, T64GPRF:$SrcB),
                        "slte_u $Dest, $SrcA, $SrcB",
                        [(set (i32 T64GPRF:$Dest), (setule (i32 T64GPRF:$SrcA), T64GPRF:$SrcB))]>;

def SLTI : InstArST64<(outs T64GPRF:$Dest),
                      (ins T64GPRF:$SrcA, i32imm:$Imm8),
                      "slti $Dest, $SrcA, $Imm8",
                      [(set (i32 T64GPRF:$Dest), (setlt (i32 T64GPRF:$SrcA), imm8:$Imm8))]>;

def SLTI_U : InstArST64<(outs T64GPRF:$Dest),
                        (ins T64GPRF:$SrcA, i32imm:$Imm8),
                        "slti_u $Dest, $SrcA, $Imm8",
                        [(set (i32 T64GPRF:$Dest), (setult (i32 T64GPRF:$SrcA), imm8:$Imm8))]>;

def SNE : InstArST64<(outs T64GPRF:$Dest),
                     (ins T64GPRF:$SrcA, T64GPRF:$SrcB),
                     "sne $Dest, $SrcA, $SrcB",
                     [(set (i32 T64GPRF:$Dest), (setne (i32 T64GPRF:$SrcA), T64GPRF:$SrcB))]>;

//===----------------------------------------------------------------------===//
// Non-instruction patterns for natively not supported comparisons
//===----------------------------------------------------------------------===//

def : Pat<(i32 (setugt (i32 T64GPRF:$SrcA), T64GPRF:$SrcB)),
          (SLT_U T64GPRF:$SrcB, T64GPRF:$SrcA)>;
def : Pat<(i32 (setuge (i32 T64GPRF:$SrcA), T64GPRF:$SrcB)),
          (SLTE_U T64GPRF:$SrcB, T64GPRF:$SrcA)>;
def : Pat<(i32 (setgt (i32 T64GPRF:$SrcA), T64GPRF:$SrcB)),
          (SLT T64GPRF:$SrcB, T64GPRF:$SrcA)>;
def : Pat<(i32 (setge (i32 T64GPRF:$SrcA), T64GPRF:$SrcB)),
          (SLTE T64GPRF:$SrcB, T64GPRF:$SrcA)>;

//===----------------------------------------------------------------------===//


//
// Control Instructions (p.95.)
//

//TODO: taken and not taken...
let isBranch = 1, isTerminator = 1, Defs = [Zero] in {

  def BBNS : InstCtrT64<(outs),
                        (ins T64GPRF:$SrcA, brtarget:$BrOff),
                        "bbns $SrcA, $BrOff",
                        [/*(brcond (i32 (seteq (urem T64GPRF:$SrcA, (i32 2)), (i32 0))), bb:$BrOff)*/]>;

  def BBNST : InstCtrT64<(outs),
                         (ins T64GPRF:$SrcA, brtarget:$BrOff),
                         "bbnst $SrcA, $BrOff",
                         [(brcond (i32 (seteq (urem T64GPRF:$SrcA, (i32 2)), (i32 0))), bb:$BrOff)]>;

  def BBS : InstCtrT64<(outs),
                       (ins T64GPRF:$SrcA, brtarget:$BrOff),
                       "bbs $SrcA, $BrOff",
                       [/*(brcond (i32 (seteq (urem T64GPRF:$SrcA, (i32 2)), (i32 1))), bb:$BrOff)*/]>;

  def BBST : InstCtrT64<(outs),
                        (ins T64GPRF:$SrcA, brtarget:$BrOff),
                        "bbst $SrcA, $BrOff",
                        [(brcond (i32 (seteq (urem T64GPRF:$SrcA, (i32 2)), (i32 1))), bb:$BrOff)]>;

  multiclass T64_BranchInst<string OpStr, PatFrag condOp> {

    def _nt : InstCtrT64<(outs), (ins T64GPRF:$SrcA, brtarget:$BrOff),
                         !strconcat(OpStr, " $SrcA, $BrOff"),
                         [/*(brcond (i32 (condOp T64GPRF:$SrcA, (i32 0))), bb:$BrOff)*/]>;

    def _t : InstCtrT64<(outs), (ins T64GPRF:$SrcA, brtarget:$BrOff),
                         !strconcat(OpStr, "t $SrcA, $BrOff"),
                         [(brcond (i32 (condOp T64GPRF:$SrcA, (i32 0))), bb:$BrOff)]>;

  }

  defm BGEZ : T64_BranchInst<"bgez", setge>;
  defm BGZ : T64_BranchInst<"bgz", setgt>;
  defm BLEZ : T64_BranchInst<"blez", setle>;
  defm BLZ : T64_BranchInst<"blz", setlt>;
  defm BNZ : T64_BranchInst<"bnz", setne>;
  defm BZ : T64_BranchInst<"bz", seteq>;

}

let isBranch = 1, isTerminator = 1, Defs = [LinkRegister] in {

  //JALB nad JALF are for calling backward and forward, use pseudo-instruction
  //JAL instead of them
  //skip JALB
  //skip JALF

  let isCall = 1,
      //All calls clobber the caller saved registers...
      Defs = [R2,  R3,  R4,  R5,  R6,  R7,  R8,  R9,
              R10, R11, R12, R13, R14, R15, R16, R17, R18, R19,
              R20, R21, R22, R23, R24, R25, R26, R27, R28, R29] in {
    //These instructions directly modify lr, but it's handled by the caller, so
    //lr is not mentioned in the list.

    //Pseudo instruction for JALB and JALF
    def JAL : InstCtrT64<(outs),
                         (ins calltarget:$dst, variable_ops),
                         "jal $dst",
                         []>;

    //pseudo instruction for PIC relocation
    def PICJAL : InstCtrT64<(outs),
                            (ins calltarget:$dst, variable_ops),
                            "jal plt($dst)",
                            []>;

    def JALR : InstCtrT64<(outs),
                          (ins T64GPRF:$SrcA, variable_ops),
                          "jalr $SrcA",
                          [(T64_jalr T64GPRF:$SrcA)]>;


  }

  //skip JALRP

}

//===----------------------------------------------------------------------===//
// Non-instruction patterns for call pseudo instruction
//===----------------------------------------------------------------------===//

def : Pat<(T64_call tglobaladdr:$dst), (JAL tglobaladdr:$dst)>;
def : Pat<(T64_call texternalsym:$dst), (JAL texternalsym:$dst)>;
def : Pat<(T64_piccall tglobaladdr:$dst), (PICJAL tglobaladdr:$dst)>;
def : Pat<(T64_piccall texternalsym:$dst), (PICJAL texternalsym:$dst)>;


//===----------------------------------------------------------------------===//

let isBranch = 1, isTerminator = 1 in {

  //JB and JF are for jumping backward and forward, use pseudo-instruction J
  //instead of them
  //skip JB
  //skip JF

  //Pseudo instruction for JB and JF
  def J : InstCtrT64<(outs),
                     (ins jmptarget:$JOff),
                     "j $JOff",
                     [(br bb:$JOff)]>;

  def JR : InstCtrT64<(outs),
                      (ins T64GPRF:$SrcA),
                      "jr $SrcA",
                      [(brind T64GPRF:$SrcA)]>;

  //Predict used on return
  let isReturn = 1 in
    def JRP : InstCtrT64<(outs),
                         (ins T64GPRF:$SrcA),
                         "jrp $SrcA",
                         [(T64_jrp T64GPRF:$SrcA)]>;

}

//pseudo instruction for store a base pointer with lnk
def GBR : PseudoT64<(outs gbr:$reg), (ins), "$reg", []>;

//===----------------------------------------------------------------------===//
// Non-instruction patterns for branching
//===----------------------------------------------------------------------===//

def : Pat<(brcond (i32 false), (bb)), (FNOP)>;
def : Pat<(brcond (i32 true), bb:$dst), (J bb:$dst)>;
def : Pat<(brcond (i32 T64GPRF:$Src), bb:$dst), (BNZ_t T64GPRF:$Src, bb:$dst)>;

//
// Logical Instructions (p.21.)
//

def AND : InstArST64<(outs T64GPRF:$Dest),
                     (ins T64GPRF:$SrcA, T64GPRF:$SrcB),
                     "and $Dest = $SrcA, $SrcB",
                     [(set (i32 T64GPRF:$Dest), (and T64GPRF:$SrcA, T64GPRF:$SrcB))]>;

def ANDI : InstArST64<(outs T64GPRF:$Dest),
                      (ins T64GPRF:$SrcA, i32imm:$Imm8),
                      "andi $Dest = $SrcA, $Imm8",
                      [(set (i32 T64GPRF:$Dest), (and T64GPRF:$SrcA, imm8:$Imm8))]>;

def MM : InstArLT64<(outs T64GPRF:$Dest),
                    (ins T64GPRF:$SrcA, T64GPRF:$SrcB, i32imm:$MMStart, i32imm:$MMEnd),
                    "mm $Dest = $SrcA, $SrcB, $MMStart, $MMEnd",
                    [(set T64GPRF:$Dest, (T64_mm T64GPRF:$SrcA, T64GPRF:$SrcB, (i32 regimm:$MMStart), (i32 regimm:$MMEnd)))]>;

def MNZ : InstArST64<(outs T64GPRF:$Dest),
                     (ins T64GPRF:$SrcA, T64GPRF:$SrcB),
                     "mnz $Dest = $SrcA, $SrcB",
                     [(set T64GPRF:$Dest, (selectcc T64GPRF:$SrcA, (i32 0), T64GPRF:$SrcB, (i32 0), SETNE))]>;

def MVNZ : InstBmST64<(outs T64GPRF:$Dest),
                      (ins T64GPRF:$SrcA, T64GPRF:$SrcB, T64GPRF:$src),
                      "mvnz $Dest = $SrcA, $SrcB",
                      [(set (i32 T64GPRF:$Dest), (selectcc T64GPRF:$SrcA, (i32 0), T64GPRF:$SrcB, T64GPRF:$src, SETNE))],
                      "$src = $Dest">;

def MVZ : InstBmST64<(outs T64GPRF:$Dest),
                     (ins T64GPRF:$SrcA, T64GPRF:$SrcB, T64GPRF:$src),
                     "mvz $Dest = $SrcA, $SrcB",
                     [(set (i32 T64GPRF:$Dest), (selectcc T64GPRF:$SrcA, (i32 0), T64GPRF:$SrcB, T64GPRF:$src, SETEQ))],
                     "$src = $Dest">;

def MZ : InstArST64<(outs T64GPRF:$Dest),
                    (ins T64GPRF:$SrcA, T64GPRF:$SrcB),
                    "mz $Dest = $SrcA, $SrcB",
                    [(set T64GPRF:$Dest, (selectcc T64GPRF:$SrcA, (i32 0), T64GPRF:$SrcB, (i32 0), SETEQ))]>;

def NOR : InstArST64<(outs T64GPRF:$Dest),
                     (ins T64GPRF:$SrcA, T64GPRF:$SrcB),
                     "nor $Dest = $SrcA, $SrcB",
                     [(set (i32 T64GPRF:$Dest), (not (or T64GPRF:$SrcA, T64GPRF:$SrcB)))]>;

def OR : InstArST64<(outs T64GPRF:$Dest),
                    (ins T64GPRF:$SrcA, T64GPRF:$SrcB),
                    "or $Dest = $SrcA, $SrcB",
                    [(set (i32 T64GPRF:$Dest), (or T64GPRF:$SrcA, T64GPRF:$SrcB))]>;

def ORI : InstArST64<(outs T64GPRF:$Dest),
                     (ins T64GPRF:$SrcA, i32imm:$Imm8),
                     "ori $Dest = $SrcA, $Imm8",
                     [(set (i32 T64GPRF:$Dest), (or T64GPRF:$SrcA, imm8:$Imm8))]>;

def RL : InstArST64<(outs T64GPRF:$Dest),
                    (ins T64GPRF:$SrcA, T64GPRF:$SrcB),
                    "rl $Dest = $SrcA, $SrcB",
                    [(set (i32 T64GPRF:$Dest), (rotl T64GPRF:$SrcA, (i32 T64GPRF:$SrcB)))]>;

def RLI : InstArST64<(outs T64GPRF:$Dest),
                     (ins T64GPRF:$SrcA, i32imm:$ShAmt),
                     "rli $Dest = $SrcA, $ShAmt",
                     [(set (i32 T64GPRF:$Dest), (rotl T64GPRF:$SrcA, (i32 regimm:$ShAmt)))]>;

def SHL : InstArST64<(outs T64GPRF:$Dest),
                     (ins T64GPRF:$SrcA, T64GPRF:$SrcB),
                     "shl $Dest = $SrcA, $SrcB",
                     [(set (i32 T64GPRF:$Dest), (shl T64GPRF:$SrcA, (i32 T64GPRF:$SrcB)))]>;

def SHLI : InstArST64<(outs T64GPRF:$Dest),
                      (ins T64GPRF:$SrcA, i32imm:$ShAmt),
                      "shli $Dest = $SrcA, $ShAmt",
                      [(set (i32 T64GPRF:$Dest), (shl T64GPRF:$SrcA, (i32 regimm:$ShAmt)))]>;

def SHR : InstArST64<(outs T64GPRF:$Dest),
                     (ins T64GPRF:$SrcA, T64GPRF:$SrcB),
                     "shr $Dest = $SrcA, $SrcB",
                     [(set (i32 T64GPRF:$Dest), (srl T64GPRF:$SrcA, (i32 T64GPRF:$SrcB)))]>;

def SHRI : InstArST64<(outs T64GPRF:$Dest),
                      (ins T64GPRF:$SrcA, i32imm:$ShAmt),
                      "shri $Dest = $SrcA, $ShAmt",
                      [(set (i32 T64GPRF:$Dest), (srl T64GPRF:$SrcA, (i32 regimm:$ShAmt)))]>;

def SRA : InstArST64<(outs T64GPRF:$Dest),
                     (ins T64GPRF:$SrcA, T64GPRF:$SrcB),
                     "sra $Dest = $SrcA, $SrcB",
                     [(set (i32 T64GPRF:$Dest), (sra T64GPRF:$SrcA, (i32 T64GPRF:$SrcB)))]>;

def SRAI : InstArST64<(outs T64GPRF:$Dest),
                     (ins T64GPRF:$SrcA, i32imm:$ShAmt),
                     "srai $Dest = $SrcA, $ShAmt",
                     [(set (i32 T64GPRF:$Dest), (sra T64GPRF:$SrcA, (i32 regimm:$ShAmt)))]>;

//skip TBLIDXB0
//skip TBLIDXB1
//skip TBLIDXB2
//skip TBLIDXB3

def XOR : InstArST64<(outs T64GPRF:$Dest),
                     (ins T64GPRF:$SrcA, T64GPRF:$SrcB),
                     "xor $Dest, $SrcA, $SrcB",
                     [(set (i32 T64GPRF:$Dest), (xor T64GPRF:$SrcA, T64GPRF:$SrcB))]>;

def XORI : InstArLT64<(outs T64GPRF:$Dest),
                      (ins T64GPRF:$SrcA, i32imm:$Imm8),
                      "xori $Dest, $SrcA, $Imm8",
                      [(set (i32 T64GPRF:$Dest), (xor T64GPRF:$SrcA, imm8:$Imm8))]>;

//===----------------------------------------------------------------------===//
// Non-instruction pattern for special logical operations to masked merge.
//===----------------------------------------------------------------------===//

def : Pat<(and T64GPRF:$Src, (i32 255)), (MM T64GPRF:$Src, (i32 Zero), (i32 0), (i32 7))>;
def : Pat<(and T64GPRF:$Src, (i32 511)), (MM T64GPRF:$Src, (i32 Zero), (i32 0), (i32 8))>;
def : Pat<(and T64GPRF:$Src, (i32 1023)), (MM T64GPRF:$Src, (i32 Zero), (i32 0), (i32 9))>;
def : Pat<(and T64GPRF:$Src, (i32 2047)), (MM T64GPRF:$Src, (i32 Zero), (i32 0), (i32 10))>;

//TODO: cont

//skip SWADD because it's only for TilePro

def TNS : InstMeLT64<(outs T64GPRF:$Dest),
                     (ins T64GPRF:$Src),
                     "tns $Dest, $Src",
                     [(set T64GPRF:$Dest, (atomic_swap_32 T64GPRF:$Src, (i32 1)))]>;

//
// Memory Maintenance Instructions (p.183.)
//

//skip DTLBPR

//skip FINV
//skip FLUSH
//skip INV

let hasSideEffects = 1 in
  def MF : InstMeLT64<(outs), (ins),
                      "mf",
                      [(T64_fence)]>;

//===----------------------------------------------------------------------===//
// Non-instruction pattern for fence pseudo instruction
//===----------------------------------------------------------------------===//

def : Pat<(atomic_fence (imm), (imm)), (MF)>;

//===----------------------------------------------------------------------===//

//skip WH64 because it's only for TilePro


//
// Multiply Instructions (p.190.)
//

def MULHH_SS : MulInstBmST64<"mulhh_ss", T64_mulhh_ss>;
def MULHH_SU : MulInstBmST64<"mulhh_su", T64_mulhh_su>;
def MULHH_UU : MulInstBmST64<"mulhh_uu", T64_mulhh_uu>;
def MULHHA_SS : MulAInstBmST64<"mulhha_ss", T64_mulhha_ss>;
def MULHHA_SU : MulAInstBmLT64<"mulhha_su", T64_mulhha_su>;
def MULHHA_UU : MulAInstBmST64<"mulhha_uu", T64_mulhha_uu>;
def MULHHSA_UU : MulAInstBmLT64<"mulhhsa_uu", T64_mulhhsa_uu>;
def MULHL_SS : MulInstBmLT64<"mulhl_ss", T64_mulhl_ss>;
def MULHL_SU : MulInstBmLT64<"mulhl_su", T64_mulhl_su>;
def MULHL_US : MulInstBmLT64<"mulhl_us", T64_mulhl_us>;
def MULHL_UU : MulInstBmLT64<"mulhl_uu", T64_mulhl_uu>;
def MULHLA_SS : MulAInstBmLT64<"mulhla_ss", T64_mulhla_ss>;
def MULHLA_SU : MulAInstBmLT64<"mulhla_su", T64_mulhla_su>;
def MULHLA_US : MulAInstBmLT64<"mulhla_us", T64_mulhla_us>;
def MULHLA_UU : MulAInstBmLT64<"mulhla_uu", T64_mulhla_uu>;
def MULHLSA_UU : MulAInstBmST64<"mulhlsa_uu", T64_mulhlsa_uu>;
def MULLL_SS : MulInstBmST64<"mulll_ss", T64_mulll_ss>;
def MULLL_SU : MulInstBmLT64<"mulll_su", T64_mulll_su>;
def MULLL_UU : MulInstBmST64<"mulll_uu", T64_mulll_uu>;
def MULLLA_SS : MulAInstBmST64<"mullla_ss", T64_mullla_ss>;
def MULLLA_SU : MulAInstBmLT64<"mullla_su", T64_mullla_su>;
def MULLLA_UU : MulAInstBmST64<"mullla_uu", T64_mullla_uu>;
def MULLLSA_UU : MulAInstBmLT64<"mulllsa_uu", T64_mulllsa_uu>;


//
// NOP Instructions (p.214.)
//

//See the beginning of instrucion definitions.

//
// SIMD Instructions (p.218.)
//

//TODO!!!
//include "rvexInstrInfoSIMD.td"

//
// System Instructions (p.347.)
//
let isBarrier = 1, hasSideEffects = 1 in
  def DRAIN : InstMeLT64<(outs), (ins),
                         "drain",
                         [(T64_mb)]>;

//===----------------------------------------------------------------------===//
// Non-instruction pattern for memory barrier pseudo instruction
//===----------------------------------------------------------------------===//

def : Pat<(membarrier (i32 imm), (i32 imm), (i32 imm), (i32 imm), (i32 imm)),
          (DRAIN)>;

//===----------------------------------------------------------------------===//

//skip ICOH
//skip ILL
//skip IRET
//skip MFSPR
//skip MTSPR
//skip NAP
//skip SWINT0
//skip SWINT1
//skip SWINT2
//skip SWINT3


//
// Pseudo Instructions (p.359.)
//

//Pseudo instruction for moving data between registers. Utilized by function
//rvexInstrInfo::copyPhysReg()
def MOVE : InstArST64<(outs T64GPRF:$Dest),
                      (ins T64GPRF:$Src),
                      "or $Dest = $Src, 0",
                      [(set (i32 T64GPRF:$Dest), (i32 T64GPRF:$Src))]>;

let isMoveImm = 1 in {

  def MOVEI_pos : InstArST64<(outs T64GPRF:$Dest),
                         (ins i32imm:$Imm32),
                         "mov $Dest = $Imm32",
                         [(set (i32 T64GPRF:$Dest), imm32_pos:$Imm32)]>;

  def MOVEI_neg : InstArST64<(outs T64GPRF:$Dest),
                         (ins i32imm:$Imm32),
                         "mov $Dest = ($Imm32)",
                         [(set (i32 T64GPRF:$Dest), imm32_neg:$Imm32)]>;

}

def PREFETCH : InstMeST64<(outs),
                          (ins T64GPRF:$Src),
                          "lb_u zero, $Src",
                          [(prefetch T64GPRF:$Src, (i32 imm), (i32 imm), (i32 imm))]>;

//TODO: is there need here for the assembler's other pseudo instructions?

//===----------------------------------------------------------------------===//
// Non-instruction patterns for utilizing zero register.
//===----------------------------------------------------------------------===//

def : Pat<(add T64GPRF:$SrcA, (i32 0)), (ADD T64GPRF:$SrcA, (i32 Zero))>;
def : Pat<(and T64GPRF:$SrcA, (i32 0)), (AND T64GPRF:$SrcA, (i32 Zero))>;
def : Pat<(or T64GPRF:$SrcA, (i32 0)), (OR T64GPRF:$SrcA, (i32 Zero))>;
def : Pat<(xor T64GPRF:$SrcA, (i32 0)), (XOR T64GPRF:$SrcA, (i32 Zero))>;

def : Pat<(i32 (seteq T64GPRF:$SrcA, (i32 0))), (SEQ T64GPRF:$SrcA, (i32 Zero))>;
def : Pat<(i32 (seteq (i32 0), T64GPRF:$SrcA)), (SEQ (i32 Zero), T64GPRF:$SrcA)>;
def : Pat<(i32 (setne T64GPRF:$SrcA, (i32 0))), (SNE T64GPRF:$SrcA, (i32 Zero))>;
def : Pat<(i32 (setne (i32 0), T64GPRF:$SrcA)), (SNE (i32 Zero), T64GPRF:$SrcA)>;

def : Pat<(i32 (setlt T64GPRF:$SrcA, (i32 0))), (SLT T64GPRF:$SrcA, (i32 Zero))>;
def : Pat<(i32 (setlt (i32 0), T64GPRF:$SrcA)), (SLT (i32 Zero), T64GPRF:$SrcA)>;
def : Pat<(i32 (setult T64GPRF:$SrcA, (i32 0))), (SLT_U T64GPRF:$SrcA, (i32 Zero))>;
def : Pat<(i32 (setult (i32 0), T64GPRF:$SrcA)), (SLT_U (i32 Zero), T64GPRF:$SrcA)>;
def : Pat<(i32 (setle T64GPRF:$SrcA, (i32 0))), (SLTE T64GPRF:$SrcA, (i32 Zero))>;
def : Pat<(i32 (setle (i32 0), T64GPRF:$SrcA)), (SLTE (i32 Zero), T64GPRF:$SrcA)>;
def : Pat<(i32 (setule T64GPRF:$SrcA, (i32 0))), (SLTE_U T64GPRF:$SrcA, (i32 Zero))>;
def : Pat<(i32 (setule (i32 0), T64GPRF:$SrcA)), (SLTE_U (i32 Zero), T64GPRF:$SrcA)>;

def : Pat<(i32 (setgt T64GPRF:$SrcA, (i32 0))), (SLT (i32 Zero), T64GPRF:$SrcA)>;
def : Pat<(i32 (setgt (i32 0), T64GPRF:$SrcA)), (SLT T64GPRF:$SrcA, (i32 Zero))>;
def : Pat<(i32 (setugt T64GPRF:$SrcA, (i32 0))), (SLT_U (i32 Zero), T64GPRF:$SrcA)>;
def : Pat<(i32 (setugt (i32 0), T64GPRF:$SrcA)), (SLT_U T64GPRF:$SrcA, (i32 Zero))>;
def : Pat<(i32 (setge T64GPRF:$SrcA, (i32 0))), (SLTE (i32 Zero), T64GPRF:$SrcA)>;
def : Pat<(i32 (setge (i32 0), T64GPRF:$SrcA)), (SLTE T64GPRF:$SrcA, (i32 Zero))>;
def : Pat<(i32 (setuge T64GPRF:$SrcA, (i32 0))), (SLTE_U (i32 Zero), T64GPRF:$SrcA)>;
def : Pat<(i32 (setuge (i32 0), T64GPRF:$SrcA)), (SLTE_U T64GPRF:$SrcA, (i32 Zero))>;
