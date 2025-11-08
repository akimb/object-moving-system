extends Button


func _on_pressed() -> void:
	SoundBus.ui_button_click.play()

func _on_mouse_entered() -> void:
	SoundBus.ui_button_hover.play()
