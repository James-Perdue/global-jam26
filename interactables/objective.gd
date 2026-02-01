extends Node3D
class_name Objective

@export var tier: int = 0

signal completed(objective: Objective)

@onready var mesh: MeshInstance3D = $InteractComponent/MeshInstance3D
@onready var collision_shape: CollisionShape3D = $InteractComponent/CollisionShape3D
@onready var interact_component: InteractComponent = $InteractComponent
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interact_component.interacted.connect(_on_interacted)

func _on_interacted() -> void:
	completed.emit(self)

# func enable_objective() -> void:
# 	var material = mesh.get_active_material(0)
# 	if material:
# 		var new_material = material.duplicate()
# 		new_material.albedo_color = Color.GREEN
# 		mesh.material_override = new_material

func complete() -> void:
	collision_shape.disabled = true
	mesh.visible = false
