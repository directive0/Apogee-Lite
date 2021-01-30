extends Line2D

var subject
var point_array = []

var zoompoint = 6

var camera
var default

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	default = get_width()
	subject = get_parent()
	set_as_toplevel(true)
	camera = get_tree().get_nodes_in_group("camera")[0]
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	set_points(point_array)

	if camera.get_zoom().y > zoompoint:
		set_width((camera.get_zoom().y / zoompoint) * default)
	else:
		set_width(default)
#	pass



func _on_Timer_timeout():
	
	if point_array.size() > 1000:
		point_array.pop_front()
	
	
	point_array.append(subject.get_position())
	pass # Replace with function body.
