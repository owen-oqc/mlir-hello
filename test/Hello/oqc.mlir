func.func @main() {
    %0 = "hello.constant_phase"() {value = 1.000000e+00 : f64} : () -> f64
    %1 = "hello.constant_channel"() {value = 1 : i32, tag = "tag_entry"} : () -> !hello.QuantumComponent
    %2 = "hello.phase_shift"(%1, %0) : (!hello.QuantumComponent, f64) -> !hello.QuantumComponent
    %3 = "hello.phase_shift"(%2, %0) : (!hello.QuantumComponent, f64) -> !hello.QuantumComponent
    return
}
