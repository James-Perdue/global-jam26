extends Node3D
class_name Mask

signal hit

@export var emotion: Enums.Emotion = Enums.Emotion.HAPPY

@onready var emotion_debug_label: Label3D = %EmotionDebugLabel
@onready var mesh: MeshInstance3D = %Mesh

func _ready() -> void:
	hit.connect(_on_hit)
	set_emotion(emotion)
	$Collider/CollisionShape3D.disabled = true
	emotion_debug_label.text = ""

func reset_mask():
	hide()
	$Collider/CollisionShape3D.disabled = true

func set_emotion(value: Enums.Emotion) -> void:
	emotion = value
	#emotion_debug_label.text = Enums.Emotion.keys()[emotion]
	
	var mat = mesh.get_surface_override_material(0)
	if mat is StandardMaterial3D:
		# Duplicate material to ensure UV offset is unique to this instance
		mat = mat.duplicate()
		mat.albedo_color = EmotionDatabase.colors[Enums.Emotion.keys()[emotion]]
		mesh.set_surface_override_material(0, mat)
		
		mat.uv1_offset.x = float(_atlas_index_from_emotion(emotion)) * (1/6.0)

func enable_collision() -> void:
	if(visible):
		$Collider/CollisionShape3D.disabled = false

func _on_hit() -> void:
	print("Mask hit: ", emotion)

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
