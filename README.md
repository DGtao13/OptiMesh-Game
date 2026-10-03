# OptiMesh Game

Standalone local **Godot 4.5+** office management game. Demo and Normal Mode share one deterministic 08:00–18:00 challenge. No backend, account, hardware connection or external assets are required.

## Launch

On this workstation use `./run.ps1` (or `./run.ps1 -Fullscreen`). The ignored `.tools/godot` directory contains the standard portable Godot runtime. Elsewhere import `project.godot` in standard Godot 4.5+ and press F5, or pass `-GodotPath C:\Tools\Godot.exe` to the launcher. No .NET, addons or export templates are needed. No standalone export is bundled.

## Play

New Game → name → Demo or Normal. **Demo** advances 1.25 simulated minutes per real second: eight minutes of clock time, plus onboarding/pauses. **Normal** advances 0.5: twenty minutes, plus pauses. Both use the same fair scenario, score and comparisons.

Opti introduces the site, EV charging, battery and tariff planning. The clock waits during learning; Continue and Skip are available. Afterward, Opti announces arrivals, weather, maintenance, changed deadlines and the grid challenge, acknowledges resolved tasks, and warns about heat/overload. Important events return accelerated playback to 1× so players can read and react.

- Click a **task in the deadline ribbon** to open its controls; hover for its description. **All tasks** opens history, including completed/missed tasks. Selecting equipment closes the drawer.
- Click equipment or its map label for a contextual inspector. All three EVs, climate, battery, solar cleaning and the equipment wash affect real simulation state. The wash has its own map object and label. Close the inspector with × or Esc to see the whole site.
- Opti's current tip offers **Open [equipment]**. Got it acknowledges only that tip. Quiet tips collapse after 18 seconds; the small Opti chip brings the message back. New events reopen it. **Recent notes** pauses the day to reread the last six delivered events; closing it restores the previous pause state.
- Meet EV departure targets, keep rooms comfortable, complete the wash/cleaning and manage the temporary grid limit. Lower cost/peak helps, but cannot compensate for abandoned services.
- Pause/resume; choose 1× / 5× / 15×. Space toggles pause, 1/2/3 set speed, Esc closes the inspector (or skips the intro), F11 toggles fullscreen.
- Settings provides music/effects percentages, a **Test sound** preview, mute and reduced ambient visuals. These persist locally.
- Reset Day restarts the scenario and onboarding. At 18:00 see actual Normal / Player / OptiMesh demo results, score, rank and missed requirements. Play Again resets the full run; Main Menu retains the name.

The leaderboard is local to this laptop, holds the top 50 runs and shows the top ten. Administrator reset: on that screen press **Ctrl+Shift+Delete**, then confirm. No network synchronization is implemented.

## Systems and files

| Area | Files |
| --- | --- |
| Playable scene/UI | `scenes/main.tscn`, `scripts/management_game.gd` |
| Scenario, tasks and extended model | `scripts/demo_scenario.gd`, `scripts/management_simulation.gd` |
| Comparison policies | `scripts/reference_runs.gd` |
| Local ranking/settings | `scripts/local_store.gd` |
| Original synthesized sound | `scripts/game_audio.gd` |
| Vector world / activity / companion | `scripts/site_map.gd`, `scripts/site_activity.gd`, `scripts/opti_face.gd` |
| Preserved foundation | `scripts/energy_simulation.gd`, `scripts/main.gd`, `scripts/site_catalog.gd`, `scripts/demo_guidance.gd` |
| Preserved regression scene | `scenes/legacy_regression.tscn` |
| Tests | `tests/energy_simulation_test.gd`, `tests/prototype_test.gd`, `tests/demo_loop_test.gd`, `tests/management_test.gd`, `tests/exhibition_test.gd`, `tests/playstyle_test.gd`, `tests/polish_test.gd` |

The new playable scene extends the previous UI and deterministic core. The legacy scene preserves every old assertion against its original scenario, including independent integration expectations. New model and real-scene suites cover the expanded exhibition game. `.gd.uid` files are stable script IDs.

See **SCENARIO.md** for exact assumptions, timeline, scoring, policies and storage; **SIMULATION.md** specifies the legacy core; **AUDIO.md** explains original audio generation; **VALIDATION.md** records runs and remaining hardware checks.

## Performance and validation

Compatibility renderer, 1920×1080 logical canvas with uniform scaling/letterboxing, 60 FPS cap. Static campus drawing remains cached; one small activity layer redraws at 20 Hz. HUD/tasks update at 5 Hz. Bounded vector cars/people/clouds/birds, no physics, pathfinding, heavy textures, particles or lighting shaders. Disable ambient people/clouds/birds in Settings on slower machines; weather still affects real solar output.

```powershell
./Test-Prototype.ps1
./Test-Prototype.ps1 -Capture -Resolution 1920x1080
./Test-Prototype.ps1 -Capture -Resolution 1366x768
./Test-Prototype.ps1 -Capture -Resolution 1280x720
```

Each run executes all seven suites. Captures go to ignored `artifacts/`. Exhibition tests isolate their leaderboard/preferences from real players and exercise a full reactive plan, failed unattended runs, UI containment, retry/menu, sound settings and repeated sessions. The playstyle suite executes ten complete Demo strategies plus the strong strategy in Normal Mode, with audio enabled, a message/results journal and nine rendered moments per strategy. See **POLISH_REVIEW.md** for the current pass's direct desktop sessions, issue log and outcomes; **PLAYTEST.md** preserves the earlier pass as historical context. Real exhibition-laptop scaling, sustained frame rate, speaker volume and first-time human comprehension still need an on-device playtest.
