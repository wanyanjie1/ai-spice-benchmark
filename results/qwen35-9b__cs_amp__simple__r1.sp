* Common-Source NMOS Amplifier Design
* Specifications: Gain ~10 (20dB), f=1kHz, VDD=5V

VDD ddrain 0 DC 5
Vin in 0 AC 1
Rsig in gate 1k
M1 drain out gate source NMOS
Rs source 0 1k
RL drain out 10k
Cload out 0 1uF
Ccouple_in Vin in 1uF

* Small-signal parameters for Gain = -gm*Rd_total approx 10
* Assume Vov=0.2V, Id=1mA -> gm = 2*Id/Vov = 100 mS
* Required Rd_total = 10 / 0.1 = 100 Ohms. 
* We set RL=10k and Rs=1k (degeneration reduces gain). 
* To get |Av|=10 with degeneration: Av = -gm*Rd / (1+gm*Rs)
* Let's target gm=50mS, Rs=1k -> denominator ~6. Need numerator large.
* Revised approach: Use high gm and small effective load or adjust bias.
* Let's define a specific NMOS model to ensure operation in saturation.

NMOS L=1u W=100u VTO=-0.4 KP=50u GAMMA=0 PHI=0.6 LAMBDA=0.02 CGSO=1p CGDO=1p CJ=1f MJSW=0
* Biasing to set Id ~ 1mA for gm ~ 100mS (if Vov=0.2)
* With Rs=1k, Vgs = Vth + Vov. Let's assume Vth=-0.4. 
* We need a DC bias point. Since no explicit current source is given in the prompt constraints other than components,
* we will use a simple resistor divider or just rely on the load line if possible, but for stability we add a gate bias.
* However, to keep it minimal and robust: Let's set up a self-biasing configuration or fixed bias.
* Given the strict "Design" request, I will provide a fixed bias setup using a voltage divider at the gate to ensure saturation.

Vbias gate 0 DC 2.5
Rg1 gate Vbias 1M
Rg2 Vbias 0 1M
* Wait, simpler: Just connect gate to a DC voltage via high impedance resistor from Vin? 
* Standard practice: AC coupled input. DC bias needs a path.
* Let's use a simple voltage divider for DC bias at Gate.
VDD ddrain 0 DC 5
Vin in 0 AC 1
Rsig in gate 1k
M1 drain out gate source NMOS
Rs source 0 1k
RL drain out 10k
Ccouple_in Vin in 1uF
* DC Bias Network for Gate (Voltage Divider)
Rg_top gate VDD 100k
Rg_bot gate 0 100k 
* This sets Vg = 2.5V. If Vth=-0.4, Vov=1.9V -> Id huge. Need to adjust.
* Let's recalculate for realistic values: VDD=5V. Target Id=0.5mA.
* If W/L=100u/1u, KP=50uA/V^2. Id = 0.5*KP*(W/L)*(Vgs-Vth)^2
* 0.5e-3 = 0.5 * 50e-6 * 100 * (Vgs+0.4)^2 => 0.5e-3 = 2.5e-3 * (Vgs+0.4)^2
* (Vgs+0.4)^2 = 0.2 => Vgs+0.4 = 0.447 => Vgs = 0.047V. Too low, near threshold.
* Let's increase W/L or adjust model. 
* Alternative: Use a current source load? No, RL is specified as resistor usually.
* Let's try Id=1mA with W=200u.
* 1e-3 = 0.5 * 50e-6 * 200 * (Vgs+0.4)^2 => 1e-3 = 5e-3 * (Vgs+0.4)^2 => (Vgs+0.4)^2 = 0.2 => Vgs=0.047 again?
* Math check: Id = 0.5 * KP * (W/L) * Vov^2. 
* If KP=50u, W/L=100. Coeff = 0.5*50e-6*100 = 2.5e-3.
* To get Id=1mA (1e-3), Vov^2 = 1e-3 / 2.5e-3 = 0.4. Vov = 0.63V.
* So Vgs = 0.63 + (-0.4) = 0.23V? Wait VTO is negative for enhancement? Usually NMOS VTO > 0 (e.g., 0.4).
* Let's set VTO=0.4. Then Vgs = 0.4 + 0.63 = 1.03V.
* Divider: Rg_top=50k, Rg_bot=20k -> Vg = 5 * 20/70 = 1.43V. Too low.
* Adjust divider: Rg_top=100k, Rg_bot=40k -> Vg = 5 * 40/140 = 1.43V. Still low.
* Need Vg ~ 1.2V? No, Vgs needs to be ~1.03V. Source is at Is*Rs = 1mA*1k = 1V.
* So Vg = Vs + Vgs = 1 + 1.03 = 2.03V.
* Divider for 2.03V: R_top/R_bot = (5-2.03)/2.03 = 2.97/2.03 ~ 1.46.
* Let R_top=150k, R_bot=100k -> Vg = 5 * 100/250 = 2V. Close enough.

* Finalizing Netlist with corrected bias and model
VDD ddrain 0 DC 5
Vin in 0 AC 1
Rsig in gate 1k
M1 drain out gate source NMOS
Rs source 0 1k
RL drain out 10k
Ccouple_in Vin in 1uF
* Gate Bias Divider
Rg1 gate VDD 150k
Rg2 gate 0 100k

.model NMOS VTO=0.4 KP=50u LAMBDA=0.02 CGSO=1p CGDO=1p CJ=1f MJSW=0
