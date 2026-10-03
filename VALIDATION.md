# Guided demo validation

Validated on 3 October 2026 with official **Godot 4.5 stable** Windows x64 (`876b29033`), building on energy-core commit `1ce6b40`.

## Results

| Run | Result |
| --- | --- |
| Independent energy model suite | 258 checks, 0 failures |
| Headless scene regression | 557 checks, 0 failures |
| Headless guided demo suite | 171 checks, 0 failures |
| Rendered 1920×1080 scene / guided demo | 578 / 180 checks, 0 failures |
| Rendered 1366×768 scene / guided demo | 578 / 180 checks, 0 failures |
| Godot editor import / script load | Passed |
| Git whitespace check | Passed |

`Test-Prototype.ps1` runs the unchanged model suite, existing scene regression, then the new guided demo suite. Model coverage includes deterministic repeats, accurate integration, tariffs, battery behavior, EV limits/departure, pause/reset and full-day accounting. The energy model and its tests have no diff from `1ce6b40`.

Existing scene regression preserves start/name/mode flow, all nine object selections, inspector controls, actual battery/EV/grid effects, keyboard transport, HUD refresh, reset and placeholder exclusions. Its day-end assertion now expects results, and it skips onboarding because guidance has a separate suite.

The guided suite verifies intro and blocked map input, paused learning clock, action-driven steps, unrelated actions not advancing guidance, completion and both skip paths, persistent objective and nearest upcoming event. It checks actual success/failure SoC, zero charging after departure, moving vehicle on the road, disappearance beyond the site edge, empty-bay selection and actual frame animation. It also verifies all results against the model, frozen day-end state, complete Retry/reset restoration and Main Menu/name retention. Panel child bounds are checked.

Rendered runs save **30 captures per resolution** in ignored `artifacts/`: 21 existing scene captures and nine guided intro/action/departure/results captures. Representative screens were visually reviewed at 1920×1080 and 1366×768. Instructions fit, objectives remain visible, ready/missed feedback is prominent, bay 01 empties, the road reaches the right campus edge, and results/Retry/Menu fit without obvious clipping. Captures and scripted viewport interactions validate presentation and behavior; first-time human comprehension still needs a playtest.

Untouched full-day scenario still yields building **161 kWh**, solar **194.5 kWh**, import **28.988636 kWh**, export **34.488636 kWh**, cost **€6.028864**, peak import **11 kW**, battery **64%**, and successful EV departure at **80%**. Low throughout yields **58.25%** at departure and a missed requirement. Results label the local-supply percentage as an **instantaneous 18:00** measurement.

Rendering used an AMD Radeon RX 5700 XT with OpenGL 3.3 Compatibility. The map remains cached; departure animates one small drawn node for six real seconds, with no physics or pathfinding. The 60 FPS cap remains.

## Environment observations

Sandbox runs report Windows certificate-store access restrictions. Final editor import and all headless/rendered suites ran with normal Windows access and completed without these errors. AppData was redirected to ignored `.tools/profile`. No networking is used by the game.

## Remaining manual checks

- Play once as a new player: confirm the objective and charging/battery choices are understandable without outside explanation.
- Run on the intended exhibition laptop; verify text size, pointer targeting, Windows scaling, fullscreen/window resizing, keyboard focus and sustained FPS.
- Review the six-second cosmetic departure at the preferred simulation speed. It intentionally continues if the simulation clock is paused.

HVAC and EV 02/03 remain placeholders. There is no scoring, automated optimization, comparison baseline, random-event system, networking or hardware integration. No standalone exported executable is included; the local portable runtime is ignored by Git. Exact simulation assumptions remain in `SIMULATION.md`.
