#ifndef HELLO_OPS
#define HELLO_OPS

include "HelloDialect.td"
include "mlir/Interfaces/SideEffectInterfaces.td"
include "mlir/IR/AttrTypeBase.td"
include "mlir/IR/BuiltinTypes.td"
include "mlir/IR/OpBase.td"


// It's common to define a base classes for types in the same dialect. This
// removes the need to pass in the dialect for each type, and can also be used
// to define a few fields ahead of time.
class MyDialect_Type<string name, string typeMnemonic, list<Trait> traits = []>
: TypeDef<Hello_Dialect, name, traits> {
let mnemonic = typeMnemonic;
}

def ChannelType :
DialectType<Hello_Dialect, CPred<"$_self.isa<hello::ChannelType>()">,
        "ChannelType">;


def ConstantPhaseOp : Hello_Op<"constant_phase", [Pure]> {
  let summary = "constant_phase";
  let description = [{
    Constant operation turns a literal into an SSA phase value. The data is attached
    to the operation as an attribute. For example:

    ```mlir
      %0 = "hello.constant_phase"()
      { value = 1.00 : f64 }
      : () -> f64
    ```
  }];

  let results = (outs F64:$result);
}

def ConstantChannel : Hello_Op<"constant_channel", [Pure]> {
let summary = "constant_channel";
let description = [{
Constant operation turns a literal into an SSA channel value. The data is attached
to the operation as an attribute. For example:

```mlir
%0 = "hello.constant_channel"()
{ value = 1 : hello::ChannelType }
: () -> ChannelType
```
}];
let results = (outs ChannelType:$result);
}

def PhaseShift : Hello_Op<"phase_shift"> {
let summary = "phase_shift";
let description = [{
Phase shift.

```mlir
%2 = "hello.phase_shift"(%0, %1)
{}
: () -> f64
```
}];
let arguments = (ins ChannelType:$lhs, F<64>:$rhs);
let results = (outs ChannelType:$result);
}

def ConstantOp : Hello_Op<"constant", [Pure]> {
  let summary = "constant";
  let description = [{
  Constant operation turns a literal into an SSA value. The data is attached
  to the operation as an attribute. For example:

  ```mlir
  %0 = "hello.constant"()
  { value = dense<[[1.0, 2.0, 3.0], [5.0, 5.0, 6.0]]> : tensor<1x3xf64> }
  : () -> tensor<2x3xf64>
  ```
  }];

  let builders = [
  OpBuilder<(ins "mlir::DenseElementsAttr":$value), [{
  build($_builder, $_state, value.getType(), value);
  }]>,
  OpBuilder<(ins "double":$value)>
  ];

  //  let parser = [{ return ::parseConstantOp(parser, result); }];
  let arguments = (ins F64ElementsAttr:$value);
  let results = (outs F64Tensor);
}

def PrintOp : Hello_Op<"print", [Pure]> {
    let summary = "print operation";
    let description = [{
        The "print" builtin operation prints a given input tensor, and produces
        no results.
    }];

    // The print operation takes an input tensor to print.
    let arguments = (ins AnyTypeOf<[F64Tensor, F64MemRef]>:$input);

    let assemblyFormat = "$input attr-dict `:` type($input)";
}

#endif // HELLO_OPS
