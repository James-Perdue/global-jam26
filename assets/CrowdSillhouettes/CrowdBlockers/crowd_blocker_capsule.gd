extends Node3D
const numSillhouettes = 5;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var collider = $CollisionShape3D
	for i in range(numSillhouettes):
		var newMesh = $SillhouetteInstance.duplicate();
		# position
		newMesh.position.x = randf_range((collider.position.x - collider.shape.radius)
		, (collider.position.x + collider.shape.radius));
		newMesh.position.y = collider.position.y;
		newMesh.position.z = randf_range((collider.position.z - collider.shape.radius)
		, (collider.position.z + collider.shape.radius));
		
		#rotation
		var dir = newMesh.position.direction_to(collider.position);
		newMesh.rotation.y = dir.z;
		
		add_child(newMesh);


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
