extends ColorRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	#$window_body/settings/VBoxContainer/music_slider.value = gamestate.music_volume
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass



func _on_music_slider_value_changed(value):
	gamestate.music_volume = $window_body/settings/VBoxContainer/music_slider.value
	print("sent request")
	pass # Replace with function body.


func _on_settings_okay_pressed():
	get_parent().queue_free()
	pass # Replace with function body.
