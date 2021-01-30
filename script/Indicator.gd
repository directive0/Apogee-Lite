extends Node2D
var subject
var camera
var targets
var target
var default
var zoomset = 4
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	
	if is_network_master():
		visible = true


	default = get_scale()
	subject = get_parent()
	camera = subject.get_node("Camera2D")
	set_as_toplevel(true)


func pointing():
	return subject.get_rotation()

func target():
	var target_loc = subject.target.global_position
	var rotater = target_loc.angle_to_point(subject.position) - deg2rad(0)
	$target_reticule.set_as_toplevel(true)
	$target_reticule.position = subject.target.get_global_position()
	return rotater
	
func heading(): 
	var motion = subject.motion
	var origin = Vector2()
	var rotater = motion.angle_to_point(origin)
	if subject.engine_on:
		$arrow/plume.set_visible(true)
	else:
		$arrow/plume.set_visible(false)
	return rotater
		
func gravity():
	var gravity = subject.gravity.normalized()
	var origin = Vector2()
	var rotater = gravity.angle_to_point(origin)
	return rotater

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	set_position(subject.position) 

	# Keeps the indicator information from being called if the computer we are on is not the owner of this node
	if is_network_master():
		$heading.set_rotation(heading())
		$arrow.set_rotation(pointing())
		$gravity.set_rotation(gravity())
		$target.set_rotation(target())
	
	#turns the heading arrow on when zoomed out, and removes it when zoomed in
	if camera.get_zoom().y > zoomset:
		$arrow.set_visible(true)
		$target_reticule.set_visible(true)
		set_scale((camera.get_zoom() / Vector2(zoomset,zoomset)) * default)
		$target_reticule.set_scale((camera.get_zoom() / Vector2(zoomset,zoomset)) * default)
	else:
		$arrow.set_visible(false)
		$target_reticule.set_visible(false)
		$target_reticule.set_scale(default)
		set_scale(default)

