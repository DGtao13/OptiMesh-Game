# Windows exhibition release — v0.1.0-demo

Release: **OptiMesh Game — Exhibition Demo v0.1.0**, marked as a pre-release.

[Download and release notes](https://github.com/DGtao13/OptiMesh-Game/releases/tag/v0.1.0-demo)

## Play

Extract `OptiMesh-Game-v0.1.0-demo-windows-x86_64.zip`, open the extracted folder and run `OptiMesh.exe`. Keep the PCK beside it. No editor, backend, account or repository checkout is required.

The game starts windowed at 1280×720, scales its 1920×1080 logical canvas uniformly, and supports F11 fullscreen while playing. Settings/rankings are stored under `%APPDATA%\Godot\app_userdata\OptiMesh Game\`; extracting a new build does not erase them.

## Build configuration

- Engine and export templates: **Godot 4.5 stable**, exact engine version `4.5.stable.official.876b29033`.
- Preset: **Windows Desktop**, standard x86_64 release template, Compatibility renderer.
- Product name: **OptiMesh**; file/product version **0.1.0.0**; game version **0.1.0-demo**.
- Separate executable and PCK. [Godot's Windows export guidance](https://docs.godotengine.org/en/4.5/tutorials/export/exporting_for_windows.html) recommends avoiding PCK embedding for ordinary Windows distribution.
- No custom icon was available; no temporary branding asset was invented.
- No signing certificate is configured. The first public build is unsigned.
- Tests, documentation/screenshots, legacy regression scene, PowerShell tools and local artifacts are excluded from the PCK. Runtime scripts are compiled/compressed by Godot. Generated binaries/ZIP remain ignored under `dist/`.

## Reproduce

1. Check out tag `v0.1.0-demo`.
2. Install standard Godot **4.5 stable** and its matching **4.5.stable** export templates using Godot's Export Template Manager. The official [archive download page](https://godotengine.org/download/archive/4.5-stable/) provides both. Other Godot versions may produce different builds; this release script checks the pinned engine version.
3. Run:

```powershell
./Build-Windows.ps1 -GodotPath 'C:\Tools\Godot_v4.5-stable_win64_console.exe'
./Test-Release.ps1
```

The builder imports the project, exports the release preset, adds required Godot legal notices, creates the ZIP and prints its size/SHA-256. The export preset contains no credentials or machine-specific paths. Matching templates must be installed in the Godot user-data directory used by the build process.

The official template archive used for this build had SHA-256 `375d83b661794f91746d2dec9b569a99d4d24f85a70c4ec0068aafb18b551d53`, checked against the Godot release asset's published digest. Engine license/third-party notices are preserved from the official `4.5-stable` source tag in `third_party/godot/`; those notices concern the bundled engine and dependencies.

## Player package

```text
dist/
  OptiMesh-Game-v0.1.0-demo-windows-x86_64.zip
  OptiMesh-Game-v0.1.0-demo-windows-x86_64/
    OptiMesh.exe
    OptiMesh.pck
    GODOT-LICENSE.txt
    GODOT-THIRD-PARTY-NOTICES.txt
```

The ZIP contains only that player folder. There is no loose source tree, test harness, editor, screenshot collection or development cache. Godot's generated runtime resource metadata inside the PCK is required packaged game data.

## Exported-build validation

`Test-Release.ps1` extracts the ZIP to a new Windows temporary folder outside the repository and runs the exported executable. The external source test harness loads the game's compiled scene/resources; the harness is not shipped to players. A separate isolated AppData profile avoids affecting real player rankings. Closing/reopening between sizes tests persisted data.

| Rendered size | Exported-template assertions | Outcome |
|---|---:|---|
| 1920×1080 | 24 | Zero failures |
| 1366×768 | 25 | Zero failures, including reopened settings/ranking |
| 1280×720 | 25 | Zero failures, including reopened settings/ranking |

**74 checks** cover template versus editor identity, absence of development files in the package, menu/name/Demo onboarding, gameplay loading, sound-preview/music routing, mute/unmute, settings saving, fullscreen/window return, a complete accelerated rendered day, results, local leaderboard write, retry reset and menu/ranking navigation. Captures and logs go to ignored `artifacts/release-tests/`.

Direct desktop review of the normal exported startup additionally exercised name entry, Demo selection, tutorial skip, live gameplay, settings and Test sound at 1366×768. F11 expanded to the physical 2560×1440 desktop and returned to the previous window size; the game closed normally. Reviewed exported captures at all target sizes showed readable gameplay/results/ranking.

The release template emitted a Windows common-controls initialization warning in logs. The game's own Godot controls and tested flows worked; native operating-system dialogs were not tested and the game does not require them. No script errors, missing resources or audio resource leaks occurred in the completed exported tests. Audio playback/routing was exercised; subjective speaker balance remains a hardware listening check. Sustained exhibition-laptop performance and independent visitor feedback remain covered by the limitations in VALIDATION.md.

The tagged release changes presentation/export/test tooling and application version metadata only; gameplay and simulation scripts remain at the established polish baseline.
