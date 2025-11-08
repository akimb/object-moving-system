extends Node

@export var player : Player
@export var item_positioner : Marker3D = null
@onready var cursor: TextureRect = $"../Camera3D/Player UI/Cursor"

var current_object : Object
var last_object : Object
var interaction_component : Node # this is dynamic to other objects

const RESTING_CURSOR : CompressedTexture2D = preload("res://Player/Player UI/resting_cursor.png")
const GRABBING_CURSOR : CompressedTexture2D = preload("res://Player/Player UI/grabbing_cursor.png")
const HOVER_CURSOR : CompressedTexture2D = preload("res://Player/Player UI/hover_cursor.png")

func _ready() -> void:
	cursor.texture = RESTING_CURSOR

func _process(_delta: float) -> void:
	object_interaction_helper()

func object_interaction_helper() -> void:
	if current_object:
		if Input.is_action_pressed("left_click"):
			if interaction_component:
				interaction_component.interact()
		else:
			if interaction_component:
				interaction_component.post_interact()
				item_positioner.item_in_hand.emit(false)
				last_object.lock_rotation = false
				player.get_currently_held_object(null)
				current_object = null
	else:
		var potential_object := player.generic_physics_raycast()
		
		# If we were highlighting something but now see nothing
		if not potential_object:
			if last_object:
				last_object.highlight_object.emit(false)
				last_object = null
				cursor.texture = RESTING_CURSOR
			return

		# If we see a new movable object
		if potential_object is MovableObject:
			cursor.texture = HOVER_CURSOR
			# Unhighlight previous if it's different
			if last_object and last_object != potential_object:
				last_object.highlight_object.emit(false)

			# Highlight the new one
			potential_object.highlight_object.emit(true)
			player.get_currently_held_object(last_object)
			last_object = potential_object

			interaction_component = potential_object.get_node_or_null("Interaction Component")

			if interaction_component and interaction_component.can_interact:
				if Input.is_action_pressed("left_click"):
					item_positioner.item_in_hand.emit(true)
					cursor.texture = GRABBING_CURSOR
					current_object = potential_object
					current_object.lock_rotation = true
					interaction_component.pre_interact()
