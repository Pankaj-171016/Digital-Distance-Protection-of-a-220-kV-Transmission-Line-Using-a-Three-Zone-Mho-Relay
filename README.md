# Digital Distance Protection of a 220 kV Transmission Line Using a Three-Zone Mho Relay

MATLAB/Simulink simulation and performance analysis of a digital three-zone mho distance relay protecting a 220 kV, 50 Hz transmission line against phase-to-ground faults.

---

## System Parameters & Relay Settings

### Power System Network
- **Nominal Voltage:** 220 kV (Phase-to-Ground: 127 kV rms, peak ≈ 180 kV)
- **Frequency:** 50 Hz
- **Protected Line (Line 1):** 60 km ($R = 0.01273\ \Omega/\text{km}$, $L = 0.9337\text{ mH}/\text{km}$, $C = 12.74\text{ nF}/\text{km}$)
- **Adjacent Line (Line 2):** 90 km ($R = 0.01273\ \Omega/\text{km}$, $L = 0.9337\text{ mH}/\text{km}$, $C = 12.74\text{ nF}/\text{km}$)
- **Total Line Impedance:** $z = 0.2936\ \Omega/\text{km} \angle 87.5^\circ$
- **Load Model:** 3-Phase constant-Z load (100 MW, 20 MVAR)

### Three-Zone Mho Relay Reach & Coordination
The digital relay samples voltages and currents at $T_s = 200\ \mu\text{s}$ (5 kHz) and extracts fundamental phasors via a 100-point Discrete Fourier Transform (DFT) window. Zero-sequence compensation is applied using $k_N = 1.156 - j0.374$.

| Zone | Reach Coverage | Reach Impedance ($Z_r$) | Intentional Time Delay | Operating Role |
| :--- | :--- | :--- | :--- | :--- |
| **Zone 1** | 80% of protected line (80 km) | 23.49 $\Omega$ | 0.0 s (Instantaneous) | Primary protection |
| **Zone 2** | 100% Line 1 + 50% Line 2 (120 km) | 35.23 $\Omega$ | 0.3 s | Backup for Line 1 / boundary |
| **Zone 3** | 100% Line 1 + 100% Line 2 (150 km) | 44.04 $\Omega$ | 0.6 s | Remote backup |

---

## Simulation Test Case: Single Phase-to-Ground (A-G) Fault

- **Fault Type:** Single Line-to-Ground (Phase A to Ground)
- **Fault Location:** 60 km from relay bus (Zone 1 reach)
- **Inception Time ($t_{\text{fault}}$):** 0.400 s
- **Calculated Fault Impedance:** $Z_{\text{seen}} = 0.76 + j17.60\ \Omega$ ($|Z_{\text{seen}}| = 17.62\ \Omega < Z_{r1} = 23.49\ \Omega$)

---

## Results & Waveforms

### 1. Phase Voltages at the Relay
Healthy balanced sinusoidal voltages (≈ 180 kV peak) remain stiff on the source bus. Phase A undergoes a minor dip during the fault period (0.400 s to 0.422 s) before the breaker isolates the line.

![1. Phase Voltages](1_Phase_Voltages.png)

---

### 2. Phase Currents at the Relay
Pre-fault steady-state load current is ≈ 400 A peak. Upon fault inception at 0.400 s, Phase A experiences an asymmetrical fault surge peaking at ≈ 6000 A with DC offset. At $t \approx 0.422\text{ s}$, the circuit breaker opens and interrupts all phase currents cleanly to zero.

![2. Phase Currents](2_Phase_Currents.png)

---

### 3. Latched Zone Trips
The relay detects the fault inside Zone 1 within one fundamental cycle (13 ms). The Zone 1 trip signal rises from `0` to `1` at $t = 0.413\text{ s}$ and latches. Zone 2 and Zone 3 do not time out because the fault is cleared instantaneously.

![3. Latched Zone Trips](3_Latched_Zone_Trips.png)

---

### 4. Breaker Trip Command
The circuit breaker trip signal (`cb_cmd`) operates on active-low trip logic ($1 = \text{closed}$, $0 = \text{open}$). The command transitions from `1` to `0` at $t = 0.413\text{ s}$, initiating mechanical contact separation.

![4. Breaker Command](4_Breaker_Command.png)

---

### 5. R-X Plane Operating Characteristic
The measured fault trajectory moves from the normal operating load impedance ($465 + j93\ \Omega$, far off-chart) directly into the Zone 1 mho circle, settling at $0.76 + j17.60\ \Omega$.

![5. R-X Plane](5_RX_Plane_Zone1.png)

---

### 6. Measured Impedance Magnitude vs. Time
Apparent impedance seen by the relay drops sharply from normal load impedance (475 $\Omega$) at $t = 0.400\text{ s}$ to 17.62 $\Omega$ at $t = 0.413\text{ s}$, well below the Zone 1 reach threshold (23.5 $\Omega$). After breaker opening, current ceases and impedance becomes undefined.

![6. Impedance vs Time](6_Impedance_Magnitude.png)

---

### 7. Stepped Time-Distance Coordination Curve
Coordination profile displaying Zone 1 (0 to 80 km, 0 s delay), Zone 2 (80 to 120 km, 0.3 s delay), and Zone 3 (120 to 150 km, 0.6 s delay). The test fault at 60 km sits within the instantaneous clearing region.

![7. Zone Coordination](7_Zone_Coordination_Delay.png)

---

### 8. Apparent Impedance vs. Distance
Linear growth of loop impedance with distance ($0.2936\ \Omega/\text{km}$). The 60 km fault corresponds to 17.62 $\Omega$, confirming proper selectivity below the Zone 1 boundary (23.49 $\Omega$).

![8. Apparent Impedance](8_Apparent_Impedance.png)

---

## How to Run

### Simulink Model
1. Open MATLAB (R2023a or newer with Simscape Electrical).
2. Open `mho_distance_model.slx`.
3. Run the simulation. The logged workspace variables `Zrx` and `trips` record the relay states.
