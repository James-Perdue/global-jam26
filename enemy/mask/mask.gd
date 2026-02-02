extends Node3D
class_name Mask

signal hit

@export var emotion: Enums.Emotion = Enums.Emotion.HAPPY
var original_scale: Vector3 = Vector3.ONE
@onready var emotion_debug_label: Label3D = %EmotionDebugLabel
@onready var mesh: MeshInstance3D = %Mesh
@onready var sparks: Node3D = %MaskSparks

func _ready() -> void:
	hit.connect(_on_hit)
	set_emotion(emotion)
	$Collider/CollisionShape3D.disabled = true
	emotion_debug_label.text = ""
	original_scale = scale

func reset_mask():
	$Collider/CollisionShape3D.disabled = true
	var tween_scale = create_tween()
	tween_scale.tween_property(self, "scale", original_scale * 0.5, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await tween_scale.finished
	hide()

func set_emotion(value: Enums.Emotion) -> void:
	emotion = value
	#emotion_debug_label.text = Enums.Emotion.keys()[emotion]
	show()
	
	var mat = mesh.get_surface_override_material(0)
	if mat is StandardMaterial3D:
		# Duplicate material to ensure UV offset is unique to this instance
		mat = mat.duplicate()
		mat.albedo_color = EmotionDatabase.colors[Enums.Emotion.keys()[emotion]]
		sparks.get_node("CPUParticles3D").color = EmotionDatabase.colors[Enums.Emotion.keys()[emotion]]
		mesh.set_surface_override_material(0, mat)
		
		mat.uv1_offset.x = float(_atlas_index_from_emotion(emotion)) * (1/6.0)
	var tween_scale = create_tween()
	tween_scale.tween_property(self, "scale", original_scale, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await tween_scale.finished
	
func enable_collision() -> void:
	if(visible):
		$Collider/CollisionShape3D.disabled = false

func _on_hit() -> void:
	print("Mask hit: ", emotion)
	sparks.get_node("CPUParticles3D").emitting = true

func _atlas_index_from_emotion(emotion_input: Enums.Emotion) -> int:
	match emotion_input:
		Enums.Emotion.HAPPY:
			return 0
		Enums.Emotion.SAD:
			return 1
		Enums.Emotion.FEAR:
			return 2
		Enums.Emotion.ANGRY:
			return 3
		Enums.Emotion.ANNOYED:
			return 5
		_:
			return 0
