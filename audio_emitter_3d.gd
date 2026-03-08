extends Node3D
class_name AudioEmitter3D

@onready var audio_player: AudioStreamPlayer3D = $AudioPlayer

@export_category("Playback")
@export var stream: AudioStream
@export var play_on_ready: bool = true
@export var wait_for_done_loading: bool = true
@export var loop: bool = true
@export var bus_name: String = "Sfx Bus"
@export var volume_db: float = -3.0

@export_category("3D Distance")
@export var max_distance: float = 18.0
@export var unit_size: float = 1.0
@export var attenuation: float = 1.0

@export_category("Randomization (Optional)")
@export var base_pitch: float = 1.0
@export var random_pitch: bool = false
@export var pitch_min: float = 0.95
@export var pitch_max: float = 1.05
@export var random_start_time: bool = false

@export_category("Occlusion / Muffle (Optional)")
@export var enable_occlusion: bool = false
@export var occlusion_check_rate: float = 0.1   # seconds
@export var open_cutoff_hz: float = 20000.0     # clear
@export var occluded_cutoff_hz: float = 1200.0  # muffled
@export var occlusion_mask: int = 1             # collision layers that count as "walls"

var _time_accum: float = 0.0

func _ready() -> void:
	_apply_settings()

	# Setup the built-in per-player filter (used for occlusion)
	audio_player.attenuation_filter_db = -24.0
	audio_player.attenuation_filter_cutoff_hz = open_cutoff_hz

	if not play_on_ready:
		return

	if wait_for_done_loading:
		SignalBus.done_loading.connect(_on_done_loading, CONNECT_ONE_SHOT)
	else:
		play()

func _on_done_loading() -> void:
	play()
func _apply_settings() -> void:
	# Route audio into the correct bus 
	audio_player.bus = bus_name

	# Assign the audio file to play
	audio_player.stream = stream

	# Set loudness
	audio_player.volume_db = volume_db

	# Loop (works for common stream types; if a stream type doesn't support it,
	# you can just enable loop in the Import settings instead)
	if audio_player.stream != null:
		audio_player.stream.loop = loop

	# 3D falloff settings
	audio_player.max_distance = max_distance
	audio_player.unit_size = unit_size

	# Default pitch
	audio_player.pitch_scale = base_pitch

func play() -> void:
	if stream == null:
		return

	# Pitch: either fixed or randomized
	if random_pitch:
		audio_player.pitch_scale = randf_range(pitch_min, pitch_max)
	else:
		audio_player.pitch_scale = base_pitch

	# Start playback
	audio_player.play()

	# Random start time (useful so multiple emitters don’t sync)
	if random_start_time and audio_player.stream != null:
		var length: float = audio_player.stream.get_length()
		if length > 0.1:
			audio_player.seek(randf_range(0.0, length))

func stop() -> void:
	audio_player.stop()

func _process(delta: float) -> void:
	if not enable_occlusion:
		return
	if not audio_player.playing:
		return

	_time_accum += delta
	if _time_accum < occlusion_check_rate:
		return
	_time_accum = 0.0

	_update_occlusion()

func _update_occlusion() -> void:
	# The active camera is the "listener" (the player's ears)
	var cam := get_viewport().get_camera_3d()
	if cam == null:
		return

	# Raycast from listener -> emitter
	var from_pos: Vector3 = cam.global_position
	var to_pos: Vector3 = global_position

	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(from_pos, to_pos)
	query.collision_mask = occlusion_mask

	var hit := space_state.intersect_ray(query)

	# If something blocks the ray (a wall), muffle the sound
	if hit.size() > 0:
		audio_player.attenuation_filter_cutoff_hz = occluded_cutoff_hz
	else:
		audio_player.attenuation_filter_cutoff_hz = open_cutoff_hz
