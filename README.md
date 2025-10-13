# Dead Reckoning Navigation (GPS-Denied Return-to-Home)

### Overview
This project implements a **dead reckoning–based Return-to-Home (RTL)** system in ArduPilot using **Lua scripting**.  
The goal is to allow a UAV to navigate back to its launch position when GPS signal is lost.

### Concept
Dead reckoning estimates position by integrating IMU, barometer, and magnetometer data.  
When GPS data becomes unavailable, the UAV uses these onboard sensors to infer its position and perform RTL autonomously.

### Approach
1. **GPS Loss Detection** – Lua script monitors GPS health using ArduPilot parameters (`gpsstatus`, `gpshdop`).  
2. **Fallback Navigation** – On detecting GPS loss, the system switches to dead reckoning mode.  
3. **Sensor Fusion** – Position and heading are estimated from IMU acceleration, barometric altitude, and magnetometer yaw.  
4. **Return Command** – Estimated offset from home is used to compute vector heading and trigger RTL.  


