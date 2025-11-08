class_name Player extends CharacterBody3D

signal find_current_object(MovableObject)
signal show_ui(bool)

const SPEED := 3.0
const JUMP_VELOCITY := 4.5

@export var ray_range : float = 3.0

@onready var camera: Camera3D = $Camera3D
@onready var right_cast: RayCast3D = $Camera3D/RightCast
@onready var left_cast: RayCast3D = $Camera3D/LeftCast
@onready var item_positioner: Marker3D = $"Camera3D/Item Positioner"
@onready var player_ui: Control = $"Camera3D/Player UI"
@onready var flashlight: SpotLight3D = $Camera3D/Flashlight

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var mouse_sensitivity : float = 0.002
var movement_lock : bool = false
var current_object: MovableObject = null
var lean_rot : float = 30.0
var lean_pos : float = 1.0
var lean_speed : float = 0.15
var max_zoom : float = -2.0
var min_zoom : float = -0.5
var target_zoom := 0.0
var zoom_speed := 8.0

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	target_zoom = item_positioner.position.z
	find_current_object.connect(get_currently_held_object)
	show_ui.connect(_get_ui)

func _physics_process(delta: float) -> void:
	if movement_lock:
		return
	_movement(delta)

func _input(event):
	if Input.is_action_pressed("right_click") and item_positioner.is_holding and current_object is MovableObject:
		movement_lock = true
		return
	
	movement_lock = false
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		camera_helper(event)
	
	if Input.is_action_just_pressed("flashlight"):
		SoundBus.flashlight.play()
		flashlight.visible = !flashlight.visible
	
	_peek_player()
	
	
	
	if Input.is_action_just_pressed("escape"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if Input.is_action_just_pressed("ui_accept"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func camera_helper(event) -> void:
	rotate_y(-event.relative.x * mouse_sensitivity)
	camera.rotate_x(-event.relative.y * mouse_sensitivity)
	camera.rotation.x = clampf(camera.rotation.x, -deg_to_rad(90), deg_to_rad(70))

func _movement(delta) -> void:
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if not is_on_floor():
		velocity.y -= gravity * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y += JUMP_VELOCITY
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()

func get_currently_held_object(obj: MovableObject) -> void:
	current_object = obj

func _peek_player() -> void:
	
	if Input.is_action_pressed("lean_left"):
		peek_helper(lean_rot, lean_pos, lean_speed, true)
	elif Input.is_action_pressed("lean_right"):
		peek_helper(lean_rot, lean_pos, lean_speed, false)
	elif Input.is_action_just_released("lean_left") or Input.is_action_just_released("lean_right"):
		peek_helper(0.0, 0.0, lean_speed, false)

func peek_helper(new_rot : float, new_pos : float, speed : float, left_lean : bool) -> void:
	var peek := get_tree().create_tween()
	peek.set_parallel(true)
	
	if left_lean:
		if left_cast.is_colliding():
			peek.tween_property(camera, 
			"position", 
			Vector3(0.0, camera.position.y, camera.position.z), 
			speed)
			
			peek.tween_property(camera, 
			"rotation_degrees", 
			Vector3(camera.rotation_degrees.x, 
			camera.rotation_degrees.y, -5.0), 
			speed)
		else:
			peek.tween_property(camera, 
			"position", 
			Vector3(-new_pos, camera.position.y, camera.position.z), 
			speed)
			
			peek.tween_property(camera, 
			"rotation_degrees", 
			Vector3(camera.rotation_degrees.x, 
			camera.rotation_degrees.y, new_rot), 
			speed)
	else:
		if right_cast.is_colliding():
			peek.tween_property(camera, 
			"position", Vector3(0.0, 
			camera.position.y, 
			camera.position.z), 
			speed)
			
			peek.tween_property(camera, 
			"rotation_degrees", 
			Vector3(camera.rotation_degrees.x, 
			camera.rotation_degrees.y, 5.0), 
			speed)
		else:
			peek.tween_property(camera, 
			"position", 
			Vector3(new_pos, camera.position.y, camera.position.z), 
			speed)
			
			peek.tween_property(camera, 
			"rotation_degrees", 
			Vector3(camera.rotation_degrees.x, camera.rotation_degrees.y, 
			-new_rot), 
			speed)

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

func _get_ui(visibility: bool) -> void:
	player_ui.visible = visibility
