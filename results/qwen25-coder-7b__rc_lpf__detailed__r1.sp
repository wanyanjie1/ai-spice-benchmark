* First-order passive RC low-pass filter design
* Cutoff frequency fc = 1 kHz
* Passband gain 0 dB
* Standard capacitor value: 100 nF
.model R1 resistor
.model C1 capacitor
* Calculate the required resistor value R
* fc = 1 / (2 * pi * R * C)
* R = 1 / (2 * pi * fc * C)
* R = 1 / (2 * pi * 1000 * 100e-9)
* R = 159.155 ohms
R1 1 2 159.155
C1 2 0 100n
* Input AC source
V1 1 0 AC 1
* Output node
.out 2