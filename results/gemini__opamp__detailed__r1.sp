* Two-Stage Miller-Compensated CMOS Op Amp
*
* Hand Calculations & Design Verification:
* ----------------------------------------------------------------------
* 1. Transistor Models & Bias Currents:
*    - NMOS1: VTO = 0.7V, KP = 110u A/V^2, LAMBDA = 0.04 V^-1
*    - PMOS1: VTO = -0.7V, KP = 50u A/V^2, LAMBDA = 0.05 V^-1
*    - Reference Current Iref = 20uA
*    - Tail current I_M5 = 20uA -> Differential pair currents I_M1 = I_M2 = 10uA
*    - First-stage PMOS load currents I_M3 = I_M4 = 10uA
*    - Second-stage currents I_M7 = I_M8 = 100uA
*
* 2. Device Sizing:
*    - M1, M2 (NMOS Diff Pair): W = 10u, L = 2u  ((W/L)_1 = 5)
*    - M3, M4 (PMOS Load Mirror): W = 10u, L = 2u ((W/L)_3 = 5)
*    - M5 (NMOS Tail Source): W = 10u, L = 2u    ((W/L)_5 = 5)
*    - M6 (NMOS Bias Diode): W = 10u, L = 2u     ((W/L)_6 = 5)
*    - M7 (PMOS 2nd Stage CS): W = 100u, L = 2u  ((W/L)_7 = 50)
*    - M8 (NMOS 2nd Stage Load): W = 50u, L = 2u  ((W/L)_8 = 25)
*
* 3. Gain & Small-Signal Calculations:
*    - First Stage Transconductance:
*      gm1 = sqrt(2 * KP_n * (W/L)_1 * I_D1) = sqrt(2 * 110u * 5 * 10u) = 104.9 uS
*    - First Stage Output Resistance:
*      gds2 = LAMBDA_n * I_D2 = 0.04 * 10u = 0.4 uS
*      gds4 = LAMBDA_p * I_D4 = 0.05 * 10u = 0.5 uS
*      R_out1 = 1 / (gds2 + gds4) = 1 / 0.9 uS = 1.111 MOhm
*      Av1 = gm1 * R_out1 = 104.9 uS * 1.111 MOhm = 116.5 V/V (41.3 dB)
*
*    - Second Stage Transconductance:
*      gm7 = sqrt(2 * KP_p * (W/L)_7 * I_D7) = sqrt(2 * 50u * 50 * 100u) = 447.2 uS
*    - Second Stage Output Resistance:
*      gds7 = LAMBDA_p * I_D7 = 0.05 * 100u = 5.0 uS
*      gds8 = LAMBDA_n * I_D8 = 0.04 * 100u = 4.0 uS
*      R_out2 = 1 / (gds7 + gds8) = 1 / 9.0 uS = 111.1 kOhm
*      Av2 = gm7 * R_out2 = 447.2 uS * 111.1 kOhm = 49.7 V/V (33.9 dB)
*
*    - Total Open-Loop Low-Frequency Gain:
*      Av = Av1 * Av2 = 116.5 * 49.7 = 5790 V/V (75.2 dB) >= 60 dB target.
*
* 4. Saturation Checks:
*    - Vov6 = sqrt(2 * 20u / (110u * 5)) = 0.27 V -> V_nbias = 0.7 + 0.27 = 0.97 V
*    - Vov1 = sqrt(2 * 10u / (110u * 5)) = 0.19 V -> V_tail = 2.5 - 0.7 - 0.19 = 1.61 V
*    - VDS5 = 1.61 V > Vov5 (0.27 V) -> M5 Saturated.
*    - Vov3 = sqrt(2 * 10u / (50u * 5)) = 0.28 V -> V_n1 = 5.0 - 0.7 - 0.28 = 4.02 V
*    - VDS1 = VDS2 = 4.02 - 1.61 = 2.41 V > Vov1 (0.19 V) -> M1, M2 Saturated.
*    - VSD3 = VSD4 = 5.0 - 4.02 = 0.98 V > |Vov3| (0.28 V) -> M3, M4 Saturated.
*    - Vout (DC) approx 2.5 V -> VDS8 = 2.5 V > Vov8 (0.27 V), VSD7 = 2.5 V > |Vov7| (0.28 V) -> M7, M8 Saturated.

* Model Definitions
.model NMOS1 nmos level=1 vto=0.7 kp=110u lambda=0.04
.model PMOS1 pmos level=1 vto=-0.7 kp=50u lambda=0.05

* Power Supplies & Bias
VDD vdd 0 DC 5
Iref vdd nbias DC 20u

* Input Signal (Non-Inverting Input)
Vin in 0 DC 2.5 AC 1

* First Stage: Differential Pair & Load Mirror
M1 n1 in tail 0 NMOS1 W=10u L=2u
M2 out1 inn tail 0 NMOS1 W=10u L=2u
M3 n1 n1 vdd vdd PMOS1 W=10u L=2u
M4 out1 n1 vdd vdd PMOS1 W=10u L=2u

* Tail Current Source & Reference Mirror
M5 tail nbias 0 0 NMOS1 W=10u L=2u
M6 nbias nbias 0 0 NMOS1 W=10u L=2u

* Second Stage: Common Source Amplifier & Active Load
M7 out out1 vdd vdd PMOS1 W=100u L=2u
M8 out nbias 0 0 NMOS1 W=50u L=2u

* Compensation & Load Capacitance
Cc out1 out 2p
CL out 0 1p

* Open-Loop AC Test Bench (DC Bias Feedback & AC Break)
L1 out inn 1G
C1 inn 0 1

* Analysis Setup
.op
.ac dec 10 1 100MEG

.end
