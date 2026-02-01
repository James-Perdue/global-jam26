extends Node3D
class_name HealItem

@export var heal_amount: int = 20

@onready var mesh: MeshInstance3D = $InteractComponent/MeshInstance3D
@onready var collision_shape: CollisionShape3D = $InteractComponent/CollisionShape3D
@onready var interact_component: InteractComponent = $InteractComponent

func _ready() -> void:
	interact_component.interacted.connect(_on_interacted)

func _on_interacted() -> void:
	SignalBus.player_healed.emit(heal_amount)
	SignalBus.drunk_started.emit()
	interact_component.hide_preview()
	collision_shape.disabled = true
	mesh.visible = false
	queue_free()
