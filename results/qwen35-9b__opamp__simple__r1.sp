* Two-Stage CMOS Op-Amp: Differential Pair + Common Source + Miller Compensation
* VDD = 5V, Target Gain >= 60dB

* Technology Parameters (Simplified for simulation)
.param VDD=5
.param W1=20u L1=0.18u   ; Input Pair Transistors (NMOS)
.param W2=20u L2=0.18u   ; Input Pair Transistors (PMOS)
.param W3=40u L3=0.18u   ; Second Stage NMOS
.param W4=40u L4=0.18u   ; Second Stage PMOS (Load)
.param W5=20u L5=0.18u   ; Compensation Capacitor transistor (optional, using direct cap here)
.param Cc=3p             ; Miller Compensation Capacitor

* Device Models
.model NMOS nmos (LEVEL=1 VTO=0.4 KP=110u CGDO=10f CGSO=10f CGBO=10f)
.model PMOS pmos (LEVEL=1 VTO=-0.4 KP=50u CGDO=10f CGSO=10f CGBO=10f)

* Circuit Nodes
* Input: in, Output: out
* Differential Pair: M1 (NMOS), M2 (PMOS)
* Second Stage: M3 (NMOS), M4 (PMOS)
* Bias Current Source: IBIAS

* DC Supply
VDD vdd 0 DC {VDD}
VGND gnd 0 DC 0

* Bias Current Generation (Simple Current Mirror Reference)
VBias bias_node 0 DC 2.5
IBIAS ibias_node 0 VMODEL NMOS W=1u L=0.18u
Rbias bias_node ibias_node 1k

* Input Differential Pair
* M1: NMOS, Drain connected to current source tail (simplified as resistor or current source)
* To ensure proper operation without complex biasing network in netlist, we use a current source for the tail.
Vtail tail_node 0 DC 2.5
Mtail tail_node gnd 0 0 NMOS W=1u L=0.18u

* Input Pair Transistors
* M1: Left Input (NMOS)
M1 drain1 in gate1 0 NMOS W={W1} L={L1}
* M2: Right Input (PMOS) - Note: For a standard diff pair with active load, usually one side is PMOS load.
* Let's design as: M1/M3 are NMOS input pair? No, standard is NMOS diff pair with PMOS active load or vice versa.
* Standard 2-stage: NMOS Diff Pair (M1, M2) with PMOS Current Mirror Load (M5, M6)? 
* Simpler robust design: NMOS Input Pair with PMOS Active Load (Current Mirror).
* Let's define:
*   M1: NMOS Input (Left)
*   M2: NMOS Input (Right) -> Wait, usually one is NMOS and load is PMOS.
*   Correct Topology: 
*     Stage 1: NMOS Differential Pair (M1, M2) with PMOS Current Mirror Load (M3, M4).
*     But the prompt asks for "Differential input pair + common-source second stage".
*     Standard implementation: 
*       Input Pair: M1 (NMOS), M2 (PMOS) ? No, usually same type for diff pair.
*       Let's use NMOS Differential Pair with PMOS Active Load Current Mirror.
*       M1: NMOS (Input +)
*       M2: NMOS (Input -) -> Connected to tail current source.
*       M3: PMOS (Load for M1, connected to VDD and M1 drain)
*       M4: PMOS (Load for M2, connected to VDD and M2 drain) - Forming the mirror.
*       Wait, if M3 and M4 are the load, they form a current mirror. 
*       Let's refine:
*         Tail Current Source: IM1 (NMOS or PMOS depending on topology). Let's use PMOS tail for NMOS diff pair? No, NMOS diff pair needs NMOS tail.
*         Let's stick to the most common: NMOS Differential Pair with PMOS Active Load.
*         M1: NMOS Input (Gate=in)
*         M2: NMOS Input (Gate=0 or AC ground for single-ended input simulation, but physically part of pair)
*         Actually, for a differential amplifier where 'in' is non-inverting, we connect 'in' to one gate and the other to AC ground (or bias).
*         Let's assume standard layout:
*           M1: NMOS, Gate=in, Source=Tail, Drain=Node X
*           M2: NMOS, Gate=bias (AC GND), Source=Tail, Drain=Node Y
*           Tail Current Source: IM_tail (PMOS usually for NMOS diff pair to save headroom? No, NMOS tail needs high impedance. PMOS current source is better if VDD is high).
*           Let's use a simple resistor or current source for tail.
*           Load: PMOS Current Mirror (M3, M4).
*           M3: PMOS connected to Node X (Drain of M1), Gate=Node Y, Source=VDD.
*           M4: PMOS connected to Node Y (Drain of M2), Gate=Node Y, Source=VDD.
*           This forms the first stage output at Node X (or Y).
*           Second Stage: Common Source.
*             M5: NMOS (Driver), Gate=Node X, Drain=out, Source=GND.
*             M6: PMOS (Load), Gate=bias, Drain=out, Source=VDD.
*           Compensation: Capacitor Cc from Node X to out.

