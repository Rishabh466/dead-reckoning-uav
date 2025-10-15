**Watch the Live Demo → [YouTube Video](https://youtu.be/pdFYwzBmNsg)**  


# Dead Reckoning Navigation (GPS-Denied Return-to-Home)

## Introduction
In GPS-denied environments such as tunnels, dense urban areas, or under canopy cover, UAVs can lose positional awareness, making it impossible to perform autonomous Return-to-Home (RTL) operations.  
This project implements a **Lua-scripted dead reckoning system** within the **ArduPilot SITL simulation environment** to allow drones to return to their launch position without GPS.  

The algorithm estimates position using onboard sensors—**IMU, barometer, and magnetometer**—and commands an RTL sequence based on relative displacement from the home point.  
The system was developed and tested under simulated GPS-loss conditions using **MAVProxy** and **ArduPilot Copter** SITL and later on a real drone.

---

## Principle of Operation
The system operates on the principle of **dead reckoning**—estimating the current position based on previously known position, velocity, and heading.  
When GPS data becomes unavailable, the drone:
1. Detects loss of GPS signal using ArduPilot Lua APIs.
2. Switches to **sensor-based estimation**, integrating acceleration and heading over time.
3. Estimates displacement vector relative to home.
4. Executes an RTL maneuver using this estimated position.

This ensures safe and autonomous recovery even in the absence of satellite data.

---

## Working
The project was first developed entirely using ArduPilot’s **SITL (Software-In-The-Loop)** simulation and tested through **MAVProxy** console visualization.  
A Lua script runs onboard (within ArduPilot) and continuously monitors GPS status.  
Once GPS is lost, it triggers the dead reckoning routine and computes approximate distance and bearing to the home location.

### Step-by-Step Workflow:
1. **Normal Flight Phase:**  
   The drone navigates using GPS-based positional updates.
2. **GPS Loss Detection:**  
   The Lua script checks the GPS status (`gps:status()`) periodically. If status < 3, it flags GPS failure.
3. **Sensor Data Retrieval:**  
   IMU acceleration (`ahrs:get_accel()`), barometric altitude (`baro:get_pressure()`), and yaw angle (`ahrs:get_yaw()`) are continuously read.
4. **Dead Reckoning Estimation:**  
   Velocity and displacement are integrated using IMU data, corrected with heading and altitude.
5. **Return-to-Home Execution:**  
   When estimated position error < threshold, the vehicle sets flight mode to RTL (`vehicle:set_mode(6)`).

---

## Hardware & Software Components
| Component | Function |
|------------|-----------|
| **ArduPilot SITL** | Provides virtual drone simulation for testing GPS loss scenarios |
| **Lua Scripting Engine** | Embedded within ArduPilot firmware for onboard automation |
| **MAVProxy** | Ground control interface for telemetry and monitoring |
| **Python (pymavlink)** | Used for logging and automation of SITL missions |
| **IMU, Barometer, Magnetometer (Simulated)** | Provide necessary sensor data for dead reckoning |
| **Ubuntu/Linux** | Simulation and testing environment |

---

## Testing and Result
- **Scenario**: Simulated GPS loss mid-mission.
- **Action**: Lua script switched control from GPS-based navigation to sensor-based dead reckoning.
- **Outcome**: Drone returned within ~3 meters of home position under moderate sensor drift conditions.
- **Validation**: Verified through MAVProxy position logs and SITL map visualization.

---

## Project Demonstration

[![Dead Reckoning Demo](https://img.youtube.com/vi/pdFYwzBmNsg/0.jpg)](https://youtu.be/pdFYwzBmNsg)

> *Watch the UAV autonomously execute Return-to-Home under GPS-denied conditions using dead reckoning.*

**Highlights:**
- Simulated GPS loss during flight  
- Lua-based fallback navigation switching  
- Real-time estimation & RTL   

---

## Applications
- **GPS-Denied UAV Operations** – Urban, tunnel, or indoor navigation.
- **Autonomous Recovery Systems** – Safe fallback for GPS-compromised drones.
- **Military or Research Missions** – Reliable mission continuity in adversarial or obstructed environments.
- **Academic Simulation Studies** – Understanding sensor drift, integration errors, and autonomous fallback design.

---

## Advamatages
- **GPS Independence** – Enables autonomous navigation even without satellite signals.
- **Modular Implementation** – Written fully in Lua, can be deployed to any ArduPilot-based platform.
- **Lightweight and Fast** – Low CPU overhead on embedded flight controllers.
- **Scalable for Swarms** – Can be extended to multi-UAV cooperative dead reckoning.
- **Educational Value** – Excellent project to understand sensor fusion and error propagation.

---

## Summary
This project showcases an implementation of dead reckoning-based Return-to-Home (RTL) for UAVs under GPS-denied conditions.
By combining IMU, barometric, and magnetometer data, the drone estimates its position drift and autonomously returns home.
The system was tested in SITL simulation using ArduPilot and validated with MAVProxy visualization, achieving near-accurate home recovery with moderate drift.

This Lua-based system lays the groundwork for robust GPS-denied navigation in future UAV missions.

---

## Future Improvements
- Implement Kalman or Gaussian Sum Filter for better drift correction.
- Add sensor calibration routines for bias compensation.
- Extend 3D position estimation using integrated accelerometer and gyro data.
- Integrate with formation flight module for swarm-level dead reckoning.
- Test under hardware-in-the-loop (HIL) for real-flight validation.

---

## Tech Stack Summary
| Category | Tools/Components |
|------------|-----------|
| **Simulation** | ArduPilot SITL, MAVProxy |
| **Control Interface** | Lua Scripting |
| **Sensors Used** | IMU, Barometer, Magnetometer | 
| **Programming Languages** | Lua |
| **Operating System** | Ubuntu / Linux |

---

## Author
**Rishabh Singh Rawat**  
B.Tech Electronics Engineering (IoT)  
JC Bose Institute of Technology, YMCA  
Intern @ BotLab Dynamics | Ahuja Radios  


