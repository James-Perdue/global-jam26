extends Node3D
class_name Objective

@export var tier: int = 0

signal completed(objective: Objective)

@onready var mesh: MeshInstance3D = $StaticBody3D/MeshInstance3D
@onready var collision_shape: CollisionShape3D = $StaticBody3D/CollisionShape3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func enable_objective() -> void:
	var material = mesh.get_active_material(0)
	if material:
		var new_material = material.duplicate()
		new_material.albedo_color = Color.GREEN
		mesh.material_override = new_material
func show_preview() -> void:
	pass

func complete() -> void:
	collision_shape.disabled = true
	mesh.visible = false
	completed.emit(self)
