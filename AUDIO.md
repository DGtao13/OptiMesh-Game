# Audio provenance

All audio is original and synthesized locally by `scripts/game_audio.gd`. No external recording, commercial music, downloaded sample or third-party asset is used. There are no external source URLs or attribution obligations.

Music: a quiet 16-second looping sequence of eight simple tones (C3/E3/G3/D3/F3/A3/E3/G3), fundamental plus a low-amplitude fifth, with note/loop fades. Mono 22050 Hz, 16-bit PCM; about 706 kB generated once at application startup. It continues across menus and repeated games using one player.

Effects: seven short enveloped tones for click, task completion, warning, EV arrival/departure, cleaning and results. One effects player prevents layers accumulating. They are subtle cues rather than recorded vehicle/office sounds.

Music/effects volume and mute are available from Settings and persisted with the local leaderboard/settings file. Muting pauses music and suppresses new cues. Sound files are not stored in the repository; synthesis introduces no asset licensing dependency. Final perceived loudness/tone suitability needs listening on the exhibition laptop speakers.
