# Energy core validation

Validated on 3 October 2026 with official **Godot 4.5 stable** Windows x64 (`876b29033`), building on the clean visual-polish commit `6a39a71`.

## Results

| Run | Result |
| --- | --- |
| Independent energy model suite | 258 checks, 0 failures |
| Headless scene regression | 557 checks, 0 failures |
| Rendered 1920×1080 scene regression | 578 checks, 0 failures |
| Rendered 1366×768 scene regression | 578 checks, 0 failures |
| Godot editor import / script load | Passed |

`Test-Prototype.ps1` runs model tests before scene regression in both headless and capture modes. The model suite covers deterministic repeats, clock/pause, representative curves/tariffs, exact power balance, import/export zero crossings, cumulative energy and cost, battery intents/efficiency/bounds, EV powers/limits/target/100% bound, ETA, successful/missed departure, reset and day-end preservation. Identical timed control schedules are compared with large, minute, 0.25/0.1 minute, 1/60 minute and irregular subdivisions at 1e-7 absolute tolerance. Full-day totals are checked against independent hand integration.

A 60 FPS-sized subdivision test exposed a near-boundary tariff rounding issue. Boundary handling was fixed, and an explicit regression check confirms that a frame ending just below 15:00 does not price the next frame at the midday tariff.

Scene tests preserve the complete start → name → Demo flow, name validation, disabled Normal Mode, all nine object selections and highlights, every inspector control, keyboard pause/speed, menu return and new-demo reset. Additional checks verify real battery/grid effects, EV/grid effects, changing SoC/HUD/inspector values, ETA, missed departure, tariff evolution, complete Reset Day restoration, and exclusion of placeholder HVAC/EV 02 controls from the model. The actual frame callback runs at 15× during a timed check; HUD/inspector values update and pause freezes both time and energy. Inspector containment is checked, and real viewport mouse events activate New Game, select the battery and press Charge.

Rendered runs save **21 captures per resolution** under ignored `artifacts/`: start-flow screens, every inspector, day end, charging/discharging battery, charging/departed EV, afternoon grid metrics and the running clock. Representative screenshots were visually inspected at 1920×1080 and 1366×768. EV 01 uses six compact reading rows in the same inspector; the map, HUD card positions and previous visual polish are preserved. No obvious clipping was observed.

Default untouched scenario totals validated at 18:00: building **161 kWh**, solar **194.5 kWh**, grid import **28.988636 kWh**, grid export **34.488636 kWh**, bill **€6.028864**, peak import **11 kW**, battery **64%**, EV **80%** with successful 12:30 departure.

Rendering used an AMD Radeon RX 5700 XT with OpenGL 3.3 Compatibility. This validates the scene and simulation integration, not weak-laptop performance. The application retains the 60 FPS cap, static cached map and lightweight drawing.

## Environment observations

The restricted execution sandbox initially blocked Godot's standard AppData directories and Windows certificate-store access. Validation redirected AppData into ignored `.tools/profile`. A subsequent unrestricted rendered run and editor import completed without those environment errors. The game itself uses no networking or certificate-dependent features.

## Remaining manual checks

- Run `run.ps1` or import `project.godot` and press F5 on the actual exhibition laptop. Check text size, pointer targeting, Windows display scaling and sustained FPS on that hardware.
- Try fullscreen (`run.ps1 -Fullscreen`, or F11 in Demo Mode), window resize and keyboard focus with the intended display configuration.
- Review the visual direction and placement for the next artwork milestone.

Review the illustrative curves/tariff/efficiencies for the next scenario-design milestone. Exact assumptions and deliberate limitations are in `SIMULATION.md`; no scoring, events, optimization, multiple simulated EVs or hardware/backend integration has been started. No standalone exported executable is included; the portable runtime is local and ignored by Git.