* Re-evaluating Biasing for Stability and Gain:
*   We need specific bias voltages. Let's define a simple bias network or assume ideal current sources if not specified. 
*   To make it self-contained, I will use resistors to set bias points roughly, but for an Op-Amp netlist, current sources are preferred.
*   I will implement a basic bias circuit using diode-connected transistors to generate Vbias.

* Revised Topology Plan:
*   VDD = 5V.
*   Tail Current (IT): PMOS Current Source (M_tail_p) connected to GND? No, NMOS diff pair needs current sinking to GND. So Tail is NMOS current source.
*   Load: PMOS Current Mirror (M_load1, M_load2).
*   Stage 1 Output Node: Out1 (Drain of M1 and M_load1).
*   Stage 2 Driver: NMOS (M_out_drv) with Gate=Out1.
*   Stage 2 Load: PMOS (M_out_load) diode connected or current source? Usually current source for high gain, but Miller cap needs a node. 
*   Let's use:
*     M1 (NMOS): Input + (Gate=in)
*     M2 (NMOS): Input - (Gate=0V DC, AC Grounded via large R or direct to GND? No, usually biased at Vbias).
*     Let's bias the second gate of the diff pair to a fixed voltage.
*     Tail: NMOS Current Source (M_tail) connected to GND. Gate biased by a reference.
*     Load 1 & 2: PMOS Current Mirror (M_p1, M_p2).
*     Out1: Drain of M1 and M_p1.
*     Stage 2: M_cs (NMOS) with Gate=Out1, Drain=out. Load M_pl (PMOS).
*     Cc from Out1 to out.

* Simplified Biasing for Netlist (No external bias file):
*   Use a simple resistor divider or diode-connected stack to set Vbias.
*   Let's create a bias generator at the bottom.
*   Actually, to keep the netlist clean and robust:
*     We will define specific DC voltages using voltage sources for gates if exact sizing isn't provided, but that defeats the purpose of design.
*     Better: Use a standard bias circuit.
*     Let's assume we have a reference current Iref generated by a diode connected NMOS and PMOS pair? 
*     Okay, let's just use large resistors to set gate voltages for simplicity in this specific request, or better yet, define the bias nodes with voltage sources relative to VDD/GND to ensure saturation.
*     However, the prompt asks to "Design", implying a functional circuit.
*     I will use a standard biasing scheme:
*       Vbias generated by a simple bandgap-like structure is too complex for a single block.
*       Alternative: Assume gates of M2 and Tail are biased at specific voltages using voltage sources (e.g., 1.5V, 0.8V) to ensure saturation.
*       Let's calculate approximate Vgs for NMOS (Vth=0.4, Id~10uA). Vgs ~ 0.6-0.7V.
*       Let's set:
*         Tail Gate = 0.5V (Source at ~0.1V? No, tail source is near GND).
*         Let's use a current mirror bias.
*         
*   Final Decision on Biasing for Netlist:
*     Use a simple resistor network to set gate voltages for the second stage and tail, and assume the diff pair inputs are biased correctly by the user or AC coupling. 
*     BUT, for DC gain, we need proper DC operating points.
*     I will implement a "Bias Generator" sub-circuit logic inline:
*       1. Reference Current: Diode connected NMOS (M_ref) and PMOS (P_ref) forming a loop? No.
*       2. Simple approach: Use voltage sources for bias nodes to guarantee saturation, as calculating exact Vgs without process parameters is hard in a generic netlist. 
*       Wait, I can define the models with specific parameters and then set gate voltages to ensure saturation (e.g., Vbias_n = 1.5V, Vbias_p = 3.5V).
*       
*   Let's construct the netlist carefully:
*     Nodes: in, out, vdd, gnd.
*     Internal nodes: n1 (diff pair output), bias_node_1, bias_node_2.
*     
*   Components:
*     VDD source.
*     M1 (NMOS): Gate=in, Source=bias_tail, Drain=n1.
*     M2 (NMOS): Gate=bias_vg2, Source=bias_tail, Drain=n2 (unused or tied to n1 for single ended? No, standard diff amp outputs from one side).
*     Let's do Single-Ended Output Diff Pair:
*       M1 (NMOS) Input +.
*       M2 (NMOS) Input - (biased at Vbias_p).
*       Tail Current Source: IM_tail (PMOS? No, NMOS diff pair sinks current to GND). So Tail is NMOS.
*       Load: PMOS Current Mirror (M3, M4).
*         M3: Diode connected (Gate=Drain=n1), Source=VDD.
*         M4: Gate=M3_Gate, Drain=n1? No, M3 and M4 form the mirror. 
*         Standard: M3 (Load for M1) is diode connected. M4 (Load for M2) is the other half.
*         Output of Stage 1 is taken from Drain of M1 (and M3).
*         
*   Let's refine the specific transistor list:
*     VDD = 5V.
*     M_tail: NMOS, Source=GND, Gate=VBias_Tail. Need VBias_Tail.
*     To generate VBias_Tail without external file: Use a simple resistor divider or assume a voltage source. 
*     I will use Voltage Sources for bias nodes to ensure the circuit works immediately in simulation without complex iterative biasing networks which might oscillate or require specific initial conditions. This is acceptable for "Design a netlist" where exact process corner isn't specified, just topology.
*     
*   Bias Voltages (Estimated for 0.18um, Vth=0.4):
*     Id ~ 50uA.
*     Vgs_nmos ~ 0.6V. Vds_sat > Vgs-Vth ~ 0.2V.
*     VBias_Tail (NMOS tail gate): Needs to keep Tail in saturation. If Tail Source is GND, Gate needs to be > Vth + Vds_sat. Let's say 1.0V.
*     VBias_M2 (NMOS input - gate): Same as M1? No, usually biased at same potential for common mode rejection, but here we just need DC bias. Let's tie M2 gate to a bias voltage that keeps it on. 1.0V.
*     PMOS Loads (M3, M4): Source=VDD. Vsg needs to be ~0.6-0.8V. Gate needs to be ~5 - 0.7 = 4.3V.
*     
*   Let's create the netlist.

