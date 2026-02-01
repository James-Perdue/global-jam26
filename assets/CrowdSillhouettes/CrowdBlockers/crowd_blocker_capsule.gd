extends Node3D
const numSillhouettes = 5;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var collider = $StaticBody3D/CollisionShape3D;
	for i in range(numSillhouettes):
		var newMesh = $SillhouetteInstance.duplicate();
		initializeSillhouette(newMesh, collider);
		add_child(newMesh);
		
		#rotation
		newMesh.look_at(collider.global_position);
		
	initializeSillhouette($SillhouetteInstance, collider);

func initializeSillhouette(sill: MeshInstance3D, collider: CollisionShape3D) -> void:
	#UV
	sill.set_instance_shader_parameter("uvoffset_x", float(randi_range(0, 4)) * (1/4.0));
	
	# position
	sill.position.x = randf_range((collider.position.x - collider.shape.radius)
	, (collider.position.x + collider.shape.radius));
	sill.position.y = collider.position.y;
	sill.position.z = randf_range((collider.position.z - collider.shape.radius)
	, (collider.position.z + collider.shape.radius));

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
