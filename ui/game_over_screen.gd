extends Control

@onready var replay_button: Button = %ReplayButton
@onready var menu_button: Button = %MenuButton

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	replay_button.pressed.connect(_on_replay_button_pressed)
	menu_button.pressed.connect(_on_menu_button_pressed)

func _on_replay_button_pressed() -> void:
	GameManager.load_level("level_1")

func _on_menu_button_pressed() -> void:
	GameManager.load_level("main_menu")
