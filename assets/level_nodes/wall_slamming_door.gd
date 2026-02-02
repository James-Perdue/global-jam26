extends StaticBody3D
@onready var collision_area: Area3D = %CollisionArea
@onready var slam_audio: AudioStreamPlayer3D = $SlamPlayer

func _ready() -> void:
	collision_area.body_entered.connect(_on_collision_area_body_entered)

func _on_collision_area_body_entered(body: Node3D) -> void:
	if(body is Player):
		print("Player entered: ", body.name)
		slam_audio.play()
		var tween = create_tween()
		tween.tween_property($Door2, "rotation:y", 0, .5).set_trans(Tween.TRANS_EXPO)
