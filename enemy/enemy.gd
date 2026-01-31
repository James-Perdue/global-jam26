extends CharacterBody3D
class_name Enemy

signal enemy_defeated
@export var max_active_masks: int = 3

var emotion_targets: Array[EmotionMessage] = []
var targeting_index: int = 0

@onready var masks: Array[Mask] = [$MaskSocket1/Mask, $MaskSocket2/Mask, $MaskSocket3/Mask,
 $MaskSocket4/Mask, $MaskSocket5/Mask, $MaskSocket6/Mask,
 $MaskSocket7/Mask, $MaskSocket8/Mask, $MaskSocket9/Mask]

@onready var emotion_message_label: Label3D = %EmotionMessage
func _ready() -> void:
	emotion_message_label.text = ""
	hide()
	for mask in masks:
		mask.hide()


func start_encounter() -> void:
	show()
	# Only pick one emotion target for now
	
	emotion_targets = EmotionDatabase.select_emotions()
	emotion_message_label.text = emotion_targets[0].message
	_enable_masks()

func _clear_masks() -> void:
	for mask in masks:
		mask.hit.disconnect(_on_mask_hit)
		mask.hide()

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
		if(active_masks == 0):
			emotion = emotion_targets[0].emotion
		chosen_emotions.append(emotion)
		mask.set_emotion(emotion)
		mask.hit.connect(_on_mask_hit.bind(mask))
		print("Mask emotion: ",mask.emotion)
		available_masks.erase(mask_index)
		active_masks += 1
		mask.show()

func _on_mask_hit(mask: Mask) -> void:
	if mask.emotion != emotion_targets[targeting_index].emotion:
		print("Emotion Incorrect: ", mask.emotion, " Expected: ", emotion_targets[targeting_index])
		return
	print("Emotion Correct: ", mask.emotion)
	targeting_index += 1
	if targeting_index >= emotion_targets.size():
		end_encounter()
	else:
		emotion_message_label.text = emotion_targets[targeting_index].message
		_clear_masks()
		_enable_masks()


func end_encounter() -> void:
	print("enemy defeated")
	enemy_defeated.emit()
	queue_free()
