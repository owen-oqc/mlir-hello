#ifndef HELLO_OPS
#define HELLO_OPS

include "HelloDialect.td"
include "mlir/Interfaces/SideEffectInterfaces.td"
include "mlir/IR/AttrTypeBase.td"

def MyType : TypeDef<Hello_Dialect, "MyType"> {
   // Define a mnemonic to allow the dialect's parser hook to call into the
   // generated parser.
   let mnemonic = "my_type";

   let cppClassName="MyTypeX";

   // Define two parameters whose C++ types are indicated in string literals.
   let parameters = (ins "int":$a, "int":$b);

   // Define the assembly format. Surround the format with less `<` and greater
   // `>` so that MLIR's printer uses the pretty format.
   let assemblyFormat = "`<` `a` `=` $a `,` `b` `=` $b `>`";
}

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

  let results = (outs F<64>:$result);
}

def ConstantChannel : Hello_Op<"constant_channel", [Pure]> {
let summary = "constant_channel";
let description = [{
Constant operation turns a literal into an SSA channel value. The data is attached
to the operation as an attribute. For example:

```mlir
%0 = "hello.constant_channel"()
{ value = 1 : mlir::ShapeSize_Type }
: () -> ShapeSize_Type
```
}];
let results = (outs MyType:$result);
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
let arguments = (ins I<32>:$lhs, F<64>:$rhs);
let results = (outs I<32>:$result);
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
