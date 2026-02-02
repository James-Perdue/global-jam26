extends CharacterBody3D
class_name Enemy

signal enemy_defeated

var max_active_masks: int = 3
var emotion_targets: Array[EmotionMessage] = []
var message_parts: PackedStringArray = []
var emotion_count: int = 0
var targeting_message_index: int = 0
var targeting_emotion_index: int = 0
var in_encounter = false

@onready var masks: Array[Mask] = [%Mask1, %Mask2, %Mask3, %Mask4, %Mask5]

@onready var emotion_message_label: Label3D = %EmotionMessage
@onready var person: MeshInstance3D = $PersonMesh
@onready var enemy_mesh: Node3D = %EnemyMesh
@onready var animation_tree: AnimationTree = %AnimationTree
@onready var line_audio_player: AudioStreamPlayer3D = %LineAudioPlayer

func _ready() -> void:
	emotion_message_label.text = ""
	hide()
	for mask in masks:
		mask.hide()
		


func start_encounter(new_emotion_targets: Array[EmotionMessage]) -> void:
	show()
	# Only pick one message target for now
	
	emotion_targets = new_emotion_targets
	emotion_message_label.text = emotion_targets[0].message
	emotion_count = len(emotion_targets[0].emotions)
	message_parts = emotion_targets[0].message.split("|")
	line_audio_player.stream = EmotionDatabase.get_audio_file_for_message(emotion_targets[0])
	_enable_masks()
	if(line_audio_player.stream != null):
		line_audio_player.play()
	animation_tree.active = true
	var playback: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/StateMachine/playback")
	playback.travel("Spawn")
	await get_tree().create_timer(1).timeout 
	for mask in masks:
		mask.enable_collision()
	#enemy_mesh.get_node("AnimationPlayer").play("Idle")

	
func _clear_masks() -> void:
	for mask in masks:
		if(mask.is_connected("hit", _on_mask_hit)):
			mask.hit.disconnect(_on_mask_hit)
		mask.reset_mask()


func _enable_masks() -> void:
	var active_masks: int = 0
	var chosen_emotions: Array[Enums.Emotion] = []
	var available_masks: Array[int] = []
	for i in masks.size():
		available_masks.append(i)

	# I'm using Godot lambdas below, they help for things like filtering to make sure we don't get the same emotion twice
	while active_masks < max_active_masks:
		var mask_index: int = available_masks.pick_random()
		print("Mask index: ", mask_index)
		var mask: Mask = masks[mask_index]
		var emotion: Enums.Emotion = Enums.Emotion.values().filter(func(e: Enums.Emotion): return not e in chosen_emotions).pick_random()
		# TODO: handle multiple emotions in one message
		
		if(active_masks == 0):
			# TODO: more emotions
			emotion = emotion_targets[targeting_message_index].emotions[targeting_emotion_index]
		chosen_emotions.append(emotion)
		mask.set_emotion(emotion)
		mask.hit.connect(_on_mask_hit.bind(mask))
		print("Mask emotion: ",mask.emotion)
		available_masks.erase(mask_index)
		active_masks += 1
		mask.show()

func _on_mask_hit(mask: Mask) -> void:
	# TODO: handle multiple emotions in one message
	animation_tree.set("parameters/HitReact/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
	if mask.emotion != emotion_targets[targeting_message_index].emotions[targeting_emotion_index]:
		print("Emotion Incorrect: ", mask.emotion, " Expected: ", emotion_targets[targeting_message_index])
		SignalBus.wrong_mask.emit(mask)
		return
	print("Emotion Correct: ", mask.emotion)
	targeting_emotion_index += 1
	mask.get_node("BreakPlayer").play()
	if targeting_emotion_index>=emotion_count:
		targeting_message_index += 1
		print("Message: ", targeting_message_index, " Emotion: ", targeting_emotion_index)
		if targeting_message_index >= emotion_targets.size():
			SignalBus.correct_mask.emit(mask)
			end_encounter()
			return
		line_audio_player.stream = EmotionDatabase.get_audio_file_for_message(emotion_targets[targeting_message_index])
	SignalBus.correct_mask.emit(mask)
	#emotion_message_label.text = emotion_targets[targeting_message_index].message
	_clear_masks()
	await get_tree().create_timer(.3).timeout 
	_enable_masks()
	
	for mask_item in masks:
		mask_item.enable_collision()


func end_encounter() -> void:
	print("enemy defeated")
	for mask_item in masks:
		mask_item.reset_mask()
	animation_tree.set("parameters/StateMachine/conditions/is_dead", true)
	line_audio_player.stop()
	await get_tree().create_timer(.2).timeout 
	enemy_defeated.emit()
	while animation_tree.get("parameters/StateMachine/playback").get_current_node() != "End":
		await get_tree().process_frame
	queue_free()
	in_encounter = false
	
func auto_win() -> void:
	#Play effects and sounds here
	end_encounter()

func get_label_location():
	return emotion_message_label.global_position

#func _process(delta: float) -> void:
