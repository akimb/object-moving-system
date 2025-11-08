class_name Player extends CharacterBody3D


const SPEED := 3.0
const JUMP_VELOCITY := 4.5

@export var ray_range : float = 5.0

@onready var camera: Camera3D = $Camera3D
@onready var right_cast: RayCast3D = $Camera3D/RightCast
@onready var left_cast: RayCast3D = $Camera3D/LeftCast
@onready var item_positioner: Marker3D = $"Camera3D/Item Positioner"

var mouse_sensitivity : float = 0.002
var movement_lock : bool = false
var current_object: MovableObject = null
var lean_rot : float = 30.0
var lean_pos : float = 1.0
var lean_speed : float = 0.15

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(_delta: float) -> void:
	if movement_lock:
		return
	_movement()

func _input(event):
	if Input.is_action_pressed("mouse_wheel_button") and current_object:
		movement_lock = true
		return
	
	movement_lock = false
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		camera_helper(event)
	
	_peek_player()
	
	if Input.is_action_just_pressed("escape"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if Input.is_action_just_pressed("ui_accept"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func camera_helper(event) -> void:
	rotate_y(-event.relative.x * mouse_sensitivity)
	camera.rotate_x(-event.relative.y * mouse_sensitivity)
	camera.rotation.x = clampf(camera.rotation.x, -deg_to_rad(70), deg_to_rad(70))

func _movement() -> void:
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()

func _peek_player() -> void:
	
	if Input.is_action_pressed("lean_left"):
		peek_helper(lean_rot, lean_pos, lean_speed, true)
	elif Input.is_action_pressed("lean_right"):
		peek_helper(lean_rot, lean_pos, lean_speed, false)
	elif Input.is_action_just_released("lean_left") or Input.is_action_just_released("lean_right"):
		reset_camera()

func peek_helper(new_rot : float, new_pos : float, speed : float, left_lean : bool) -> void:
	var peek := get_tree().create_tween()
	peek.set_parallel(true)
	
	if left_lean:
		if left_cast.is_colliding():
			peek.tween_property(camera, "position", Vector3(0.0, camera.position.y, camera.position.z), speed)
			peek.tween_property(camera, "rotation_degrees", Vector3(camera.rotation_degrees.x, camera.rotation_degrees.y, -5.0), speed)
		else:
			peek.tween_property(camera, "position", Vector3(-new_pos, camera.position.y, camera.position.z), speed)
			peek.tween_property(camera, "rotation_degrees", Vector3(camera.rotation_degrees.x, camera.rotation_degrees.y, new_rot), speed)
	else:
		if right_cast.is_colliding():
			peek.tween_property(camera, "position", Vector3(0.0, camera.position.y, camera.position.z), speed)
			peek.tween_property(camera, "rotation_degrees", Vector3(camera.rotation_degrees.x, camera.rotation_degrees.y, 5.0), speed)
		else:
			peek.tween_property(camera, "position", Vector3(new_pos, camera.position.y, camera.position.z), speed)
			peek.tween_property(camera, "rotation_degrees", Vector3(camera.rotation_degrees.x, camera.rotation_degrees.y, -new_rot), speed)

func reset_camera() -> void:
	var peek := get_tree().create_tween()
	peek.set_parallel(true)
	peek.tween_property(camera, "rotation_degrees", Vector3(camera.rotation_degrees.x, camera.rotation_degrees.y, 0.0), lean_speed)
	peek.tween_property(camera, "position", Vector3(0.0, camera.position.y, camera.position.z), lean_speed)

func generic_physics_raycast() -> MovableObject:
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_direction = camera.project_ray_normal(mouse_pos)
	var ray_end = ray_origin + ray_direction * ray_range
	var space_state = camera.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	#query.collision_mask = (1 << 1)
	var result = space_state.intersect_ray(query)
	var obj = result.get("collider")
	
	return obj if obj is MovableObject else null
