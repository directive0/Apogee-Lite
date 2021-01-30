extends TextureRect
export var mode = 0
export var zoomset = 6
var subject
var camera
var default = false

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	default = visible




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#	pass
	if get_tree().get_nodes_in_group("player").size() > 0:
		if get_tree().get_nodes_in_group("player")[0].get_node("Camera2D").get_zoom().y > zoomset:
			set_visible(!default)
		else:
			set_visible(default)
