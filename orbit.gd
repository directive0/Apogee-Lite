extends Node2D
var rotate = 0
export var speed = 3.0
var adjust = 0.6
var camera
var default 

# Called when the node enters the scene tree for the first time.
func _ready():
	default = $orbit.get_width()
	#randomize()
	
	#var randrotate = randi()%361+1
	#print(randrotate)
	#set_rotation_degrees(randrotate)
	#print(get_tree().get_nodes_in_group("camera")[0])
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	camera = get_tree().get_nodes_in_group("camera")[0]
	draw_orbit()
	if camera.get_zoom().y > 6:
		$orbit.set_width((camera.get_zoom().y) / 6 * default)
	else:
		$orbit.set_width(default)

	set_rotation_degrees(rotate)
	#rint("planet rotation is ", rotate)
	rotate -= (speed * adjust) * delta
#	pass

func draw_orbit():
	var target = $planet.get_position()
	var resolution = 360
	var ring = []

	for i in range(int(resolution)):
		var rotation = float(i) / resolution * TAU
		ring.append(target.rotated(rotation))
	$orbit.set_points(ring)
	
