extends Node3D
class_name LoaderScene

func _ready() -> void:
	SignalBus.done_loading.connect(_on_done_loading)
	$monsterPart/CPUParticles3D.emitting = true
func _on_done_loading() -> void:
	queue_free()
