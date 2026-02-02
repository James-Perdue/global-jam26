extends Node3D
@export var color = Color.BLUE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var emitter = $CPUParticles3D;
	emitter.color = color
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
