extends Node
var levels: Dictionary = {
	"main_menu": preload("res://ui/main_menu.tscn"),
	"level_1": preload("res://levels/test_level_1.tscn"),
	"test": preload("res://levels/playground.tscn")
}
func _ready() -> void:
	SignalBus.game_over.connect(_on_game_over)
	SignalBus.win.connect(_on_win)

func _on_win() -> void:
	print("Win")
	load_level("main_menu")

func _on_game_over() -> void:
	print("Game over")
	load_level("main_menu")

func load_level(level_name: String) -> void:
	var result = get_tree().change_scene_to_packed(levels[level_name])
	if result != OK:
		print("Failed to change scene to level: ", level_name)

func reset_game() -> void:
	#Reset globals here
	pass