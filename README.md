# DRC DynaCam

A custom dynamic cinematic chase camera built for RP.
Inspired by Assetto Corsa's DynaCam mod — adds motion, speed sensation,
and impact feedback to GTA V's default chase camera.

## Features

- **Dynamic FOV** — widens at speed for increased sense of velocity
- **Camera lean** — swings out on turns based on angular velocity
- **Pitch lean** — tilts subtly during acceleration/braking for added weight
- **Impact shake** — screen shakes on crashes and hard landings
- **Per-player toggle** — each player can enable/disable with a keybind
- **Vehicle class filtering** — disabled for planes, helis, boats, trains
- **drc_notify integration** — standardized notifications

## Installation

1. Drop the `drc_dynacam` folder into your `resources/[scripts]/` directory
2. Add to `server.cfg`:
   ```
   ensure drc_dynacam
   ```
3. Restart your server (or `refresh` + `ensure drc_dynacam` via txAdmin console)

**Dependency:** `drc_notify` must be running (you already have this).

## Usage

- **Toggle with keybind:** Default is `F7` (players can rebind via FiveM Settings → Key Bindings → FiveM)
- **Toggle with command:** Type `/dynacam` in chat

## Tuning

All parameters live in `config.lua` with inline comments.
Key values to experiment with:

| Parameter | What it does | Try |
|-----------|--------------|-----|
| `CameraDistance` | How far behind the car | 5.0 – 8.0 |
| `CameraHeight` | How high above the car | 1.5 – 3.0 |
| `BaseFOV` / `MaxFOV` | FOV at rest / top speed | 65/85 subtle, 70/95 aggressive |
| `LeanStrength` | How hard the cam swings on turns | 0.3 = subtle, 0.6 = drift-cam |
| `MaxLeanAngle` | Cap on lean degrees | 12° conservative, 25° arcade |
| `LeanSmoothing` | Lean responsiveness | 0.05 floaty, 0.15 snappy |
| `ImpactThreshold` | Sensitivity to bumps | 4.0 sensitive, 8.0 only big hits |
| `ImpactIntensity` | Shake strength | 0.8 light, 1.5 heavy |

After tweaking `config.lua`, just `restart drc_dynacam` in the console.
No server restart needed.

## Compatibility

- Works with QBCore (tested) and standalone
- Only depends on `drc_notify`
- Does not conflict with standard vehicle scripts
- Automatically disables for aircraft and boats

## Known Limitations

- Only applies to the driver (passengers get vanilla cam)
- May feel different inside tunnels/interiors — this is expected
- Third-person only. First-person view uses vanilla GTA cam.

## Toggling Default State

If you want the camera **on by default** for all players, set in `config.lua`:
```lua
Config.EnabledByDefault = true
```

---

Built for DRILL CITY RP
