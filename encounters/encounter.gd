extends Node3D
class_name Encounter

@export var damage_rate : float = 1.0
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
		tween.tween_property(body, "position:x", trigger.global_position.x, 1)
		tween.parallel().tween_property(body, "position:z", trigger.global_position.z, 1)
		tween.tween_callback(func(): start_encounter())

func start_encounter() -> void:
	pre_enemy_sprite.hide()
	SignalBus.start_encounter.emit()
	enemy.start_encounter()
	
func _on_enemy_defeated() -> void:
	SignalBus.end_encounter.emit()
	queue_free()
