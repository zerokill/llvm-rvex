add_llvm_library(LLVMCpu0Desc
  Cpu0MCTargetDesc.cpp
  Cpu0MCAsmInfo.cpp
  )

add_dependencies(LLVMCpu0Desc Cpu0CommonTableGen)
