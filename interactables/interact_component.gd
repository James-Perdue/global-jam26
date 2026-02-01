extends StaticBody3D
class_name InteractComponent
@export var mesh: Mesh

signal interacted

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MeshInstance3D.mesh = mesh

func interact() -> void:
	print("Interacted with: ", name)
	interacted.emit()

func show_preview() -> void:
	pass
