-- ====================================================================
-- DRC DYNACAM - Client
-- Dynamic cinematic chase camera for vehicles
-- ====================================================================

local cameraActive = false
local cam = nil

-- Smoothed state values
local currentFOV = Config.BaseFOV
local currentLeanYaw = 0.0
local currentLeanPitch = 0.0
local lastVelocity = vector3(0.0, 0.0, 0.0)

-- Impact shake state
local shakeEndTime = 0
local currentShakeAmp = 0.0

-- ====================================================================
-- HELPERS
-- ====================================================================

local function SendNotification(data)
    if not Config.Notifications.Enabled then return end
    exports['drc_notify']:SendNotification({
        title = data.title,
        message = data.message,
        type = data.type,
        duration = Config.Notifications.Duration
    })
end

local function Lerp(a, b, t)
    return a + (b - a) * t
end

local function Clamp(val, min, max)
    if val < min then return min end
    if val > max then return max end
    return val
end

local function IsVehicleAllowed(vehicle)
    if not vehicle or vehicle == 0 then return false end
    local class = GetVehicleClass(vehicle)
    return not Config.DisabledVehicleClasses[class]
end

-- ====================================================================
-- CAMERA CREATE / DESTROY
-- ====================================================================

local function CreateDynaCam()
    if cam then return end
    cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamFov(cam, Config.BaseFOV)
    RenderScriptCams(true, false, 0, true, false)
    currentFOV = Config.BaseFOV
    currentLeanYaw = 0.0
    currentLeanPitch = 0.0
    shakeEndTime = 0
    currentShakeAmp = 0.0
end

local function DestroyDynaCam()
    if not cam then return end
    RenderScriptCams(false, false, 0, true, false)
    DestroyCam(cam, false)
    cam = nil
end

-- ====================================================================
-- TOGGLE
-- ====================================================================

local function ToggleCamera()
    cameraActive = not cameraActive
    if cameraActive then
        SendNotification(Config.Notifications.OnEnable)
    else
        DestroyDynaCam()
        SendNotification(Config.Notifications.OnDisable)
    end
end

RegisterCommand(Config.ToggleCommand, function()
    ToggleCamera()
end, false)

RegisterKeyMapping(Config.ToggleCommand, 'Toggle DynaCam', 'keyboard', Config.ToggleKey)

-- ====================================================================
-- MAIN LOOP
-- ====================================================================

