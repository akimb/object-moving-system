extends Node

# Defined on individual objects

enum InteractionType {
	DEFAULT,
	DOOR,
	KEY_ITEM,
	AMMO,
	HEALTH
}

@export var object_ref : Node3D
@export var interaction_type : InteractionType = InteractionType.DEFAULT

var can_interact : bool = true
var is_interacting : bool = false
var rotation_amount : float = 20.0
var dead_zone : float = 6.0

var item_positioner : Marker3D
#var player_cam : Camera3D
var player : Player

var item_ui : PackedScene = preload("res://Player/Player UI/pick_up_object_ui.tscn")

func _ready() -> void:
	return

func pre_interact() -> void:
	is_interacting = true
	SoundBus.pick_up.play()
	get_parent().reset_all_rotations()
	match interaction_type:
		
		InteractionType.DEFAULT:
			item_positioner = get_tree().get_root().find_child("Item Positioner", true, false)
		
		InteractionType.KEY_ITEM:
			player = get_tree().get_root().find_child("Player", true, false)
		
		InteractionType.AMMO:
			player = get_tree().get_root().find_child("Player", true, false)
		
		InteractionType.HEALTH:
			player = get_tree().get_root().find_child("Player", true, false)
		
		InteractionType.DOOR:
			pass
		

func interact() -> void:
	if not can_interact:
		return
	
	get_parent().set_collisions(false)
	
	match interaction_type:
		
		InteractionType.DEFAULT:
			_default_interact()
		
		InteractionType.KEY_ITEM:
			_pick_up_key_item()
		
		InteractionType.AMMO:
			# TODO SET UP CUSTOM SCRIPT FOR DIFFERENT OBJECTS IF NECESSARY
			_pick_up_key_item()
		
		InteractionType.HEALTH:
			# TODO SET UP CUSTOM SCRIPT FOR DIFFERENT OBJECTS IF NECESSARY
			_pick_up_key_item()
		
		InteractionType.DOOR:
			pass
		

func post_interact() -> void:
	is_interacting = false
	get_parent().reset_collision_transform()
	get_parent().set_collisions(true)

func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("right_click") and is_interacting:
		if event is InputEventMouseMotion:
			var rel : Vector2 = event.screen_relative
			if rel.length() < dead_zone:
				return
			
			var angle := rad_to_deg(atan2(event.screen_relative.y, event.screen_relative.x))
			if angle < 0:
				angle += 360.0
			if angle > 315.0 or angle < 45.0:
				get_parent().rotate_object_y(rotation_amount)
			elif angle > 135 and angle < 225:
				get_parent().rotate_object_y(-rotation_amount)
			elif angle >= 45 and angle <= 135:
				get_parent().rotate_object_z(-rotation_amount)
			elif angle > 225 and angle <= 315:
				get_parent().rotate_object_z(rotation_amount) 

func _default_interact() -> void:
	var object_current_position : Vector3 = object_ref.global_transform.origin
	#var world_offset : Vector3 = object_ref.global_transform.basis * object_ref.holding_offset
	#var item_positioner_position = item_positioner.global_transform.origin + world_offset
	var item_positioner_position : Vector3 = item_positioner.global_transform.origin
	var object_distance : Vector3 = item_positioner_position - object_current_position
	
	var movable_object : MovableObject = object_ref as MovableObject
	
	if movable_object:
		movable_object.set_linear_velocity((object_distance) * (5 / movable_object.mass))

func _pick_up_key_item() -> void:
	get_tree().paused = true
	var prompt_ui = item_ui.instantiate()
	player.camera.add_child(prompt_ui)
	player.show_ui.emit(false)
	
	prompt_ui.get_object_to_display.emit(object_ref)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
