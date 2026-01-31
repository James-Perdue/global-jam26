extends Node3D
class_name RootLevel

@onready var player: Player = $Player
@onready var hud: Hud = $Hud
func _ready() -> void:
	hud.player = player
