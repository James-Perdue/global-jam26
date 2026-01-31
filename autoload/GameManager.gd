extends Node

func _ready() -> void:
	SignalBus.game_over.connect(_on_game_over)

func _on_game_over() -> void:
	get_tree().reload_current_scene()