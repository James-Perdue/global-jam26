extends Node
var levels: Dictionary = {
	"main_menu": preload("res://ui/main_menu.tscn"),
	"level_1": preload("res://levels/test_level_1.tscn"),
	"test": preload("res://levels/playground.tscn")
}
func _ready() -> void:
	SignalBus.game_over.connect(_on_game_over)

func _on_game_over() -> void:
	load_level("main_menu")

func load_level(level_name: String) -> void:
	var result = get_tree().change_scene_to_packed(levels[level_name])
	if result != OK:
		print("Failed to change scene to level: ", level_name)