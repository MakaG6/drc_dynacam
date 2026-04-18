Config = {}

-- ====================================================================
-- DRC DYNACAM - Dynamic Cinematic Chase Camera
-- ====================================================================
-- All values can be tuned live. Restart the resource after changes.
-- ====================================================================

-- Enable the camera on resource start, or require players to toggle it
Config.EnabledByDefault = false

-- Keybind to toggle camera on/off (FiveM keybind string)
-- See: https://docs.fivem.net/docs/game-references/controls/
Config.ToggleKey = 'F7'

-- Command to toggle camera (alternative to keybind)
Config.ToggleCommand = 'dynacam'

-- ====================================================================
-- CAMERA POSITION
-- ====================================================================

-- Distance behind the vehicle (meters)
Config.CameraDistance = 5.0

-- Height above the vehicle (meters)
Config.CameraHeight = 1.50

-- How much the camera looks down at the car (degrees, negative = looks down)
Config.CameraPitch = -7.0

-- ====================================================================
-- FIELD OF VIEW
-- ====================================================================

-- Base FOV when stationary
Config.BaseFOV = 50.0

-- Maximum FOV at top speed (higher = more speed sensation)
Config.MaxFOV = 90.0

-- Speed (m/s) at which max FOV kicks in (30 m/s = ~108 km/h, ~67 mph)
Config.FOVMaxSpeed = 40.0

-- How smoothly FOV changes (0.01 = very smooth, 0.2 = snappy)
Config.FOVSmoothing = 0.04

-- ====================================================================
-- CAMERA LEAN / TURN RESPONSE
-- ====================================================================

-- How much the camera swings out on turns (0 = no lean, 1 = aggressive)
Config.LeanStrength = 0.00

-- Max lean angle in degrees
Config.MaxLeanAngle = 18.0

-- How smoothly lean interpolates (0.01 = very smooth, 0.3 = snappy)
Config.LeanSmoothing = 0.08

-- How much the camera pitches up/down based on acceleration
-- (car feels weightier when accelerating/braking)
Config.PitchLeanStrength = 0.25

-- ====================================================================
-- IMPACT SHAKE
-- ====================================================================

-- Enable impact shake on crashes
Config.ImpactShakeEnabled = true

-- Delta-velocity (m/s) in one frame required to trigger shake
-- Lower = more sensitive (fires on smaller bumps)
Config.ImpactThreshold = 6.0

-- Shake intensity multiplier
Config.ImpactIntensity = 1.2

-- Max shake amplitude regardless of impact strength
Config.MaxShakeAmplitude = 2.5

-- How long shake lasts (milliseconds)
Config.ShakeDuration = 600

-- ====================================================================
-- VEHICLE TYPE FILTERS
-- ====================================================================

-- Vehicle classes where camera is disabled
-- 14=Boats, 15=Helicopters, 16=Planes, 21=Trains
Config.DisabledVehicleClasses = {
    [14] = true,
    [15] = true,
    [16] = true,
    [21] = true,
}

-- ====================================================================
-- NOTIFICATIONS (uses drc_notify)
-- ====================================================================

Config.Notifications = {
    Enabled = true,
    Duration = 2500,
    OnEnable = {
        title = 'DynaCam',
        message = 'Cinematic camera enabled',
        type = 'success'
    },
    OnDisable = {
        title = 'DynaCam',
        message = 'Cinematic camera disabled',
        type = 'info'
    },
}
