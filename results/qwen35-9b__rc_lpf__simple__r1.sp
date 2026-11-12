* First-order Passive RC Low-Pass Filter
* Cutoff Frequency: 1 kHz
Vsource in 0 AC 1
Rload out 0 1k
Cfilter in out 159.15u
.model Vsource vsource (voltage=0)
.model Rload resistor (r=1k)
.model Cfilter capacitor (c=159.15u)
.ac dec 100 10 1Meg
.plot ac v(out)
.end