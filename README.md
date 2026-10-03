# OptiMesh Game

The standalone interactive energy-management game and exhibition demo for **OptiMesh**, built with **Godot 4.5+**. Manage an office site through a simulated working day and see how coordinated energy decisions affect cost, power peaks and service quality.

The main OptiMesh platform is developed separately at [Praz40/OptiMesh](https://github.com/Praz40/OptiMesh), which contains the dashboard, backend, firmware, documentation and **OptiMesh Web Simulator**. This repository contains **OptiMesh Game**, the standalone Godot game. The Web Simulator is the browser simulator in the main platform repository.

## What you manage

Balance rooftop solar, battery storage, three EV chargers, HVAC comfort and an equipment wash against electricity prices and temporary grid constraints. Clouds, dirty panels, vehicle arrivals and a changed departure deadline create decisions throughout the day. The **Opti companion** introduces the site, highlights risks and forecasts, and explains consequences; recent notes let you reread delivered events.

- **Demo Mode:** approximately eight minutes of running clock time, plus onboarding and pauses; intended for exhibition visitors.
- **Normal Mode:** approximately twenty minutes, plus pauses; the same scenario with more time to plan.
- **Score and local leaderboard:** up to 1000 points for services and efficiency, with serious service failures reducing the score. Rankings are stored locally on the machine.
- **Results:** compare actual simulated **Normal operation**, **Player** and **OptiMesh demo reference** runs. The reference is an illustrative offline controller; it is not the production OptiMesh optimizer.

The game runs locally without accounts, a backend or hardware connections. Audio is original and synthesized; the site uses lightweight vector drawing and Godot's Compatibility renderer.

## Run with Godot

1. Install the standard **Godot 4.5+** editor; the .NET edition is not required.
2. Clone or download this repository.
3. In Godot's Project Manager, select **Import** and open `project.godot`.
4. Open the project and press **F5** to run the main scene.

No addons or export templates are needed to play from the editor. Exported executables and the Godot runtime are not bundled in this repository.

On Windows, the optional launcher accepts an installed executable:

```powershell
./run.ps1 -GodotPath 'C:\Tools\Godot.exe'
./run.ps1 -GodotPath 'C:\Tools\Godot.exe' -Fullscreen
```

The launcher also checks `GODOT_PATH`, `godot` on PATH, or an optional local runtime in ignored `.tools/godot/`.

## Play

Choose **New Game**, enter a name, then select Demo or Normal. The tutorial pauses time and can be skipped. Click a task in the deadline ribbon or equipment on the site to open its controls. **All tasks** includes completed and missed requirements. Opti offers a button to open the relevant equipment, and **Recent notes** pauses the day for rereading.

Meet EV targets before departure, keep the office comfortable, complete maintenance and the wash, and manage the grid challenge. The inspector shows power, deadlines, ETAs and the effects of your choices. Important events return fast-forward to 1× to give you time to react.

| Control | Action |
|---|---|
| Space | Pause / resume |
| 1 / 2 / 3 | 1× / 5× / 15× speed |
| Esc | Close inspector or skip the introduction |
| F11 | Toggle fullscreen |

Settings include music/effects volume, a sound preview, mute and reduced ambient activity. **Reset Day** and **Play Again** start a new scenario. The leaderboard retains the top 50 current-rule runs and displays the top ten; it has no network synchronization. Administrator reset: **Ctrl+Shift+Delete** on the leaderboard, then confirm.

## Current status

Playable offline exhibition prototype with Demo/Normal modes, service-based scoring, deterministic comparisons and repeated-session regression coverage. The latest gameplay polish baseline is `44c76ba`. Rendered review covered **1920×1080**, **1366×768** and **1280×720**. Independent first-time visitor feedback, sustained performance on the actual exhibition laptop and perceived speaker balance remain practical validation steps.

The scenario, thermal model and solar-use metric are deliberately simplified. See the scenario documentation for their assumptions and limits.

## Documentation

- [SIMULATION.md](SIMULATION.md) — core energy model and accounting.
- [SCENARIO.md](SCENARIO.md) — events, devices, score rules, reference policies and persistence.
- [AUDIO.md](AUDIO.md) — synthesized audio and provenance.
- [VALIDATION.md](VALIDATION.md) — final test counts, rendered coverage and remaining checks.
- [POLISH_REVIEW.md](POLISH_REVIEW.md) — current refinement issue log, playthroughs and outcomes.
- [PLAYTEST.md](PLAYTEST.md) — historical developer playtest report, clearly marked as superseded.

Source is in `scripts/`, scenes in `scenes/`, and regression suites in `tests/`. Godot `.gd.uid` files are tracked stable script identifiers. Local caches, runtime downloads, builds and validation captures are excluded from publication.

## Run regression checks

Pass your Godot console executable to the Windows test runner:

```powershell
./Test-Prototype.ps1 -GodotPath 'C:\Tools\Godot.exe'
./Test-Prototype.ps1 -GodotPath 'C:\Tools\Godot.exe' -Capture -Resolution 1280x720
```

The runner executes seven suites. Rendered captures and journals are written to ignored `artifacts/`; test stores are separate from player rankings. Use 1920x1080 or 1366x768 for the other target sizes. Automated checks protect behavior; visitor playtesting is still needed to assess comprehension and enjoyment.
