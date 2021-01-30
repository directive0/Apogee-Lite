extends Label
var camera
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	if is_network_master():
		visible = false
	camera = get_tree().get_nodes_in_group("camera")[0]
	set_as_toplevel(true)
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var zoom = camera.zoom
	set_scale(zoom)
	var target = get_parent().get_position()
	target.y += 55
	target.x -= ((get_size().x * get_scale().x)/2)
	set_position(target)

#	pass
