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

### Tech Stack
- ArduPilot SITL (Software in the Loop)
- Lua Scripting
- MAVProxy
- Python (for simulation control)
- IMU, Barometer, Magnetometer

```mermaid
flowchart TD
    A[Start] --> B[Normal GPS Navigation]
    B -->|GPS Lost| C[Trigger Lua Script]
    C --> D[Read IMU, Barometer, Magnetometer]
    D --> E[Estimate Position via Dead Reckoning]
    E --> F[Compute Vector to Home]
    F --> G[Command RTL Mode]
    G --> H[Landing / Recovery]



### Code Snippet
```lua
-- Pseudo-section of Lua script
if gps:status() < 3 then
    local imu_data = ahrs:get_accel()
    local heading = ahrs:get_yaw()
    local alt = baro:get_pressure()
    -- Estimate displacement using IMU integration
    -- Calculate vector to home and trigger RTL
    vehicle:set_mode(6) -- RTL mode
end


