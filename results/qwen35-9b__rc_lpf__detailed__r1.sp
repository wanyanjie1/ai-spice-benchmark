* First-order Passive RC Low-Pass Filter Design
* Specification: fc = 1 kHz, Passband Gain = 0 dB
* Topology: V1 (AC 1) -> R -> out -> C -> GND
* Calculation: fc = 1/(2*pi*R*C) => R = 1/(2*pi*fc*C)
* Given C = 100nF, fc = 1000 Hz
* R = 1 / (2 * pi * 1000 * 100e-9) ≈ 1591.55 Ohms
* Using standard resistor value: 1.6kOhm (approximate for simulation)
V1 in 0 AC 1
R1 in out 1.6k
C1 out 0 100nF
.ac dec 1 1Meg
.plot ac v(out)
.end