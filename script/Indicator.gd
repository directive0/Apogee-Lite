extends Node2D
var subject
var camera
var targets
var target
var default
var zoomset = 2
var shrinkset = .5
var mods
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	
	if is_network_master():
		visible = true
	else:
		visible = false


	default = get_scale() * 0.5
	subject = get_parent()
	camera = subject.get_node("Camera2D")
	set_as_toplevel(true)
	mods = get_self_modulate()

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
	else:
		$arrow.set_visible(false)
		$target_reticule.set_visible(false)


	if camera.get_zoom().y > shrinkset:
		# when its zoomed out
		set_scale((camera.get_zoom() / Vector2(shrinkset,shrinkset)) * default)
		$target_reticule.set_scale((camera.get_zoom() / Vector2(shrinkset,shrinkset)) * default)
		mods = get_modulate()
		mods.a = 0.5
		set_modulate(mods)
	else:
		mods = get_modulate()
		mods.a = 0.1
		set_modulate(mods)
		$target_reticule.set_scale(default)
		set_scale(default)
