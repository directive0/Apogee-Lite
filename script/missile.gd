extends RigidBody2D

var player
var in_area = []
var from_player
var fuel = 400
var explosion = preload("res://scenes/explosion.tscn")
var thrust = 30
var stop = false
# Called from the animation
func explode():
	stop = true
	#add_child(explosion.instance())
	#$nuke_wave.set_as_toplevel(true)
	$pushback.set_gravity_is_point(true) 
	$anim.set_assigned_animation("explode")
	$anim.play()
	
	
	
	if not is_network_master():
		# But will call explosion only on master
		return
		
	for p in in_area:
		if p.has_method("exploded"):
			p.rpc("exploded", from_player) # Exploded has a master keyword, so it will only be received by the master
func _integrate_forces(state):
	if stop:
		linear_velocity = Vector2(0,0)
	
func _physics_process(delta):
	var motioned = Vector2(-thrust,0).rotated(get_rotation() - deg2rad(-90))
	if fuel != 0:
		apply_impulse(Vector2(0,0), motioned)
		fuel -= 1
		
func _ready():
	player = get_tree().get_nodes_in_group("player")[0]
	set_as_toplevel(true)


func done():
	queue_free()


func _on_detonator_area_entered(area):
	if area.is_in_group("planet") or area.is_in_group("corona") or area.is_in_group("target"):
		explode()

