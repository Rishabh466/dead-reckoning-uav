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

## Lua Script Example

```lua
-- Dead Reckoning RTL Script (simplified)
local function update()
    if gps:status() < 3 then
        gcs:send_text(0, "⚠️ GPS signal lost, switching to dead reckoning...")
        local imu_data = ahrs:get_accel()
        local heading = ahrs:get_yaw()
        local altitude = baro:get_pressure()
        -- Compute displacement using IMU data (simplified)
        -- In actual implementation, integrate acceleration over time
        local dx, dy = imu_data:x() * math.cos(heading), imu_data:x() * math.sin(heading)
        -- Trigger RTL command
        vehicle:set_mode(6)
        gcs:send_text(0, "Executing RTL using Dead Reckoning")
    end
end

return update

