extends Control

signal get_object_to_display

@onready var prompt: RichTextLabel = $"UI Container/Prompt"
@onready var item_container: Marker3D = $"UI Container/Item Viewer/SubViewportContainer/SubViewport/Item Container"

var rot_speed : float = 20.0

var item_to_showcase : MeshInstance3D = null
var item_last_transform : Transform3D = Transform3D.IDENTITY
var player : Player

func _ready() -> void:
	get_object_to_display.connect(_display_item)
	SoundBus.ui_popup.play()
	player = get_tree().get_root().find_child("Player", true, false)
	#item_container.rotation_degrees.x += 5


func _process(delta: float) -> void:
	item_container.rotation_degrees.y += rot_speed * delta

func _display_item(obj: MovableObject) -> void:
	
	var type = obj.interaction_component.interaction_type
	var obj_enum := obj.interaction_component
	match type:
		obj_enum.InteractionType.KEY_ITEM:
			prompt.text = "[b]Pick up [[color=tan]%s[/color]]?[/b]" % obj.name
		
		obj_enum.InteractionType.AMMO:
			prompt.text = "[b]Pick up [[color=darkblue]%s[/color]]?[/b]" % obj.name
		
		obj_enum.InteractionType.HEALTH:
			prompt.text = "[b]Pick up [[color=darkgreen]%s[/color]]?[/b]" % obj.name
	
	if item_container.get_child_count() > 0:
		item_container.get_child(0).queue_free()

	var mesh := obj.object_mesh
	
	if mesh:
		var clone := mesh.duplicate()
		item_container.add_child(clone)

#func _get_last_position(obj: MovableObject) -> void:
	#if obj is MovableObject:
		#item_last_transform = obj.global_transform

func _on_drop_it_pressed() -> void:
	
	await get_tree().create_timer(0.5).timeout
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	player.show_ui.emit(true)
	get_tree().paused = false
	queue_free()


func _on_pick_up_pressed() -> void:
	
	print("delete the item")
	await get_tree().create_timer(0.5).timeout
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	player.show_ui.emit(true)
	get_tree().paused = false
	queue_free()
