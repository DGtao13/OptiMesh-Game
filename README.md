# OptiMesh Game

First playable **Godot 4.5+** desktop visual-interaction prototype. This is a separate game project; it does not integrate with OptiMesh hardware or cloud services.

## Run

Import `project.godot` in the standard Godot editor and press **F6** on `scenes/main.tscn`, or **F5** to run the project. No .NET version, addons, export templates or external assets are needed.

On this workstation, the official portable Godot 4.5 runtime is already available in the ignored `.tools/godot` directory:

```powershell
.\run.ps1
.\run.ps1 -Fullscreen
```

On another machine, download [standard Godot 4.5 or newer](https://godotengine.org/download/archive/4.5-stable/) and import the project, or use:

```powershell
.\run.ps1 -GodotPath 'C:\Tools\Godot.exe'
```

The portable runtime is **not** part of Git. The launcher also accepts `GODOT_PATH` or `godot` on PATH. If PowerShell blocks local scripts, run `powershell -ExecutionPolicy Bypass -File .\run.ps1` for this launch only.

## Play

1. New Game → enter a nonempty name (maximum 24 characters) → Continue.
2. Choose **Demo Mode**. Normal Mode is visibly disabled.
3. Click the building, rooftop solar, HVAC, inverter, battery, grid, or any of the three EV bays. Equipment labels are also clickable; the EV group label describes the bays below it.
4. The selected system gains an outline and an inspector. Select control intent and switch between objects; settings persist for the current demo session.
5. Pause/resume, choose **1× / 5× / 15×**, or reset the office clock. At 1×, one real second advances one simulated minute. The day runs from 08:00 to 18:00 and then pauses.

Keyboard shortcuts in Demo Mode: **Space** pause/resume; **1 / 2 / 3** speed; **Esc** close inspector; **F11** toggle fullscreen. Buttons support standard keyboard focus. Starting a new demo resets clock and object settings. Returning to the menu retains the entered name.

## Scope and structure

| File | Responsibility |
| --- | --- |
| `project.godot` | Main scene, 1920×1080 logical canvas, 1280×720 initial window, Compatibility renderer |
| `scenes/main.tscn` | Root scene |
| `scripts/main.gd` | Start/name/mode flow, HUD, inspector, control intent and accelerated clock |
| `scripts/site_map.gd` | Fixed vector campus, hover/selection outlines and polygon mouse picking |
| `scripts/site_catalog.gd` | Static demonstration object readings and default control settings |
| `tests/prototype_test.gd` | Scene integration, button routing, picking, intent persistence and clock checks; optional viewport screenshots |
| `run.ps1` | Local game launcher |
| `Test-Prototype.ps1` | Local validation launcher |
| `VALIDATION.md` | Recorded validation and remaining manual checks |
| `.gitignore` | Excludes runtime, import cache and generated captures |

The `.gd.uid` files are Godot's stable script identifiers and are kept with their scripts. No third-party art is used. The isometric-inspired map uses cached 2D draw calls; redraw happens on hover/selection, with no textures, physics, particles or shaders. Rendering is capped at 60 FPS, and HUD text refreshes five times per second. The fixed canvas scales uniformly and letterboxes other aspect ratios.

Energy values, tariff, self-supply, occupancy and upcoming EV departure are **illustrative constants**. Control buttons change selected intent and visible feedback; they do not affect readings or vehicle charge. There is no simulation, scoring, optimization, save system, scenario engine, networking or hardware integration. The clock is the only evolving game state. Live FPS is an actual runtime measurement; the site snapshot is a demo metric. Opti supplies simple contextual messages, with no assistant service.

The catalog, map and UI are separated so a later milestone can connect a simulation without replacing the scene or interaction design. This milestone deliberately avoids empty frameworks for future systems.

## Validate

```powershell
.\Test-Prototype.ps1
.\Test-Prototype.ps1 -Capture -Resolution 1920x1080
.\Test-Prototype.ps1 -Capture -Resolution 1366x768
.\Test-Prototype.ps1 -Capture -Resolution 1280x720
```

Use `-GodotPath` if the ignored runtime is absent. Capture mode launches real rendered windows, exercises the scene, saves PNGs to `artifacts/`, and exits. The tests directly exercise scene signals and polygon input and also dispatch real viewport mouse events. They are not a substitute for testing the intended exhibition laptop. Godot's [command-line documentation](https://docs.godotengine.org/en/4.5/tutorials/editor/command_line_tutorial.html) describes the underlying launch options.
