# Exhibition milestone validation

Validated on 3 October 2026 with Godot **4.5 stable** Windows x64 (`876b29033`), building on `2d50da4`.

| Suite / check | Headless | Rendered at each target resolution |
| --- | --- | --- |
| Preserved independent energy core | 258 checks, 0 failures | 258 checks, 0 failures |
| Preserved prototype integration | 557 checks, 0 failures | 578 checks, 0 failures |
| Preserved guided demo | 171 checks, 0 failures | 180 checks, 0 failures |
| Extended management model | 127 checks, 0 failures | 127 checks, 0 failures |
| Actual exhibition scene/UI | 979 checks, 0 failures | 993 checks, 0 failures |
| Godot editor import / script load | Passed | — |
| Git whitespace check | Passed | — |

Rendered validation completed at **1920×1080**, **1366×768** and **1280×720** with the Compatibility renderer on AMD Radeon RX 5700 XT / OpenGL 3.3. Final normal-Windows runs had no script/runtime errors or resource-leak warnings. Sandbox certificate-store restrictions were avoided in final runs. Test AppData and captures are isolated under ignored `.tools/profile` and `artifacts/`.

## Coverage and preservation

The original energy model and its independent tests are unchanged. `legacy_regression.tscn` preserves the old scene/scenario and every existing prototype/tutorial assertion. `main.tscn` runs the new management UI; its separate suite exercises the actual extended scene rather than relying on the preserved scene to validate new features.

Extended tests cover all EV arrivals/departures and shutoff, revised visitor deadline, target failures, thermal power/comfort tradeoffs, an independent first thermal interval, wash window/pause/completion, clouds affecting real solar, paid/offline cleaning/recovery and late-cleaning failure, grid overload duration and task resolution, full event traversal, score service caps, baseline/reference feasibility and repeat determinism, ranking persistence/limits and audio preference persistence.

Independent accounting checks verify grid energy = consumption + battery charge − battery discharge − solar, and battery stored energy = initial + charge × 0.95 − discharge / 0.95. Controlled schedules including fractional-minute cleaning agree across large, minute, 0.1-minute, frame-sized and irregular partitions at 1e-6 tolerance. The original suite retains its tighter 1e-7 checks.

The actual-scene suite covers name validation, Demo/Normal selection/pacing, action-driven onboarding, real viewport clicks on task and scaled map, all result comparisons from real model runs, one leaderboard entry per completed session, score help, menu/settings, mute/unmute and effects routing, ambient disable from menu, important-event speed reduction, vehicle road paths/hiding, complete reset, and twelve consecutive completed sessions with bounded screen/audio node counts. Controls are routed through inspector handlers in the reactive playthrough.

## Playthroughs and visual review

One complete scripted reactive player plan starts the wash at 12:15, stores solar, cleans at 13:00, increases visitor charging on the 14:30 change and discharges during the grid window. It meets all services and scores **932**, with **€15.96 cost** and **44.0 kW peak**. The comparison reveals room to improve charging coordination even on a successful run.

Normal baseline calculates **€17.401874**, **96.225681 kWh import**, **22.5 kW peak**, two of three EV requirements, 100% comfort, completed wash, missed maintenance/grid requirements. Reference calculates **€10.581781**, **52.105435 kWh import**, **20.0 kW peak**, all services/tasks, 100% comfort and score **962**. These are computed, not constants in game code. The reference learns the surprise at the same scenario event as the player.

The suite also repeats unattended failed runs, reset during play, mute/ambient changes and menu transitions. Each capture run produces 14 exhibition screenshots plus 30 preserved regression captures. Intro, task list, cloud/HVAC, dirty/clean solar, revised EV deadline, grid challenge, comparison, score explanation, ranking and settings were visually reviewed across the target sizes. No remaining overlap/clipping was observed after the score-help fix.

Issues discovered and fixed during iteration: transient policy trial settings inflated peak measurements; urgent messages queued behind older hints; important events did not immediately reduce fast playback; menu ambient toggle could target a missing activity layer; loop/audio playback release needed explicit shutdown; score-help text overlapped its button. Added checks exercise the relevant behavior.

## Remaining on-device checks

- First-time human playtest: comprehension, difficulty and message pacing. Automated completion proves feasibility, not human understanding.
- Exhibition laptop: Windows scaling/fullscreen, pointer precision, sustained frame rate and speaker/headphone loudness over repeated play. Validation hardware is a desktop GPU; no weak-laptop performance claim is made.

No known functional blocker remains from automated/rendered validation. Thermal behavior, solar-use proxy and controller are illustrative approximations, documented in SCENARIO.md. No backend/network/hardware integration or standalone exported executable is included.
