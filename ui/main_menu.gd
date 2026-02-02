extends Node3D
@onready var play_button: Button = %PlayButton
@onready var playground_button: Button = %PlaygroundButton

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	play_button.pressed.connect(_on_play_button_pressed)
	playground_button.pressed.connect(_on_playground_button_pressed)
	MusicManager.play_music("main_menu")
	if not OS.is_debug_build():
		playground_button.hide()

func _on_play_button_pressed() -> void:
	#TODO: Jared ref your level in GameManager
	GameManager.load_level("level_1")

func _on_playground_button_pressed() -> void:
	GameManager.load_level("test")
