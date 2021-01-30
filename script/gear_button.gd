extends TextureButton

func _on_TextureButton_pressed():
	var panel = load("res://scenes/settings_pane.tscn").instance()
	panel.set_as_toplevel(true)
	get_parent().add_child(panel)
