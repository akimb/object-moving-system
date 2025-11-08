extends Node

# Defined on individual objects

enum InteractionType {
	DEFAULT,
	DOOR
}

@export var object_ref : Node3D
@export var interaction_type : InteractionType = InteractionType.DEFAULT

var can_interact : bool = true
var is_interacting : bool = false
var rotation_amount : float = 10.0

var item_positioner : Marker3D

func _ready() -> void:
	return

func pre_interact() -> void:
	is_interacting = true
	get_parent().reset_all_rotations()
	match interaction_type:
		
		InteractionType.DEFAULT:
			item_positioner = get_tree().get_root().find_child("Item Positioner", true, false)

func interact() -> void:
	if not can_interact:
		return
	
	get_parent().set_collisions(false)
	
	match interaction_type:
		
		InteractionType.DEFAULT:
			_default_interact()

func post_interact() -> void:
	is_interacting = false
	get_parent().reset_collision_transform()
	get_parent().set_collisions(true)

func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("mouse_wheel_button") and is_interacting:
		if event is InputEventMouseMotion:
			var angle := rad_to_deg(atan2(event.screen_relative.y, event.screen_relative.x))
			if angle < 0:
				angle += 360.0
			if angle > 315.0 or angle < 45.0:
				get_parent().rotate_object_y(rotation_amount)
			elif angle > 135 and angle < 225:
				get_parent().rotate_object_y(-rotation_amount)
			elif angle >= 45 and angle <= 135:
				get_parent().rotate_object_z(rotation_amount)
			elif angle > 225 and angle <= 315:
				get_parent().rotate_object_z(-rotation_amount) 

func _default_interact() -> void:
	var object_current_position : Vector3 = object_ref.global_transform.origin
	var world_offset : Vector3 = object_ref.global_transform.basis * object_ref.holding_offset
	var item_positioner_position = item_positioner.global_transform.origin + world_offset
	#var item_positioner_position : Vector3 = item_positioner.global_transform.origin + (object_ref.holding_offset)
	var object_distance : Vector3 = item_positioner_position - object_current_position
	
	var movable_object : MovableObject = object_ref as MovableObject
	
	if movable_object:
		movable_object.set_linear_velocity((object_distance) * (5 / movable_object.mass))
