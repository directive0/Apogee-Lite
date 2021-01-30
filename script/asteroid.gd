extends RigidBody2D
var state = "idle"
var current_motion
var current_gravity
export var mass_fudge = 1.0
export var multi = 15
var mother_star
var star
var starangle



# Called when the node enters the scene tree for the first time.
func _ready():
	star = get_tree().get_nodes_in_group("star")[0].get_node("gravity")
	var push = Vector2(0, orbit_calculate(star))
	var starangle = star.get_global_position().angle_to_point(get_global_position())
	print(starangle)
	var push_rotated = push.rotated(starangle)
	#$arrow.set_rotation(starangle)
	set_linear_velocity(push_rotated*multi)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_colliding_bodies() and state == "idle":
		state = "free"
		set_as_toplevel(true)
		set_sleeping(false) 

func _integrate_forces(state):
	current_motion = state.get_linear_velocity()
	current_gravity = state.get_total_gravity() 

func orbit_calculate(target):
	var g = target.get_gravity()
	var m = mass_fudge
	var r = position.distance_to(target.position)
	return sqrt(g * m / 1)
