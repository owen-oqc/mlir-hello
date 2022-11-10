// Licensed to the Apache Software Foundation (ASF) under one
// or more contributor license agreements.  See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership.  The ASF licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
#include <iostream>
#include "llvm/ADT/TypeSwitch.h"
#include "mlir/IR/Builders.h"
#include "mlir/IR/OpImplementation.h"
#include "mlir/IR/DialectImplementation.h"
#include "Hello/HelloDialect.h"
#include "Hello/HelloOps.h"

using namespace mlir;
using namespace hello;

//===----------------------------------------------------------------------===//
// Hello dialect.
//===----------------------------------------------------------------------===//

#include "Hello/HelloOpsDialect.cpp.inc"

void HelloDialect::initialize() {
  addOperations<
#define GET_OP_LIST
#include "Hello/HelloOps.cpp.inc"
      >();
    addTypes<ChannelType, QuantumComponent>();
}

void hello::ConstantOp::build(mlir::OpBuilder &builder, mlir::OperationState &state, double value) {
  auto dataType = RankedTensorType::get({}, builder.getF64Type());
  auto dataAttribute = DenseElementsAttr::get(dataType, value);
  hello::ConstantOp::build(builder, state, dataType, dataAttribute);
}

mlir::Operation *HelloDialect::materializeConstant(mlir::OpBuilder &builder,
                                                 mlir::Attribute value,
                                                 mlir::Type type,
                                                 mlir::Location loc) {
    return builder.create<hello::ConstantOp>(loc, type,
                                      value.cast<mlir::DenseElementsAttr>());
}


::mlir::Type HelloDialect::parseType(::mlir::DialectAsmParser &parser) const{
    llvm::StringRef keyword;
    if (parser.parseKeyword(&keyword))
        return Type();

    if (keyword == "ChannelType")
        return ChannelType::get(getContext());
    if (keyword == "QuantumComponent")
        return QuantumComponent::get(getContext());
    parser.emitError(parser.getNameLoc(), "unknown hello type: ") << keyword;
    return Type();

}

/// Print a type registered to this dialect.
void HelloDialect::printType(::mlir::Type type,
               ::mlir::DialectAsmPrinter &os) const{
    mlir::TypeSwitch<Type>(type)
            .Case<ChannelType>([&](Type) { os << "ChannelType"; })
            .Case<QuantumComponent>([&](Type) { os << "QuantumComponent"; })
            .Default([](Type) { llvm_unreachable("unexpected 'hello' type kind"); });
}
