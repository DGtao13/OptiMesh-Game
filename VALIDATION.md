# Prototype validation

Validated on 3 October 2026 with the official **Godot 4.5 stable** Windows x64 build (`876b29033`). The repository was initially empty, with no commits, existing assets or repository instructions.

## Results

| Run | Result |
| --- | --- |
| Headless real-scene integration | 505 checks, 0 failures |
| Rendered 1920×1080 | 520 checks, 0 failures |
| Rendered 1366×768 | 520 checks, 0 failures |
| Rendered 1280×720 | 520 checks, 0 failures |
| Godot editor import / script load | Passed |

Checks cover the complete start → name → mode → Demo flow, whitespace rejection, trimmed name submission by Enter, disabled Normal Mode, all nine clickable objects and their panels, every control choice, retained settings across selection changes, unchanged demonstration readings, deselection, pause/resume, 1×/5×/15× advancement, time formatting, 18:00 clamping, day reset, keyboard shortcuts, menu return, and new-demo reset. Inspector children are checked for horizontal and vertical containment. Real viewport mouse events additionally activate New Game, select the battery and press its Charge button.

Rendered runs created 15 viewport screenshots at each resolution: all start-flow screens, the unselected site, each object's inspector, day end and the battery interaction. Captures are retained locally in `artifacts/` and excluded from Git and Godot's asset importer. Representative screenshots were visually inspected at all three resolutions. Text wrapping and small control-button sizing issues found during review were fixed, then the affected checks and captures were rerun.

The renderer ran on this workstation's AMD Radeon RX 5700 XT using OpenGL 3.3 Compatibility. This validates rendering, not performance on weak laptops. The prototype uses a 60 FPS cap and no external assets, textures, shaders, particles, physics or 3D rendering.

## Environment observations

The restricted execution sandbox initially blocked Godot's standard AppData directories and Windows certificate-store access. Validation redirected AppData into ignored `.tools/profile`. A subsequent unrestricted rendered run and editor import completed without those environment errors. The game itself uses no networking or certificate-dependent features.

## Remaining manual checks

- Run `run.ps1` or import `project.godot` and press F5 on the actual exhibition laptop. Check text size, pointer targeting, Windows display scaling and sustained FPS on that hardware.
- Try fullscreen (`run.ps1 -Fullscreen`, or F11 in Demo Mode), window resize and keyboard focus with the intended display configuration.
- Review the visual direction and placement for the next artwork milestone.

Energy values and future event/assistant areas are intentionally illustrative. No complete simulation, score, persistence or hardware/backend integration has been implemented. No standalone exported executable is included; running the project requires Godot. The portable Godot runtime downloaded for this workstation is local and ignored by Git.
