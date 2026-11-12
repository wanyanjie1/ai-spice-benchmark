* Single-stage common-source NMOS amplifier design
* VDD = 5 V, Av = 10 (20 dB) at 1 kHz, no external load
* Model: NMOS1 nmos level=1 vto=0.7 kp=200u lambda=0.01
* Step 1: Choose ID and VGS
* Av = gm * RD
* 10 = gm * RD
* gm = 2 * ID / (VGS - VTO)
* Let's choose ID = 100uA for simplicity
* 10 = (2 * 100uA) / (VGS - 0.7V)
* VGS = 0.7V + 5V / 20 = 0.7V + 0.25V = 0.95V
* Step 2: Choose RD
* gm = 2 * ID / (VGS - VTO) = 2 * 100uA / (0.95V - 0.7V) = 2 * 100uA / 0.25V = 800uS
* RD = Av / gm = 10 / 800uS = 12.5kΩ
* Step 3: Check MOSFET stays in saturation
* VDS = VDD - VGS = 5V - 0.95V = 4.05V
* VGS - VTO = 0.95V - 0.7V = 0.25V
* Since VDS > VGS - VTO, the MOSFET stays in saturation
* Netlist
.model NMOS1 nmos level=1 vto=0.7 kp=200u lambda=0.01
R1 in 1 10u
R2 1 0 10k
R3 0 out 12.5k
M1 1 out 0 0 NMOS1
V1 in 0 DC 0 AC 1