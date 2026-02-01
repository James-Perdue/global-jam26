extends Node3D
class_name Encounter

@export var damage_rate : float = 1.0
@export var drag_duration: float = .5
@export_category("Difficulty")
## Control how many emotions are in each message, > 0 to set
@export var emotion_count: int = -1
## Control how many masks are active at once
@export var max_active_masks: int = 3
## Control how many messages are in the encounter
@export var message_count: int = 1
## Control how many enemies are in the encounter
@export var enemy_count: int = 1
## Hardcoded emotion key to use for the encounter, if null, use semi-random lookup
@export var fixed_key: String = ""

@onready var enemy: Enemy = $Enemy
@onready var trigger: Area3D = $Trigger
@onready var pre_enemy_sprite: Sprite3D = $PreEnemySprite

func _ready() -> void:
	pre_enemy_sprite.show()
	trigger.body_entered.connect(_on_trigger_body_entered)
	enemy.enemy_defeated.connect(_on_enemy_defeated)

func _on_trigger_body_entered(body: Node3D) -> void:
	if(body is Player):
		print("Body entered: ", body.name)

		var tween = create_tween()
		tween.tween_property(body, "position:x", trigger.global_position.x, drag_duration)
		tween.parallel().tween_property(body, "position:z", trigger.global_position.z, drag_duration)
		tween.tween_callback(func(): start_encounter())

func start_encounter() -> void:
	pre_enemy_sprite.hide()
	var emotion_targets: Array[EmotionMessage] = []
	if(fixed_key != ""):
		emotion_targets = [EmotionDatabase.select_specific_emotion_message(fixed_key)]
	else:
		for i in message_count:
			emotion_targets.append(EmotionDatabase.select_new_emotion_message(emotion_count))
	enemy.max_active_masks = max_active_masks
	enemy.start_encounter(emotion_targets)
	SignalBus.start_encounter.emit(self)
	
	
func _on_enemy_defeated() -> void:
	SignalBus.end_encounter.emit()
	await enemy.tree_exited
	queue_free()
