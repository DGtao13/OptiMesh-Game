# Audio provenance

All audio is original and synthesized locally by `scripts/game_audio.gd`. No external recording, commercial music, downloaded sample or third-party asset is used. There are no external source URLs or attribution obligations.

Music: a quiet 32-second looping sequence of sixteen simple tones, fundamental plus a low-amplitude fifth, with note/loop fades. Mono 22050 Hz, 16-bit PCM; about 1.4 MB generated once at application startup. The longer phrase reduces repetition. It continues across menus and repeated games using one player.

Effects: seven short enveloped tones for click, task completion, warning, EV arrival/departure, cleaning and results. Completion/arrival/results rise, departure falls, warning pulses twice, and clicks last 80 ms. Repeated warnings have a two-second cooldown. Buttons play their click before their action; a click cannot interrupt an active event cue. One effects player prevents layers accumulating. They are subtle cues rather than recorded vehicle/office sounds.

Music/effects volume and mute are available from Settings and persisted with the local leaderboard/settings file. Muting pauses music and suppresses new cues. Sound files are not stored in the repository; synthesis introduces no asset licensing dependency. Final perceived loudness/tone suitability needs listening on the exhibition laptop speakers.
