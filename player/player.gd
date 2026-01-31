extends CharacterBody3D
class_name Player

@export var move_speed: float = 5.0
@export var mouse_sensitivity = 0.002

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var in_encounter : bool = false
var rotation_locked : bool = false
@onready var camera = $Camera3D

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	SignalBus.start_encounter.connect(_on_encounter_started)
	SignalBus.end_encounter.connect(_on_encounter_ended)

func _on_encounter_started() -> void:
	in_encounter = true

func _on_encounter_ended() -> void:
	in_encounter = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and not rotation_locked:
		# Rotate character body left/right
		rotate_y(-event.relative.x * mouse_sensitivity)
		
		# Rotate camera up/down
		var camera_x_rotation = $Camera3D.rotation.x - event.relative.y * mouse_sensitivity
		camera_x_rotation = clamp(camera_x_rotation, -PI/2, PI/2)
		camera.rotation.x = camera_x_rotation
	if event.is_action_pressed("shoot"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

		shoot()
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func shoot() -> void:
	if not in_encounter:
		return
	var space_state = get_world_3d().direct_space_state
	var origin = camera.global_position
	var end = origin - camera.global_transform.basis.z * 100.0
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	
	var result = space_state.intersect_ray(query)
	
	if result:
		_draw_hit_marker(result.position)
		print("Hit: ", result.collider.name)
		if result.collider.owner is Mask:
			result.collider.owner.hit.emit()

func _draw_hit_marker(pos: Vector3) -> void:
	var mesh_instance = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	var material = ORMMaterial3D.new()
	
	sphere_mesh.radius = 0.1
	sphere_mesh.height = 0.2
	mesh_instance.mesh = sphere_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.RED
	mesh_instance.material_override = material
	
	get_tree().get_root().add_child(mesh_instance)
	mesh_instance.global_position = pos
	
	await get_tree().create_timer(0.1).timeout
	mesh_instance.queue_free()

func _physics_process(delta: float) -> void:
	if in_encounter:
		return
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	# Apply movement
	if direction:
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed	
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)
		velocity.z = move_toward(velocity.z, 0, move_speed)

	move_and_slide()
