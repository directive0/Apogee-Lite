extends AudioStreamPlayer
var last_volume = 0

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	#pass
	last_volume = gamestate.get_volume()
	set_volume_db(last_volume)

	#pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if gamestate.music_volume != last_volume:
		#print("received request!")
		set_volume_db(gamestate.music_volume)
		last_volume = gamestate.music_volume
#	pass
