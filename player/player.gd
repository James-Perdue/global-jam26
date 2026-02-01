extends CharacterBody3D
class_name Player

@export var move_speed: float = 5.0
@export var mouse_sensitivity = 0.002
@export var max_health: int = 100
@export var damage_cooldown: float = 1.0
@export var default_damage_rate: int = 1
@export var wrong_mask_damage: int = 10
@export_category("Camera")
@export var bob_freq = 2.0
@export var bob_amp = 0.1
@export var t_bob = 0.0
@export_category("Recoil")
@export var recoil_amount = deg_to_rad(10.0)
@export var recoil_duration = 0.15

var health: int = max_health
var damage_rate: int = default_damage_rate
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var in_encounter : bool = false
var rotation_locked : bool = false
var current_encounter : Encounter = null
var interactable_in_zone: Node3D = null
var camera_starting_position: Vector3 = Vector3.ZERO
var base_rotation: Vector2 = Vector2.ZERO
var is_clamped: bool = false
var is_loading: bool = true
var clamp_angle: float = deg_to_rad(30.0)

@onready var camera = $Camera3D
@onready var damage_timer: Timer = Timer.new()
@onready var interact_zone: Area3D = %InteractZone
@onready var revolver: Node3D = %Revolver

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	SignalBus.start_encounter.connect(_on_encounter_started)
	SignalBus.end_encounter.connect(_on_encounter_ended)
	SignalBus.player_healed.connect(_on_player_healed)
	SignalBus.wrong_mask.connect(_on_wrong_mask)
	camera_starting_position = camera.position
	add_child(damage_timer)
	damage_timer.wait_time = damage_cooldown
	damage_timer.timeout.connect(_on_damage_timer_timeout)
	interact_zone.body_entered.connect(_on_interact_zone_body_entered)
	interact_zone.body_exited.connect(_on_interact_zone_body_exited)
	revolver.hide()
	await get_tree().process_frame
	SignalBus.player_health_changed.emit(health)
	damage_timer.start()

	#spin 360 to force loading
	var tween = create_tween()
	var start_rotation = rotation.y
	var end_rotation = start_rotation + TAU # 360 degrees in radians
	tween.tween_property(self, "rotation:y", end_rotation, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	# Ensures rotation.y stays within 0..TAU
	rotation.y = 0
	is_loading = false
	SignalBus.done_loading.emit()


func _on_encounter_started(encounter: Encounter) -> void:
	in_encounter = true
	current_encounter = encounter
	damage_rate = ceil(encounter.damage_rate)
	#arbitrary delay so gun not out before enemy spawns
	#await get_tree().create_timer(1.5).timeout 
	revolver.show()
	revolver.get_node("AnimationPlayer").play("Ready")
	await revolver.get_node("AnimationPlayer").animation_finished
	rotation_locked = false

	

func _on_encounter_ended() -> void:
	in_encounter = false
	is_clamped = false
	current_encounter = null
	damage_rate = default_damage_rate
	revolver.get_node("AnimationPlayer").play("PutAway")
	await revolver.get_node("AnimationPlayer").animation_finished
	revolver.hide()

func _on_player_healed(amount: int) -> void:
	health = min(health + amount, max_health)
	print("Player healed: ", health)
	SignalBus.player_health_changed.emit(health)

func _on_interact_zone_body_entered(body: Node3D) -> void:
	if(in_encounter):
		return
	if body is InteractComponent:
		interactable_in_zone = body
		body.show_preview()
		#body.complete()

func _on_interact_zone_body_exited(body: Node3D) -> void:
	if(in_encounter):
		return
	if body == interactable_in_zone:
		interactable_in_zone.hide_preview()
		interactable_in_zone = null
func _input(event: InputEvent) -> void:
	if(is_loading):
		return
	if event is InputEventMouseMotion and not rotation_locked:
		if is_clamped:
			var rot_y = rotation.y - event.relative.x * mouse_sensitivity
			var rot_x = camera.rotation.x - event.relative.y * mouse_sensitivity
			
			rotation.y = lerp_angle(rotation.y, clamp(rot_y, base_rotation.y - clamp_angle, base_rotation.y + clamp_angle), 1.0)
			camera.rotation.x = clamp(rot_x, base_rotation.x - clamp_angle, base_rotation.x + clamp_angle)
		else:
			rotate_y(-event.relative.x * mouse_sensitivity)
			camera.rotate_x(-event.relative.y * mouse_sensitivity)
			camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
	if event.is_action_pressed("shoot"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

		shoot()
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if event.is_action_pressed("interact"):
		if interactable_in_zone:
			interactable_in_zone.interact()

func shoot() -> void:
	if not in_encounter:
		return
	if(revolver.get_node("AnimationPlayer").current_animation != ""):
		return
	revolver.get_node("AnimationPlayer").play("Fire")
	
	# Recoil effect
	var original_rotation = camera.rotation.x
	var target_rotation = original_rotation + recoil_amount
	
	var tween = create_tween()
	tween.tween_property(camera, "rotation:x", target_rotation, recoil_duration / 3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(camera, "rotation:x", original_rotation, recoil_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	
	var space_state = get_world_3d().direct_space_state
	var origin = camera.global_position
	var end = origin - camera.global_transform.basis.z * 100.0
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	
	var result = space_state.intersect_ray(query)
	
	if result:
		#_draw_hit_marker(result.position)
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
	var input_dir :Vector2 = Vector2.ZERO
	if not is_loading:
		input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
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

	# Only bob when moving and on the floor
	if is_on_floor() and velocity.length() > 0.1:
		t_bob += delta * velocity.length() * float(is_on_floor())
		camera.position = camera_starting_position + _headbob(t_bob)
	else:
		# Smoothly return camera to center when still
		camera.position = camera.position.lerp(camera_starting_position, delta * 5.0)

	move_and_slide()

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * bob_freq) * bob_amp
	pos.x = cos(time * bob_freq * 0.5) * bob_amp / 2
	return pos

func _on_damage_timer_timeout() -> void:
	if not is_inside_tree():
		return
	take_damage(damage_rate)
	if health > 0:
		damage_timer.start()

func take_damage(damage: int) -> void:
	health -= damage
	#print("Player damaged: ", health)
	SignalBus.player_health_changed.emit(health)
	if health <= 0:
		print("Game over")
		damage_timer.stop()
		SignalBus.game_over.emit()

func _on_wrong_mask(_mask: Mask) -> void:
	take_damage(wrong_mask_damage)