*   Transistor List:
*     M1: NMOS, G=in, S=tail_s, D=n1
*     M2: NMOS, G=bias_vg2, S=tail_s, D=n2 (We will tie n2 to n1? No, standard diff amp has two drains. We take output from one. Let's make it single-ended output by tying M2 drain to M3/M4 mirror).
*     Actually, simplest 2-stage:
*       Stage 1: NMOS Diff Pair (M1, M2) with PMOS Active Load Mirror (M3, M4).
*         M1: G=in, S=tail_s, D=out1
*         M2: G=bias_vg2, S=tail_s, D=out1_mirror (connected to M4 drain)
*         M3: P-MOS, S=VDD, D=out1, G=out1_mirror (Diode connected load for M1? No, M3 is diode connected, M4 is the mirror).
*         Correction: 
*           M3 (PMOS): S=VDD, D=out1, G=out1_mirror.
*           M4 (PMOS): S=VDD, D=out1_mirror, G=out1_mirror. (Diode connected).
*           Wait, standard mirror: One diode connected, one follows.
*           Let's do: 
*             M3 (PMOS): Diode connected (G=D=out1). Load for M1? No, if M3 is diode connected, it loads M1. Then M4 loads M2.
*             Output of stage 1 is at out1.
*             But we need a current mirror to convert differential to single ended.
*             Topology: 
*               M1 (NMOS) -> D = n1
*               M2 (NMOS) -> D = n2
*               M3 (PMOS): S=VDD, G=n2, D=n1 (Mirror load for M1? No).
*               Standard: 
*                 M1 (NMOS) Drain connected to M3 (PMOS) Drain.
*                 M2 (NMOS) Drain connected to M4 (PMOS) Drain.
*                 M3 and M4 form a current mirror. M3 is diode connected (G=D=n1? No, usually the one with M2 is diode connected).
*                 Let's say M4 is diode connected (G=D=n2). M3 has G connected to n2.
*                 Then output is taken from n1.
*     Stage 2:
*       M5 (NMOS): G=out1, S=GND, D=out.
*       M6 (PMOS): S=VDD, G=bias_vg_out, D=out.
*     Compensation:
*       Cc between out1 and out.
*     
*   Biasing Nodes:
*     tail_s: Connected to a current source. Let's use an NMOS current source M_tail connected to GND. Gate of M_tail needs bias.
*     Let's create a simple bias circuit at the bottom:
*       Vbias_gen: A diode connected NMOS and resistor? 
*       To keep it simple and robust: I will define voltage sources for the bias nodes (VBias_Tail, VBias_M2, VBias_OutLoad) with values that ensure saturation based on typical 0.18um parameters (Vth=0.4).
*       Vtail_gate = 1.0V (Ensures NMOS tail is on and in saturation if Id is small).
*       Vbias_M2 = 1.0V (Common mode bias).
*       Vbias_OutLoad = 3.5V (PMOS load gate, ensuring PMOS is in saturation).
*       
*   Wait, the prompt says "Design". I should probably include a minimal bias generator to make it self-starting without arbitrary voltage sources if possible, but arbitrary voltage sources are standard in SPICE netlists for op-amps unless a specific bias circuit is requested. I will use Voltage Sources for clarity and stability.

*   Final Component List:
*     VDD 5V
*     M1 NMOS (In+, Tail)
*     M2 NMOS (In-, Bias_Vg2)
*     M_tail NMOS (Tail Current Source, Gate=VBias_Tail)
*     M3 PMOS (Load for M1, Diode connected? No, part of mirror).
*     M4 PMOS (Load for M2, Diode connected).
*     Mirror connection: M3 Gate = M4 Drain.
*     M5 NMOS (Second Stage Driver)
*     M6 PMOS (Second Stage Load)
*     Cc Capacitor
*     
*   Let's write the netlist.

