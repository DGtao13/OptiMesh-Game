extends Node
## Original synthesized audio. No external assets, samples or licensing dependencies.
var music: AudioStreamPlayer
var effects: AudioStreamPlayer
var settings: Dictionary
var tones: Dictionary={}

func wave(seconds: float, frequency: float, music_notes: bool = false) -> AudioStreamWAV:
	var bytes := PackedByteArray()
	var rate := 22050
	bytes.resize(int(seconds*rate)*2)
	for i in range(bytes.size()/2):
		var t := float(i)/rate
		var f := frequency
		if music_notes: f=[130.81,164.81,196.0,146.83,174.61,220.0,164.81,196.0][int(t/2)%8]
		var envelope := minf(t*10,1.0)*minf((seconds-t)*6,1.0)
		if music_notes:
			var note_time:=fmod(t,2.0)
			envelope=(0.2+0.15*sin(t*PI))*minf(note_time*20,1)*minf((2-note_time)*5,1)*minf(t*2,1)*minf((seconds-t)*2,1)
		var sample := int((sin(t*TAU*f)*0.16+sin(t*TAU*f*1.5)*0.05)*envelope*32767)
		bytes.encode_s16(i*2,sample)
	var stream := AudioStreamWAV.new()
	stream.format=AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate=rate
	stream.data=bytes
	if music_notes:
		stream.loop_mode=AudioStreamWAV.LOOP_FORWARD
		stream.loop_end=bytes.size()/2
	return stream

func _ready() -> void:
	music=AudioStreamPlayer.new()
	effects=AudioStreamPlayer.new()
	add_child(music)
	add_child(effects)
	music.stream=wave(16,130.81,true)
	for kind in ["click","complete","warning","arrival","departure","clean","results"]:
		tones[kind]=wave(0.14 if kind=="click" else 0.45,{"click":440,"complete":660,"warning":220,"arrival":523,"departure":392,"clean":587,"results":784}[kind])
	music.play()
	apply_settings()

func apply_settings() -> void:
	if not is_instance_valid(music): return
	music.volume_db=linear_to_db(maxf(float(settings.get("music",0.22)),0.0001))
	effects.volume_db=linear_to_db(maxf(float(settings.get("effects",0.35)),0.0001))
	music.stream_paused=settings.get("mute",false)
	if settings.get("mute",false): effects.stop()

func cue(kind: String) -> void:
	if settings.get("mute",false) or not is_instance_valid(effects): return
	effects.stream=tones.get(kind,tones.click)
	effects.play()

func _exit_tree() -> void:
	if is_instance_valid(music):
		music.stop()
		music.stream=null
	if is_instance_valid(effects):
		effects.stop()
		effects.stream=null
	tones.clear()
