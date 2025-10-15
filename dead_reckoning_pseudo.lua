-- Define system parameters
DR_ENABLE       = 1
DR_GPS_SACC_MAX = 0.8
DR_GPS_SAT_MIN  = 6
DR_ACCURACY_M   = 4
DR_NAV_SPEED    = 5

-- Define states
SystemState = {
    IDLE = 0,
    MONITORING = 1,
    YAW_ALIGN = 2,
    NAVIGATING = 3,
    PRECISION_APPROACH = 4,
    LANDING = 5
}
local state = SystemState.IDLE

-- Initialize variables
local gps_healthy = true
local home_location = nil
local last_good_gps = nil
local yaw = 0
local dt = 0.02

gcs:send_text(3, "Dead Reckoning v2.0 initialized")

-- MAIN UPDATE LOOP

function update()
    if DR_ENABLE == 0 then return update, 1000 end

    if not arming:is_armed() then
        state = SystemState.IDLE
        return update, 1000
    end

    yaw = math.deg(ahrs:get_yaw())

    gps_healthy = check_gps_health()
    if not gps_healthy then
        engage_dead_reckoning()
    end

    update_state_machine(dt)

    return update, 20
end

-- GPS HEALTH CHECK

function check_gps_health()
    local sats = gps:num_sats()
    local acc  = gps:speed_accuracy()
    local fix  = gps:status()

    if fix < 3 or sats < DR_GPS_SAT_MIN or acc > DR_GPS_SACC_MAX then
        return false
    end
    return true
end

-- STATE MACHINE

function update_state_machine(dt)
    if state == SystemState.IDLE then
        if not gps_healthy then
            vehicle:set_mode(20) -- GUIDED_NOGPS
            state = SystemState.YAW_ALIGN
            gcs:send_text(5, "GPS lost -> Dead Reckoning active")
        end

    elseif state == SystemState.YAW_ALIGN then
        local bearing = get_home_bearing()
        if align_yaw_to(bearing, dt) then
            state = SystemState.NAVIGATING
        end

    elseif state == SystemState.NAVIGATING then
        local dist, bearing = estimate_home_vector()
        local speed = calc_speed(dist)
        local climb = maintain_altitude()

        move_towards(bearing, speed, climb)

        if dist < DR_ACCURACY_M then
            state = SystemState.PRECISION_APPROACH
        end

    elseif state == SystemState.PRECISION_APPROACH then
        local dist = get_distance_to_home()
        if dist < 2.0 then
            state = SystemState.LANDING
            gcs:send_text(3, "Reached home, initiating landing")
        else
            precision_move(dist)
        end

    elseif state == SystemState.LANDING then
        if execute_landing() then
            state = SystemState.IDLE
            gcs:send_text(6, "Landing complete — system idle")
        end
    end
end

-- NAVIGATION HELPERS

function align_yaw_to(target_bearing, dt)
    local current_yaw = math.deg(ahrs:get_yaw())
    local diff = target_bearing - current_yaw
    if math.abs(diff) < 10 then
        return true
    else
        local new_yaw = current_yaw + diff * dt
        vehicle:set_target_angle_and_climbrate(0, 0, new_yaw, 0, false, 0)
        return false
    end
end

function estimate_home_vector()
    -- Use IMU/velocity data for dead reckoning
    local vn, ve, _ = ahrs:get_velocity_NED()
    position_north = position_north + vn * dt
    position_east  = position_east  + ve * dt
    local dist = math.sqrt(position_north^2 + position_east^2)
    local bearing = math.deg(math.atan2(position_east, position_north))
    return dist, bearing
end

function calc_speed(dist)
    if dist < 4 then
        return DR_NAV_SPEED * 0.2
    elseif dist < 20 then
        local f = (dist / 20)^2
        return DR_NAV_SPEED * f
    else
        return DR_NAV_SPEED
    end
end

function maintain_altitude()
    local alt = -ahrs:get_relative_position_D_home()
    local error = 5 - alt
    return math.max(-1, math.min(1, error * 0.3))
end

function precision_move(dist)
    local bearing = get_home_bearing()
    local speed = math.min(3.0, dist * 0.3)
    vehicle:set_target_angle_and_climbrate(0, -5, bearing, 0, false, 0)
end

function execute_landing()
    local alt = -ahrs:get_relative_position_D_home()
    if alt < 2.0 then
        vehicle:set_mode(9) -- LAND
        return true
    end
    vehicle:set_target_angle_and_climbrate(0, 0, yaw, -0.5, false, 0)
    return false
end

function get_home_bearing()
    local home = ahrs:get_home()
    local loc = ahrs:get_location()
    return loc:get_bearing(home)
end

-- System ready message

gcs:send_text(6, "DR v2.0 Pseudocode ready for execution")
return update
