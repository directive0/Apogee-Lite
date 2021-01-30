extends Sprite
var subject
var camera
var targets
var target
var default
var zoomset = 6

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	default = get_scale()
	subject = get_tree().get_nodes_in_group("player")[0]
	camera = subject.get_node("Camera2D")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#	pass
	if camera.get_zoom().y > zoomset:
		set_visible(true)
		set_scale((camera.get_zoom() / Vector2(zoomset,zoomset)) * default)
	else:
		set_visible(false)
		set_scale(default)
