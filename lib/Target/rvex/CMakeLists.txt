set(LLVM_TARGET_DEFINITIONS rvex.td)

tablegen(LLVM rvexGenRegisterInfo.inc -gen-register-info)
tablegen(LLVM rvexGenInstrInfo.inc -gen-instr-info)
tablegen(LLVM rvexGenAsmWriter.inc -gen-asm-writer)
tablegen(LLVM rvexGenDAGISel.inc -gen-dag-isel)
tablegen(LLVM rvexGenSubtargetInfo.inc -gen-subtarget)
tablegen(LLVM rvexGenCallingConv.inc -gen-callingconv)
tablegen(LLVM rvexGenDFAPacketizer.inc -gen-dfa-packetizer)
add_public_tablegen_target(rvexCommonTableGen)

add_llvm_target(rvexCodeGen
  rvexAsmPrinter.cpp
  rvexInstrInfo.cpp
  rvexISelDAGToDAG.cpp
  rvexISelLowering.cpp
  rvexFrameLowering.cpp
  rvexRegisterInfo.cpp
  rvexSubtarget.cpp
  rvexTargetMachine.cpp
  rvexSelectionDAGInfo.cpp
  rvexVLIWPacketizer.cpp
  )

add_subdirectory(TargetInfo)
add_subdirectory(MCTargetDesc)

