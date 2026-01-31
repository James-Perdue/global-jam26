extends CanvasLayer
class_name Hud

var player: Player = null
@onready var health_bar: ProgressBar = %HealthBar
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.player_health_changed.connect(_on_player_health_changed)

func _on_player_health_changed(health: int) -> void:
	health_bar.value = health
