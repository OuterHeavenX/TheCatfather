extends Node
## Jukebox — the speakeasy loop, with a mute toggle that outlives a new game.

const STREAM_PATH := "res://assets/audio/speakeasy_loop.wav"
const SETTINGS_PATH := "user://pawfellas_audio.cfg"
const MUSIC_DB := -9.0

var muted: bool = false

var _player: AudioStreamPlayer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_player = AudioStreamPlayer.new()
	_player.volume_db = MUSIC_DB
	# Loop is set here, on a duplicate, for two reasons. Setting
	# edit/loop_mode=1 on the .import does not survive — the imported resource
	# still reports loop_mode 0 even after a forced reimport. And mutating the
	# shared cached resource instead of a copy keeps it alive past engine
	# cleanup, which shows up as a leaked-resource error on shutdown.
	var stream: AudioStream = load(STREAM_PATH)
	if stream is AudioStreamWAV:
		var wav: AudioStreamWAV = (stream as AudioStreamWAV).duplicate()
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav.loop_begin = 0
		wav.loop_end = int(wav.get_length() * float(wav.mix_rate))
		stream = wav
	_player.stream = stream
	add_child(_player)
	_load_settings()
	_start()


## Browsers refuse to start audio before the player touches the page, so keep
## trying on input until it takes.
func _input(_event: InputEvent) -> void:
	if not muted and not _player.playing:
		_start()


func _start() -> void:
	if DisplayServer.get_name() == "headless":
		return
	if muted or _player.playing:
		return
	_player.play()


## Release the stream on shutdown; holding it leaves the resource alive past
## the engine's cleanup pass.
func _exit_tree() -> void:
	if _player != null:
		_player.stop()
		_player.stream = null


func set_muted(value: bool) -> void:
	muted = value
	if muted:
		_player.stop()
	else:
		_player.play()
	_save_settings()


func toggle() -> void:
	set_muted(not muted)


func _load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SETTINGS_PATH) == OK:
		muted = bool(cfg.get_value("audio", "muted", false))


func _save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "muted", muted)
	cfg.save(SETTINGS_PATH)
