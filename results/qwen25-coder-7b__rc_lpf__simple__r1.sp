.model R1 resistor
.model C1 capacitor

* RC low-pass filter with -3 dB cutoff frequency of 1 kHz
R1 in out 1k
C1 out gnd 1u

* AC source
AC 1
