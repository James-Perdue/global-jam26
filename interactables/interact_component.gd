extends StaticBody3D
class_name InteractComponent
@export var mesh: Mesh

@onready var interact_label: Label3D = %InteractLabel
signal interacted

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MeshInstance3D.mesh = mesh
	interact_label.hide()
	
func interact() -> void:
	print("Interacted with: ", name)
	interacted.emit()

func show_preview() -> void:
	interact_label.show()
	
func hide_preview():
	interact_label.hide()
