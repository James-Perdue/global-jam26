extends StaticBody3D
class_name InteractComponent

@export var stream : AudioStream = null
@onready var interact_label: Label3D = %InteractLabel
@onready var interact_audio: AudioStreamPlayer3D = $AudioStreamPlayer3D

signal interacted

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interact_label.hide()
	await get_tree().process_frame
	interact_audio.stream = stream
	
func interact() -> void:
	print("Interacted with: ", name)
	if(interact_audio.stream != null):
		interact_audio.play()
	interacted.emit()

func show_preview() -> void:
	interact_label.show()
	
func hide_preview():
	interact_label.hide()
