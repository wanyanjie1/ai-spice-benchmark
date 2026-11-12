* First-Order Passive RC Low-Pass Filter
* 
* Hand Calculation:
* Formula: fc = 1 / (2 * pi * R * C)
* Target cutoff frequency (fc) = 1 kHz = 1000 Hz
* Selected standard capacitor value: C = 100 nF (100e-9 F)
* R = 1 / (2 * pi * fc * C)
* R = 1 / (2 * pi * 1000 * 100e-9) = 1591.55 ohms

* Input Signal Source
V1 in 0 DC 0 AC 1

* Filter Components
R1 in out 1.59155k
C1 out 0 100n

* AC Analysis from 10 Hz to 100 kHz (20 points per decade)
.ac dec 20 10 100k

.end
