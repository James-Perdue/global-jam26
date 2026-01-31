extends Node3D
class_name Mask

signal hit

@export var emotion: Enums.Emotion = Enums.Emotion.HAPPY

@onready var emotion_debug_label: Label3D = %EmotionDebugLabel

func _ready() -> void:
	hit.connect(_on_hit)
	emotion_debug_label.text = Enums.Emotion.keys()[emotion]

func reset_mask():
	hide()
	$Collider/CollisionShape3D.disabled = true

func set_emotion(value: Enums.Emotion) -> void:
	$Collider/CollisionShape3D.disabled = false
	emotion = value
	emotion_debug_label.text = Enums.Emotion.keys()[emotion]

func _on_hit() -> void:
	print("Mask hit: ", emotion)
