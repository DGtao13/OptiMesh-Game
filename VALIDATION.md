# Validation — exhibition playtest pass

October 2026, starting from `3d6453c`. See PLAYTEST.md for the qualitative issue log and strategy outcomes; passing assertions alone are not the usability conclusion.

| Suite | Headless | Rendered, each target size |
| --- | ---: | ---: |
| Original energy model | 258, zero failures | 258, zero failures |
| Preserved prototype | 557, zero failures | 578, zero failures |
| Preserved guided demo | 171, zero failures | 180, zero failures |
| Extended management model | 131, zero failures | 131, zero failures |
| Actual exhibition scene/UI | 898, zero failures | 914, zero failures |
| Six playstyles | 15, zero failures | 69, zero failures |

Final full rendered suites ran at **1920×1080**, **1366×768**, and **1280×720**. Visual inspection caught a score-help line touching the button and a focused task using white text on a pale card. Typography/focus contrast were adjusted and the affected exhibition UI suite repeated at every target size. Godot editor import/script load and Git whitespace checks passed. Final normal-Windows runs produced no script/runtime or resource-leak errors. Sandbox-only certificate-store warnings were eliminated by using normal Windows access for final validation.

## Coverage

The original energy core and its independent tests are unchanged. `legacy_regression.tscn` preserves the original UI/scenario expectations. New checks cover service score caps, three/six-minute grid recovery outcomes, score-rule ranking separation, task drawer, actual task/map picks including wash, monitoring-only controls, numeric battery consequences, acknowledging/reopening Opti without losing queued notices, and live clock/animation sampling.

Existing coverage retains EV arrivals/departures/targets, comfort/power tradeoffs, wash/pause/window, weather/cleaning/paid downtime, revised deadline, exact energy balances, timestep partition invariance, deterministic reference comparisons, bounded persistence, name/menu/settings/mute/reset and vehicle paths. Each exhibition invocation also completes twelve consecutive stress sessions with bounded screen/audio nodes. Strategy tests route decisions through actual selection/control handlers and calculate real model results.

## Rendered review and performance

**36 complete rendered Demo strategy runs** across before/layout/refinement/final rounds. Six personas: naive, EV-first, cost-focused, chaotic, passive, strong. Nine captured moments per strategy include clouds, dust, revised departure, grid challenge, final hour and results. Automated strategies run faster than wall-clock Demo, with audio output enabled. Separate UI captures cover intro, drawer, inspectors, scoring explanation, leaderboard and settings at all three sizes.

Visual review checked map dominance, label separation, contextual panels, tasks, current Opti text, success/failure coaching, score help and ranking. The final score-help screenshot has a clear gap above its button. No unresolved clipping was observed in reviewed final frames. The map takes approximately 67% of logical screen area, compared with 20% before; overlays open only as needed. Inspectors move to the opposite side for right-side equipment.

Compatibility renderer, AMD Radeon RX 5700 XT / OpenGL 3.3. A three-second live clock/animation sample at each target size reported **about 60 FPS** (60.5 including the initial sampled frame) at the configured cap. Root nodes remain two, audio players two, and the drawn activity layer adds no actor nodes. This is a short desktop observation, not sustained low-power laptop benchmarking. Static site caching and 20 Hz activity remain; no additional heavy rendering system was introduced.

All tests redirect AppData into ignored `.tools/profile`, use separate local-store files, and write captures/journals into ignored `artifacts/`. Production player records are not test data. New scoring rules preserve previous entries within the bounded store while excluding incompatible scores from the current leaderboard.

## Necessary manual checks

- One real first-time visitor: complete an eight-minute Demo without coaching; assess tutorial comprehension, response time, last-hour engagement and subjective fun.
- Exhibition laptop: Windows scaling/fullscreen, sustained performance and perceived speaker volume/cue distinction/music repetition. Actual playback was enabled, but tools do not provide physical speaker listening.

No known functional blocker remains from developer render/regression review. The simplified thermal model, solar-use proxy and offline reference controller remain illustrative; exact assumptions are in SCENARIO.md. No new major systems or networking were added.
