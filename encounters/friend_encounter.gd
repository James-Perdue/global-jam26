extends Node3D

@export var drag_duration: float = 0.5
@export var audio_clips: Array[AudioStream] = []
@export var dialog_texts: Array[String] = []

@onready var trigger: Area3D = $Trigger
@onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var friend_model: Node3D = $SillhouetteInstance
@onready var dialog_label: Label3D = $DialogLabel

var current_clip_index: int = 0

func _ready() -> void:
	trigger.body_entered.connect(_on_trigger_body_entered)
	if audio_player:
		audio_player.finished.connect(_on_audio_finished)
	if dialog_label:
		dialog_label.text = ""

func _on_trigger_body_entered(body: Node3D) -> void:
	if body is Player:
		trigger.body_entered.disconnect(_on_trigger_body_entered)
		
		# Lock the player in
		body.rotation_locked = true
		
		# Hide the player's gun
		SignalBus.end_encounter.emit()
		
		# Move player to trigger position and face friend
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(body, "global_position:x", trigger.global_position.x, drag_duration)
		tween.tween_property(body, "global_position:z", trigger.global_position.z, drag_duration)
		
		var target_dir = (friend_model.global_position - trigger.global_position).normalized()
		target_dir.y = 0
		var target_yaw = atan2(-target_dir.x, -target_dir.z)
		
		tween.tween_property(body, "rotation:y", target_yaw, drag_duration).set_trans(Tween.TRANS_SINE)
		body.in_encounter = true
		tween.set_parallel(false)
		tween.tween_callback(func(): 
			body.base_rotation = Vector2(body.camera.rotation.x, target_yaw)
			body.is_clamped = true
			play_audio()
		)

func play_audio() -> void:
	if current_clip_index < audio_clips.size() and audio_player:
		audio_player.stream = audio_clips[current_clip_index]
		
		if current_clip_index < dialog_texts.size() and dialog_label:
			dialog_label.text = dialog_texts[current_clip_index]
			
		audio_player.play()
	else:
		# No more clips or missing components
		_on_sequence_complete()

func _on_audio_finished() -> void:
	current_clip_index += 1
	if current_clip_index < audio_clips.size():
		play_audio()
	else:
		_on_sequence_complete()

func _on_sequence_complete() -> void:
	if dialog_label:
		dialog_label.text = ""
	SignalBus.win.emit()
