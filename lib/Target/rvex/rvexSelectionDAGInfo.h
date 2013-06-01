//===-- rvexSelectionDAGInfo.h - rvex SelectionDAG Info -----*- C++ -*-===//
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
// This file defines the rvex subclass for TargetSelectionDAGInfo.
//
//===----------------------------------------------------------------------===//

#ifndef rvexSELECTIONDAGINFO_H
#define rvexSELECTIONDAGINFO_H

#include "llvm/Target/TargetSelectionDAGInfo.h"

namespace llvm {

class rvexTargetMachine;

class rvexSelectionDAGInfo : public TargetSelectionDAGInfo {
public:
  explicit rvexSelectionDAGInfo(const rvexTargetMachine &TM);
  ~rvexSelectionDAGInfo();
};

}

#endif

