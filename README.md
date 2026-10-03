# OptiMesh Game

**Godot 4.5+** desktop office energy demo with a deterministic simulation core. This is a separate game project; it does not integrate with OptiMesh hardware or cloud services.

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
3. Continue through Opti's introduction, or **Skip tutorial**. The clock waits while you inspect the site, choose an EV 01 charging mode, try a battery mode, and acknowledge price planning. Relevant actions advance the guide; you can skip any remaining step.
4. The selected system gains an outline and a live inspector. Battery **Charge / Hold / Discharge** and EV 01 **Pause / Low / Normal / Fast** now affect actual energy and grid flow. Settings persist when switching selection.
5. Get EV 01 to **80% before 12:30**, while keeping cost and grid peak low. Click objects or their equipment labels to inspect them. The persistent objective and Upcoming area track the requirement and nearest tariff/departure events.
6. Pause/resume or choose **1× / 5× / 15×**. At 1×, one real second advances one simulated minute. At 12:30, EV 01 leaves with clear success/failure feedback and its actual departure SoC. Its bay stays empty.
7. At **18:00**, review your actual results, then choose **Play Again** or **Main Menu**. Play Again restores the full scenario and introduction. **Reset Day** during play restores the scenario, vehicle, controls and 1× speed without repeating completed guidance.

Keyboard shortcuts in Demo Mode: **Space** pause/resume; **1 / 2 / 3** speed; **Esc** close inspector; **F11** toggle fullscreen. Buttons support standard keyboard focus. Starting a new demo resets clock and object settings. Returning to the menu retains the entered name.

## Scope and structure

| File | Responsibility |
| --- | --- |
| `project.godot` | Main scene, 1920×1080 logical canvas, 1280×720 initial window, Compatibility renderer |
| `scenes/main.tscn` | Root scene |
| `scripts/main.gd` | Start/name/mode flow, speed/pause inputs and UI observing simulation state |
| `scripts/demo_guidance.gd` | Small action-driven tutorial state and instructions |
| `scripts/energy_simulation.gd` | Deterministic time, profiles, tariff, grid accounting, battery and EV 01 |
| `scripts/site_map.gd` | Vector campus, guided/selected outlines, polygon picking and lightweight EV departure |
| `scripts/site_catalog.gd` | Presentation metadata, default buttons and explicitly marked placeholder readings |
| `tests/energy_simulation_test.gd` | Independent accounting expectations, equipment bounds, departure, reset and timestep tests |
| `tests/prototype_test.gd` | Scene integration, button routing, picking, intent persistence and clock checks; optional viewport screenshots |
| `tests/demo_loop_test.gd` | Tutorial, departure animation/feedback, actual results, retry/menu and layout checks |
| `run.ps1` | Local game launcher |
| `Test-Prototype.ps1` | Local validation launcher |
| `VALIDATION.md` | Recorded validation and remaining manual checks |
| `SIMULATION.md` | Exact scenario assumptions, units, integration and metric definitions |
| `.gitignore` | Excludes runtime, import cache and generated captures |

The `.gd.uid` files are Godot's stable script identifiers and are kept with their scripts. No third-party art is used. The isometric-inspired map uses cached 2D draw calls, with no textures, physics, particles or shaders. EV departure moves one small drawn node for six real seconds, independently of simulation speed/pause. Rendering is capped at 60 FPS, and HUD text refreshes five times per second. The fixed canvas scales uniformly and letterboxes other aspect ratios.

Building demand, solar generation, import price, grid import/export, cumulative energy/cost, battery state and EV 01 are now simulated. HUD/inspectors observe that state and refresh five times per second; control actions refresh immediately. The site snapshot shows the actual instantaneous local supply share, and live FPS is a runtime measurement. The EV departure area shows the connected/departed status and whether the target was missed.

HVAC and EV 02/03 remain explicitly marked placeholders and do not alter demand. The other existing inspector buttons select presentation intent only; they do not implement forecasting, diagnostics or schedules. Opti supplies deterministic tutorial instructions and occasional contextual messages, with no assistant service. Results show only the player's actual run; local supply is explicitly an instantaneous 18:00 reading. There is no scoring, automated optimization, comparison baseline, random-event engine, persistence, networking or hardware integration.

The model is an independent Godot `RefCounted` object with no scene/UI dependency. Its profiles and configuration are documented in [SIMULATION.md](SIMULATION.md). This milestone deliberately avoids frameworks for future systems.

## Validate

```powershell
.\Test-Prototype.ps1
.\Test-Prototype.ps1 -Capture -Resolution 1920x1080
.\Test-Prototype.ps1 -Capture -Resolution 1366x768
.\Test-Prototype.ps1 -Capture -Resolution 1280x720
```

Use `-GodotPath` if the ignored runtime is absent. Every run first executes model tests, then scene regression and guided demo tests. Capture mode launches real rendered windows, exercises the scene, saves PNGs to `artifacts/`, and exits. Tests also exercise real viewport mouse events and the actual frame callback/HUD refresh. They are not a substitute for testing the intended exhibition laptop. Godot's [command-line documentation](https://docs.godotengine.org/en/4.5/tutorials/editor/command_line_tutorial.html) describes the underlying launch options.
