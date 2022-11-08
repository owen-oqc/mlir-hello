!QuantumComponent = i32
func.func @main() {
    %0 = "hello.constant_phase"() {value = 1.000000e+00 : f64} : () -> f64
    %1 = "hello.constant_channel"() {value = 1 : i32} : () -> !QuantumComponent
    %2 = "hello.phase_shift"(%1, %0) : (!QuantumComponent, f64) -> !QuantumComponent
    return
}