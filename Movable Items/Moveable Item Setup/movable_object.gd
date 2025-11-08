class_name MovableObject extends RigidBody3D

signal highlight_object

@export var object_mesh : MeshInstance3D = null
@export var collision_shape : CollisionShape3D = null
@export var holding_offset : Vector3 = Vector3.ZERO

@onready var interaction_component: Node = $"Interaction Component"

var default_rotation_degrees : Vector3 = Vector3.ZERO
var default_mesh_rotation_degrees : Vector3 = Vector3.ZERO
var default_collider_rotation_degrees : Vector3 = Vector3.ZERO
const outline_material : StandardMaterial3D = preload("res://outline.tres")

func _ready() -> void:
	set_collisions()
	continuous_cd = true
	highlight_object.connect(highlighter)
	default_rotation_degrees = rotation_degrees
	default_mesh_rotation_degrees = object_mesh.rotation_degrees
	default_collider_rotation_degrees = collision_shape.rotation_degrees

func highlighter(can_highlight: bool) -> void:
	if can_highlight:
		object_mesh.material_overlay = outline_material
	else:
		object_mesh.material_overlay = null

func rotate_object_y(rotation_amount: float) -> void:
	var rotate_tween := get_tree().create_tween()
	rotate_tween.set_parallel()
	rotate_tween.tween_property(object_mesh, "rotation_degrees:y", object_mesh.rotation_degrees.y + rotation_amount, 0.2)
	collision_shape.rotate_y(deg_to_rad(rotation_amount))

func rotate_object_z(rotation_amount: float) -> void:
	var rotate_tween := get_tree().create_tween()
	rotate_tween.set_parallel()
	rotate_tween.tween_property(object_mesh, "rotation_degrees:z", object_mesh.rotation_degrees.z + rotation_amount, 0.2)
	collision_shape.rotate_x(deg_to_rad(rotation_amount))

func reset_collision_transform() -> void:
	await get_tree().create_timer(0.1).timeout
	collision_shape.global_transform = object_mesh.global_transform

func reset_all_rotations() -> void:
	rotation_degrees = Vector3.ZERO
	object_mesh.global_rotation_degrees = default_mesh_rotation_degrees
	collision_shape.global_rotation_degrees = Vector3.ZERO


func set_collisions(idle: bool = true) -> void:
	collision_layer = 1
	set_collision_mask_value(1, true)
	set_collision_mask_value(2, true)
	if not idle:
		collision_layer = 2
	