CreateThread(function()
    if Config.EnabledByDefault then
        cameraActive = true
    end

    while true do
        Wait(0)

        if not cameraActive then
            if cam then DestroyDynaCam() end
            Wait(500)
            goto continue
        end

        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)

        -- Not in a vehicle or vehicle type disabled: drop the cam
        if vehicle == 0 or not IsVehicleAllowed(vehicle) or GetPedInVehicleSeat(vehicle, -1) ~= ped then
            if cam then DestroyDynaCam() end
            Wait(250)
            goto continue
        end

        -- Create cam if needed
        if not cam then CreateDynaCam() end

        -- ============================================================
        -- GATHER VEHICLE DATA
        -- ============================================================
        local vehCoords = GetEntityCoords(vehicle)
        local vehHeading = GetEntityHeading(vehicle)
        local vehRot = GetEntityRotation(vehicle, 2)
        local velocity = GetEntityVelocity(vehicle)
        local speed = #velocity  -- magnitude in m/s

        -- Angular velocity (rotation around Z axis = yaw rate)
        -- Positive = turning left, Negative = turning right
        local rotVelocity = GetEntityRotationVelocity(vehicle)
        local yawRate = rotVelocity.z

        -- Acceleration delta (for pitch lean + impact detection)
        local accel = velocity - lastVelocity
        lastVelocity = velocity
        local accelMagnitude = #accel

        -- ============================================================
        -- DYNAMIC FOV
        -- ============================================================
        local speedRatio = Clamp(speed / Config.FOVMaxSpeed, 0.0, 1.0)
        local targetFOV = Lerp(Config.BaseFOV, Config.MaxFOV, speedRatio)
        currentFOV = Lerp(currentFOV, targetFOV, Config.FOVSmoothing)

        -- ============================================================
        -- CAMERA LEAN (yaw swing based on angular velocity)
        -- ============================================================
        local targetLeanYaw = yawRate * Config.LeanStrength * 57.2958  -- rad/s to deg
        targetLeanYaw = Clamp(targetLeanYaw, -Config.MaxLeanAngle, Config.MaxLeanAngle)
        currentLeanYaw = Lerp(currentLeanYaw, targetLeanYaw, Config.LeanSmoothing)

        -- Pitch lean from acceleration (forward accel = cam tilts down slightly)
        -- Dot product of accel with forward vector to get longitudinal accel
        local forwardVec = GetEntityForwardVector(vehicle)
        local longAccel = accel.x * forwardVec.x + accel.y * forwardVec.y
        local targetLeanPitch = -longAccel * Config.PitchLeanStrength
        targetLeanPitch = Clamp(targetLeanPitch, -8.0, 8.0)
        currentLeanPitch = Lerp(currentLeanPitch, targetLeanPitch, Config.LeanSmoothing)

        -- ============================================================
        -- IMPACT SHAKE
        -- ============================================================
        if Config.ImpactShakeEnabled and accelMagnitude > Config.ImpactThreshold then
            local shakeStrength = Clamp(
                (accelMagnitude - Config.ImpactThreshold) * Config.ImpactIntensity * 0.15,
                0.0,
                Config.MaxShakeAmplitude
            )
            if shakeStrength > currentShakeAmp then
                currentShakeAmp = shakeStrength
                shakeEndTime = GetGameTimer() + Config.ShakeDuration
            end
        end

        -- Decay shake over time
        local shakeOffsetX, shakeOffsetY, shakeOffsetZ = 0.0, 0.0, 0.0
        if GetGameTimer() < shakeEndTime and currentShakeAmp > 0.01 then
            local remaining = (shakeEndTime - GetGameTimer()) / Config.ShakeDuration
            local amp = currentShakeAmp * remaining
            shakeOffsetX = (math.random() - 0.5) * amp * 0.1
            shakeOffsetY = (math.random() - 0.5) * amp * 0.1
            shakeOffsetZ = (math.random() - 0.5) * amp * 0.1
        else
            currentShakeAmp = 0.0
        end

        -- ============================================================
        -- CALCULATE CAMERA POSITION
        -- ============================================================
        -- Base heading with lean applied
        local effectiveHeading = vehHeading + currentLeanYaw
        local headingRad = math.rad(effectiveHeading)

        -- Position camera behind vehicle based on effective heading
        local offsetX = math.sin(headingRad) * Config.CameraDistance
        local offsetY = -math.cos(headingRad) * Config.CameraDistance

        local camX = vehCoords.x + offsetX + shakeOffsetX
        local camY = vehCoords.y + offsetY + shakeOffsetY
        local camZ = vehCoords.z + Config.CameraHeight + shakeOffsetZ

        -- ============================================================
        -- APPLY CAMERA
        -- ============================================================
        SetCamCoord(cam, camX, camY, camZ)
        PointCamAtEntity(cam, vehicle, 0.0, 0.0, 0.8, true)

        -- Apply pitch lean on top of look-at (small rotation offset)
        local currentCamRot = GetCamRot(cam, 2)
        SetCamRot(cam,
            currentCamRot.x + Config.CameraPitch + currentLeanPitch,
            currentCamRot.y,
            currentCamRot.z,
            2
        )

        SetCamFov(cam, currentFOV)

        ::continue::
    end
end)

-- ====================================================================
-- CLEANUP ON RESOURCE STOP
-- ====================================================================

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        if cam then
            RenderScriptCams(false, false, 0, true, false)
            DestroyCam(cam, false)
            cam = nil
        end
    end
end)
