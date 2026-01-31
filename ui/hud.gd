extends CanvasLayer
class_name Hud

var player: Player = null
var enemy: Enemy = null
@onready var health_bar: ProgressBar = %HealthBar
@onready var rich_text: RichTextLabel = %DialogueBox
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.player_health_changed.connect(_on_player_health_changed)
	SignalBus.start_encounter.connect(_on_encounter_start)
	SignalBus.end_encounter.connect(_on_encounter_end)

func _process(delta: float) -> void:
	if enemy != null:
		rich_text.show()
		rich_text.set_position(player.camera.unproject_position(enemy.get_label_location()) + Vector2(-500,-20))
		rich_text.text = "[b]" + enemy.emotion_targets[0].message + "[/b]"
		

func _on_player_health_changed(health: int) -> void:
	health_bar.value = health
	
func _on_encounter_start(encounter:Encounter):
	enemy = encounter.enemy

func _on_encounter_end():
	rich_text.hide()
	enemy = null
